#ifdef QCS_QTHTML
#include "documentpage.h"
#include "csoundhtmlview.h"
#include "ui_html5guidisplay.h"
#include <QLabel>
#include <QVBoxLayout>
#include <QWaitCondition>
#include <QFile>

CsoundHtmlView::CsoundHtmlView(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::Html5GuiDisplay),
    documentPage(0),
	webView(0),
    pid(0)
{
#ifdef WIN32
	pid = GetCurrentProcessId();
    qDebug("CsoundHtmlView::CsoundHtmlView: pid: %d\n", pid);
#else
    pid = getpid();
#endif
    ui->setupUi(this);
#ifdef QCS_HTML5
	webView = new QCefWebView(this);
	//setWidget(webView);
	webView->loadFromUrl(QUrl("http://csound.github.io/docs/manual/indexframes.html"));
	//webView->sizePolicy().setVerticalPolicy(QSizePolicy::Policy::Expanding);
#endif
#ifdef USE_WEBKIT
	webView = new QWebView(this);
	//webView->setUrl(QUrl("file:///home/tarmo/tarmo/programm/webchannel-test/test.csd.html"));
#else
	webView = new QWebEngineView(this);
#endif
	setWidget(webView);
	webView->sizePolicy().setVerticalPolicy(QSizePolicy::Policy::Expanding);

    layout()->setMargin(0);

#ifdef USE_WEBKIT
	// webView->page()->mainFrame()->addToJavaScriptWindowObject("csound", &cs);

	// add javascript inspector -  open with right click on htmlview
	webView->page()->settings()->setAttribute(QWebSettings::DeveloperExtrasEnabled, true);

	QWebInspector inspector;
	inspector.setPage(webView->page());
	inspector.setVisible(true);
#else
	webView->page()->setWebChannel(&channel);
	// channel.registerObject("csound", &cs) ;
#endif
}

void CsoundHtmlView::closeEvent(QCloseEvent *event)
{
    qDebug() << __FUNCTION__;
    if (webView) {
		webView->close(); // is it necessary?
    }
}



CsoundHtmlView::~CsoundHtmlView()
{
    delete ui;
}

QString getElement(const QString &text, const QString &tag)
{
    QString::SectionFlags sectionflags = QString::SectionIncludeLeadingSep | QString::SectionIncludeTrailingSep | QString::SectionCaseInsensitiveSeps;
    QString element = text.section("<" + tag, 1, 1, sectionflags);
    element = element.section("</" + tag + ">", 0, 0, sectionflags);
    return element;
}

/**
 * @brief Html5GuiDisplay.play
 * @param documentPage
 *
 * Save the <html> element, if it exists,
 * to filename xxx.csd.html, and load it into the CEF web view.
 */
void CsoundHtmlView::load(DocumentPage *documentPage_) //TODO: call this whenever document is saved, not only on run. Usually always saved when run but there is also option not to save... Think.
{
	documentPage = documentPage_; // consider rewrite...
	qDebug() << "CsoundHtmlView::load()...";
    auto text = documentPage.load()->getFullText();
    auto filename = documentPage.load()->getFileName();
    QFile csdfile(filename);
    csdfile.open(QIODevice::WriteOnly);
    QTextStream out(&csdfile);
    out << text;
    csdfile.close();
    auto html = getElement(text, "html");
    if (html.size() > 0) {
        QString htmlfilename = filename + ".html";
        QFile htmlfile(htmlfilename);
        htmlfile.open(QIODevice::WriteOnly);
        QTextStream out(&htmlfile);
        out << html;
        htmlfile.close();
		//webView->loadFromUrl(QUrl::fromLocalFile(htmlfilename)); // TODO: uncomment!
		loadFromUrl(QUrl::fromLocalFile(htmlfilename));
    }
    repaint();
}

void CsoundHtmlView::stop() // why this function necessary?
{
    documentPage = 0;
    qDebug() << "CsoundHtmlView::stop()...";
}

void CsoundHtmlView::loadFromUrl(const QUrl &url)
{
    qDebug() << "CsoundHtmlView::loadFromUrl()...";
    if(webView != 0) {
#ifdef QCS_HTML5
        //webView->evaluateJavaScript("debugger;");
		webView->loadFromUrl(url);
#else
		webView->setUrl(url);
#endif
    }
}

#endif
