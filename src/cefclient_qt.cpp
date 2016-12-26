#include "cefclient.h"
#include <QApplication>

#include <QDebug>
#include <QThread>
#include <QWaitCondition>

//extern CefRefPtr<ClientHandler> global_client_handler;
extern QMutex mutex;
extern QWaitCondition wait_for_browsers_to_close;

//void CefQuitUntilAllBrowserClosed() {
//    qDebug()  << QThread::currentThreadId() << QCoreApplication::applicationPid ();
//    if (ClientHandler::m_BrowserCount > 0 && global_client_handler.get()) {
//        global_client_handler->CloseAllBrowsers(false);
//    }
//    qDebug()  << QThread::currentThreadId() << QCoreApplication::applicationPid ();
//    CefQuit();
//}

QString AppGetWorkingDirectory() {
    return qApp->applicationDirPath();
}

//void NotifyAllBrowserClosed() {
//    qDebug()   << QCoreApplication::applicationPid () << QThread::currentThreadId();
//    // Notify all browser windows have closed.
//    wait_for_browsers_to_close.wakeAll();
//}
