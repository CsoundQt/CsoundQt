#ifndef HTML5GUIDISPLAY_H
#define HTML5GUIDISPLAY_H

#include <QDockWidget>
#ifdef USE_QT_GT_54
#include <QWebEngineView>
#endif

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
#ifdef USE_QT_GT_54
	QWebEngineView *m_webView;
#endif
};

#endif // HTML5GUIDISPLAY_H
