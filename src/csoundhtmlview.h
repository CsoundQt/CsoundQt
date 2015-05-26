#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#ifdef QCS_HTML5

#include <atomic>
#include <QDebug>
#include <QDockWidget>
#include "qcefwebview.h"

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
    void play(DocumentPage *documentPage);
    void stop();
    QCefWebView *webView;
protected:
    virtual void closeEvent(QCloseEvent *event);
private:
	Ui::Html5GuiDisplay *ui;
    std::atomic<DocumentPage *> documentPage;
};

#endif
#endif // HTML5GUIDISPLAY_H
