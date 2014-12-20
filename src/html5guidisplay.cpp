#include "html5guidisplay.h"
#include "ui_html5guidisplay.h"

#include <QLabel>

Html5GuiDisplay::Html5GuiDisplay(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::Html5GuiDisplay)
{
	ui->setupUi(this);
#ifdef USE_QT_GT_54
	m_webView = new QWebEngineView(ui->dockWidgetContents);
	m_webView->show();
#else
	QLabel *label = new QLabel(tr("This version of CsoundQt does not support HTML5 display."));
	this->setWidget(label);
	label->show();
#endif
}

Html5GuiDisplay::~Html5GuiDisplay()
{
	delete ui;
}
