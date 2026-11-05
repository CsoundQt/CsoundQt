# qmake integration for the bundled litehtml submodule (and its bundled gumbo parser).
# Included from CsoundQt's qmake/src.pri.

# litehtml compiles against its src/, include/ and include/litehtml/ dirs.
LITEHTML_INCLUDEPATH = $$PWD/../third_party/litehtml/src $$PWD/../third_party/litehtml/include $$PWD/../third_party/litehtml/include/litehtml \
    $$PWD/../third_party/litehtml/src/gumbo/include $$PWD/../third_party/litehtml/src/gumbo/include/gumbo

INCLUDEPATH += $$LITEHTML_INCLUDEPATH

# The Gumbo parser bundled with litehtml includes the POSIX header
# <strings.h>, which MSVC does not provide. Add a tiny compatibility shim to
# the include path when building with MSVC.
win32-msvc {
    INCLUDEPATH += $$PWD/../src/compat
}

LITEHTML_SOURCES = \
    $$PWD/../third_party/litehtml/src/background.cpp \
    $$PWD/../third_party/litehtml/src/codepoint.cpp \
    $$PWD/../third_party/litehtml/src/css_borders.cpp \
    $$PWD/../third_party/litehtml/src/css_length.cpp \
    $$PWD/../third_party/litehtml/src/css_parser.cpp \
    $$PWD/../third_party/litehtml/src/css_properties.cpp \
    $$PWD/../third_party/litehtml/src/css_selector.cpp \
    $$PWD/../third_party/litehtml/src/css_tokenizer.cpp \
    $$PWD/../third_party/litehtml/src/document_container.cpp \
    $$PWD/../third_party/litehtml/src/document.cpp \
    $$PWD/../third_party/litehtml/src/el_anchor.cpp \
    $$PWD/../third_party/litehtml/src/el_base.cpp \
    $$PWD/../third_party/litehtml/src/el_before_after.cpp \
    $$PWD/../third_party/litehtml/src/el_body.cpp \
    $$PWD/../third_party/litehtml/src/el_break.cpp \
    $$PWD/../third_party/litehtml/src/el_cdata.cpp \
    $$PWD/../third_party/litehtml/src/el_comment.cpp \
    $$PWD/../third_party/litehtml/src/el_div.cpp \
    $$PWD/../third_party/litehtml/src/element.cpp \
    $$PWD/../third_party/litehtml/src/el_font.cpp \
    $$PWD/../third_party/litehtml/src/el_image.cpp \
    $$PWD/../third_party/litehtml/src/el_link.cpp \
    $$PWD/../third_party/litehtml/src/el_para.cpp \
    $$PWD/../third_party/litehtml/src/el_script.cpp \
    $$PWD/../third_party/litehtml/src/el_space.cpp \
    $$PWD/../third_party/litehtml/src/el_style.cpp \
    $$PWD/../third_party/litehtml/src/el_table.cpp \
    $$PWD/../third_party/litehtml/src/el_td.cpp \
    $$PWD/../third_party/litehtml/src/el_text.cpp \
    $$PWD/../third_party/litehtml/src/el_title.cpp \
    $$PWD/../third_party/litehtml/src/el_tr.cpp \
    $$PWD/../third_party/litehtml/src/encodings.cpp \
    $$PWD/../third_party/litehtml/src/flex_item.cpp \
    $$PWD/../third_party/litehtml/src/flex_line.cpp \
    $$PWD/../third_party/litehtml/src/formatting_context.cpp \
    $$PWD/../third_party/litehtml/src/gradient.cpp \
    $$PWD/../third_party/litehtml/src/html.cpp \
    $$PWD/../third_party/litehtml/src/html_microsyntaxes.cpp \
    $$PWD/../third_party/litehtml/src/html_tag.cpp \
    $$PWD/../third_party/litehtml/src/iterators.cpp \
    $$PWD/../third_party/litehtml/src/line_box.cpp \
    $$PWD/../third_party/litehtml/src/media_query.cpp \
    $$PWD/../third_party/litehtml/src/num_cvt.cpp \
    $$PWD/../third_party/litehtml/src/render_block_context.cpp \
    $$PWD/../third_party/litehtml/src/render_block.cpp \
    $$PWD/../third_party/litehtml/src/render_flex.cpp \
    $$PWD/../third_party/litehtml/src/render_image.cpp \
    $$PWD/../third_party/litehtml/src/render_inline_context.cpp \
    $$PWD/../third_party/litehtml/src/render_item.cpp \
    $$PWD/../third_party/litehtml/src/render_table.cpp \
    $$PWD/../third_party/litehtml/src/string_id.cpp \
    $$PWD/../third_party/litehtml/src/strtod.cpp \
    $$PWD/../third_party/litehtml/src/style.cpp \
    $$PWD/../third_party/litehtml/src/stylesheet.cpp \
    $$PWD/../third_party/litehtml/src/table.cpp \
    $$PWD/../third_party/litehtml/src/url.cpp \
    $$PWD/../third_party/litehtml/src/url_path.cpp \
    $$PWD/../third_party/litehtml/src/utf8_strings.cpp \
    $$PWD/../third_party/litehtml/src/web_color.cpp \

LITEHTML_GUMBO_SOURCES = \
    $$PWD/../third_party/litehtml/src/gumbo/attribute.c \
    $$PWD/../third_party/litehtml/src/gumbo/char_ref.c \
    $$PWD/../third_party/litehtml/src/gumbo/error.c \
    $$PWD/../third_party/litehtml/src/gumbo/parser.c \
    $$PWD/../third_party/litehtml/src/gumbo/string_buffer.c \
    $$PWD/../third_party/litehtml/src/gumbo/string_piece.c \
    $$PWD/../third_party/litehtml/src/gumbo/tag.c \
    $$PWD/../third_party/litehtml/src/gumbo/tokenizer.c \
    $$PWD/../third_party/litehtml/src/gumbo/utf8.c \
    $$PWD/../third_party/litehtml/src/gumbo/util.c \
    $$PWD/../third_party/litehtml/src/gumbo/vector.c \

SOURCES += $$LITEHTML_SOURCES $$LITEHTML_GUMBO_SOURCES
