#include "client_handler.h"
#include <sstream>
#include <stdio.h>
#include <string>
#include "include/base/cef_lock.h"
#include "include/cef_browser.h"
#include "include/cef_frame.h"
#include "include/cef_runnable.h"
#include "cefclient.h"
#include "client_renderer.h"
#include "client_binding.h"

#include <QDebug>

namespace {

// Custom menu command Ids.
enum client_menu_ids {
    CLIENT_ID_SHOW_DEVTOOLS = MENU_ID_USER_FIRST,
};

}  // namespace

extern QMutex mutex;
extern QWaitCondition wait_for_browsers_to_close;

int ClientHandler::m_BrowserCount = 0;

ClientHandler::ClientHandler()
    : m_BrowserId(0),
      m_bIsClosing(false),
      m_bFocusOnEditableField(false) {
    qDebug() << __FUNCTION__;
    CreateProcessMessageDelegates(process_message_delegates_);
    if (m_StartupURL.empty())
        m_StartupURL = "about:blank";
}

ClientHandler::~ClientHandler() {
}

bool ClientHandler::OnProcessMessageReceived(
        CefRefPtr<CefBrowser> browser,
        CefProcessId source_process,
        CefRefPtr<CefProcessMessage> message) {
    // Check for messages from the client renderer.
    std::string message_name = message->GetName();
    if (message_name == client_renderer::kFocusedNodeChangedMessage) {
        // A message is sent from ClientRenderDelegate to tell us whether the
        // currently focused DOM node is editable. Use of |m_bFocusOnEditableField|
        // is redundant with CefKeyEvent.focus_on_editable_field in OnPreKeyEvent
        // but is useful for demonstration purposes.
        m_bFocusOnEditableField = message->GetArgumentList()->GetBool(0);
        return true;
    }
    bool handled = false;
    ProcessMessageDelegateSet::iterator it = process_message_delegates_.begin();
    for (; it != process_message_delegates_.end() && !handled; ++it) {
        handled = (*it)->OnProcessMessageReceived(this, browser, source_process,
                                                  message);
    }
    return handled;
}

void ClientHandler::OnBeforeContextMenu(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefContextMenuParams> params,
        CefRefPtr<CefMenuModel> model) {
    if ((params->GetTypeFlags() & (CM_TYPEFLAG_PAGE | CM_TYPEFLAG_FRAME)) != 0) {
        // Clear all context menus.
        //model->Clear();
        // Clear all context menus except MENU_ID_VIEW_SOURCE.
        int count = model->GetCount();
        for (int i = count - 1; i >=0; i--) {
            if (model->GetCommandIdAt(i) != MENU_ID_VIEW_SOURCE) {
                model->RemoveAt(i);
            }
        }
        // Add a "Show DevTools" item to all context menus.
        model->AddItem(CLIENT_ID_SHOW_DEVTOOLS, "&Show DevTools");
        model->SetEnabled(CLIENT_ID_SHOW_DEVTOOLS, true);
        //    CefString devtools_url = browser->GetHost()->GetDevToolsURL(true);
        //    if (devtools_url.empty() ||
        //        m_OpenDevToolsURLs.find(devtools_url) != m_OpenDevToolsURLs.end()) {
        //      // Disable the menu option if DevTools isn't enabled or if a window is
        //      // already open for the current URL.
        //      model->SetEnabled(CLIENT_ID_SHOW_DEVTOOLS, false);
        //    }
    }
}

bool ClientHandler::OnContextMenuCommand(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefContextMenuParams> params,
        int command_id,
        EventFlags event_flags) {
    CefPoint point;
    point.x = params->GetXCoord();
    point.y = params->GetYCoord();
    switch (command_id) {
    case CLIENT_ID_SHOW_DEVTOOLS:
        ShowDevTools(browser, point);
        return true;
    default:  // Allow default handling, if any.
        return false;
    }
}
void ClientHandler::ShowDevTools(CefRefPtr<CefBrowser> browser,
                                 const CefPoint& inspect_element_at) {
    CefWindowInfo windowInfo;
    CefBrowserSettings settings;

#if defined(OS_WIN)
    windowInfo.SetAsPopup(browser->GetHost()->GetWindowHandle(), "DevTools");
#endif

    browser->GetHost()->ShowDevTools(windowInfo, this, settings,
                                     inspect_element_at);
}

void ClientHandler::CloseDevTools(CefRefPtr<CefBrowser> browser) {
    browser->GetHost()->CloseDevTools();
}

bool ClientHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                     const CefString& message,
                                     const CefString& source,
                                     int line) {
    return false;  // Output the message to the console.
}

void ClientHandler::OnBeforeDownload(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefDownloadItem> download_item,
        const CefString& suggested_name,
        CefRefPtr<CefBeforeDownloadCallback> callback) {
    REQUIRE_UI_THREAD();
}

