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

#include "litehtmlcontainer.h"
#include <QPainter>
#include <QFontMetrics>
#include <QFontDatabase>
#include <QImageReader>
#include <QFile>
#include <QUrl>
#include <QDir>
#include <QLinearGradient>
#include <QRadialGradient>
#include <QConicalGradient>
#include <QDebug>

using namespace litehtml;

LiteHtmlContainer::~LiteHtmlContainer()
{
    for (auto &kv : m_fonts)
        delete kv.second;
}

static QColor toQColor(const web_color &c)
{
    return QColor(int(c.red), int(c.green), int(c.blue), int(c.alpha));
}

static QRect toQRect(const position &p)
{
    return QRect(int(p.x), int(p.y), int(p.width), int(p.height));
}

uint_ptr LiteHtmlContainer::create_font(const font_description &descr, const document *, font_metrics *fm)
{
    auto *fd = new LiteHtmlFont;
    // Resolve a possibly comma-separated CSS font-family list, picking the
    // first installed family; map generic names (monospace/serif/sans-serif).
    QString chosen;
    const QStringList families = QString::fromStdString(descr.family).split(',', Qt::SkipEmptyParts);
    const QStringList installed = QFontDatabase::families();
    for (const QString &f : families)
    {
        QString t = f.trimmed();
        if (installed.contains(t))
        {
            chosen = t;
            break;
        }
    }
    if (chosen.isEmpty())
    {
        QString lower = QString::fromStdString(descr.family).toLower();
        if (lower.contains("mono"))
            chosen = QFontDatabase::systemFont(QFontDatabase::FixedFont).family();
        else
            chosen = QFontDatabase::systemFont(QFontDatabase::GeneralFont).family();
    }
    fd->font.setFamily(chosen);
    fd->font.setPixelSize(int(descr.size));
    if (descr.style == font_style_italic)
        fd->font.setItalic(true);
    int weight = descr.weight == 0 ? 400 : descr.weight;
    fd->font.setWeight(QFont::Weight(weight));
    fd->font.setUnderline(descr.decoration_line & text_decoration_line_underline);
    fd->font.setStrikeOut(descr.decoration_line & text_decoration_line_line_through);

    QFontMetrics fmtr(fd->font);
    fd->ascent  = fmtr.ascent();
    fd->descent = fmtr.descent();
    fd->height  = fmtr.height();
    fd->xHeight = fmtr.xHeight();
    fd->chWidth = fmtr.horizontalAdvance(QStringLiteral("0"));

    if (fm)
    {
        fm->font_size = int(descr.size);
        fm->height    = fd->height;
        fm->ascent    = fd->ascent;
        fm->descent   = fd->descent;
        fm->x_height  = fd->xHeight;
        fm->ch_width  = fd->chWidth;
        fm->draw_spaces = true;
    }
    litehtml::uint_ptr h = reinterpret_cast<litehtml::uint_ptr>(fd);
    m_fonts[h] = fd;
    return h;
}

void LiteHtmlContainer::delete_font(uint_ptr hFont)
{
    auto it = m_fonts.find(hFont);
    if (it != m_fonts.end())
    {
        delete it->second;
        m_fonts.erase(it);
    }
}

pixel_t LiteHtmlContainer::text_width(const char *text, uint_ptr hFont)
{
    auto it = m_fonts.find(hFont);
    if (it == m_fonts.end())
        return 0;
    return QFontMetrics(it->second->font).horizontalAdvance(QString::fromUtf8(text));
}

void LiteHtmlContainer::draw_text(uint_ptr hdc, const char *text, uint_ptr hFont, web_color color, const position &pos)
{
    Q_UNUSED(hdc);
    auto it = m_fonts.find(hFont);
    if (it == m_fonts.end())
        return;
    if (m_recordFragments)
    {
        QString str = QString::fromUtf8(text);
        TextFragment f;
        f.rect = QRectF(pos.x, pos.y, QFontMetrics(it->second->font).horizontalAdvance(str), it->second->height);
        f.text = str;
        f.metrics = QFontMetrics(it->second->font);
        m_fragments.append(f);
    }
    if (!m_painter)
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setFont(it->second->font);
    p.setPen(toQColor(color));
    QString str = QString::fromUtf8(text);
    // pos is the text box; litehtml places the baseline at pos.y + ascent.
    p.drawText(QPointF(pos.x, pos.y + it->second->ascent), str);
    p.restore();
}

pixel_t LiteHtmlContainer::pt_to_px(float pt) const
{
    return pt * 96.0f / 72.0f;
}
pixel_t LiteHtmlContainer::get_default_font_size() const
{
    return m_defaultFontSize;
}
const char *LiteHtmlContainer::get_default_font_name() const
{
    return "sans-serif";
}

