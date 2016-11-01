#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#ifdef QCS_QTHTML

#include <atomic>
#include <QDebug>
#include <QDockWidget>
#ifdef QCS_HTML5
	#include "qcefwebview.h"
#endif

#ifdef USE_WEBKIT
	#include <QtWebKit>
	#include <QWebView>
	#include <QWebFrame>
	#include <QWebInspector>
#endif
#ifdef USE_WEBENGINE
	#include <QtWebEngineWidgets>
	#include <QtWebChannel/QtWebChannel>
	#include <QWebEngineView>
#endif


#include <QTemporaryFile>

//#include "csoundwrapper.h"

namespace Ui {
class Html5GuiDisplay;
}

class DocumentPage;

class CsoundHtmlView : public QDockWidget
{
	Q_OBJECT
public:
	explicit CsoundHtmlView(QWidget *parent = 0);
	~CsoundHtmlView();
    void loadFromUrl(const QUrl &url);
    void load(DocumentPage *documentPage);
    void stop();
#ifdef QCS_HTML5
	QCefWebView *webView;
#endif
#ifdef USE_WEBKIT
	QWebView *webView;
#endif
#ifdef USE_WEBENGINE
	QWebChannel channel ;            // Channel for C++ to Javascript comms
	QWebEngineView * webView;

#endif

protected:
    virtual void closeEvent(QCloseEvent *event);
private:
	Ui::Html5GuiDisplay *ui;
	std::atomic<DocumentPage *> documentPage; // ?? why and what is std::atomic
    pid_t pid;

	QString csd; // kas vajalik?
	QTemporaryFile  tempHtml;

};

#endif
#endif // HTML5GUIDISPLAY_H