void ClientHandler::OnDownloadUpdated(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefDownloadItem> download_item,
        CefRefPtr<CefDownloadItemCallback> callback) {
    REQUIRE_UI_THREAD();
    /*if (download_item->IsComplete()) {
  }*/
}

bool ClientHandler::OnDragEnter(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefDragData> dragData,
                                DragOperationsMask mask) {
    REQUIRE_UI_THREAD();

    // Forbid dragging of link URLs.
    if (mask & DRAG_OPERATION_LINK)
        return true;

    return false;
}

bool ClientHandler::OnRequestGeolocationPermission(
        CefRefPtr<CefBrowser> browser,
        const CefString& requesting_url,
        int request_id,
        CefRefPtr<CefGeolocationCallback> callback) {
    // Allow geolocation access from all websites.
    callback->Continue(true);
    return true;
}


bool ClientHandler::OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                                  const CefKeyEvent& event,
                                  CefEventHandle os_event,
                                  bool* is_keyboard_shortcut) {
    return false;
}

bool ClientHandler::OnBeforePopup(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  const CefString& target_url,
                                  const CefString& target_frame_name,
                                  const CefPopupFeatures& popupFeatures,
                                  CefWindowInfo& windowInfo,
                                  CefRefPtr<CefClient>& client,
                                  CefBrowserSettings& settings,
                                  bool* no_javascript_access) {
    if (browser->GetHost()->IsWindowRenderingDisabled()) {
        // Cancel popups in off-screen rendering mode.
        return true;
    }
    return false;
}

// Whichever browser is first created is the "main" one.

void ClientHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
    qDebug() << __FUNCTION__;
    REQUIRE_UI_THREAD();
    base::AutoLock lock_scope(lock_OnAfterCreated);
    if (!m_Browser.get())   {
        // We need to keep the main child window, but not popup windows
        m_Browser = browser;
        m_BrowserId = browser->GetIdentifier();
        qDebug() << "m_BrowserId:" << m_BrowserId;
        if (listener_) {
            listener_->OnAfterCreated();
        }
    } else if (browser->IsPopup()) {
        // Add to the list of popup browsers.
        qDebug() << __FUNCTION__ "is popup.";
        m_PopupBrowsers.push_back(browser);
    }
    m_BrowserCount++;
}

bool ClientHandler::DoClose(CefRefPtr<CefBrowser> browser) {
    qDebug() << __FUNCTION__;
    REQUIRE_UI_THREAD();
    base::AutoLock lock_scope(lock_DoClose);
    // Closing the main window requires special handling. See the DoClose()
    // documentation in the CEF header for a detailed destription of this
    // process.
    /// TODO probably too late already, onbeforeunload has probably already been called.
    qDebug() << "browser->GetIdentifier():" << browser->GetIdentifier();
    if (m_BrowserId == browser->GetIdentifier() && !m_bIsClosing) {
        /// Notify the browser that the parent window is about to close.
        /// NOTE: ParentWindowWillClose appears to have been removed because it was never
        /// actually implemented.
        /// browser->ParentWindowWillClose();
        // Set a flag to indicate that the window close should be allowed.
        m_bIsClosing = true;
        qDebug() << "CEF closing step 6 a: is closing: " << IsClosing();
#ifdef WIN32
        // Maybe to CsoundQt?
        //::DestroyWindow(browser->GetHost()->GetWindowHandle());
#endif
    }
    // Allow the close. For windowed browsers this will result in the OS close
    // event being sent.
    qDebug() << "CEF closing step 6 b: is closing: " << IsClosing();
    return true;
}

void ClientHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
    qDebug() << __FUNCTION__;
    REQUIRE_UI_THREAD();
    qDebug() << "browser->GetIdentifier():" << browser->GetIdentifier();
    if (m_BrowserId == browser->GetIdentifier()) {
        // Free the browser pointer so that the browser can be destroyed
        m_Browser = NULL;
        qDebug() << "CEF closing step 10.";
    } else if (browser->IsPopup()) {
        // Remove the record for DevTools popup windows.
        std::set<std::string>::iterator it =
                m_OpenDevToolsURLs.find(browser->GetMainFrame()->GetURL());
        if (it != m_OpenDevToolsURLs.end())
            m_OpenDevToolsURLs.erase(it);
        // Remove from the browser popup list.
        BrowserList::iterator bit = m_PopupBrowsers.begin();
        for (; bit != m_PopupBrowsers.end(); ++bit) {
            if ((*bit)->IsSame(browser)) {
                m_PopupBrowsers.erase(bit);
                break;
            }
        }
    }
    if (--m_BrowserCount == 0) {
        m_bIsClosing = true;
        qDebug() << __FUNCTION__ << "m_BrowserCount:" << m_BrowserCount;
        //NotifyAllBrowserClosed();
        //wait_for_browsers_to_close.wakeAll();

    }
}

