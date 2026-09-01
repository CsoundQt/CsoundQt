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

#include "litehtmlview.h"

#include <QApplication>
#include <QScrollBar>
#include <QPainter>
#include <QMouseEvent>
#include <QWheelEvent>
#include <QResizeEvent>
#include <QPaintEvent>
#include <QKeyEvent>
#include <QTimer>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QLineEdit>
#include <QListWidget>
#include <QVBoxLayout>
#include <QClipboard>
#include <QRegularExpression>
#include <QMap>
#include <QDebug>

#include <litehtml.h>
#include <litehtml/render_item.h>
#include <algorithm>
#include <limits>
#include <functional>
#include <memory>

using namespace litehtml;

// ---------------------------------------------------------------------------
// MkDocs article extraction + tab flattening (see LITEHTML_INTEGRATION_PLAN.md)
// ---------------------------------------------------------------------------

static int matchDiv(const QString &html, int start)
{
    int depth = 0;
    for (int i = start; i < html.size(); ++i)
    {
        if (html.at(i) == '<')
        {
            if (html.mid(i, 4) == "<div")
            {
                ++depth;
                i += 3;
            }
            else if (html.mid(i, 6) == "</div>")
            {
                --depth;
                i += 5;
                if (depth == 0)
                    return i + 1;
            }
        }
    }
    return -1;
}

static void flattenTabs(QString &art)
{
    QRegularExpression labelRe("<label[^>]*>([\\s\\S]*?)</label>");
    int                pos = 0;
    while ((pos = art.indexOf("<div class=\"tabbed-set", pos)) != -1)
    {
        int end = matchDiv(art, pos);
        if (end == -1)
            break;
        QString block = art.mid(pos, end - pos);

        QStringList labels;
        QRegularExpressionMatchIterator li = labelRe.globalMatch(block);
        while (li.hasNext())
            labels << li.next().captured(1).trimmed();

        QStringList contents;
        int         bp = block.indexOf("<div class=\"tabbed-block\">");
        while (bp != -1)
        {
            int bstart = block.indexOf('>', bp) + 1;
            int bend   = matchDiv(block, bp);
            if (bend == -1)
                break;
            contents << block.mid(bstart, bend - bstart);
            bp = block.indexOf("<div class=\"tabbed-block\">", bend);
        }

        QString rebuilt;
        for (int i = 0; i < qMin(labels.size(), contents.size()); ++i)
            rebuilt += "<h3>" + labels.at(i) + "</h3>" + contents.at(i);
        art.replace(pos, end - pos, rebuilt);
        pos += rebuilt.size();
    }
}

static QString extractArticle(const QString &html)
{
    int start = html.indexOf("<article");
    if (start == -1)
        return html;
    int end = html.indexOf("</article>", start);
    if (end == -1)
        return html.mid(start);
    QString art = html.mid(start, end - start + 10);
    flattenTabs(art);
    return art;
}

static QString findSiteRoot(const QString &file)
{
    QDir d = QFileInfo(file).absoluteDir();
    while (!d.exists("assets/stylesheets") && !d.isRoot())
        d.cdUp();
    return d.absolutePath();
}

static std::string loadStylesheets(const QString &dir)
{
    std::string all;
    QDir d(dir + "/assets/stylesheets");
    QStringList list;
    for (const QFileInfo &fi : d.entryInfoList({"main.*.min.css"}, QDir::Files))
        list << fi.absoluteFilePath();
    for (const QFileInfo &fi : d.entryInfoList({"palette.*.min.css"}, QDir::Files))
        list << fi.absoluteFilePath();
    QDir e(dir + "/stylesheets");
    for (const QFileInfo &fi : e.entryInfoList({"*.css"}, QDir::Files))
        list << fi.absoluteFilePath();
    for (const QString &f : list)
    {
        QFile ff(f);
        if (ff.open(QIODevice::ReadOnly))
            all += QString::fromUtf8(ff.readAll()).toStdString() + "\n";
    }
    return all;
}

// ---------------------------------------------------------------------------

