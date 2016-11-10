#if defined(QCS_HTML5) || defined(QCS_QTHTML)
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
	pid(0),
	m_csoundEngine(NULL)
{
#ifdef WIN32
	pid = GetCurrentProcessId();
    qDebug("CsoundHtmlView::CsoundHtmlView: pid: %d\n", pid);
#else
    pid = getpid();
#endif
    ui->setupUi(this);
	// set csound to csoundwrapper here? setCsoundPointer(CSOUND *cs) {csoundWrapper.setCsoundPointer(cs){ csound = cs; } }
#ifdef QCS_HTML5
	webView = new QCefWebView(this);
	webView->loadFromUrl(QUrl("http://csound.github.io/docs/manual/indexframes.html"));
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
	QObject::connect(webView->page()->mainFrame(), SIGNAL(javaScriptWindowObjectCleared()),
						this, SLOT(addJSObject()));  // to enable adding the object after reload
	// add javascript inspector -  open with right click on htmlview
	webView->page()->settings()->setAttribute(QWebSettings::DeveloperExtrasEnabled, true);
	QWebInspector inspector;
	inspector.setPage(webView->page());
	inspector.setVisible(true);
#else
	webView->page()->setWebChannel(&channel);
	channel.registerObject("csound", &csoundWrapper) ; // is it still present after reload?
#endif
}

//void CsoundHtmlView::closeEvent(QCloseEvent *event)
//{
//    qDebug() << __FUNCTION__;
//    if (webView) {
//		webView->close(); // is it necessary?
//    }
//}



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
// keep load() for CEF HTML5 for now; otherwise use viewHtml()
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

void CsoundHtmlView::stop() // why is this function necessary?
{
    documentPage = 0;
	qDebug() << "CsoundHtmlView::stop()...";
}

void CsoundHtmlView::viewHtml(QString htmlText)
{
	qDebug()<<Q_FUNC_INFO;
	tempHtml.setFileTemplate( QDir::tempPath()+"/csoundqt-html-XXXXXX.html" ); // must have html ending for webkit
	if (tempHtml.open()) {
		// add necessary lines to load qtwebchannel/qwebchannel.js and qtcsound.js
		// TODO: take care if html includes <head ...something...>
#ifdef USE_WEBENGINE //TODO: have a look at MKG QHSound
		QString replaceString = "<head> \
					<script type=\"text/javascript\" src=\"qrc:///qtwebchannel/qwebchannel.js\"> </script> \
					<script type=\"text/javascript\" src=\"qrc:///qtcsound.js\"></script> ";


		htmlText = htmlText.replace("<head>", replaceString);
		qDebug()<<"Replaced html: " <<htmlText;
#endif
		tempHtml.write(htmlText.toLocal8Bit());
		tempHtml.resize(tempHtml.pos()); // otherwise may keep contents from previous write if that was bigger
		tempHtml.close();
		loadFromUrl(QUrl::fromLocalFile(tempHtml.fileName()));
	}

}




#ifdef USE_WEBKIT
void CsoundHtmlView::addJSObject()
{
	if (webView) {
		qDebug()<<"Adding Csound as javascript object";
		webView->page()->mainFrame()->addToJavaScriptWindowObject("csound", &csoundWrapper);
	}
}
#endif



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

void CsoundHtmlView::clear()
{
	loadFromUrl(QUrl()); // empty URL to clear
}

#endif