void ClientHandler::OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                         bool isLoading,
                                         bool canGoBack,
                                         bool canGoForward) {
    REQUIRE_UI_THREAD();
    //SetLoading(isLoading); // For overall browser load status.
    SetNavState(canGoBack, canGoForward);
}

void ClientHandler::OnLoadStart(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame) {
    REQUIRE_UI_THREAD();
    if (m_BrowserId == browser->GetIdentifier() && frame->IsMain()) {
        SetLoading(true);
    }
}

void ClientHandler::OnLoadEnd(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              int httpStatusCode) {
    REQUIRE_UI_THREAD();
    if (m_BrowserId == browser->GetIdentifier() && frame->IsMain()) {
        SetLoading(false);
    }
}

void ClientHandler::OnLoadError(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                ErrorCode errorCode,
                                const CefString& errorText,
                                const CefString& failedUrl) {
    REQUIRE_UI_THREAD();
    // Don't display an error for downloaded files.
    if (errorCode == ERR_ABORTED)
        return;
    // Don't display an error for external protocols that we allow the OS to
    // handle. See OnProtocolExecution().
    if (errorCode == ERR_UNKNOWN_URL_SCHEME) {
        std::string urlStr = frame->GetURL();
        if (urlStr.find("spotify:") == 0)
            return;
    }
    // Display a load error message.
    std::stringstream ss;
    //ss << "<html><body bgcolor=\"white\">"
    //      "<h2>Failed to load URL " << std::string(failedUrl) <<
    //      " with error " << std::string(errorText) << " (" << errorCode <<
    //      ").</h2></body></html>";
    //frame->LoadString(ss.str(), failedUrl);

    // Issue: It will repeated load the url which is a not existed file path on
    // Win32 CEF 3.1650.1522,1544.
    // 1. You need load the file:/// (not exists) several times.
    // 2. It jumps to about:blank after the first time, then load the url again.
    // 3. It also jumps to about:blank and repeated load, but finally displays
    // LoadString() on Win32 CEF 3.1547.1551. Sometimes also repeated load forever.
    // 4. It will directly repeated load if you stop loading m_StartupURL.
    // 5. It doesn't go into OnRenderProcessTerminated().er
    // Also have been tested with its own cefclient project.

    ss << "Failed to load URL " << std::string(failedUrl) <<
          " with error " << std::string(errorText) << " (" << errorCode << ").";
    qDebug() << __FUNCTION__ << QString::fromStdString(ss.str());
}

CefRefPtr<CefResourceHandler> ClientHandler::GetResourceHandler(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request) {
    return NULL;
}

bool ClientHandler::OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                                   const CefString& origin_url,
                                   int64 new_size,
                                   CefRefPtr<CefQuotaCallback> callback) {
    static const int64 max_size = 1024 * 1024 * 20;  // 20mb.

    // Grant the quota request if the size is reasonable.
    callback->Continue(new_size <= max_size);
    return true;
}

void ClientHandler::OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                                        const CefString& url,
                                        bool& allow_os_execution) {
}

void ClientHandler::OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                              TerminationStatus status) {
    // Load the startup URL if that's not the website that we terminated on.
    CefRefPtr<CefFrame> frame = browser->GetMainFrame();
    std::string url = frame->GetURL();
    std::transform(url.begin(), url.end(), url.begin(), tolower);
    std::string startupURL = GetStartupURL();
    if (url.find(startupURL) != 0)
        frame->LoadURL(startupURL);
}

void ClientHandler::CloseAllBrowsers(bool force_close) {
    qDebug() << __FUNCTION__ << __LINE__ << QThread::currentThreadId() << QCoreApplication::applicationPid ();
    if (!CefCurrentlyOn(TID_UI)) {
        // Execute on the UI thread.
        CefPostTask(TID_UI,
                    NewCefRunnableMethod(this, &ClientHandler::CloseAllBrowsers,
                                         force_close));
        return;
    }
    if (!m_PopupBrowsers.empty()) {
        // Request that any popup browsers close.
        BrowserList::const_iterator it = m_PopupBrowsers.begin();
        for (; it != m_PopupBrowsers.end(); ++it)
            (*it)->GetHost()->CloseBrowser(force_close);
    }
    if (m_Browser.get()) {
        // Request that the main browser close.
        m_Browser->GetHost()->CloseBrowser(force_close);
    }
}

// static
void ClientHandler::CreateProcessMessageDelegates(
        ProcessMessageDelegateSet& delegates) {
    client_binding::CreateProcessMessageDelegates(delegates);
}
