#include "cefclient.h"
#include <QApplication>

#include <QDebug>

extern CefRefPtr<ClientHandler> g_handler;

void CefQuitUntilAllBrowserClosed() {
  qDebug() << __FUNCTION__ << __LINE__;
  ///if (ClientHandler::m_BrowserCount > 0 && g_handler.get()) {
  ///  g_handler->CloseAllBrowsers(false);
  ///  // TODO Wait until all browser windows have closed.
  ///}
  qDebug() << __FUNCTION__ << __LINE__;
  CefQuit();
}

QString AppGetWorkingDirectory() {
  return qApp->applicationDirPath();
}

void NotifyAllBrowserClosed() {
  qDebug() << __FUNCTION__;
  // Notify all browser windows have closed.
}
