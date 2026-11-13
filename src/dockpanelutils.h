/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
*/

#ifndef DOCKPANELUTILS_H
#define DOCKPANELUTILS_H

#include <QAction>
#include <QContextMenuEvent>
#include <QCoreApplication>
#include <QDockWidget>
#include <QList>
#include <QMainWindow>
#include <QMenu>
#include <QPointer>
#include <QTimer>
#include <QVariant>
#include <QWidget>

namespace DockPanelUtils {

// When enabled, docked panels use the zero-height title bar even when they are
// not tabified. Floating panels always keep their normal title bar so they can
// still be moved and closed.
inline bool &hideDockedPanelTitles()
{
    static bool hide = false;
    return hide;
}

// True when the dock is docked and shares a tab bar with another dock.
inline bool isTabified(QDockWidget *dock)
{
    auto *mainWindow = qobject_cast<QMainWindow *>(dock->parentWidget());
    return mainWindow != nullptr
            && !mainWindow->tabifiedDockWidgets(dock).isEmpty();
}

// The QDockWidget containing widget, if any.
inline QDockWidget *dockWidgetFor(QWidget *widget)
{
    for (QWidget *w = widget; w != nullptr; w = w->parentWidget()) {
        if (auto *dock = qobject_cast<QDockWidget *>(w))
            return dock;
    }
    return nullptr;
}

inline bool isKeepingFloating(const QDockWidget *dock)
{
    return dock->property("csoundqtKeepFloating").toBool();
}

// While enabled, the dock cannot be dropped back into the main window.
// The allowed areas are restored when the option is turned off or the dock
// is docked by another means.
inline void setKeepFloating(QDockWidget *dock, bool keep)
{
    if (isKeepingFloating(dock) == keep)
        return;
    if (keep) {
        dock->setProperty("csoundqtSavedAllowedAreas",
                          dock->allowedAreas().toInt());
        dock->setAllowedAreas(Qt::NoDockWidgetArea);
        dock->setProperty("csoundqtKeepFloating", true);
    } else {
        const int areas = dock->property("csoundqtSavedAllowedAreas").toInt();
        dock->setAllowedAreas(areas != 0
                ? Qt::DockWidgetAreas::fromInt(areas)
                : Qt::AllDockWidgetAreas);
        dock->setProperty("csoundqtSavedAllowedAreas", QVariant());
        dock->setProperty("csoundqtKeepFloating", false);
    }
}

// Adds the actions shared by the panel context menus. The actions are
// deferred so that the menu is closed before the dock is floated or docked.
inline void addPanelActions(QDockWidget *dock, QMenu &menu, bool separatorBeforeClose = true)
{
    const QByteArray context = dock->metaObject()->className();
    const auto tr = [&context](const char *text) {
        return QCoreApplication::translate(context.constData(), text);
    };

    menu.addSeparator();
    QAction *floatAction = menu.addAction(dock->isFloating()
                                          ? tr("Dock Panel")
                                          : tr("Float Panel"));
    QObject::connect(floatAction, &QAction::triggered, dock, [dock]() {
        QTimer::singleShot(0, dock, [dock]() {
            if (dock->isFloating()) {
                setKeepFloating(dock, false);
                dock->setFloating(false);
            } else {
                dock->setFloating(true);
            }
        });
    });

    if (dock->isFloating()) {
        QAction *keepAction = menu.addAction(tr("Keep Panel Floating"));
        keepAction->setCheckable(true);
        keepAction->setChecked(isKeepingFloating(dock));
        QObject::connect(keepAction, &QAction::toggled, dock, [dock](bool checked) {
            QTimer::singleShot(0, dock, [dock, checked]() {
                setKeepFloating(dock, checked);
            });
        });
    }

    if (separatorBeforeClose)
        menu.addSeparator();
    QAction *closeAction = menu.addAction(tr("Close"));
    QObject::connect(closeAction, &QAction::triggered, dock, [dock]() {
        // Close after the menu has gone, like the float/dock actions above.
        QTimer::singleShot(0, dock, [dock]() { dock->close(); });
    });
}

// Give a dock that does not build its own panel menu the shared actions
// (including Close). Child widgets that provide their own context menu keep
// it; the dock menu is shown for the remaining area and for events that
// propagate up from the content.
inline void installPanelContextMenu(QDockWidget *dock)
{
    dock->setContextMenuPolicy(Qt::CustomContextMenu);
    QObject::connect(dock, &QWidget::customContextMenuRequested, dock,
                     [dock](const QPoint &pos) {
        QMenu menu;
        addPanelActions(dock, menu);
        menu.exec(dock->mapToGlobal(pos));
    });
}

// Keeps a dock's custom title bar hidden while it is tabified (or while the
// global "hide docked panel titles" option is on), and uses the native
// (style-coloured) title bar when it is floating or when the option is off.
// It also watches for tabify/untabify changes, which have no QDockWidget
// signal of their own.
class TitleBarController : public QObject
{
public:
    explicit TitleBarController(QDockWidget *dock)
        : QObject(dock), m_dock(dock)
    {
        m_hiddenTitleBar = new QWidget(dock);
        m_hiddenTitleBar->setFixedHeight(0);
        dock->installEventFilter(this);
        QObject::connect(dock, &QDockWidget::topLevelChanged, this,
                         [this](bool) { scheduleUpdate(); });
        instances().append(this);
        scheduleUpdate();
    }

    // Update the global setting and re-evaluate every live title bar.
    static void setHideDockedPanelTitles(bool hide)
    {
        hideDockedPanelTitles() = hide;
        for (QPointer<QObject> &object : instances()) {
            if (object != nullptr) {
                static_cast<TitleBarController *>(object.data())->scheduleUpdate();
            }
        }
        instances().removeIf([](const QPointer<QObject> &object) {
            return object.isNull();
        });
    }

protected:
    bool eventFilter(QObject *watched, QEvent *event) override
    {
        if (watched == m_dock) {
            switch (event->type()) {
            case QEvent::ChildAdded:
            case QEvent::ChildRemoved:
            case QEvent::Move:
            case QEvent::ZOrderChange:
            case QEvent::Show:
            case QEvent::Hide:
                scheduleUpdate();
                break;
            default:
                break;
            }
        }
        return QObject::eventFilter(watched, event);
    }

private:
    static QList<QPointer<QObject>> &instances()
    {
        static QList<QPointer<QObject>> controllers;
        return controllers;
    }

    void scheduleUpdate()
    {
        if (m_updatePending)
            return;
        m_updatePending = true;
        QTimer::singleShot(0, this, [this]() {
            m_updatePending = false;
            updateTitleBar();
        });
    }

    void updateTitleBar()
    {
        if (m_dock == nullptr)
            return;
        const bool hideTitle = !m_dock->isFloating()
                && (hideDockedPanelTitles() || isTabified(m_dock));
        if (hideTitle) {
            if (m_dock->titleBarWidget() != m_hiddenTitleBar)
                m_dock->setTitleBarWidget(m_hiddenTitleBar);
        } else if (m_dock->titleBarWidget() != nullptr) {
            m_dock->setTitleBarWidget(nullptr);
        }
        if (!m_dock->isFloating() && isKeepingFloating(m_dock))
            setKeepFloating(m_dock, false);
    }

    QPointer<QDockWidget> m_dock;
    QWidget *m_hiddenTitleBar = nullptr;
    bool m_updatePending = false;
};

} // namespace DockPanelUtils

#endif // DOCKPANELUTILS_H
