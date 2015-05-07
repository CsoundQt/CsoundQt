#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#ifdef QCS_HTML5

#include <QDockWidget>
#include "qcefwebview.h"

namespace Ui {
class Html5GuiDisplay;
}

class DocumentPage;

class Html5GuiDisplay : public QDockWidget
{
	Q_OBJECT
public:
	explicit Html5GuiDisplay(QWidget *parent = 0);
	~Html5GuiDisplay();
    void play(DocumentPage *documentPage);
private:
	Ui::Html5GuiDisplay *ui;
    QCefWebView *webView;
    DocumentPage *documentPage;
};

#endif
#endif // HTML5GUIDISPLAY_H
