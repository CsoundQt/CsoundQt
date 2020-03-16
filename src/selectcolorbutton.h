#ifndef SELECTCOLORBUTTON_H
#define SELECTCOLORBUTTON_H

#include <QtWidgets>


class SelectColorButton : public QPushButton
{
    Q_OBJECT

public:
    SelectColorButton( QWidget* parent );
    void setEnabled(bool);
    void setColor( const QColor& color );
    const QColor& getColor();

public slots:
    void selectColor();

private:
    QColor color;
    void paintColor(QColor color);

protected:
    virtual void changeEvent(QEvent *event) override;
};


#endif // SELECTCOLORBUTTON_H

