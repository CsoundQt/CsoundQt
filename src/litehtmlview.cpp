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
#include <QStyle>
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
#include <QCryptographicHash>
#include <QMap>
#include <QDebug>

#include <litehtml.h>
#include <litehtml/render_item.h>
#include <algorithm>
#include <limits>
#include <functional>
#include <memory>
using namespace Qt::StringLiterals;

using namespace litehtml;

// Ctrl+wheel zoom shows the new scale immediately by magnifying the existing
// rendering; the document is reflowed at the new font size once the gesture
// stops. Keep this short: the deferred wait is pure latency for the user.
static constexpr int ZOOM_COMMIT_DELAY_MS = 60;

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
    QRegularExpression labelRe(uR"(<label[^>]*>([\s\S]*?)</label>)"_s);
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
            // matchDiv returns one past the tabbed-block's own closing </div>;
            // the content must exclude that closing tag, otherwise the emitted
            // HTML is unbalanced and the following tab escapes its container.
            int cend = block.lastIndexOf("</div>", bend - 1);
            if (cend == -1 || cend < bstart)
                cend = bend;
            contents << block.mid(bstart, cend - bstart);
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
    // The article is rendered standalone, without the original <html>/<body>
    // ancestors. mkdocs-material indents lists and blockquotes only via
    // [dir=ltr]-scoped selectors (e.g. "[dir=ltr] .md-typeset ul"), so the
    // wrapper must carry dir="ltr" for nested lists to be indented.
    return QStringLiteral("<div dir=\"ltr\">") + art + QStringLiteral("</div>");
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

// Styling for pages that are not part of the manual (UDO docstrings). The
// manual stylesheets are not available for those pages, so this supplies the
// few rules the generated Markdown HTML relies on.
static const char *const inlineCss = R"(
body {
    color: #202020;
    background-color: #ffffff;
    margin: 16px;
    font-size: 14px;
}
h1, h2, h3, h4, h5, h6 {
    color: #202020;
    margin-top: 0.8em;
    margin-bottom: 0.4em;
}
h1 {
    margin-top: 0;
}
p {
    margin-top: 0.6em;
    margin-bottom: 0.6em;
}
ul {
    margin-top: 0.4em;
    margin-bottom: 0.4em;
    padding-left: 24px;
}
li {
    margin-top: 0.15em;
    margin-bottom: 0.15em;
}
code {
    font-family: monospace;
    background-color: #f1f1f1;
    color: #202020;
}
pre {
    background-color: #f4f4f4;
    padding: 8px;
    margin-top: 0.8em;
    margin-bottom: 0.8em;
}
pre code {
    background-color: transparent;
    padding: 0;
}
)";

// ---------------------------------------------------------------------------

