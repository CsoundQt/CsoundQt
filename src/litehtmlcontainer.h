
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

#ifndef LITEHTMLCONTAINER_H
#define LITEHTMLCONTAINER_H

#include <QColor>
#include <QFont>
#include <QFontMetrics>
#include <QImage>
#include <QString>
#include <QUrl>
#include <QVector>
#include <QRectF>
#include <map>
#include <memory>
#include <functional>
#include <litehtml.h>

class QPainter;

struct LiteHtmlFont
{
    QFont font;
    int   ascent  = 0;
    int   descent = 0;
    int   height  = 0;
    int   xHeight = 0;
    int   chWidth = 0;
};

// One text run drawn by the container, used for selection and in-page search.
struct TextFragment
{
    TextFragment() : metrics(QFont()) {}
    QRectF       rect;
    QString      text;
    QFontMetrics metrics;
};

// litehtml document_container that draws into a QImage via QPainter.
class LiteHtmlContainer : public litehtml::document_container
{
public:
    LiteHtmlContainer() = default;
    ~LiteHtmlContainer() override;

    // The widget sets the painter before doc->draw() and clears it after.
    void setPainter(QPainter *p) { m_painter = p; }
    void setViewport(int w, int h)
    {
        m_viewW = w;
        m_viewH = h;
    }
    void setBaseDir(const QString &dir) { m_baseDir = dir; }
    int  imageCount() const { return int(m_images.size()); }
    void setDefaultFontSize(int px) { m_defaultFontSize = px; }

    // Text-fragment recording so the widget can implement selection/search.
    void setRecordFragments(bool on) { m_recordFragments = on; }
    void clearFragments() { m_fragments.clear(); }
    const QVector<TextFragment> &fragments() const { return m_fragments; }

    // Called on anchor clicks; the viewer installs a handler.
    std::function<void(const QUrl &)> linkClicked;

    // litehtml::document_container
    litehtml::uint_ptr create_font(const litehtml::font_description &descr, const litehtml::document *,
                                   litehtml::font_metrics *fm) override;
    void               delete_font(litehtml::uint_ptr hFont) override;
    litehtml::pixel_t  text_width(const char *text, litehtml::uint_ptr hFont) override;
    void draw_text(litehtml::uint_ptr hdc, const char *text, litehtml::uint_ptr hFont, litehtml::web_color color,
                   const litehtml::position &pos) override;
    litehtml::pixel_t pt_to_px(float pt) const override;
    litehtml::pixel_t get_default_font_size() const override;
    const char *      get_default_font_name() const override;
    void              draw_list_marker(litehtml::uint_ptr hdc, const litehtml::list_marker &marker) override;
    void              load_image(const char *src, const char *baseurl, bool redraw_on_ready) override;
    void              get_image_size(const char *src, const char *baseurl, litehtml::size &sz) override;
    void draw_image(litehtml::uint_ptr hdc, const litehtml::background_layer &layer, const std::string &url,
                    const std::string &base_url) override;
    void draw_solid_fill(litehtml::uint_ptr hdc, const litehtml::background_layer &layer,
                         const litehtml::web_color &color) override;
    void draw_linear_gradient(litehtml::uint_ptr hdc, const litehtml::background_layer &layer,
                              const litehtml::background_layer::linear_gradient &gradient) override;
    void draw_radial_gradient(litehtml::uint_ptr hdc, const litehtml::background_layer &layer,
                              const litehtml::background_layer::radial_gradient &gradient) override;
    void draw_conic_gradient(litehtml::uint_ptr hdc, const litehtml::background_layer &layer,
                             const litehtml::background_layer::conic_gradient &gradient) override;
    void draw_borders(litehtml::uint_ptr hdc, const litehtml::borders &borders, const litehtml::position &draw_pos,
                      bool root) override;
    void set_caption(const char *) override {}
    void set_base_url(const char *base_url) override;
    void link(const std::shared_ptr<litehtml::document> &, const litehtml::element::ptr &) override {}
    void on_anchor_click(const char *url, const litehtml::element::ptr &el) override;
    bool on_element_click(const litehtml::element::ptr &) override { return false; }
    void on_mouse_event(const litehtml::element::ptr &, litehtml::mouse_event) override {}
    void set_cursor(const char *cursor) override;
    void transform_text(std::string &text, litehtml::text_transform tt) override;
    void import_css(std::string &text, const std::string &url, std::string &baseurl) override;
    void set_clip(const litehtml::position &pos, const litehtml::border_radiuses &bdr_radius) override;
    void del_clip() override;
    void get_viewport(litehtml::position &viewport) const override;
    litehtml::element::ptr create_element(const char *, const litehtml::string_map &,
                                          const std::shared_ptr<litehtml::document> &) override
    {
        return nullptr;
    }
    void get_media_features(litehtml::media_features &media) const override;
    void get_language(std::string &language, std::string &culture) const override
    {
        language = "en";
        culture = "";
    }

private:
    QString              m_baseDir;
    QPainter            *m_painter = nullptr;
    int                  m_viewW   = 1000;
    int                  m_viewH   = 600;
    int                  m_defaultFontSize = 16;
    std::map<litehtml::uint_ptr, LiteHtmlFont *> m_fonts;
    std::map<std::string, QImage>              m_images;
    bool                                    m_recordFragments = false;
    QVector<TextFragment>                   m_fragments;
    QString resolvePath(const char *src, const char *baseurl) const;
};

#endif // LITEHTMLCONTAINER_H
