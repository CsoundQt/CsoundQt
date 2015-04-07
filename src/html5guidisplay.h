#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#ifdef QCS_HTML5

#include <QDockWidget>
#include <QWebEngineView>

namespace Ui {
class Html5GuiDisplay;
}

class Html5GuiDisplay : public QDockWidget
{
	Q_OBJECT

public:
	explicit Html5GuiDisplay(QWidget *parent = 0);
	~Html5GuiDisplay();

private:
	Ui::Html5GuiDisplay *ui;
	QWebEngineView *m_webView;
};

#endif
#endif // HTML5GUIDISPLAY_H
