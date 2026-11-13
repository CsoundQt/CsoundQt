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

#include "widgetwindow.h"

#include "console.h"
#include "csoundengine.h"
#include "csoundqt.h"
#include "documentpage.h"
#include "documentview.h"
#include "midihandler.h"
#include "options.h"
#include "themedicons.h"
#include "widgetlayout.h"

#include <QAction>
#include <QCloseEvent>
#include <QDockWidget>
#include <QFileInfo>
#include <QMenu>
#include <QMenuBar>
#include <QMessageBox>
#include <QScrollArea>
#include <QTimer>
#include <QToolBar>

WidgetWindow::WidgetWindow(CsoundQt *mainWindow, const QString &fileName,
                           const QString &text, bool readOnly)
    : QMainWindow(nullptr), m_mainWindow(mainWindow), m_fileName(fileName)
{
    setAttribute(Qt::WA_QuitOnClose, false);

    m_page = new DocumentPage(this, mainWindow->m_opcodeTree,
                              &mainWindow->m_configlists,
                              mainWindow->m_midiLearn);
    m_page->setFileName(fileName);
    m_page->setReadOnly(readOnly);
    // The editor is not used in a widget-only document, but its view is still a
    // child of this window; hide it so showing the window does not show it.
    m_page->getView()->hide();

    // Csound messages go to the document's own console. Put it in a proper
    // bottom dock (hidden initially) instead of leaving it as an unmanaged child
    // that would overlap the toolbar, as happened on macOS.
    m_consoleDock = new QDockWidget(tr("Console"), this);
    m_consoleDock->setObjectName("widgetWindowConsole");
    m_page->getConsole()->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_consoleDock->setWidget(m_page->getConsole());
    // No title bar while docked (the toolbar already has the toggle button).
    // The console's own context menu offers Float/Dock Panel; when floating,
    // restore the native title bar so the window can be moved.
    auto *emptyTitleBar = new QWidget(m_consoleDock);
    emptyTitleBar->setFixedHeight(0);
    m_consoleDock->setTitleBarWidget(emptyTitleBar);
    connect(m_consoleDock, &QDockWidget::topLevelChanged, this,
            [this, emptyTitleBar](bool floating) {
        m_consoleDock->setTitleBarWidget(floating ? nullptr : emptyTitleBar);
        if (floating) {
            if (m_consoleExtraHeight > 0) {
                resize(width(), qMax(minimumHeight(),
                                     height() - m_consoleExtraHeight));
                m_consoleExtraHeight = 0;
            }
            m_consoleDock->resize(m_consoleDock->width(), 140);
        } else if (m_consoleDock->isVisible() && m_consoleExtraHeight == 0) {
            m_consoleExtraHeight = 140;
            resize(width(), height() + m_consoleExtraHeight);
            QTimer::singleShot(0, this, [this]() {
                resizeDocks({m_consoleDock}, {m_consoleExtraHeight}, Qt::Vertical);
            });
        }
    });
    addDockWidget(Qt::BottomDockWidgetArea, m_consoleDock);
    connect(m_consoleDock, &QDockWidget::visibilityChanged, this, [this](bool visible) {
        if (visible) {
            if (m_consoleDock->isFloating()) {
                m_consoleDock->resize(m_consoleDock->width(), 140);
                return;
            }
            // The window is normally sized exactly to the widget panel. Grow
            // it by the console height so showing the console does not shrink
            // the panel or introduce scroll bars.
            if (m_consoleExtraHeight == 0) {
                m_consoleExtraHeight = 140;
                resize(width(), height() + m_consoleExtraHeight);
            }
            QTimer::singleShot(0, this, [this]() {
                resizeDocks({m_consoleDock}, {m_consoleExtraHeight}, Qt::Vertical);
            });
        } else if (m_consoleExtraHeight > 0) {
            // Give the space back when the console is hidden again.
            resize(width(), qMax(minimumHeight(),
                                 height() - m_consoleExtraHeight));
            m_consoleExtraHeight = 0;
        }
    });
    m_consoleDock->hide();
    mainWindow->setCurrentOptionsForPage(m_page);
    QString textCopy = text;
    m_page->loadTextString(textCopy);
    m_page->setModified(false);

    mainWindow->midiHandler->addListener(m_page);
    m_page->getEngine()->setMidiHandler(mainWindow->midiHandler);

    connect(m_page, &DocumentPage::playRequested, this, &WidgetWindow::play);
    connect(m_page, &DocumentPage::renderRequested, this, &WidgetWindow::render);
    connect(m_page, &DocumentPage::pauseRequested, this, &WidgetWindow::pause);
    connect(m_page, &DocumentPage::stopRequested, this, &WidgetWindow::stop);

    WidgetLayout *layout = m_page->getWidgetLayout();
    m_scrollArea = new QScrollArea(this);
    m_scrollArea->setWidgetResizable(false);
    // No frame: the scroll area is the whole central widget, and Fusion draws
    // a bright 1px frame line directly below the toolbar otherwise.
    m_scrollArea->setFrameShape(QFrame::NoFrame);
    m_scrollArea->setAutoFillBackground(true);
    m_scrollArea->setBackgroundRole(QPalette::Window);
    if (layout != nullptr) {
        m_scrollArea->setWidget(layout);
        m_scrollArea->viewport()->installEventFilter(
                    new WidgetLayoutViewportFilter(layout));
        layout->setContained(true);
        layout->adjustLayoutSize();
        connect(layout, &WidgetLayout::windowStatus,
                this, &WidgetWindow::widgetWindowStatus);
        setWindowTitle(layout->windowTitle());
    } else {
        setWindowTitle(tr("Widgets"));
    }
    setCentralWidget(m_scrollArea);

    const QString theme = m_mainWindow->m_options->theme;
    auto themedIcon = [&theme](const QString &name) {
        return ThemedIcons::forMenu(
                    QString(":/themes/%1/%2").arg(theme, name));
    };
    m_runAction = new QAction(themedIcon("media-play.svg"),
                              tr("Run Csound"), this);
    m_runAction->setCheckable(true);
    m_pauseAction = new QAction(themedIcon("media-pause.svg"),
                                tr("Pause"), this);
    m_stopAction = new QAction(themedIcon("media-stop.svg"),
                               tr("Stop"), this);
    connect(m_page, &DocumentPage::stopSignal, this,
            [this]() { setPlaying(false); });
    connect(m_runAction, &QAction::triggered, this, &WidgetWindow::play);
    connect(m_pauseAction, &QAction::triggered, this, &WidgetWindow::pause);
    connect(m_stopAction, &QAction::triggered, this, &WidgetWindow::stop);

    QMenu *fileMenu = menuBar()->addMenu(tr("File"));
    QAction *closeAction = fileMenu->addAction(tr("Close"));
    connect(closeAction, &QAction::triggered, this, &QWidget::close);

    QMenu *controlMenu = menuBar()->addMenu(tr("Control"));
    controlMenu->addAction(m_runAction);
    controlMenu->addAction(m_pauseAction);
    controlMenu->addAction(m_stopAction);

    m_consoleAction = m_consoleDock->toggleViewAction();
    m_consoleAction->setIcon(themedIcon("terminal.svg"));
    m_consoleAction->setIconText(tr("Console"));
    QMenu *viewMenu = menuBar()->addMenu(tr("View"));
    viewMenu->addAction(m_consoleAction);

    m_toolBar = addToolBar(tr("Performance"));
    m_toolBar->setObjectName("widgetWindowToolBar");
    // Fusion (and some other styles) draw a bright 1px border along the bottom
    // edge of a tool bar. In the main window it is hidden by the adjacent
    // chrome, but here it would run across the top of the widget panel.
    m_toolBar->setStyleSheet("QToolBar { border: none; }");
    m_toolBar->setFloatable(false);
    m_toolBar->setMovable(false);
    m_toolBar->addAction(m_runAction);
    m_toolBar->addAction(m_pauseAction);
    m_toolBar->addAction(m_stopAction);
    m_toolBar->addSeparator();
    m_toolBar->addAction(m_consoleAction);
    setToolbarIconSize(m_mainWindow->m_options->toolbarIconSize);
    applyPaletteToChrome();

    m_toggleToolbarAction = new QAction(tr("Toggle Toolbar"), this);
    m_toggleToolbarAction->setCheckable(true);
    m_toggleToolbarAction->setChecked(true);
    connect(m_toggleToolbarAction, &QAction::toggled,
            m_toolBar, &QToolBar::setVisible);
    viewMenu->addAction(m_toggleToolbarAction);

    if (layout != nullptr) {
        QSize content = layout->size();
        if (content.width() <= 0 || content.height() <= 0)
            content = layout->sizeHint();
        const int chrome = menuBar()->sizeHint().height()
                + m_toolBar->sizeHint().height();
        // A little breathing room: the widget layout's own size is exact, but
        // the window needs a few pixels for its frame/edges.
        resize(content.expandedTo(QSize(220, 140))
               + QSize(10, chrome + 10));
        const QRect outer = layout->getOuterGeometry();
        if (outer.x() >= 0 && outer.y() >= 0)
            move(outer.x(), outer.y());
    }
}