LiteHtmlView::LiteHtmlView(QWidget *parent)
    : QWidget(parent)
{
    setAttribute(Qt::WA_OpaquePaintEvent);
    setMouseTracking(true);
    setFocusPolicy(Qt::StrongFocus);

    m_hbar = new QScrollBar(Qt::Horizontal, this);
    m_vbar = new QScrollBar(Qt::Vertical, this);
    m_vbar->setRange(0, 0);
    connect(m_vbar, &QScrollBar::valueChanged, this, [this](int) { update(); });
    connect(m_hbar, &QScrollBar::valueChanged, this, [this](int) { update(); });

    m_flingTimer = new QTimer(this);
    m_flingTimer->setInterval(16);
    connect(m_flingTimer, &QTimer::timeout, this, &LiteHtmlView::onFlingTick);

    m_searchPanel = new QWidget(this);
    m_searchPanel->setObjectName("manualSearchPanel");
    m_searchPanel->setVisible(false);
    QVBoxLayout *sl = new QVBoxLayout(m_searchPanel);
    sl->setContentsMargins(0, 0, 0, 0);
    sl->setSpacing(2);
    m_searchEdit = new QLineEdit(m_searchPanel);
    m_searchEdit->setPlaceholderText(tr("Search manual — Enter to include partial matches"));
    m_searchList = new QListWidget(m_searchPanel);
    sl->addWidget(m_searchEdit);
    sl->addWidget(m_searchList);
    connect(m_searchEdit, &QLineEdit::textChanged, this, [this](const QString &) {
        m_searchPending = m_searchEdit->text();
        m_searchWithPrefix = false; // exact matches while typing
        if (!m_searchLoaded)
        {
            m_searchList->clear();
            new QListWidgetItem(tr("Indexing manuals… (first search only)"), m_searchList);
            QApplication::processEvents();
        }
        QTimer::singleShot(0, this, &LiteHtmlView::runManualSearch);
    });
    connect(m_searchEdit, &QLineEdit::returnPressed, this, [this] {
        m_searchWithPrefix = true; // broaden to partial matches on Enter
        runManualSearch();
    });
    connect(m_searchList, &QListWidget::itemActivated, this, &LiteHtmlView::openSearchResult);

    m_container.setViewport(width(), height());
    m_container.linkClicked = [this](const QUrl &url) { onLink(url); };
}

LiteHtmlView::~LiteHtmlView() = default;

bool LiteHtmlView::loadFile(const QString &path, const QString &fragment)
{
    if (!QFile::exists(path))
    {
        emit statusMessage(tr("Not found: %1").arg(path));
        return false;
    }
    doLoad(path, fragment, true);
    return true;
}

void LiteHtmlView::doLoad(const QString &path, const QString &fragment, bool pushHistory)
{
    if (m_currentHtml.isEmpty() || m_currentPath != path)
    {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly))
        {
            emit statusMessage(tr("Not found: %1").arg(path));
            return;
        }
        m_currentHtml = extractArticle(QString::fromUtf8(f.readAll()));
    }
    m_currentPath = path;
    m_container.setBaseDir(QFileInfo(path).absolutePath());
    m_container.setDefaultFontSize(qRound(16.0 * m_zoomFactor));
    std::string css = loadStylesheets(findSiteRoot(path));
    m_doc = document::createFromString(m_currentHtml.toStdString(), &m_container, master_css, css);
    m_selecting = false;
    m_hasSelection = false;
    m_renderedWidth = -1; // force re-render of the new document
    relayout();

    if (pushHistory)
    {
        if (m_historyPos + 1 < m_history.size())
            m_history.resize(m_historyPos + 1);
        m_history.append(path);
        m_historyPos = m_history.size() - 1;
        emit historyChanged();
    }
    if (!fragment.isEmpty())
        QTimer::singleShot(0, this, [this, fragment] { scrollToAnchor(fragment); });
}

void LiteHtmlView::back()
{
    if (m_historyPos > 0)
    {
        --m_historyPos;
        navigateToHistory();
    }
}

