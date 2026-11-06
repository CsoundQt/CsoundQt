/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#ifndef WIDGETWINDOW_H
#define WIDGETWINDOW_H

#include <QMainWindow>

class CsoundQt;
class DocumentPage;
class QAction;
class QScrollArea;
class QToolBar;
class WidgetLayout;

// Owns a document that has no editor attached: its WidgetLayout is shown as a
// top-level window and this object only keeps the page, engine and MIDI
// listener alive. Closing the widget window closes the whole document.
class WidgetWindow : public QMainWindow
{
    Q_OBJECT

public:
    WidgetWindow(CsoundQt *mainWindow, const QString &fileName,
                 const QString &text, bool readOnly = false);
    ~WidgetWindow();

    DocumentPage *page() const { return m_page; }
    QString fileName() const { return m_fileName; }
    void showWidgets();
    // Keep the detached window's toolbar in sync with the application settings.
    void setToolbarIconSize(int size);
    void applyTheme();
    void applyPaletteToChrome();

signals:
    void closed(WidgetWindow *window);

protected:
    void closeEvent(QCloseEvent *event) override;

private slots:
    void play();
    void pause();
    void stop();
    void render();
    void widgetWindowStatus(bool visible);

private:
    CsoundQt *m_mainWindow;
    DocumentPage *m_page = nullptr;
    QString m_fileName;
    QScrollArea *m_scrollArea = nullptr;
    QToolBar *m_toolBar = nullptr;
    QAction *m_runAction = nullptr;
    QAction *m_pauseAction = nullptr;
    QAction *m_stopAction = nullptr;
};

#endif // WIDGETWINDOW_H
