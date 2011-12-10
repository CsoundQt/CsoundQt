#ifndef ABOUTWIDGET_H
#define ABOUTWIDGET_H

#include <QDialog>

namespace Ui {
    class AboutWidget;
}

class AboutWidget : public QDialog {
    Q_OBJECT
public:
    AboutWidget(QWidget *parent = 0);
    ~AboutWidget();

    void setIntroText(QString text);
    void setInstructions(QString text);
    void setStyleSheet(QString sheet);
protected:
    void changeEvent(QEvent *e);

private:
    Ui::AboutWidget *ui;
};

#endif // ABOUTWIDGET_H