void LiteHtmlView::forward()
{
    if (m_historyPos + 1 < m_history.size())
    {
        ++m_historyPos;
        navigateToHistory();
    }
}

void LiteHtmlView::navigateToHistory()
{
    QString p = m_history.at(m_historyPos);
    m_currentHtml.clear(); // force re-read for the target page
    doLoad(p, QString(), false);
}

void LiteHtmlView::setZoomFactor(qreal factor)
{
    m_zoomFactor = qBound(0.5, factor, 4.0);
    if (m_doc)
        doLoad(m_currentPath, QString(), false); // re-create doc with new base font size
}

void LiteHtmlView::zoomIn()
{
    setZoomFactor(m_zoomFactor + 0.1);
}

void LiteHtmlView::zoomOut()
{
    setZoomFactor(m_zoomFactor - 0.1);
}

void LiteHtmlView::setFindQuery(const QString &query)
{
    m_findQuery = query;
    m_searchDirty = true;
    update();
}

void LiteHtmlView::setCaseSensitive(bool on)
{
    m_findCaseSensitive = on;
    m_searchDirty = true;
    update();
}

void LiteHtmlView::setWholeWords(bool on)
{
    m_findWholeWords = on;
    m_searchDirty = true;
    update();
}

void LiteHtmlView::findNext()
{
    if (m_matches.isEmpty() || m_currentMatch < 0)
        return;
    m_currentMatch = (m_currentMatch + 1) % m_matches.size();
    scrollToMatch(m_currentMatch);
    update();
}

void LiteHtmlView::findPrevious()
{
    if (m_matches.isEmpty() || m_currentMatch < 0)
        return;
    m_currentMatch = (m_currentMatch - 1 + m_matches.size()) % m_matches.size();
    scrollToMatch(m_currentMatch);
    update();
}

void LiteHtmlView::clearFind()
{
    m_findQuery.clear();
    m_matches.clear();
    m_currentMatch = -1;
    m_searchDirty = false;
    update();
}

void LiteHtmlView::addSearchRoot(const QString &rootPath, const QString &label)
{
    m_searchManager.addRoot(rootPath, label);
}

void LiteHtmlView::showSearchPanel()
{
    m_searchPanel->setVisible(true);
    m_searchPanel->raise();
    m_searchEdit->setFocus();
    m_searchEdit->selectAll();
}

void LiteHtmlView::copySelection()
{
    QString t = selectedText();
    if (!t.isEmpty())
        QApplication::clipboard()->setText(t);
}

void LiteHtmlView::onLink(const QUrl &url)
{
    QString frag = url.fragment();
    if (!frag.isEmpty() && url.path().isEmpty())
    {
        scrollToAnchor(frag);
        return;
    }
    QUrl resolved = QUrl::fromLocalFile(QFileInfo(m_currentPath).absolutePath() + "/dummy.html").resolved(url);
    if (resolved.scheme() == "http" || resolved.scheme() == "https")
    {
        emit externalLinkRequested(resolved);
        return;
    }
    QString path = resolved.toLocalFile();
    if (path.endsWith(".csd", Qt::CaseInsensitive))
    {
        emit exampleFileRequested(path);
        return;
    }
    if (QFile::exists(path))
        QTimer::singleShot(0, this, [this, path] { loadFile(path); });
    else
        emit statusMessage(tr("Not found: %1").arg(path));
}

void LiteHtmlView::relayout()
{
    if (!m_doc)
        return;
    m_container.setViewport(width(), height());
    if (width() != m_renderedWidth)
    {
        m_doc->render(width());
        m_renderedWidth = width();
        // Layout changed -> the recorded text-fragment cache and the search
        // matches are stale and must be rebuilt.
        m_fragmentsDirty = true;
        m_searchDirty = true;
    }
    int ch = int(m_doc->height());
    int cw = int(m_doc->width());
    int oldV = m_vbar->value();
    int oldH = m_hbar->value();
    m_vbar->setRange(0, qMax(0, ch - height()));
    m_hbar->setRange(0, qMax(0, cw - width()));
    m_vbar->setValue(oldV);
    m_hbar->setValue(oldH);
    m_vbar->setPageStep(height());
    m_hbar->setPageStep(width());
    m_vbar->resize(m_vbar->width(), height());
    m_hbar->move(0, height() - m_hbar->height());
    m_vbar->move(width() - m_vbar->width(), 0);
    m_vbar->setVisible(m_vbar->maximum() > 0);
    m_hbar->setVisible(m_hbar->maximum() > 0);
    update();
}