void LiteHtmlContainer::draw_list_marker(uint_ptr hdc, const list_marker &marker)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    QPainter &p = *m_painter;
    if (!marker.image.empty())
    {
        QString path = resolvePath(marker.image.c_str(), marker.baseurl);
        auto it = m_images.find(path.toStdString());
        if (it != m_images.end())
        {
            QRect r = toQRect(marker.pos);
            p.drawImage(r, it->second);
            return;
        }
    }
    QColor c = toQColor(marker.color);
    QRect  r = toQRect(marker.pos);
    QPen   oldPen = p.pen();
    QBrush oldBr  = p.brush();
    switch (marker.marker_type)
    {
    case list_style_type_circle:
        p.setPen(QPen(c, 1));
        p.setBrush(Qt::NoBrush);
        p.drawEllipse(r);
        break;
    case list_style_type_square:
        p.fillRect(r, c);
        break;
    case list_style_type_disc:
    default:
        p.setBrush(c);
        p.setPen(Qt::NoPen);
        p.drawEllipse(r);
        break;
    }
    p.setPen(oldPen);
    p.setBrush(oldBr);
}

QString LiteHtmlContainer::resolvePath(const char *src, const char *baseurl) const
{
    QString s = QString::fromUtf8(src);
    if (s.startsWith("data:"))
        return s;
    QString base = m_baseDir;
    if (baseurl && *baseurl)
    {
        QUrl bu = QUrl(QString::fromUtf8(baseurl));
        if (bu.isLocalFile())
            base = bu.adjusted(QUrl::RemoveFilename).toLocalFile();
    }
    return QDir(base).filePath(s);
}

void LiteHtmlContainer::load_image(const char *src, const char *baseurl, bool /*redraw_on_ready*/)
{
    QString path = resolvePath(src, baseurl);
    if (path.startsWith("data:"))
        return;
    if (m_images.find(path.toStdString()) != m_images.end())
        return;
    QImage img(path);
    if (img.isNull())
        img = QImageReader(path).read();
    if (!img.isNull())
        m_images[path.toStdString()] = img;
}

void LiteHtmlContainer::get_image_size(const char *src, const char *baseurl, size &sz)
{
    QString path = resolvePath(src, baseurl);
    auto    it   = m_images.find(path.toStdString());
    if (it != m_images.end())
    {
        sz.width  = it->second.width();
        sz.height = it->second.height();
        return;
    }
    QImage img(path);
    if (!img.isNull())
    {
        m_images[path.toStdString()] = img;
        sz.width  = img.width();
        sz.height = img.height();
        return;
    }
    sz.width = sz.height = 0;
}

void LiteHtmlContainer::draw_image(uint_ptr hdc, const background_layer &bg, const std::string &url,
                             const std::string &base_url)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    QString path = resolvePath(url.c_str(), base_url.c_str());
    auto    it   = m_images.find(path.toStdString());
    if (it == m_images.end() || it->second.isNull())
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setClipRect(toQRect(bg.clip_box));
    QImage img = it->second;
    QRect  target(toQRect(bg.origin_box));
    if (bg.repeat == background_repeat_no_repeat)
    {
        p.drawImage(target, img);
    }
    else
    {
        // simple tiling
        int x0 = bg.clip_box.x;
        if (bg.repeat != background_repeat_repeat_x && bg.repeat != background_repeat_repeat)
            x0 = target.x();
        int y0 = bg.clip_box.y;
        if (bg.repeat != background_repeat_repeat_y && bg.repeat != background_repeat_repeat)
            y0 = target.y();
        int right  = bg.clip_box.x + bg.clip_box.width;
        int bottom = bg.clip_box.y + bg.clip_box.height;
        for (int y = y0; y < bottom; y += target.height())
            for (int x = x0; x < right; x += target.width())
                p.drawImage(QRect(x, y, target.width(), target.height()), img);
    }
    p.restore();
}

void LiteHtmlContainer::draw_solid_fill(uint_ptr hdc, const background_layer &layer, const web_color &color)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    m_painter->fillRect(toQRect(layer.border_box), toQColor(color));
}

void LiteHtmlContainer::draw_linear_gradient(uint_ptr hdc, const background_layer &layer,
                                       const background_layer::linear_gradient &gradient)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setClipRect(toQRect(layer.clip_box));
    QLinearGradient g(gradient.start.x, gradient.start.y, gradient.end.x, gradient.end.y);
    for (const auto &cp : gradient.color_points)
        g.setColorAt(cp.offset, toQColor(cp.color));
    p.fillRect(toQRect(layer.origin_box), g);
    p.restore();
}

void LiteHtmlContainer::draw_radial_gradient(uint_ptr hdc, const background_layer &layer,
                                       const background_layer::radial_gradient &gradient)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setClipRect(toQRect(layer.clip_box));
    QRadialGradient g(gradient.position.x, gradient.position.y, gradient.radius.x);
    for (const auto &cp : gradient.color_points)
        g.setColorAt(cp.offset, toQColor(cp.color));
    p.fillRect(toQRect(layer.origin_box), g);
    p.restore();
}

