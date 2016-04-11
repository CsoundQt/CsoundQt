#include "qcefwebview.h"
#include "include/cef_browser.h"
#include <QCoreApplication>
#include <QString>
#include "message_event.h"
#include <QDebug>
#include <QThread>

const QString QCefWebView::kUrlBlank = "about:blank";

QCefWebView::QCefWebView(QWidget* parent)
    : QWidget(parent),
      browser_state_(kNone),
      need_resize_(false),
      need_load_(false) {
    qDebug() << __FUNCTION__ << QThread::currentThreadId();
    //setAttribute(Qt::WA_NativeWindow);
    //setAttribute(Qt::WA_DontCreateNativeAncestors);
    qcef_client_handler = new ClientHandler;
}

QCefWebView::~QCefWebView() {
    qDebug() << __FUNCTION__;
}

void QCefWebView::loadFromUrl(const QUrl& url) {
    //qDebug() << __FUNCTION__ << url;
    url_ = url;
    switch (browser_state_) {
    case kNone:
        CreateBrowser(size()); break;
    case kCreating:
        // If resizeEvent()/showEvent() before you load a url, it will
        // CreateBrowser() as soon as possible with "about:blank".
        need_load_ = true; break;
    default:  // The browser should have been created.
        BrowserLoadUrl(url);
    }
}

void QCefWebView::setHtml(const QString& html, const QUrl& baseUrl) {
    // Custom Scheme and Request Handling:
    // https://code.google.com/p/chromiumembedded/wiki/GeneralUsage#Request_Handling
    if (GetBrowser().get()) {
        QUrl url = baseUrl.isEmpty() ? this->url(): baseUrl;
        if (!url.isEmpty()) {
            need_resize_ = true;
            CefRefPtr<CefFrame> frame = GetBrowser()->GetMainFrame();
            frame->LoadString(CefString(html.toStdWString()),
                              CefString(url.toString().toStdWString()));
        }
    }
}

QUrl QCefWebView::url() const {
    if (GetBrowser().get()) {
        CefString url = GetBrowser()->GetMainFrame()->GetURL();
        return QUrl(QString::fromStdWString(url.ToWString()));
    }
    return QUrl();
}

void QCefWebView::back() {
    CefRefPtr<CefBrowser> browser = GetBrowser();
    if (browser.get())
        browser->GoBack();
}

void QCefWebView::forward() {
    CefRefPtr<CefBrowser> browser = GetBrowser();
    if (browser.get())
        browser->GoForward();
}

void QCefWebView::reload() {
    CefRefPtr<CefBrowser> browser = GetBrowser();
    if (browser.get())
        browser->Reload();
}

void QCefWebView::stop() {
    CefRefPtr<CefBrowser> browser = GetBrowser();
    if (browser.get())
        browser->StopLoad();
}

QVariant QCefWebView::evaluateJavaScript(const QString& scriptSource) {
    if (GetBrowser().get()) {
        CefString code(scriptSource.toStdWString());
        GetBrowser()->GetMainFrame()->ExecuteJavaScript(code, "", 0);
        return true;
    }
    return false;
}

void QCefWebView::resizeEvent(QResizeEvent* e) {
    //qDebug() << __FUNCTION__ << e->size();
    // On WinXP, if you load a url immediately after constructed, you will
    // CreateBrowser() with the wrong Size(). At the same time, it calls
    // resizeEvent() to resize. However the browser has not been created now,
    // ResizeBrowser() will fail, and it won't displayed with the right size.
    // Although resize(0, 0) can fix it, the other platforms maybe
    // give you the right size and it will make CreateBrowser() later.
    switch (browser_state_) {
    case kNone:
        CreateBrowser(e->size());
        break;
    case kCreating:
        need_resize_ = true;
        break;
    default:
        ResizeBrowser(e->size());
    }
}

/* CEF CLOSING STEPS
 * See also: https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage#markdown-header-browser-life-span
 *
 * I'm not sure if these steps really apply here.
 * 1. User clicks the window close button which sends an OS close notification (e.g. WM_CLOSE on Windows,
 *    performClose: on OS-X and "delete_event" on Linux).
 * 2. Application's top-level window receives the close notification:
 *    A. Calls CefBrowserHost::CloseBrowser(false).
 *    B. Cancels the window close.
 * 3. JavaScript 'onbeforeunload' handler executes and shows the close confirmation dialog (which can be
 *    overridden via CefJSDialogHandler::OnBeforeUnloadDialog()).
 * 4. User approves the close.
 * 5. JavaScript 'onunload' handler executes.
 * 6. Application's DoClose() handler is called. Application will:
 *    A. Set a flag to indicate that the next close attempt will be allowed.
 *    B. Return false.
 * 7. CEF sends an OS close notification.
 * 8. Application's top-level window receives the OS close notification and allows the window to close based
 *    on the flag from #6B.
 * 9. Browser OS window is destroyed.
 * 10. Application's CefLifeSpanHandler::OnBeforeClose() handler is called and the browser object is destroyed.
 * 11. Application exits by calling CefQuitMessageLoop() if no other browsers exist (does not apply here).
 */
