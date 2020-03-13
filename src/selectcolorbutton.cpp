#include "selectcolorbutton.h"
#include <QColorDialog>


SelectColorButton::SelectColorButton( QWidget* parent ) {
    connect( this, SIGNAL(clicked()), this, SLOT(changeColor()) );
}

void SelectColorButton::updateColor() {
    setStyleSheet( "background-color: " + color.name() );
}

void SelectColorButton::changeColor() {
    QColor newColor = QColorDialog::getColor(color,parentWidget());
    if ( newColor != color ) {
        setColor( newColor );
    }
}

void SelectColorButton::setColor( const QColor& color ) {
    this->color = color;
    updateColor();
}

const QColor& SelectColorButton::getColor() {
    return color;
}
