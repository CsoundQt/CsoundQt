#if defined(QCS_QTHTML)
#include "documentpage.h"
#include "csoundhtmlview.h"
#include "ui_html5guidisplay.h"
#include <QLabel>
#include <QVBoxLayout>
#include <QWaitCondition>
#include <QFile>

CsoundHtmlView::CsoundHtmlView(QWidget *parent) :
    QDockWidget(parent),
    webView(nullptr),
    ui(new Ui::Html5GuiDisplay),
    documentPage(0),
    pid(0),
    csoundWrapper(nullptr),
    m_csoundEngine(nullptr)
{
#ifdef WIN32
	pid = GetCurrentProcessId();
    qDebug("pid: %d\n", pid);
#else
    pid = getpid();
#endif
    ui->setupUi(this);
	// set csound to csoundwrapper here? setCsoundPointer(CSOUND *cs) {csoundWrapper.setCsoundPointer(cs){ csound = cs; } }
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
	QObject::connect(webView->page()->mainFrame(), SIGNAL(javaScriptWindowObjectCleared()),
						this, SLOT(addJSObject()));  // to enable adding the object after reload
	// add javascript inspector -  open with right click on htmlview
	webView->page()->settings()->setAttribute(QWebSettings::DeveloperExtrasEnabled, true);
	QWebInspector inspector;
	inspector.setPage(webView->page());
	inspector.setVisible(true);
#else
    // Enable dev tools by default for the test browser
    if (qgetenv("QTWEBENGINE_REMOTE_DEBUGGING").isNull()) {
        qputenv("QTWEBENGINE_REMOTE_DEBUGGING", "34711");  // should be somewhere in options
    }
    webView->page()->setWebChannel(&channel);
    //qDebug() << "Setting JavaScript object on init.";
    channel.registerObject("csound", &csoundWrapper);
#endif
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

void CsoundHtmlView::load(DocumentPage *documentPage_)
{
    //TODO: call this whenever document is saved, not only on run. Usually always saved when run but there is also option not to save... Think.
    documentPage = documentPage_; // consider rewrite...
    qDebug() ;
    auto text = documentPage.load()->getFullText();
    auto filename = documentPage.load()->getFileName();
    QFile csdfile(filename);
    csdfile.open(QIODevice::WriteOnly);
    QTextStream out(&csdfile);
    out << text;
    csdfile.close();
    auto html = getElement(text, "html");
    if (html.size() > 0) {
#ifdef USE_WEBENGINE
        // Inject necessary code to load qtwebchannel/qwebchannel.js.
        QString injection = R"(
<script type="text/javascript" src="qrc:///qtwebchannel/qwebchannel.js"></script>
<script type="text/javascript">
"use strict";
document.addEventListener("DOMContentLoaded", function () {
    try {
        console.log("Initializing window.csound...");
        window.channel = new QWebChannel(qt.webChannelTransport, function(channel) {
        window.csound = channel.objects.csound;
        if (typeof window.csound === 'undefined') {
            alert('window.csound is undefined.');
            return;
        }
        if (window.csound === null) {
            alert('window.csound is null.');
            return;
        }
        csound.message("Initialized csound.\n");
        });
    } catch (e) {
        alert("initialize_csound error: " + e.message);
        console.log(e.message);
    }
});
</script>
)";
        // Tricky because now HTML doesn't have to have a <head> element,
        // and both <html> and <head> can have attributes. So we need to find an
        // injection point that is the very first place allowed to put a <script>
        // element.
        int injection_index = html.indexOf("<head", 0, Qt::CaseInsensitive);
        if (injection_index != -1) {
            injection_index = html.indexOf(">", injection_index) + 1;
        } else {
            injection_index = html.indexOf("<html", 0, Qt::CaseInsensitive);
            injection_index = html.indexOf(">", injection_index) + 1;
        }
        html = html.insert(injection_index, injection);
#endif
        QString htmlfilename;
        if (filename.startsWith(":/") ) { // an example file
            htmlfilename = QDir::tempPath()+"/html-example.html"; // TODO: take name from filename
        } else {
            htmlfilename = filename + ".html";
        }
        QFile htmlfile(htmlfilename);
        htmlfile.open(QIODevice::WriteOnly);
        QTextStream out(&htmlfile);
        out << html;
        htmlfile.close();
		loadFromUrl(QUrl::fromLocalFile(htmlfilename));
        // kas aitab, kui on siin:
#ifdef USE_WEBENGINE
        webView->page()->setWebChannel(&channel);
        channel.registerObject("csound", &csoundWrapper) ;
        qDebug()  << "Setting JavaScript object on load.";
#endif
    }
    repaint();
}

