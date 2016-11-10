#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#if defined(QCS_HTML5) || defined(QCS_QTHTML)

#include <atomic>
#include <QDebug>
#include <QDockWidget>
#include "csoundhtmlwrapper.h"
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
	void setCsoundEngine(CsoundEngine *csEngine) {csoundWrapper.setCsoundEngine(csEngine); }
	void viewHtml(QString htmlText);
	void clear();
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

public slots:
#ifdef USE_WEBKIT
	void addJSObject();
#endif

protected:
	//virtual void closeEvent(QCloseEvent *event);
private:
	Ui::Html5GuiDisplay *ui;
	std::atomic<DocumentPage *> documentPage; // ?? why and what is std::atomic
    pid_t pid;

	CsoundHtmlWrapper csoundWrapper;
	CsoundEngine * m_csoundEngine;
	QTemporaryFile  tempHtml;

};

#endif
#endif // HTML5GUIDISPLAY_H