void LiteHtmlView::paintEvent(QPaintEvent *)
{
    QPainter p(this);
    p.fillRect(rect(), Qt::white);
    if (!m_doc)
        return;
    if (m_fragmentsDirty)
    {
        recordAllFragments();
        m_fragmentsDirty = false;
    }
    p.save();
    p.translate(-m_hbar->value(), -m_vbar->value());
    // Visible rectangle in document coordinates; lets litehtml cull
    // off-screen elements instead of redrawing the whole page each frame.
    position clip = {m_hbar->value(), m_vbar->value(), width(), height()};
    m_container.setRecordFragments(false);
    m_container.setPainter(&p);
    m_doc->draw(reinterpret_cast<uint_ptr>(&p), 0, 0, &clip);
    m_container.setPainter(nullptr);
    // Selection highlight over the recorded text fragments.
    if (m_hasSelection)
    {
        QColor hl(51, 153, 255, 70);
        for (const TextFragment &f : m_container.fragments())
            if (isFragmentSelected(f))
                p.fillRect(f.rect, hl);
    }
    // In-page search highlights.
    if (m_searchDirty)
        rebuildSearch();
    for (int i = 0; i < m_matches.size(); ++i)
    {
        QRectF r = rectForMatch(m_matches.at(i));
        if (r.isEmpty())
            continue;
        QColor c = (i == m_currentMatch) ? QColor(255, 150, 0, 130) : QColor(255, 235, 60, 110);
        p.fillRect(r, c);
    }
    p.restore();
}

void LiteHtmlView::recordAllFragments()
{
    if (!m_doc)
        return;
    m_container.setPainter(nullptr);
    m_container.setRecordFragments(true);
    m_container.clearFragments();
    m_doc->draw(reinterpret_cast<uint_ptr>(nullptr), 0, 0, nullptr);
    m_container.setRecordFragments(false);
    updateLineTable();
    m_searchDirty = true;
}

void LiteHtmlView::mousePressEvent(QMouseEvent *e)
{
    if (e->button() == Qt::LeftButton && m_doc)
    {
        clearSelection();
        QPointF pos(e->pos().x() + m_hbar->value(), e->pos().y() + m_vbar->value());
        m_selAnchor = pos;
        m_selCurrent = pos;
        m_selecting = true;
        m_doc->on_lbutton_down(int(pos.x()), int(pos.y()), e->pos().x(), e->pos().y(),
                               [this](const position &b) { update(); });
    }
}

void LiteHtmlView::mouseReleaseEvent(QMouseEvent *e)
{
    if (e->button() == Qt::LeftButton && m_doc)
    {
        m_selecting = false;
        if (m_selAnchor != m_selCurrent)
            m_hasSelection = true;
        m_doc->on_lbutton_up(e->pos().x() + m_hbar->value(), e->pos().y() + m_vbar->value(),
                             e->pos().x(), e->pos().y(),
                             [this](const position &b) { update(); });
    }
}

void LiteHtmlView::mouseMoveEvent(QMouseEvent *e)
{
    if (m_selecting && m_doc)
    {
        m_selCurrent = QPointF(e->pos().x() + m_hbar->value(), e->pos().y() + m_vbar->value());
        m_hasSelection = m_selAnchor != m_selCurrent;
        update();
        return;
    }
    if (m_doc)
    {
        bool changed = m_doc->on_mouse_over(e->pos().x() + m_hbar->value(), e->pos().y() + m_vbar->value(),
                                            e->pos().x(), e->pos().y(),
                                            [this](const position &b) { update(); });
        if (changed)
            update();
    }
}

