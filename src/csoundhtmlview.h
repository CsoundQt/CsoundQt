#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#ifdef QCS_QTHTML

#include <atomic>
#include <QDebug>
#include <QDockWidget>
#ifdef QCS_HTML5
#include "qcefwebview.h"
#endif
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
#else
	QWidget *webView;
#endif

protected:
    virtual void closeEvent(QCloseEvent *event);
private:
	Ui::Html5GuiDisplay *ui;
    std::atomic<DocumentPage *> documentPage;
    pid_t pid;
};

#endif
#endif // HTML5GUIDISPLAY_H