bool QCefWebView::CloseBrowser() {
    qDebug() << __FUNCTION__ << __LINE__;
    if (qcef_client_handler.get() && !qcef_client_handler->IsClosing()) {
        CefRefPtr<CefBrowser> browser = qcef_client_handler->GetBrowser();
            browser->GetHost()->CloseBrowser(false);
            qDebug() << "CEF closing step 2 a: is closing:" << qcef_client_handler->IsClosing();
            return false;
    }
    qDebug() << "CEF closing step 8: is closing:" << qcef_client_handler->IsClosing();
    return true;
}

void QCefWebView::showEvent(QShowEvent* e) {
    //qDebug() << __FUNCTION__;
    CreateBrowser(size());
}

void QCefWebView::customEvent(QEvent* e) {
    //qDebug() << __FUNCTION__ << QThread::currentThreadId();
    if (e->type() == MessageEvent::MessageEventType) {
        MessageEvent* event = static_cast<MessageEvent*>(e);
        QString name = event->name();
        QVariantList args = event->args();
        //qDebug() << __FUNCTION__ << name << args;
        emit jsMessage(name, args);
    }
}

void QCefWebView::OnAddressChange(const QString& url) {
    //qDebug() << __FUNCTION__ << url;
    emit urlChanged(QUrl(url));
}

void QCefWebView::OnTitleChange(const QString& title) {
    //qDebug() << __FUNCTION__ << title;
    emit titleChanged(title);
}

void QCefWebView::SetLoading(bool isLoading) {
    //qDebug() << __FUNCTION__ << isLoading << url();
    if (isLoading) {
        if (!need_load_ && !url_.isEmpty())
            emit loadStarted();
    } else {
        if (need_load_) {
            //qDebug() << __FUNCTION__ << "need_load_" << url_;
            BrowserLoadUrl(url_);
            need_load_ = false;
        } else if (/*!need_load_ && */!url_.isEmpty()) {
            emit loadFinished(true);
        }
    }
}

void QCefWebView::SetNavState(bool canGoBack, bool canGoForward) {
    //qDebug() << __FUNCTION__ << canGoBack << canGoForward;
    emit navStateChanged(canGoBack, canGoForward);
}

void QCefWebView::OnAfterCreated() {
    //qDebug() << __FUNCTION__;
    browser_state_ = kCreated;
    if (need_resize_) {
        //qDebug() << __FUNCTION__ << "need_resize_";
        ResizeBrowser(size());
        need_resize_ = false;
    }
}

void QCefWebView::OnMessageEvent(MessageEvent* e) {
    //qDebug() << __FUNCTION__ << QThread::currentThreadId();
    // Cross thread. Not in ui thread here.
    QCoreApplication::postEvent(this, e, Qt::HighEventPriority);
}

bool QCefWebView::CreateBrowser(const QSize& size) {
    //qDebug() << __FUNCTION__ << __LINE__;
    if (browser_state_ != kNone || size.isEmpty()) {
        return false;
    }
    mutex_.lock();
    if (browser_state_ != kNone) {
        mutex_.unlock();
        return false;
    }
    //qDebug() << __FUNCTION__ << __LINE__;
    RECT rect;
    rect.left = 0;
    rect.top = 0;
    rect.right = size.width();
    rect.bottom = size.height();
    CefWindowInfo info;
    CefBrowserSettings settings;
    info.SetAsChild((HWND) this->winId(), rect);
    qcef_client_handler->set_listener(this);
    QString url = url_.isEmpty() ? kUrlBlank : url_.toString();
    CefBrowserHost::CreateBrowser(info,
                                  qcef_client_handler.get(),
                                  CefString(url.toStdWString()),
                                  settings,
                                  NULL);

    browser_state_ = kCreating;
    mutex_.unlock();
    return true;
}

CefRefPtr<CefBrowser> QCefWebView::GetBrowser() const {
    CefRefPtr<CefBrowser> browser;
    if (qcef_client_handler.get())
        browser = qcef_client_handler->GetBrowser();
    return browser;
}

void QCefWebView::ResizeBrowser(const QSize& size) {
    if (qcef_client_handler.get() && qcef_client_handler->GetBrowser()) {
        CefWindowHandle hwnd =
                qcef_client_handler->GetBrowser()->GetHost()->GetWindowHandle();
        if (hwnd) {
            HDWP hdwp = BeginDeferWindowPos(1);
            hdwp = DeferWindowPos(hdwp, hwnd, NULL,
                                  0, 0, size.width(), size.height(),
                                  SWP_NOZORDER);
            EndDeferWindowPos(hdwp);
        }
    }
}

bool QCefWebView::BrowserLoadUrl(const QUrl& url) {
    if (!url.isEmpty() && GetBrowser().get()) {
        CefString cefurl(url_.toString().toStdWString());
        GetBrowser()->GetMainFrame()->LoadURL(cefurl);
        return true;
    }
    return false;
}
