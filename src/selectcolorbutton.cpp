#include "selectcolorbutton.h"
#include <QColorDialog>
#include <QPainter>


SelectColorButton::SelectColorButton(QWidget* parent) {
    Q_UNUSED(parent);
    // The colour is the button icon; make the swatch large enough to read.
    setIconSize(QSize(24, 24));
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
    if (text().isEmpty()) {
        // Unlabelled colour buttons (e.g. the Display properties) keep the
        // original look: the whole button is filled with the colour.
        setIcon(QIcon());
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
        return;
    }

    // Labelled colour buttons show the colour as an icon and can carry a
    // caption (e.g. "Text"). Draw it as a rounded swatch on a transparent
    // background, with a thin border picked halfway between the theme's button
    // foreground/background so it stays visible for light and dark fills.
    QPixmap pixmap(64, 64);
    pixmap.fill(Qt::transparent);
    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing, true);

    const QPalette pal = palette();
    QColor foreground = pal.color(QPalette::ButtonText);
    QColor background = pal.color(QPalette::Button);
    if (!foreground.isValid() || !background.isValid()) {
        foreground = pal.color(QPalette::WindowText);
        background = pal.color(QPalette::Window);
    }
    const QColor borderColor = QColor::fromRgbF(
                (foreground.redF() + background.redF()) / 2.0,
                (foreground.greenF() + background.greenF()) / 2.0,
                (foreground.blueF() + background.blueF()) / 2.0);

    // One physical pixel at the displayed icon size, independent of the
    // pixmap resolution used here.
    const qreal borderWidth = 64.0 / qMax(1, iconSize().width());
    const QRectF swatch(borderWidth / 2.0, borderWidth / 2.0,
                        64.0 - borderWidth, 64.0 - borderWidth);

    painter.setPen(Qt::NoPen);
    painter.setBrush(color);
    painter.drawRoundedRect(swatch, 12.0, 12.0);

    painter.setBrush(Qt::NoBrush);
    painter.setPen(QPen(borderColor, borderWidth));
    painter.drawRoundedRect(swatch, 12.0, 12.0);
    painter.end();
    setIcon(pixmap);
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
