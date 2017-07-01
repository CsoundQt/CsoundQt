#include "cefclient.h"
#include <string.h>
#include "include/cef_app.h"
#include "include/cef_client.h"
#include "client_app.h"

#include <QDebug>

// Whether to use a separate sub-process executable? cefclient_process.exe
//#define SUB_PROCESS_DISABLED

namespace {

void CefInitSettings(CefSettings& settings) {
    settings.multi_threaded_message_loop = true;
}

}  // namespace

int CefInit(int &argc, char **argv) {
    qDebug() ;
#ifdef WIN32
    HINSTANCE hInstance = (HINSTANCE) GetModuleHandle(NULL);
    CefMainArgs main_args(hInstance);
#else
    CefMainArgs main_args(argc, argv);
#endif
    CefRefPtr<ClientApp> app(new ClientApp);
    int exit_code = CefExecuteProcess(main_args, app.get(), 0);
    if (exit_code >= 0) {
        return exit_code;
    }
    CefSettings settings;
    CefInitSettings(settings);
    CefInitialize(main_args, settings, app.get(), 0);
    //global_client_handler = new ClientHandler();
    return -1;
}

#ifdef WIN32_XXX
void CefLoadPlugins(bool isWow64) {
    // Adobe Flash Player plug-in:
    // https://support.google.com/chrome/answer/108086
    // How to load chrome flash plugin:
    // https://code.google.com/p/chromiumembedded/issues/detail?id=130
    // Load flash system plug-in on Windows.
    CefString flash_plugin_dir = isWow64 ? "C:\\Windows\\SysWOW64\\Macromed\\Flash"
                                         : "C:\\Windows\\System32\\Macromed\\Flash";
    CefAddWebPluginDirectory(flash_plugin_dir);
    CefRefreshWebPlugins();
}
#endif

void CefQuit() {
    qDebug() ;
    CefShutdown();
}


