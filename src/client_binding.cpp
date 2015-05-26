#include "client_binding.h"
#include "client_transfer.h"
#include "message_event.h"
#include "client_app_js.h"

extern CefRefPtr<ClientHandler> global_client_handler;

namespace client_binding {

namespace {

// Handle messages in the browser process.
class ProcessMessageDelegate : public ClientHandler::ProcessMessageDelegate {
 public:
  ProcessMessageDelegate() {
  }

  // From ClientHandler::ProcessMessageDelegate.
  virtual bool OnProcessMessageReceived(
      CefRefPtr<ClientHandler> handler,
      CefRefPtr<CefBrowser> browser,
      CefProcessId source_process,
      CefRefPtr<CefProcessMessage> message) OVERRIDE {
    CefString name = message->GetName();
    if (name == JS_FUNC_SENDMESSAGE) {
//      if (global_client_handler.get() && global_client_handler->listener()) {
//        CefRefPtr<CefListValue> args = message->GetArgumentList();
//        QVariantList message_args;
//        cefclient::SetList(args, message_args);
//        QString message_name = QString::fromStdWString(name.ToWString());
//        MessageEvent* e = new MessageEvent(message_name, message_args);
//        global_client_handler->listener()->OnMessageEvent(e);
//        return true;
//      }
    }
    return false;
  }

  IMPLEMENT_REFCOUNTING(ProcessMessageDelegate);
};

}  // namespace

void CreateProcessMessageDelegates(
    ClientHandler::ProcessMessageDelegateSet& delegates) {
  delegates.insert(new ProcessMessageDelegate);
}

}  // namespace client_binding