WidgetWindow::~WidgetWindow()
{
    if (m_page == nullptr)
        return;
    if (WidgetLayout *layout = m_page->getWidgetLayout())
        layout->blockSignals(true);
    m_mainWindow->midiHandler->removeListener(m_page);
    m_page->stop();
    m_mainWindow->removePlaybackTempFile(m_page);
    m_page->hideWidgets();
    delete m_page;
    m_page = nullptr;
}

void WidgetWindow::showWidgets()
{
    if (m_page == nullptr)
        return;
    if (WidgetLayout *layout = m_page->getWidgetLayout()) {
        layout->setContained(true);
        layout->adjustLayoutSize();
        layout->show();
    }
    show();
    raise();
    activateWindow();
}

void WidgetWindow::setPlaying(bool playing)
{
    if (m_runAction != nullptr)
        m_runAction->setChecked(playing);
}

void WidgetWindow::play()
{
    setPlaying(m_mainWindow->playDetached(m_page));
}

void WidgetWindow::pause()
{
    m_page->pause();
}

void WidgetWindow::stop()
{
    m_mainWindow->stopDetached(m_page);
    setPlaying(false);
}

void WidgetWindow::render()
{
    QMessageBox::information(m_page->getWidgetLayout(),
                             tr("Render"),
                             tr("Rendering is not available for a widget-only document."));
}

