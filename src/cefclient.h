#ifndef CEFCLIENT_CEFCLIENT_H_
#define CEFCLIENT_CEFCLIENT_H_
#pragma once

#include <QString>
#include "include/cef_base.h"
#include "client_handler.h"

// Initialize CEF.
int CefInit(int &argc, char **argv);

// Load web plugins.
void CefLoadPlugins(bool isWow64);

// Quit CEF.
void CefQuit();

// Quit CEF until all browser windows have closed.
/*unavailable*/ void CefQuitUntilAllBrowserClosed();

// Returns the application working directory.
QString AppGetWorkingDirectory();

// Notify all browser windows have closed.
/*internal*/ void NotifyAllBrowserClosed();

#endif  // CEFCLIENT_CEFCLIENT_H_
