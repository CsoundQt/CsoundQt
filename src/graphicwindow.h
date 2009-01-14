/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
#ifndef GRAPHICWINDOW_H
#define GRAPHICWINDOW_H

#include <QtGui>

class GraphicWindow : public QWidget
{
  Q_OBJECT
  public:
    GraphicWindow(QWidget *parent);

    ~GraphicWindow();

  private slots:
    void openPng(QString fileName);
    void zoomIn();
    void zoomOut();
    void normalSize();
    void fitToWindow();
    void print();

  protected:
    virtual void closeEvent (QCloseEvent * event);

  private:
//     QGraphicsScene *m_scene;
    void createActions();
    void createMenus();
    void updateActions();
    void scaleImage(double factor);
    void adjustScrollBar(QScrollBar *scrollBar, double factor);

    QLabel *imageLabel;
    QScrollArea *scrollArea;
    double scaleFactor;

    QPrinter printer;

//     QAction *openAct;
    QAction *printAct;
    QAction *exitAct;
    QAction *zoomInAct;
    QAction *zoomOutAct;
    QAction *normalSizeAct;
    QAction *fitToWindowAct;
//     QAction *aboutAct;
//     QAction *aboutQtAct;

    QMenu *fileMenu;
    QMenu *viewMenu;
    QMenu *helpMenu;
};

#endif