void LiteHtmlView::keyPressEvent(QKeyEvent *e)
{
    if (e->matches(QKeySequence::Copy))
    {
        copySelection();
        return;
    }
    if (e->matches(QKeySequence::SelectAll))
    {
        selectAll();
        return;
    }
    if (e->key() == Qt::Key_F && (e->modifiers() & Qt::ControlModifier) && !(e->modifiers() & Qt::ShiftModifier))
    {
        emit findBarRequested();
        return;
    }
    if (e->key() == Qt::Key_F && (e->modifiers() & Qt::ControlModifier) && (e->modifiers() & Qt::ShiftModifier))
    {
        m_searchPanel->setVisible(!m_searchPanel->isVisible());
        if (m_searchPanel->isVisible())
        {
            m_searchPanel->raise();
            m_searchEdit->setFocus();
            m_searchEdit->selectAll();
        }
        return;
    }
    if (e->key() == Qt::Key_Escape)
    {
        if (m_searchPanel->isVisible())
            m_searchPanel->setVisible(false);
        clearFind();
        clearSelection();
        emit escapePressed();
        return;
    }
    QWidget::keyPressEvent(e);
}

void LiteHtmlView::wheelEvent(QWheelEvent *e)
{
    // Prefer pixel deltas (trackpads/Wayland); fall back to notched deltas.
    QPoint delta = e->pixelDelta();
    qreal  step;
    if (!delta.isNull())
        step = delta.y();
    else
        step = e->angleDelta().y() / 120.0 * 100.0;
    if (e->phase() == Qt::ScrollBegin)
        m_wheelRemainder = 0;
    qreal dy = step + m_wheelRemainder;
    int   whole = int(dy);
    m_wheelRemainder = dy - whole;
    m_vbar->setValue(m_vbar->value() - whole);
    // accumulate velocity for kinetic continuation
    m_scrollVelocity = qBound(-800.0, m_scrollVelocity + dy * 0.4, 800.0);
    if (!m_flingTimer->isActive())
        m_flingTimer->start();
    if (delta.x() != 0)
        m_hbar->setValue(m_hbar->value() - delta.x());
    e->accept();
}

void LiteHtmlView::onFlingTick()
{
    int dy = int(m_scrollVelocity);
    if (dy == 0 || qAbs(m_scrollVelocity) < 0.5)
    {
        m_flingTimer->stop();
        m_scrollVelocity = 0;
        return;
    }
    m_vbar->setValue(m_vbar->value() - dy);
    m_scrollVelocity *= 0.85;
}

void LiteHtmlView::resizeEvent(QResizeEvent *)
{
    relayout();
    m_hbar->resize(qMax(0, width() - m_vbar->width()), m_hbar->height());
    m_hbar->move(0, height() - m_hbar->height());
    m_vbar->move(width() - m_vbar->width(), 0);
    m_searchPanel->setGeometry(width() - 440 - 20, 40, 440, 360);
    m_searchPanel->raise();
}

void LiteHtmlView::runManualSearch()
{
    QString q = m_searchPending.trimmed();
    m_searchList->clear();
    m_searchResults.clear();
    if (q.isEmpty())
        return;
    if (!m_searchLoaded)
        m_searchLoaded = m_searchManager.ensureLoaded();
    if (!m_searchLoaded)
    {
        new QListWidgetItem(tr("No search index found."), m_searchList);
        return;
    }
    m_searchResults = m_searchManager.search(q, m_searchWithPrefix);
    for (int i = 0; i < m_searchResults.size(); ++i)
    {
        const SearchResult &r     = m_searchResults.at(i);
        const QString       label = m_searchManager.roots().at(r.rootIndex).label;
        auto *item = new QListWidgetItem(QString("%1   [%2]").arg(r.title, label), m_searchList);
        item->setToolTip(r.snippet.isEmpty() ? r.location : r.snippet + "\n→ " + r.location);
        item->setData(Qt::UserRole, i);
    }
    if (m_searchResults.isEmpty())
        new QListWidgetItem(tr("No results."), m_searchList);
}

