#ifndef MYSLIDER_H
#define MYSLIDER_H

// this file is an attempt to fix sliders for MacOs 12 and later.
// code from: https://stackoverflow.com/questions/69890284/qslider-in-qt-misbehaves-in-new-macos-monterey-v12-0-1-any-workaround/69890285#69890285

#pragma once

#include <QStylePainter>
#include <QStyleOptionSlider>
#include <QStyleOptionComplex>
#include <QSlider>
#include <QColor>
#include "math.h"

class MySlider:public QSlider
{
public:
    explicit MySlider(Qt::Orientation orientation, QWidget *parent = nullptr):QSlider(orientation, parent){};
    explicit MySlider(QWidget *parent = nullptr):QSlider(parent){
        this->setStyleSheet(R"(

                            QSlider::groove:horizontal {
                                height: 2px; /* the groove expands to the size of the slider by default. by giving it a height, it has a fixed size */
                                background: #dcdcdc;
                                border: 1px solid #a8a8a8;
                                border-radius: 1px;
                            }

                            QSlider::sub-page:horizontal {
                            background: #aedaf5;
                            border: 1px solid #a8a8a8;
                            height: 4px;
                            border-radius: 2px;
                            }

                            QSlider::handle:horizontal {
                                background: #e9eaeb;
                                border: 1px solid #a8a8a8;
                                width: 18px;
                                height: 18px;
                                margin: -9px -1px; /* handle is placed by default on the contents rect of the groove. Expand outside the groove */
                                border-radius: 9px;
                                padding: -9px 0px;
                            }

                            QSlider::groove:vertical {
                                width: 2px;
                                background: #dcdcdc;
                                border: 1px solid #a8a8a8;
                                border-radius: 1px;
                            }


                            QSlider::add-page:vertical {
                                background: #aedaf5;
                                border: 1px solid #a8a8a8;
                                width: 4px;
                                border-radius: 2px;
                            }

                            QSlider::handle:vertical {
                                background: #e9eaeb;
                                border: 1px solid #a8a8a8;
                                width: 18px;
                                height: 18px;
                                margin: -1 -9px;
                                border-radius: 9px;
                            }
                        )");
    };
protected:
    virtual void paintEvent(QPaintEvent *ev)
    {
        QStylePainter p(this);
        QStyleOptionSlider opt;
        initStyleOption(&opt);

        QRect handle = style()->subControlRect(QStyle::CC_Slider, &opt, QStyle::SC_SliderHandle, this);

        // draw tick marks
        // do this manually because they are very badly behaved with style sheets
        int interval = tickInterval();
        if (interval == 0)
        {
            interval = pageStep();
        }

        if (tickPosition() != NoTicks)
        {
            for (int i = minimum(); i <= maximum(); i += interval)
            {
                int x = std::round((double)((double)((double)(i - this->minimum()) / (double)(this->maximum() - this->minimum())) * (double)(this->width() - handle.width()) + (double)(handle.width() / 2.0))) - 1;
                int h = 4;
                p.setPen(QColor(0xa5, 0xa2, 0x94));
                if (tickPosition() == TicksBothSides || tickPosition() == TicksAbove)
                {
                    int y = this->rect().top();
                    p.drawLine(x, y, x, y + h);
                }
                if (tickPosition() == TicksBothSides || tickPosition() == TicksBelow)
                {
                    int y = this->rect().bottom();
                    p.drawLine(x, y, x, y - h);
                }
            }
        }

        QSlider::paintEvent(ev);
    }
};



#endif // MYSLIDER_H
