/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifndef TYPES_H
#define TYPES_H

#include <QString>
#include <QStringList>

#ifdef LINUX
#define DEFAULT_HTML_DIR "/home/andres/src/manual/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/bin/xterm"
#endif
#ifdef MACOSX
#define DEFAULT_HTML_DIR "/Library/Frameworks/CsoundLib.framework/Versions/5.1/Resources/Manual"
#define DEFAULT_TERM_EXECUTABLE "/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal"
#endif
#ifdef WIN32
#define DEFAULT_HTML_DIR "/home/andres/src/manual/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/bin/xterm"
#endif

enum viewMode {
  VIEW_CSD,
  VIEW_ORC_SCO
};

class Opcode
{
  public:
    QString outArgs;
    QString opcodeName;
    QString inArgs;
};

#endif