void LiteHtmlView::openSearchResult(QListWidgetItem *item)
{
    int idx = item->data(Qt::UserRole).toInt();
    if (idx < 0 || idx >= m_searchResults.size())
        return;
    QString path = m_searchManager.resolvePath(m_searchResults.at(idx));
    if (path.isEmpty())
        return;
    QString frag;
    int     hash = path.indexOf('#');
    if (hash >= 0)
    {
        frag = path.mid(hash + 1);
        path = path.left(hash);
    }
    if (QFile::exists(path))
        loadFile(path, frag);
    m_searchPanel->setVisible(false);
}

void LiteHtmlView::scrollToAnchor(const QString &name)
{
    if (!m_doc)
        return;
    std::function<std::shared_ptr<render_item>(const std::shared_ptr<render_item> &, const QString &)> find =
        [&](const std::shared_ptr<render_item> &ri, const QString &n) -> std::shared_ptr<render_item> {
        if (!ri)
            return nullptr;
        const char *id = ri->src_el() ? ri->src_el()->get_attr("id") : nullptr;
        if (id && QString::fromUtf8(id) == n)
            return ri;
        for (const auto &ch : ri->children())
        {
            auto r = find(ch, n);
            if (r)
                return r;
        }
        return nullptr;
    };
    auto ri = find(m_doc->root_render(), name);
    if (ri)
    {
        position p = ri->calc_placement(0, 0);
        m_vbar->setValue(qBound(0, int(p.y) - 20, m_vbar->maximum()));
    }
}

void LiteHtmlView::rebuildSearch()
{
    m_searchDirty = false;
    m_matches.clear();
    m_currentMatch = -1;
    if (m_findQuery.isEmpty())
        return;

    const auto &frags = m_container.fragments();
    m_searchLines.clear();
    QMap<int, QVector<int>> byLine;
    for (int i = 0; i < frags.size(); ++i)
        byLine[int(frags.at(i).rect.y())].append(i);
    for (auto it = byLine.begin(); it != byLine.end(); ++it)
    {
        SearchLine sl;
        sl.y = it.key();
        sl.fragIdx = it.value();
        std::sort(sl.fragIdx.begin(), sl.fragIdx.end(), [&](int a, int b) {
            return frags.at(a).rect.x() < frags.at(b).rect.x();
        });
        for (int idx : sl.fragIdx)
        {
            sl.charStart.append(sl.text.size());
            sl.text += frags.at(idx).text;
        }
        m_searchLines.append(sl);
    }
    std::sort(m_searchLines.begin(), m_searchLines.end(),
              [](const SearchLine &a, const SearchLine &b) { return a.y < b.y; });

    Qt::CaseSensitivity cs = m_findCaseSensitive ? Qt::CaseSensitive : Qt::CaseInsensitive;
    for (int li = 0; li < m_searchLines.size(); ++li)
    {
        const SearchLine &sl = m_searchLines.at(li);
        int              from = 0;
        while ((from = sl.text.indexOf(m_findQuery, from, cs)) != -1)
        {
            if (m_findWholeWords)
            {
                bool leftOk  = (from == 0) || !sl.text.at(from - 1).isLetterOrNumber();
                bool rightOk = (from + m_findQuery.size() >= sl.text.size())
                               || !sl.text.at(from + m_findQuery.size()).isLetterOrNumber();
                if (!leftOk || !rightOk)
                {
                    from += qMax(1, m_findQuery.size());
                    continue;
                }
            }
            m_matches.append({li, from, from + m_findQuery.size()});
            from += qMax(1, m_findQuery.size());
        }
    }
    if (!m_matches.isEmpty())
    {
        m_currentMatch = 0;
        scrollToMatch(0);
    }
}