void CsoundHtmlView::setCsoundEngine(CsoundEngine *csEngine)
{
    csoundWrapper.setCsoundEngine(csEngine);
}


void CsoundHtmlView::stop() // why is this function necessary?
{
    documentPage = 0;
    qDebug() ;
}

void CsoundHtmlView::viewHtml(QString htmlText)
{
    qDebug();
    tempHtml.setFileTemplate( QDir::tempPath()+"/csoundqt-html-XXXXXX.html" ); // must have html ending for webkit
    if (tempHtml.open()) {
#ifdef USE_WEBENGINE
        // Inject necessary code to load qtwebchannel/qwebchannel.js.
        QString injection = R"(
<script type="text/javascript" src="qrc:///qtwebchannel/qwebchannel.js"></script>
<script>
"use strict";
document.addEventListener("DOMContentLoaded", function () {//void CsoundHtmlView::closeEvent(QCloseEvent *event)
                            //{
                            //    qDebug() ;
                            //    if (webView) {
                            //		webView->close(); // is it necessary?
                            //    }
                            //}




    try {
        console.log("Initializing Csound...");
        window.channel = new QWebChannel(qt.webChannelTransport, function(channel) {
        window.csound = channel.objects.csound;
        csound.message("Initialized csound.\n");
        });
    } catch (e) {
        alert("initialize_csound error: " + e.message);
        console.log(e.message);
    }
});
</script>
)";
        // Tricky because now HTML doesn't have to have a <head> element,
        // and both <html> and <head> can have attributes. So we need to find an
        // injection point that is the very first place allowed to put a <script>
        // element.
        int injection_index = htmlText.indexOf("<head", 0, Qt::CaseInsensitive);
        if (injection_index != -1) {
            injection_index = htmlText.indexOf(">", injection_index) + 1;
        } else {
            injection_index = htmlText.indexOf("<html", 0, Qt::CaseInsensitive);
            injection_index = htmlText.indexOf(">", injection_index) + 1;
        }
        htmlText = htmlText.insert(injection_index, injection);
#endif
		tempHtml.write(htmlText.toLocal8Bit());
		tempHtml.resize(tempHtml.pos()); // otherwise may keep contents from previous write if that was bigger
		tempHtml.close();
		loadFromUrl(QUrl::fromLocalFile(tempHtml.fileName()));
#ifdef USE_WEBENGINE
        webView->page()->setWebChannel(&channel);
        channel.registerObject("csound", &csoundWrapper) ;
        qDebug() << "Setting JavaScript object on view.";
#endif
	}
}

#ifdef USE_WEBKIT
void CsoundHtmlView::addJSObject()
{
	if (webView) {
        qDebug()<<"Adding Csound as JavaScript object";
		webView->page()->mainFrame()->addToJavaScriptWindowObject("csound", &csoundWrapper);
	}
}
#endif

void CsoundHtmlView::loadFromUrl(const QUrl &url)
{
    qDebug();
    if(webView != 0) {
		webView->setUrl(url);
    }
}

void CsoundHtmlView::clear()
{
	loadFromUrl(QUrl()); // empty URL to clear
}

#endif
