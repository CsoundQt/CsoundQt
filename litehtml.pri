# qmake integration for the bundled litehtml submodule (and its bundled gumbo parser).
# Included from CsoundQt's src/src.pri. $$PWD here is the project root.

# litehtml compiles against its src/, include/ and include/litehtml/ dirs
# (mirrors the include dirs in litehtml's own CMakeLists.txt).
LITEHTML_INCLUDEPATH = $$PWD/litehtml/src $$PWD/litehtml/include $$PWD/litehtml/include/litehtml \
    $$PWD/litehtml/src/gumbo/include $$PWD/litehtml/src/gumbo/include/gumbo

INCLUDEPATH += $$LITEHTML_INCLUDEPATH

LITEHTML_SOURCES = \
    $$PWD/litehtml/src/background.cpp \
    $$PWD/litehtml/src/codepoint.cpp \
    $$PWD/litehtml/src/css_borders.cpp \
    $$PWD/litehtml/src/css_length.cpp \
    $$PWD/litehtml/src/css_parser.cpp \
    $$PWD/litehtml/src/css_properties.cpp \
    $$PWD/litehtml/src/css_selector.cpp \
    $$PWD/litehtml/src/css_tokenizer.cpp \
    $$PWD/litehtml/src/document_container.cpp \
    $$PWD/litehtml/src/document.cpp \
    $$PWD/litehtml/src/el_anchor.cpp \
    $$PWD/litehtml/src/el_base.cpp \
    $$PWD/litehtml/src/el_before_after.cpp \
    $$PWD/litehtml/src/el_body.cpp \
    $$PWD/litehtml/src/el_break.cpp \
    $$PWD/litehtml/src/el_cdata.cpp \
    $$PWD/litehtml/src/el_comment.cpp \
    $$PWD/litehtml/src/el_div.cpp \
    $$PWD/litehtml/src/element.cpp \
    $$PWD/litehtml/src/el_font.cpp \
    $$PWD/litehtml/src/el_image.cpp \
    $$PWD/litehtml/src/el_link.cpp \
    $$PWD/litehtml/src/el_para.cpp \
    $$PWD/litehtml/src/el_script.cpp \
    $$PWD/litehtml/src/el_space.cpp \
    $$PWD/litehtml/src/el_style.cpp \
    $$PWD/litehtml/src/el_table.cpp \
    $$PWD/litehtml/src/el_td.cpp \
    $$PWD/litehtml/src/el_text.cpp \
    $$PWD/litehtml/src/el_title.cpp \
    $$PWD/litehtml/src/el_tr.cpp \
    $$PWD/litehtml/src/encodings.cpp \
    $$PWD/litehtml/src/flex_item.cpp \
    $$PWD/litehtml/src/flex_line.cpp \
    $$PWD/litehtml/src/formatting_context.cpp \
    $$PWD/litehtml/src/gradient.cpp \
    $$PWD/litehtml/src/html.cpp \
    $$PWD/litehtml/src/html_microsyntaxes.cpp \
    $$PWD/litehtml/src/html_tag.cpp \
    $$PWD/litehtml/src/iterators.cpp \
    $$PWD/litehtml/src/line_box.cpp \
    $$PWD/litehtml/src/media_query.cpp \
    $$PWD/litehtml/src/num_cvt.cpp \
    $$PWD/litehtml/src/render_block_context.cpp \
    $$PWD/litehtml/src/render_block.cpp \
    $$PWD/litehtml/src/render_flex.cpp \
    $$PWD/litehtml/src/render_image.cpp \
    $$PWD/litehtml/src/render_inline_context.cpp \
    $$PWD/litehtml/src/render_item.cpp \
    $$PWD/litehtml/src/render_table.cpp \
    $$PWD/litehtml/src/string_id.cpp \
    $$PWD/litehtml/src/strtod.cpp \
    $$PWD/litehtml/src/style.cpp \
    $$PWD/litehtml/src/stylesheet.cpp \
    $$PWD/litehtml/src/table.cpp \
    $$PWD/litehtml/src/url.cpp \
    $$PWD/litehtml/src/url_path.cpp \
    $$PWD/litehtml/src/utf8_strings.cpp \
    $$PWD/litehtml/src/web_color.cpp \

LITEHTML_GUMBO_SOURCES = \
    $$PWD/litehtml/src/gumbo/attribute.c \
    $$PWD/litehtml/src/gumbo/char_ref.c \
    $$PWD/litehtml/src/gumbo/error.c \
    $$PWD/litehtml/src/gumbo/parser.c \
    $$PWD/litehtml/src/gumbo/string_buffer.c \
    $$PWD/litehtml/src/gumbo/string_piece.c \
    $$PWD/litehtml/src/gumbo/tag.c \
    $$PWD/litehtml/src/gumbo/tokenizer.c \
    $$PWD/litehtml/src/gumbo/utf8.c \
    $$PWD/litehtml/src/gumbo/util.c \
    $$PWD/litehtml/src/gumbo/vector.c \

SOURCES += $$LITEHTML_SOURCES $$LITEHTML_GUMBO_SOURCES