LiteHtmlView::LiteHtmlView(QWidget *parent)
    : QWidget(parent)
{
    setAttribute(Qt::WA_OpaquePaintEvent);
    setMouseTracking(true);
    setFocusPolicy(Qt::StrongFocus);

    m_scrollbarWidth = style()->pixelMetric(QStyle::PM_ScrollBarExtent, nullptr, this);
    if (m_scrollbarWidth <= 0)
        m_scrollbarWidth = 14;

    m_hbar = new QScrollBar(Qt::Horizontal, this);
    m_vbar = new QScrollBar(Qt::Vertical, this);
    m_vbar->setRange(0, 0);
    connect(m_vbar, &QScrollBar::valueChanged, this, [this](int) { update(); });
    connect(m_hbar, &QScrollBar::valueChanged, this, [this](int) { update(); });

    m_flingTimer = new QTimer(this);
    m_flingTimer->setInterval(16);
    connect(m_flingTimer, &QTimer::timeout, this, &LiteHtmlView::onFlingTick);

    // Rebuilding the document at a new zoom is expensive (it re-parses the
    // article and the site stylesheet), so it is done once, shortly after the
    // last zoom request; until then the page is shown magnified.
    m_zoomCommitTimer = new QTimer(this);
    m_zoomCommitTimer->setSingleShot(true);
    m_zoomCommitTimer->setInterval(ZOOM_COMMIT_DELAY_MS);
    connect(m_zoomCommitTimer, &QTimer::timeout, this, &LiteHtmlView::commitZoom);

    // In-panel find box (shown on Ctrl+F / the DockHelp find toggle).
    m_findEdit = new QLineEdit(this);
    m_findEdit->setPlaceholderText(tr("Find (Enter next, Shift+Enter previous, Esc close)"));
    // Keep the box readable regardless of the app's light/dark palette: the
    // rendered document is always light, so the overlay is too.
    m_findEdit->setStyleSheet(
        "QLineEdit { background-color: #ffffff; color: #000000;"
        "  border: 1px solid #888888; border-radius: 3px; padding: 2px 6px;"
        "  selection-background-color: #3399ff; selection-color: #ffffff; }");
    m_findEdit->setVisible(false);
    connect(m_findEdit, &QLineEdit::textChanged, this, [this](const QString &) {
        setFindQuery(m_findEdit->text());
    });
    connect(m_findEdit, &QLineEdit::returnPressed, this, &LiteHtmlView::findNext);
    m_findEdit->installEventFilter(this);

    m_searchPanel = new QWidget(this);
    m_searchPanel->setObjectName("manualSearchPanel");
    m_searchPanel->setVisible(false);
    QVBoxLayout *sl = new QVBoxLayout(m_searchPanel);
    sl->setContentsMargins(0, 0, 0, 0);
    sl->setSpacing(2);
    m_searchEdit = new QLineEdit(m_searchPanel);
    m_searchEdit->setPlaceholderText(tr("Search manual"));
    m_searchEdit->setStyleSheet(
        "QLineEdit { background-color: #ffffff; color: #000000;"
        "  border: 1px solid #888888; border-radius: 3px; padding: 2px 6px;"
        "  selection-background-color: #3399ff; selection-color: #ffffff; }");
    m_searchList = new QListWidget(m_searchPanel);
    m_searchList->setStyleSheet(
        "QListWidget { background-color: #ffffff; color: #000000;"
        "  border: 1px solid #888888; }"
        "QListWidget::item:selected { background-color: #3399ff; color: #ffffff; }");
    sl->addWidget(m_searchEdit);
    sl->addWidget(m_searchList);
    connect(m_searchEdit, &QLineEdit::textChanged, this, [this](const QString &) {
        m_searchPending = m_searchEdit->text();
        // Partial (prefix) matches kick in automatically from 3 characters on.
        m_searchWithPrefix = m_searchPending.trimmed().size() >= 3;
        QTimer::singleShot(0, this, &LiteHtmlView::runManualSearch);
    });
    connect(m_searchEdit, &QLineEdit::returnPressed, this, [this] {
        // Enter opens the currently highlighted entry right away.
        if (m_searchResults.isEmpty())
            return;
        if (m_searchList->currentRow() < 0)
            m_searchList->setCurrentRow(0);
        if (auto *item = m_searchList->currentItem())
            openSearchResult(item);
    });
    connect(m_searchList, &QListWidget::itemActivated, this, &LiteHtmlView::openSearchResult);
    m_searchEdit->installEventFilter(this);
    m_searchList->installEventFilter(this);

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

bool LiteHtmlView::loadHtml(const QString &html)
{
    if (html.isEmpty())
        return false;

    // Give every distinct page its own key. History stores the key, so going
    // back to a docstring still renders that docstring and not a later one.
    const QByteArray digest = QCryptographicHash::hash(
                html.toUtf8(), QCryptographicHash::Sha1).toHex();
    const QString key = u"csoundqt-inline:"_s + QString::fromLatin1(digest);
    m_inlinePages.insert(key, html);
    if (m_currentPath == key)
        return true;
    doLoad(key, QString(), true);
    return true;
}

void LiteHtmlView::clear()
{
    // Drop the rendered document and all state that refers to it (history,
    // selection, search matches) so nothing of the previous manual remains.
    m_doc.reset();
    m_currentPath.clear();
    m_currentHtml.clear();
    m_inlinePages.clear();
    m_history.clear();
    m_historyPos = -1;
    m_selecting = false;
    m_hasSelection = false;
    m_renderedWidth = -1;
    m_matches.clear();
    m_currentMatch = -1;
    m_searchLines.clear();
    m_searchDirty = true;
    m_fragmentsDirty = true;
    m_vbar->setRange(0, 0);
    m_hbar->setRange(0, 0);
    m_vbar->setVisible(false);
    m_hbar->setVisible(false);
    emit historyChanged();
    update();
}

void LiteHtmlView::doLoad(const QString &path, const QString &fragment, bool pushHistory)
{
    m_zoomCommitTimer->stop(); // this load renders the requested zoom
    const auto inlinePage = m_inlinePages.constFind(path);
    const bool isInlinePage = inlinePage != m_inlinePages.constEnd();
    if (isInlinePage)
    {
        m_currentHtml = inlinePage.value();
    }
    else if (m_currentHtml.isEmpty() || m_currentPath != path)
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
    if (isInlinePage)
        m_container.setBaseDir(QString());
    else
        m_container.setBaseDir(QFileInfo(path).absolutePath());
    m_container.setDefaultFontSize(qRound(16.0 * m_zoomFactor));
    m_renderedZoom = m_zoomFactor; // the preview scale is 1 from here on
    std::string css = isInlinePage
            ? std::string(inlineCss)
            : loadStylesheets(findSiteRoot(path));
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

void LiteHtmlView::setZoomFactor(qreal factor, bool immediate)
{
    factor = qBound(0.5, factor, 4.0);
    if (qFuzzyCompare(factor, m_zoomFactor))
        return;

    if (!m_doc)
    {
        // Nothing rendered yet: the next load will use the new factor.
        m_zoomFactor = m_renderedZoom = factor;
        return;
    }

    m_zoomCommitTimer->stop();

    if (immediate)
    {
        // A keyboard zoom is a single, deliberate request, so skip the cheap
        // preview and rebuild the document at once. This re-parses the
        // stylesheet and costs ~100 ms, which is acceptable once per key
        // press but not per wheel notch.
        m_zoomFactor = factor;
        commitZoom();
        return;
    }

    const qreal oldScale = previewScale();
    m_zoomFactor = factor;
    const qreal newScale = previewScale();
    if (qFuzzyCompare(oldScale, newScale))
        return;

    // Show the new zoom right away by scaling what is already drawn (it is
    // cheap), and rebuild the document at the new base font size once the
    // user stops asking for zoom -- that path re-parses the stylesheet and
    // costs ~100 ms, far too much to run per wheel notch.
    const qreal docX = m_hbar->value() / oldScale;
    const qreal docY = m_vbar->value() / oldScale;
    updateScrollBars();
    m_hbar->setValue(qBound(0, qRound(docX * newScale), m_hbar->maximum()));
    m_vbar->setValue(qBound(0, qRound(docY * newScale), m_vbar->maximum()));
    update();
    m_zoomCommitTimer->start();
}

void LiteHtmlView::commitZoom()
{
    if (!m_doc || qFuzzyCompare(m_renderedZoom, m_zoomFactor))
        return;
    // The reflowed document has a different height, so keep the same relative
    // position rather than the same pixel offset.
    const qreal fracV = m_vbar->maximum() > 0 ? qreal(m_vbar->value()) / m_vbar->maximum() : 0.0;
    const qreal fracH = m_hbar->maximum() > 0 ? qreal(m_hbar->value()) / m_hbar->maximum() : 0.0;
    doLoad(m_currentPath, QString(), false); // re-parses at m_zoomFactor
    updateScrollBars(fracV, fracH);
}

void LiteHtmlView::zoomIn()
{
    setZoomFactor(m_zoomFactor + 0.1, true);
}

void LiteHtmlView::zoomOut()
{
    setZoomFactor(m_zoomFactor - 0.1, true);
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
    m_findEdit->blockSignals(true);
    m_findEdit->clear();
    m_findEdit->blockSignals(false);
    m_findQuery.clear();
    m_matches.clear();
    m_currentMatch = -1;
    m_searchDirty = false;
    m_findEdit->setVisible(false);
    // Keep the help panel focused when the find box is dismissed.
    setFocus(Qt::OtherFocusReason);
    update();
}

void LiteHtmlView::showFindBar()
{
    m_findEdit->setVisible(true);
    m_findEdit->raise();
    m_findEdit->setFocus();
    m_findEdit->selectAll();
}

void LiteHtmlView::hideFindBar()
{
    m_findEdit->setVisible(false);
    setFocus(Qt::OtherFocusReason);
}

void LiteHtmlView::toggleFindBar(bool show)
{
    if (show)
        showFindBar();
    else
        clearFind();
}

void LiteHtmlView::addSearchRoot(const QString &rootPath, const QString &label)
{
    m_searchManager.addRoot(rootPath, label);
}

void LiteHtmlView::removeSearchRoot(const QString &rootPath)
{
    m_searchManager.removeRoot(rootPath);
    // Stored results refer to the old set of roots by index, so drop them.
    m_searchResults.clear();
    if (m_searchList)
        m_searchList->clear();
    // Rebuild the index for the remaining roots on the next search.
    m_searchLoaded = false;
}

void LiteHtmlView::showSearchPanel()
{
    // Start from a clean slate every time the panel is opened.
    m_searchPending.clear();
    m_searchWithPrefix = false;
    m_searchResults.clear();
    m_searchList->clear();
    m_searchEdit->clear();
    // Load the search index before the user starts typing, so the first
    // keystrokes are not swallowed by the (lengthy) indexing step.
    if (!m_searchLoaded)
    {
        m_searchList->addItem(tr("Indexing manuals… (first search only)"));
        m_searchPanel->setVisible(true);
        m_searchPanel->raise();
        QApplication::processEvents();
        m_searchLoaded = m_searchManager.ensureLoaded();
        m_searchList->clear();
        if (!m_searchLoaded)
            m_searchList->addItem(tr("No search index found."));
    }
    else
    {
        m_searchPanel->setVisible(true);
        m_searchPanel->raise();
    }
    m_searchEdit->setFocus();
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
    updateScrollBars();
    update();
}

// The scrollbars work in view (scaled) pixels, i.e. document size x preview
// scale. When the scale changes but the document does not, pass the fraction
// of the scrollable range to keep, so the page does not jump.
void LiteHtmlView::updateScrollBars(qreal keepFractionV, qreal keepFractionH)
{
    const qreal s = previewScale();
    const int docH = m_doc ? int(m_doc->height()) : 0;
    const int docW = m_doc ? int(m_doc->width()) : 0;
    int oldV = m_vbar->value();
    int oldH = m_hbar->value();
    // The magnified page is genuinely taller, so the vertical range scales...
    m_vbar->setRange(0, qMax(0, int(docH * s) - height()));
    // ...but the page is laid out to fit the viewport horizontally, so during a
    // preview the range is capped at the (scaled) real overflow: magnifying a
    // page that fits must not make a horizontal scrollbar flash in and out
    // while the wheel is turning.
    const int hOverflow = qMin(int(docW * s) - width(), qRound((docW - width()) * s));
    m_hbar->setRange(0, qMax(0, hOverflow));
    if (keepFractionV >= 0.0 && m_vbar->maximum() > 0)
        oldV = qRound(keepFractionV * m_vbar->maximum());
    if (keepFractionH >= 0.0 && m_hbar->maximum() > 0)
        oldH = qRound(keepFractionH * m_hbar->maximum());
    m_vbar->setValue(oldV);
    m_hbar->setValue(oldH);
    m_vbar->setPageStep(height());
    m_hbar->setPageStep(width());
    m_vbar->resize(m_scrollbarWidth, height());
    m_hbar->resize(qMax(0, width() - m_scrollbarWidth), m_scrollbarWidth);
    m_hbar->move(0, height() - m_scrollbarWidth);
    m_vbar->move(width() - m_scrollbarWidth, 0);
    m_vbar->setVisible(m_vbar->maximum() > 0);
    m_hbar->setVisible(m_hbar->maximum() > 0);
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
    // The scrollbars are in view pixels; while a zoom is only previewed the
    // document is magnified by previewScale() instead of re-laid out.
    const qreal s = previewScale();
    p.scale(s, s);
    p.translate(-m_hbar->value() / s, -m_vbar->value() / s);
    // Visible rectangle in document coordinates; lets litehtml cull
    // off-screen elements instead of redrawing the whole page each frame.
    position clip = {pixel_t(qFloor(qreal(m_hbar->value()) / s)),
                     pixel_t(qFloor(qreal(m_vbar->value()) / s)),
                     pixel_t(qCeil(qreal(width()) / s) + 1),
                     pixel_t(qCeil(qreal(height()) / s) + 1)};
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
        const qreal s = previewScale();
        QPointF pos((e->pos().x() + m_hbar->value()) / s, (e->pos().y() + m_vbar->value()) / s);
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
        const qreal s = previewScale();
        m_doc->on_lbutton_up(int((e->pos().x() + m_hbar->value()) / s),
                             int((e->pos().y() + m_vbar->value()) / s),
                             e->pos().x(), e->pos().y(),
                             [this](const position &b) { update(); });
    }
}

void LiteHtmlView::mouseMoveEvent(QMouseEvent *e)
{
    const qreal s = previewScale();
    if (m_selecting && m_doc)
    {
        m_selCurrent = QPointF((e->pos().x() + m_hbar->value()) / s,
                               (e->pos().y() + m_vbar->value()) / s);
        m_hasSelection = m_selAnchor != m_selCurrent;
        update();
        return;
    }
    if (m_doc)
    {
        bool changed = m_doc->on_mouse_over(int((e->pos().x() + m_hbar->value()) / s),
                                            int((e->pos().y() + m_vbar->value()) / s),
                                            e->pos().x(), e->pos().y(),
                                            [this](const position &b) { update(); });
        if (changed)
            update();
    }
}

// Ctrl+<plus>/<minus> zoom the help page. Ctrl+= (the unshifted form of "+")
// and Ctrl+_ (Shift+minus) are accepted as aliases, and "=" / "+" and "-" on
// the numeric keypad produce the same key values, so they all work too.
// Returns +1 for zoom in, -1 for zoom out, 0 when the event is not a zoom key.
static int zoomKeyDirection(const QKeyEvent *e)
{
    if (!(e->modifiers() & Qt::ControlModifier) || (e->modifiers() & Qt::AltModifier))
        return 0;
    switch (e->key())
    {
    case Qt::Key_Plus:
    case Qt::Key_Equal:
        return +1;
    case Qt::Key_Minus:
    case Qt::Key_Underscore:
        return -1;
    default:
        return 0;
    }
}

bool LiteHtmlView::event(QEvent *e)
{
    // Claim Alt+Left/Right from the application-wide shortcuts (e.g. the
    // editor's "go back" and the tab switcher) while this view has focus.
    if (e->type() == QEvent::ShortcutOverride)
    {
        auto *ke = static_cast<QKeyEvent *>(e);
        if ((ke->modifiers() & Qt::AltModifier)
            && (ke->key() == Qt::Key_Left || ke->key() == Qt::Key_Right))
        {
            e->accept();
            return true;
        }
        // Claim Ctrl+<plus>/<minus> from the editor's font-size shortcuts so
        // that, with the help panel focused, they zoom the page instead of
        // the editor. Accepting the override makes Qt deliver a plain key
        // press to keyPressEvent() below instead of triggering the action.
        if (zoomKeyDirection(ke) != 0)
        {
            e->accept();
            return true;
        }
    }
    return QWidget::event(e);
}

void LiteHtmlView::keyPressEvent(QKeyEvent *e)
{
    if (int dir = zoomKeyDirection(e))
    {
        if (dir > 0)
            zoomIn();
        else
            zoomOut();
        return;
    }
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
        showFindBar();
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
    // Keyboard scrolling.
    if (e->key() == Qt::Key_PageDown)
    {
        m_vbar->setValue(m_vbar->value() + m_vbar->pageStep());
        return;
    }
    if (e->key() == Qt::Key_PageUp)
    {
        m_vbar->setValue(m_vbar->value() - m_vbar->pageStep());
        return;
    }
    if (e->key() == Qt::Key_Down)
    {
        m_vbar->setValue(m_vbar->value() + keyboardLineStep());
        return;
    }
    if (e->key() == Qt::Key_Up)
    {
        m_vbar->setValue(m_vbar->value() - keyboardLineStep());
        return;
    }
    if (e->key() == Qt::Key_Home)
    {
        m_vbar->setValue(0);
        return;
    }
    if (e->key() == Qt::Key_End)
    {
        m_vbar->setValue(m_vbar->maximum());
        return;
    }
    // Alt+Left/Right navigate the help history (Alt+Right also reaches here
    // only if the Shift state of Right is not otherwise consumed).
    if (e->key() == Qt::Key_Left && (e->modifiers() & Qt::AltModifier))
    {
        emit browseBackRequested();
        return;
    }
    if (e->key() == Qt::Key_Right && (e->modifiers() & Qt::AltModifier))
    {
        emit browseForwardRequested();
        return;
    }
    QWidget::keyPressEvent(e);
}

void LiteHtmlView::wheelEvent(QWheelEvent *e)
{
    // Trackpads report the end of a gesture explicitly. If a zoom is still
    // waiting for the reflow timer, rebuild the page now instead of adding
    // the timer delay after the user has already stopped.
    if (e->phase() == Qt::ScrollEnd)
        commitZoom();

    // Ctrl+wheel zooms the page instead of scrolling it.
    if (e->modifiers() & Qt::ControlModifier)
    {
        // Accumulate notches so trackpad pixel deltas zoom smoothly while a
        // mouse wheel still steps once per 120-unit notch.
        const int angle = e->angleDelta().y();
        m_zoomRemainder += (angle != 0) ? angle / 120.0 : e->pixelDelta().y() / 50.0;
        while (m_zoomRemainder >= 1.0)
        {
            setZoomFactor(m_zoomFactor + 0.1);
            m_zoomRemainder -= 1.0;
        }
        while (m_zoomRemainder <= -1.0)
        {
            setZoomFactor(m_zoomFactor - 0.1);
            m_zoomRemainder += 1.0;
        }
        m_wheelRemainder = 0;
        m_scrollVelocity = 0;
        m_flingTimer->stop();
        e->accept();
        return;
    }
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

bool LiteHtmlView::eventFilter(QObject *o, QEvent *ev)
{
    if (o == m_findEdit)
    {
        if (ev->type() == QEvent::KeyPress)
        {
            auto *ke = static_cast<QKeyEvent *>(ev);
            if (ke->key() == Qt::Key_Return || ke->key() == Qt::Key_Enter)
            {
                if (ke->modifiers() & Qt::ShiftModifier)
                    findPrevious();
                else
                    findNext();
                return true;
            }
            if (ke->key() == Qt::Key_Up)
            {
                findPrevious();
                return true;
            }
            if (ke->key() == Qt::Key_Down)
            {
                findNext();
                return true;
            }
            if (ke->key() == Qt::Key_Escape)
            {
                clearFind();
                return true;
            }
        }
    }
    if (o == m_searchEdit)
    {
        if (ev->type() == QEvent::KeyPress)
        {
            auto *ke = static_cast<QKeyEvent *>(ev);
            if (ke->key() == Qt::Key_Up)
            {
                moveSearchSelection(-1);
                return true;
            }
            if (ke->key() == Qt::Key_Down)
            {
                moveSearchSelection(1);
                return true;
            }
        }
    }
    if (o == m_searchList)
    {
        if (ev->type() == QEvent::KeyPress)
        {
            auto *ke = static_cast<QKeyEvent *>(ev);
            if (ke->key() == Qt::Key_Return || ke->key() == Qt::Key_Enter)
            {
                if (auto *item = m_searchList->currentItem())
                    openSearchResult(item);
                return true;
            }
            if (ke->key() == Qt::Key_Escape)
            {
                m_searchEdit->setFocus();
                return true;
            }
        }
    }
    return QWidget::eventFilter(o, ev);
}

void LiteHtmlView::moveSearchSelection(int delta)
{
    if (m_searchList->count() == 0)
        return;
    int row = m_searchList->currentRow();
    int next = qBound(0, row + delta, m_searchList->count() - 1);
    m_searchList->setCurrentRow(next);
}

void LiteHtmlView::resizeEvent(QResizeEvent *)
{
    relayout();
    m_hbar->resize(qMax(0, width() - m_scrollbarWidth), m_scrollbarWidth);
    m_hbar->move(0, height() - m_scrollbarWidth);
    m_vbar->move(width() - m_scrollbarWidth, 0);
    m_findEdit->resize(300, m_findEdit->height());
    m_findEdit->move(width() - 300 - 20, 10);
    // Same vertical position as the in-document find box.
    m_searchPanel->setGeometry(width() - 440 - 20, 10, 440, 360);
    m_searchPanel->raise();
}

void LiteHtmlView::runManualSearch()
{
    QString q = m_searchPending.trimmed();
    int previousRow = m_searchList->currentRow();
    m_searchList->clear();
    m_searchResults.clear();
    if (q.isEmpty())
        return;
    if (!m_searchLoaded)
        m_searchLoaded = m_searchManager.ensureLoaded(); // normally preloaded by showSearchPanel()
    if (!m_searchLoaded)
    {
        new QListWidgetItem(tr("No search index found."), m_searchList);
        return;
    }
    m_searchResults = m_searchManager.search(q, m_searchWithPrefix);
    const bool multiRoot = m_searchManager.roots().size() > 1;
    for (int i = 0; i < m_searchResults.size(); ++i)
    {
        const SearchResult &r     = m_searchResults.at(i);
        const QString       label = m_searchManager.roots().at(r.rootIndex).label;
        // Each option shows the matched section and the page it comes from;
        // roots with an empty label (the Csound manual) get no source tag.
        QString text = r.title;
        if (r.pageTitle != r.title)
            text += QString("   — %1").arg(r.pageTitle);
        if (!label.isEmpty() && multiRoot)
            text += QString("   [%1]").arg(label);
        auto *item = new QListWidgetItem(text, m_searchList);
        item->setToolTip(r.snippet.isEmpty() ? r.location : r.snippet + "\n→ " + r.location);
        item->setData(Qt::UserRole, i);
    }
    if (m_searchResults.isEmpty())
        new QListWidgetItem(tr("No results."), m_searchList);
    // Select the first result by default so Enter opens it; keep the current
    // row if it is still valid (arrow-key navigation triggers a re-search).
    m_searchList->setCurrentRow((previousRow >= 0 && previousRow < m_searchResults.size()) ? previousRow : 0);
}

void LiteHtmlView::openSearchResult(QListWidgetItem *item)
{
    if (!item)
        return;
    QVariant data = item->data(Qt::UserRole); // status rows have no result data
    if (!data.isValid())
        return;
    int idx = data.toInt();
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
    setFocus(); // return focus to the help viewer
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
        // p is in document coordinates; the scrollbar counts view pixels.
        const qreal s = previewScale();
        m_vbar->setValue(qBound(0, qRound(float(p.y) * s) - 20, m_vbar->maximum()));
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
        int from = 0;
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
            m_matches.append({li, from, from + static_cast<int>(m_findQuery.size())});
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
    // r is in document coordinates; the scrollbar counts view pixels.
    int    y = qRound(r.center().y() * previewScale());
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

int LiteHtmlView::keyboardLineStep() const
{
    // A line roughly matches the current default font size (scaled by zoom).
    return qMax(16, int(m_container.get_default_font_size()) * 15 / 10);
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
