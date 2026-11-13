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
    // A bare background-color is not enough: some styles (notably Fusion)
    // still paint the native button bevel with its gradient on top, so the
    // swatch no longer matches the color the user picked. Adding an explicit
    // border makes the stylesheet take over the whole button and fill it with
    // the exact color.
    setStyleSheet(QString("QPushButton { background: %1;"
                          " border: 1px solid palette(mid); border-radius: 2px; }")
                      .arg(color.name()));
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
    const QColor newColor = QColorDialog::getColor(color, parentWidget());
    // getColor() returns an invalid color when the dialog is cancelled or
    // dismissed with Escape; keep the previous color in that case.
    if (newColor.isValid())
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