void LiteHtmlContainer::draw_conic_gradient(uint_ptr hdc, const background_layer &layer,
                                      const background_layer::conic_gradient &gradient)
{
    Q_UNUSED(hdc);
    if (!m_painter)
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setClipRect(toQRect(layer.clip_box));
    QConicalGradient g(gradient.position.x, gradient.position.y, gradient.angle);
    for (const auto &cp : gradient.color_points)
        g.setColorAt(cp.offset, toQColor(cp.color));
    p.fillRect(toQRect(layer.origin_box), g);
    p.restore();
}

void LiteHtmlContainer::draw_borders(uint_ptr hdc, const borders &borders, const position &pos, bool root)
{
    Q_UNUSED(hdc);
    Q_UNUSED(root);
    if (!m_painter || !borders.is_visible())
        return;
    QPainter &p = *m_painter;
    p.save();
    p.setRenderHint(QPainter::Antialiasing, false);
    float W = pos.width, H = pos.height;
    float lw = borders.left.width, rw = borders.right.width;
    float tw = borders.top.width, bw = borders.bottom.width;

    QPolygonF topPoly, rightPoly, bottomPoly, leftPoly;
    topPoly << QPointF(0, 0) << QPointF(W, 0) << QPointF(W - rw, tw) << QPointF(lw, tw);
    rightPoly << QPointF(W, 0) << QPointF(W, H) << QPointF(W - rw, H - bw) << QPointF(W - rw, tw);
    bottomPoly << QPointF(W, H) << QPointF(0, H) << QPointF(lw, H - bw) << QPointF(W - rw, H - bw);
    leftPoly << QPointF(0, 0) << QPointF(lw, tw) << QPointF(lw, H - bw) << QPointF(0, H);

    p.translate(pos.x, pos.y);
    p.setPen(Qt::NoPen);
    if (tw > 0)
    {
        p.setBrush(toQColor(borders.top.color));
        p.drawPolygon(topPoly);
    }
    if (rw > 0)
    {
        p.setBrush(toQColor(borders.right.color));
        p.drawPolygon(rightPoly);
    }
    if (bw > 0)
    {
        p.setBrush(toQColor(borders.bottom.color));
        p.drawPolygon(bottomPoly);
    }
    if (lw > 0)
    {
        p.setBrush(toQColor(borders.left.color));
        p.drawPolygon(leftPoly);
    }
    p.restore();
}

void LiteHtmlContainer::set_base_url(const char *base_url)
{
    Q_UNUSED(base_url);
}

void LiteHtmlContainer::on_anchor_click(const char *url, const element::ptr &)
{
    if (linkClicked)
        linkClicked(QUrl(QString::fromUtf8(url)));
}

void LiteHtmlContainer::set_cursor(const char *cursor)
{
    Q_UNUSED(cursor);
}

void LiteHtmlContainer::transform_text(std::string &text, text_transform tt)
{
    QString s = QString::fromStdString(text);
    switch (tt)
    {
    case text_transform_uppercase:
        s = s.toUpper();
        break;
    case text_transform_lowercase:
        s = s.toLower();
        break;
    case text_transform_capitalize:
        s = s.toLower();
        QStringList words = s.split(' ', Qt::SkipEmptyParts);
        for (QString &w : words)
            w[0] = w[0].toUpper();
        s = words.join(' ');
        break;
    }
    text = s.toStdString();
}

void LiteHtmlContainer::import_css(std::string &text, const std::string &url, std::string &baseurl)
{
    Q_UNUSED(baseurl);
    QString path = resolvePath(url.c_str(), url.c_str());
    QFile   f(path);
    if (f.open(QIODevice::ReadOnly))
        text = QString::fromUtf8(f.readAll()).toStdString();
}

void LiteHtmlContainer::set_clip(const position &pos, const border_radiuses &bdr_radius)
{
    Q_UNUSED(bdr_radius);
    if (m_painter)
    {
        m_painter->save();
        m_painter->setClipRect(toQRect(pos), Qt::IntersectClip);
    }
}

void LiteHtmlContainer::del_clip()
{
    if (m_painter)
        m_painter->restore();
}

void LiteHtmlContainer::get_viewport(position &viewport) const
{
    viewport = position(0, 0, m_viewW, m_viewH);
}

void LiteHtmlContainer::get_media_features(media_features &media) const
{
    media.type        = media_type_screen;
    media.width       = m_viewW;
    media.height      = m_viewH;
    media.color       = 8;
    media.monochrome  = 0;
    media.color_index = 0;
    media.resolution  = 96;
}
