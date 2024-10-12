#include "selectcolorbutton.h"
#include <QColorDialog>


SelectColorButton::SelectColorButton(QWidget* parent) {
    Q_UNUSED(parent);
    connect( this, SIGNAL(clicked()), this, SLOT(selectColor()) );
}

void SelectColorButton::setEnabled(bool enabled) {
    qDebug() << "setEnabled" << enabled;
    if(enabled) {
        this->paintColor(this->getColor());
    } else {
        this->paintColor(QColor(128, 128, 128));
    }
    this->QPushButton::setEnabled(enabled);
}

void SelectColorButton::changeEvent(QEvent *event) {
    if(event->type() == QEvent::EnabledChange) {
        this->setEnabled(this->isEnabled());
        event->accept();
    }
}

void SelectColorButton::paintColor(QColor color) {
#ifndef Q_OS_MAC
    setStyleSheet( "background-color: " + color.name() );
#else
    QPixmap pixmap(64, 64);
    pixmap.fill(color);
    setIcon(pixmap);
    QPalette palette(color);
    palette.color(QPalette::Window);
    setPalette(palette);
#endif
}

void SelectColorButton::selectColor() {
    QColor newColor = QColorDialog::getColor(color, parentWidget());
    setColor(newColor);
}

void SelectColorButton::setColor( const QColor& color ) {
    this->color = color;
    if(this->isEnabled())
        paintColor(color);
}

const QColor& SelectColorButton::getColor() {
    return color;
}