void WidgetWindow::setToolbarIconSize(int size)
{
    if (m_toolBar != nullptr)
        m_toolBar->setIconSize(QSize(size, size));
}

void WidgetWindow::applyTheme()
{
    const QString theme = m_mainWindow->m_options->theme;
    auto themedIcon = [&theme](const QString &name) {
        return ThemedIcons::forMenu(
                    QString(":/themes/%1/%2").arg(theme, name));
    };
    if (m_runAction != nullptr)
        m_runAction->setIcon(themedIcon("media-play.svg"));
    if (m_pauseAction != nullptr)
        m_pauseAction->setIcon(themedIcon("media-pause.svg"));
    if (m_stopAction != nullptr)
        m_stopAction->setIcon(themedIcon("media-stop.svg"));
    if (m_consoleAction != nullptr)
        m_consoleAction->setIcon(themedIcon("terminal.svg"));
    if (m_toolBar != nullptr)
        m_toolBar->update();
}

void WidgetWindow::applyPaletteToChrome()
{
    // Mirror CsoundQt::applyPaletteToChrome(): Breeze and similar styles give
    // tool/menu bars their own palette, so a forced application colour theme
    // has to be re-asserted on them explicitly.
#ifdef Q_OS_LINUX
    if (m_mainWindow->m_options->themeMode == "auto")
        return;
    const QPalette pal = qApp->palette();
    if (m_toolBar != nullptr) {
        m_toolBar->setPalette(pal);
        m_toolBar->setAutoFillBackground(true);
    }
    if (QMenuBar *bar = menuBar()) {
        bar->setPalette(pal);
        bar->setAutoFillBackground(true);
    }
#endif
}

void WidgetWindow::closeEvent(QCloseEvent *event)
{
    emit closed(this);
    QMainWindow::closeEvent(event);
}

void WidgetWindow::widgetWindowStatus(bool visible)
{
    if (!visible)
        emit closed(this);
}
