/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

#ifndef CHANNELHIGHLIGHTMODE_H
#define CHANNELHIGHLIGHTMODE_H

// How the editor outlines widgets associated with a channel literal.
enum class ChannelHighlightMode {
    Never = 0,      // only the explicit Maximize/Highlight action
    CursorOnly = 1, // text cursor inside a literal
    Full = 2,       // text cursor and mouse hover
    MouseOnly = 3   // mouse hover only
};

// When to automatically mark editor lines that reference a widget's channels.
// The enum values are persisted in the settings file, so keep the existing
// numbering (Always stays 2) and append new modes.
enum class ChannelReferenceHighlightMode {
    Never = 0,
    EditMode = 1,       // only while the widget layout is in edit mode
    Always = 2,         // in all modes, performing or not
    NotPerforming = 3   // in all modes, but during performance only in edit mode
};

#endif // CHANNELHIGHLIGHTMODE_H
