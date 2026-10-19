/*
    Copyright (C) 2025 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with CsoundQt; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include "debuglog.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QMutex>
#include <QMutexLocker>
#include <QStandardPaths>
#include <QtGlobal>

#include <cstdio>

#ifdef Q_OS_WIN
#  ifndef WIN32_LEAN_AND_MEAN
#    define WIN32_LEAN_AND_MEAN
#  endif
#  ifndef NOMINMAX
#    define NOMINMAX
#  endif
#  include <windows.h>
#endif

namespace DebugLog {

namespace {

QMutex g_mutex;
bool g_enabled = false;
QFile g_file;

// The Qt message handler. It replaces Qt's default handler, so it has to
// reproduce its behaviour (write to stderr, and to the debugger on Windows)
// in addition to optionally appending to the log file. qFormatLogMessage()
// applies the pattern set with qSetMessagePattern() in main().
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    const QString text = qFormatLogMessage(type, context, message);
    const QByteArray local = text.toLocal8Bit();

    std::fwrite(local.constData(), 1, size_t(local.size()), stderr);
    std::fputc('\n', stderr);
    std::fflush(stderr);

#ifdef Q_OS_WIN
    OutputDebugStringW(reinterpret_cast<const wchar_t *>(text.utf16()));
    OutputDebugStringW(L"\n");
#endif

    QMutexLocker locker(&g_mutex);
    if (!g_enabled || !g_file.isOpen())
        return;
    g_file.write(local);
    g_file.write("\n");
    g_file.flush();
}

} // namespace

void install()
{
    qInstallMessageHandler(messageHandler);
}

QString filePath()
{
#if defined(Q_OS_LINUX)
    QString stateHome = qEnvironmentVariable("XDG_STATE_HOME");
    if (stateHome.isEmpty())
        stateHome = QDir::homePath() + QStringLiteral("/.local/state");
    return QDir(stateHome).filePath(QStringLiteral("csoundqt/csoundqt.log"));
#elif defined(Q_OS_MACOS)
    return QDir::homePath() + QStringLiteral("/Library/Logs/CsoundQt/csoundqt.log");
#elif defined(Q_OS_WIN)
    QString base = qEnvironmentVariable("LOCALAPPDATA");
    if (base.isEmpty())
        base = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    return QDir(base).filePath(QStringLiteral("CsoundQt/csoundqt.log"));
#else
    return QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation))
            .filePath(QStringLiteral("csoundqt.log"));
#endif
}

bool isEnabled()
{
    QMutexLocker locker(&g_mutex);
    return g_enabled;
}

void setEnabled(bool enabled)
{
    QMutexLocker locker(&g_mutex);
    if (enabled == g_enabled)
        return;

    if (!enabled) {
        g_enabled = false;
        if (g_file.isOpen()) {
            g_file.flush();
            g_file.close();
        }
        return;
    }

    const QString path = filePath();
    const QFileInfo info(path);
    if (!info.absoluteDir().exists() && !QDir().mkpath(info.absolutePath())) {
        std::fprintf(stderr, "CsoundQt: cannot create log directory %s\n",
                     qPrintable(info.absolutePath()));
        return;
    }
    g_file.setFileName(path);
    if (!g_file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        std::fprintf(stderr, "CsoundQt: cannot open debug log %s: %s\n",
                     qPrintable(path), qPrintable(g_file.errorString()));
        return;
    }
    const QString header = QStringLiteral("--**-- %1 CsoundQt debug log started\n")
            .arg(QDateTime::currentDateTime().toString(Qt::ISODate));
    g_file.write(header.toUtf8());
    g_file.flush();
    g_enabled = true;
}

} // namespace DebugLog
