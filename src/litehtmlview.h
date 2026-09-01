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
*/

#ifndef LITEHTMLVIEW_H
#define LITEHTMLVIEW_H

#include <QWidget>
#include <QUrl>
#include <QLineEdit>
#include <QStringList>
#include <QList>
#include <QVector>
#include <QRectF>
#include <QPointF>

#include <memory>

#include "litehtmlcontainer.h"
#include "searchindex.h"

class QScrollBar;
class QTimer;
class QWidget;
class QListWidget;
class QListWidgetItem;
class QKeyEvent;
class QMouseEvent;
class QWheelEvent;
class QResizeEvent;
class QPaintEvent;

namespace litehtml
{
class document;
}

struct SearchLine
{
    int          y;
    QString      text;
    QVector<int> fragIdx;
    QVector<int> charStart;
};

struct Match
{
    int line;
    int start;
    int end;
};

// A QWidget that renders a local HTML manual page with litehtml: scrolling with
// inertia, text selection, in-page find, whole-manual search, history and zoom.
class LiteHtmlView : public QWidget
{
    Q_OBJECT
public:
    explicit LiteHtmlView(QWidget *parent = nullptr);
    ~LiteHtmlView() override;

    bool loadFile(const QString &path, const QString &fragment = QString());
    QString currentPath() const { return m_currentPath; }

    void back();
    void forward();
    bool canGoBack() const { return m_historyPos > 0; }
    bool canGoForward() const { return m_historyPos + 1 < m_history.size(); }

    void zoomIn();
    void zoomOut();
    qreal zoomFactor() const { return m_zoomFactor; }
    void setZoomFactor(qreal factor);

    // In-page find (hosted as an in-panel box inside the viewer).
    void setFindQuery(const QString &query);
    void findNext();
    void findPrevious();
    void clearFind();
    void setCaseSensitive(bool on);
    void setWholeWords(bool on);
    void showFindBar();
    void hideFindBar();
    void toggleFindBar(bool show);
    bool isFindBarVisible() const { return m_findEdit && m_findEdit->isVisible(); }

    // Whole-manual search (roots are populated lazily on first search).
    void addSearchRoot(const QString &rootPath, const QString &label);
    void showSearchPanel();

    // Copy the current text selection to the clipboard.
    void copySelection();

signals:
    // Links the host application must decide on.
    void externalLinkRequested(const QUrl &url);
    void exampleFileRequested(const QString &filePath);
    // Status messages the host may show (e.g. in the main status bar).
    void statusMessage(const QString &message);
    // Esc pressed in the viewer: the host may hide its own overlays.
    void escapePressed();
    void historyChanged();

protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;
    bool eventFilter(QObject *o, QEvent *event) override;

private slots:
    void onLink(const QUrl &url);
    void runManualSearch();
    void openSearchResult(QListWidgetItem *item);
    void onFlingTick();

private:
    void doLoad(const QString &path, const QString &fragment, bool pushHistory);
    void navigateToHistory();
    void relayout();
    void recordAllFragments();
    void updateLineTable();
    void rebuildSearch();
    void scrollToMatch(int i);
    void scrollToAnchor(const QString &name);
    void selectAll();
    void clearSelection();

    QRectF selectionRect() const;
    int    lineForY(qreal y) const;
    bool   isFragmentSelected(const TextFragment &f) const;
    QString selectedText() const;
    QRectF rectForMatch(const Match &m) const;

    LiteHtmlContainer         m_container;
    std::shared_ptr<litehtml::document> m_doc;
    QScrollBar               *m_vbar = nullptr;
    QScrollBar               *m_hbar = nullptr;
    QTimer                   *m_flingTimer = nullptr;
    QLineEdit                *m_findEdit = nullptr;
    QWidget                  *m_searchPanel = nullptr;
    QLineEdit                *m_searchEdit = nullptr;
    QListWidget              *m_searchList = nullptr;
    SearchIndexManager        m_searchManager;
    QString                   m_searchPending;
    QList<SearchResult>       m_searchResults;
    bool                      m_searchLoaded = false;
    bool                      m_searchWithPrefix = false;

    QString                   m_currentPath;
    QString                   m_currentHtml;      // processed article, cached for zoom re-load
    int                       m_scrollbarWidth = 14;
    QStringList               m_history;
    int                       m_historyPos = -1;
    qreal                     m_zoomFactor = 1.0;
    int                       m_renderedWidth = -1;
    qreal                     m_wheelRemainder = 0;
    qreal                     m_scrollVelocity = 0;

    QPointF                   m_selAnchor;
    QPointF                   m_selCurrent;
    bool                      m_selecting = false;
    bool                      m_hasSelection = false;
    QList<int>                m_lineYs;

    QString                   m_findQuery;
    bool                      m_findCaseSensitive = false;
    bool                      m_findWholeWords = false;
    bool                      m_searchDirty = false;
    bool                      m_fragmentsDirty = false;
    QList<SearchLine>         m_searchLines;
    QList<Match>              m_matches;
    int                       m_currentMatch = -1;
};

#endif // LITEHTMLVIEW_H