QRectF LiteHtmlView::rectForMatch(const Match &m) const
{
    const auto      &frags = m_container.fragments();
    const SearchLine &sl   = m_searchLines.at(m.line);
    QRectF           r;
    for (int k = 0; k < sl.fragIdx.size(); ++k)
    {
        int fstart = sl.charStart.at(k);
        int fend   = fstart + frags.at(sl.fragIdx.at(k)).text.size();
        int lo     = qMax(m.start, fstart);
        int hi     = qMin(m.end, fend);
        if (lo >= hi)
            continue;
        const TextFragment &f = frags.at(sl.fragIdx.at(k));
        qreal x = f.rect.x() + f.metrics.horizontalAdvance(f.text.left(lo - fstart));
        qreal w = f.metrics.horizontalAdvance(f.text.mid(lo - fstart, hi - lo));
        QRectF sub(x, f.rect.y(), w, f.rect.height());
        r = r.isNull() ? sub : r.united(sub);
    }
    return r;
}

void LiteHtmlView::scrollToMatch(int i)
{
    if (i < 0 || i >= m_matches.size())
        return;
    QRectF r = rectForMatch(m_matches.at(i));
    int    y = int(r.center().y());
    m_vbar->setValue(qBound(0, y - height() / 3, m_vbar->maximum()));
}

void LiteHtmlView::selectAll()
{
    if (!m_doc)
        return;
    m_selAnchor = QPointF(0, 0);
    m_selCurrent = QPointF(m_doc->width(), m_doc->height());
    m_hasSelection = true;
    m_selecting = false;
    update();
}

void LiteHtmlView::clearSelection()
{
    m_selecting = false;
    m_hasSelection = false;
    m_selAnchor = QPointF();
    m_selCurrent = QPointF();
    update();
}

QRectF LiteHtmlView::selectionRect() const
{
    QRectF r(m_selAnchor, m_selCurrent);
    return r.normalized();
}

int LiteHtmlView::lineForY(qreal y) const
{
    if (m_lineYs.isEmpty())
        return -1;
    if (y <= m_lineYs.first())
        return m_lineYs.first();
    if (y >= m_lineYs.last())
        return m_lineYs.last();
    int lo = 0, hi = m_lineYs.size() - 1;
    while (lo < hi)
    {
        int mid = (lo + hi + 1) / 2;
        if (m_lineYs[mid] <= y)
            lo = mid;
        else
            hi = mid - 1;
    }
    return m_lineYs[lo];
}

bool LiteHtmlView::isFragmentSelected(const TextFragment &f) const
{
    if (!m_hasSelection)
        return false;
    int fline = int(f.rect.y());
    int aline = lineForY(m_selAnchor.y());
    int cline = lineForY(m_selCurrent.y());
    if (aline < 0 || cline < 0)
        return false;
    if (aline == cline)
    {
        qreal lo = qMin(m_selAnchor.x(), m_selCurrent.x());
        qreal hi = qMax(m_selAnchor.x(), m_selCurrent.x());
        return fline == aline && f.rect.right() > lo && f.rect.left() < hi;
    }
    bool  down      = cline > aline;
    int   startLine = down ? aline : cline;
    int   endLine   = down ? cline : aline;
    qreal startX    = down ? m_selAnchor.x() : m_selCurrent.x();
    qreal endX      = down ? m_selCurrent.x() : m_selAnchor.x();
    if (fline > startLine && fline < endLine)
        return true;
    if (fline == startLine)
        return f.rect.right() > startX;
    if (fline == endLine)
        return f.rect.left() < endX;
    return false;
}

void LiteHtmlView::updateLineTable()
{
    m_lineYs.clear();
    for (const TextFragment &f : m_container.fragments())
        m_lineYs.append(int(f.rect.y()));
    std::sort(m_lineYs.begin(), m_lineYs.end());
    m_lineYs.erase(std::unique(m_lineYs.begin(), m_lineYs.end()), m_lineYs.end());
}

QString LiteHtmlView::selectedText() const
{
    const auto &frags = m_container.fragments();
    QString     out;
    int         lastLine = std::numeric_limits<int>::min();
    for (const TextFragment &f : frags)
    {
        if (!isFragmentSelected(f))
            continue;
        int fline = int(f.rect.y());
        if (lastLine != std::numeric_limits<int>::min() && fline != lastLine)
            out += '\n';
        out += f.text;
        lastLine = fline;
    }
    return out.trimmed();
}
