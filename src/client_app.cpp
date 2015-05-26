#include "client_app.h"  // NOLINT(build/include)

#include <string>

#include "include/cef_cookie.h"
#include "include/cef_process_message.h"
#include "include/cef_task.h"
#include "include/cef_v8.h"
#include "client_handler.h"
#include "csoundengine.h"
#include "client_transfer.h"
#include "client_app_js.h"
#include "util.h"  // NOLINT(build/include)

namespace {

class CsoundV8Handler : public CefV8Handler
{
    CsoundQt *csoundQt;
public:
    CsoundV8Handler(CsoundQt *csoundQt_) : csoundQt(csoundQt_){};
    CSOUND* csoundApiEnabled()
    {
        CefRefPtr<CefV8Context> currentContext = CefV8Context::GetCurrentContext();
        if (!currentContext) {
            return 0;
        }
        if (csoundQt == 0) {
            return 0;
        }
        CefRefPtr<CefV8Value> global = currentContext->GetGlobal();
        auto jcsound = global->GetValue("csound");
        if (!jcsound) {
            return 0;
        }
        auto csoundEngine = csoundQt->getEngine();
        if (csoundEngine == 0){
            return 0;
        }
        CSOUND *csound = csoundEngine->getCsound();
        if (csound == 0) {
            return 0;
        }
        if (csoundEngine->isRunning()) {
            return csound;
        } else {
            return 0;
        }
    }
    virtual bool Execute(const CefString& name,
                         CefRefPtr<CefV8Value> object,
                         const CefV8ValueList& arguments,
                         CefRefPtr<CefV8Value>& retval,
                         CefString& exception) OVERRIDE
    {
        CSOUND *csound = csoundApiEnabled();
        if (name == "isPlaying" && arguments.size() == 0) {
            retval = CefV8Value::CreateBool(csound != 0);
            return true;
        }
        if (csound == 0) {
            return false;
        }
        if (name == "setControlChannel" && arguments.size() == 2) {
            std::string name = arguments.at(0)->GetStringValue().ToString();
            double value = arguments.at(1)->GetDoubleValue();
            csoundSetControlChannel(csound, name.c_str(), value);
            return true;
        }
        if (name == "inputMessage" && arguments.size() == 1) {
            std::string lines = arguments.at(0)->GetStringValue().ToString();
            csoundInputMessage(csound, lines.c_str());
            return true;
        }
        if (name == "getControlChannel" && arguments.size() == 1) {
            std::string name = arguments.at(0)->GetStringValue().ToString();
            int result = 0;
            double value = csoundGetControlChannel(csound, name.c_str(), &result);
            retval = CefV8Value::CreateDouble(value);
            return true;
        }
        if (name == "message" && arguments.size() == 1) {
            std::string text = arguments.at(0)->GetStringValue().ToString();
            csoundMessage(csound, text.c_str());
            return true;
        }
        if (name == "readScore" && arguments.size() == 1) {
            std::string code = arguments.at(0)->GetStringValue().ToString();
            csoundReadScore(csound, code.c_str());
            return true;
        }
        if (name == "getVersion" && arguments.size() == 0) {
            auto version = csoundGetVersion();
            retval = CefV8Value::CreateInt(version);
            return true;
        }
        if (name == "compileOrc" && arguments.size() == 1) {
            std::string code = arguments.at(0)->GetStringValue().ToString();
            int result = csoundCompileOrc(csound, code.c_str());
            retval = CefV8Value::CreateInt(result);
            return true;
        }
        if (name == "evalCode" && arguments.size() == 1) {
            std::string code = arguments.at(0)->GetStringValue().ToString();
            double value = csoundEvalCode(csound, code.c_str());
            retval = CefV8Value::CreateDouble(value);
            return true;
        }
        if (name == "getSr" && arguments.size() == 0) {
            double sr = csoundGetSr(csound);
            retval = CefV8Value::CreateDouble(sr);
            return true;
        }
        if (name == "getKsmps" && arguments.size() == 0) {
            uint32_t ksmps = csoundGetKsmps(csound);
            retval = CefV8Value::CreateInt(ksmps);
            return true;
        }
        if (name == "getNchnls" && arguments.size() == 0) {
            uint32_t nchnls = csoundGetNchnls(csound);
            retval = CefV8Value::CreateInt(nchnls);
            return true;
        }
        //exception = "Invalid method arguments.";
        return false;
    }
    // Provide the reference counting implementation for this class.
    IMPLEMENT_REFCOUNTING(CsoundV8Handler);
};

// Handles the native implementation for the client_app extension.
class ClientAppExtensionHandler : public CefV8Handler {
public:
    explicit ClientAppExtensionHandler(CefRefPtr<ClientApp> client_app)
        : client_app_(client_app) {
    }

    virtual bool Execute(const CefString& name,
                         CefRefPtr<CefV8Value> object,
                         const CefV8ValueList& arguments,
                         CefRefPtr<CefV8Value>& retval,
                         CefString& exception) {
        bool handled = false;
        if (name == JS_FUNC_SENDMESSAGE && arguments.size() >= 1) {
            CefRefPtr<CefBrowser> browser =
                    CefV8Context::GetCurrentContext()->GetBrowser();
            ASSERT(browser.get());
            CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create(name);
            cefclient::SetList(arguments, message->GetArgumentList());
            browser->SendProcessMessage(PID_BROWSER, message);
            handled = true;
        }
        if (!handled)
            exception = "Invalid method arguments";

        return true;
    }
private:
    CefRefPtr<ClientApp> client_app_;
    IMPLEMENT_REFCOUNTING(ClientAppExtensionHandler);
};

}  // namespace


ClientApp::ClientApp() : mainWindow(0)
{
    CreateBrowserDelegates(browser_delegates_);
    CreateRenderDelegates(render_delegates_);
    // Default schemes that support cookies.
    //cookieable_schemes_.push_back("http");
    //cookieable_schemes_.push_back("https");
}

void ClientApp::setMainWindow(CsoundQt *mainWindow_)
{
    mainWindow = mainWindow_;
}

void ClientApp::OnContextInitialized() {
    // Register cookieable schemes with the global cookie manager.
    //CefRefPtr<CefCookieManager> manager = CefCookieManager::GetGlobalManager();
    //ASSERT(manager.get());
    //manager->SetSupportedSchemes(cookieable_schemes_);
    BrowserDelegateSet::iterator it = browser_delegates_.begin();
    for (; it != browser_delegates_.end(); ++it)
        (*it)->OnContextInitialized(this);
}

void ClientApp::OnBeforeChildProcessLaunch(
        CefRefPtr<CefCommandLine> command_line) {
    BrowserDelegateSet::iterator it = browser_delegates_.begin();
    for (; it != browser_delegates_.end(); ++it)
        (*it)->OnBeforeChildProcessLaunch(this, command_line);
}

void ClientApp::OnRenderProcessThreadCreated(
        CefRefPtr<CefListValue> extra_info) {
    BrowserDelegateSet::iterator it = browser_delegates_.begin();
    for (; it != browser_delegates_.end(); ++it)
        (*it)->OnRenderProcessThreadCreated(this, extra_info);
}

void ClientApp::OnRenderThreadCreated(CefRefPtr<CefListValue> extra_info) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnRenderThreadCreated(this, extra_info);
}

void ClientApp::OnWebKitInitialized() {
    // Register the client_app extension.
    std::string app_code =
            "var app;"
            "if (!app) {"
            "  app = {"
            "    sendMessage: function(/*one or more*/) {"
            "      native function sendMessage();"
            "      return sendMessage.apply(this, Array.prototype.slice.call(arguments));"
            "    }"
            "  }"
            "}";
    CefRegisterExtension("v8/app", app_code,
                         new ClientAppExtensionHandler(this));

    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnWebKitInitialized(this);
}

void ClientApp::OnBrowserCreated(CefRefPtr<CefBrowser> browser) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnBrowserCreated(this, browser);
}

void ClientApp::OnBrowserDestroyed(CefRefPtr<CefBrowser> browser) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnBrowserDestroyed(this, browser);
}

CefRefPtr<CefLoadHandler> ClientApp::GetLoadHandler() {
    CefRefPtr<CefLoadHandler> load_handler;
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end() && !load_handler.get(); ++it)
        load_handler = (*it)->GetLoadHandler(this);

    return load_handler;
}

bool ClientApp::OnBeforeNavigation(CefRefPtr<CefBrowser> browser,
                                   CefRefPtr<CefFrame> frame,
                                   CefRefPtr<CefRequest> request,
                                   NavigationType navigation_type,
                                   bool is_redirect) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it) {
        if ((*it)->OnBeforeNavigation(this, browser, frame, request,
                                      navigation_type, is_redirect)) {
            return true;
        }
    }

    return false;  // Allow the navigation to proceed.
}

/**
 * @brief ClientApp::OnContextCreated
 * @param browser
 * @param frame
 * @param context
 *
 * Here we create the following methods of the "csound" object
 * in the browser's JavaScript context:
 *
 * int getVersion ()
 * void compileOrc (String orchestracode)
 * double evalCode (String orchestracode)
 * void readScore (String scorelines)
 * void setControlChannel (String channelName, double value)
 * double getControlChannel (String channelName)
 * void message (String text)
 * int getSr ()
 * int getKsmps ()
 * int getNchnls ()
 * int isPlaying ()
 *
 * Later I will try to put in the Emscripten Web Audio connections.
 */

void ClientApp::OnContextCreated(CefRefPtr<CefBrowser> browser,
                                 CefRefPtr<CefFrame> frame,
                                 CefRefPtr<CefV8Context> context) {
    CefRefPtr<CefV8Value> global = context->GetGlobal();
    CefRefPtr<CefV8Value> jcsound = CefV8Value::CreateObject(0);
    qDebug() << "CreateObject jcsound:" << jcsound;
    global->SetValue("csound", jcsound, V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetRethrowExceptions(true);
    CefRefPtr<CsoundV8Handler> csoundV8Handler = new CsoundV8Handler(mainWindow);
    jcsound->SetValue("getVersion",
                      CefV8Value::CreateFunction("getVersion", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("compileOrc",
                      CefV8Value::CreateFunction("compileOrc", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("evalCode",
                      CefV8Value::CreateFunction("evalCode", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("readScore",
                      CefV8Value::CreateFunction("readScore", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("setControlChannel",
                      CefV8Value::CreateFunction("setControlChannel", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("getControlChannel",
                      CefV8Value::CreateFunction("getControlChannel", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("message",
                      CefV8Value::CreateFunction("message", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("getSr",
                      CefV8Value::CreateFunction("getSr", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("getKsmps",
                      CefV8Value::CreateFunction("getKsmps", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("getNchnls",
                      CefV8Value::CreateFunction("getNchnls", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    jcsound->SetValue("isPlaying",
                      CefV8Value::CreateFunction("isPlaying", this),
                      V8_PROPERTY_ATTRIBUTE_NONE);
    std::cout << "app:" << this << std::endl;
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnContextCreated(this, browser, frame, context);
}

void ClientApp::OnContextReleased(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  CefRefPtr<CefV8Context> context) {
    auto global = context->GetGlobal();
    auto result = global->DeleteValue("csound");
    qDebug() << "DeleteValue jcsound:" << result;
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnContextReleased(this, browser, frame, context);
}

void ClientApp::OnUncaughtException(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefV8Context> context,
                                    CefRefPtr<CefV8Exception> exception,
                                    CefRefPtr<CefV8StackTrace> stackTrace) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it) {
        (*it)->OnUncaughtException(this, browser, frame, context, exception,
                                   stackTrace);
    }
}

void ClientApp::OnFocusedNodeChanged(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefDOMNode> node) {
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end(); ++it)
        (*it)->OnFocusedNodeChanged(this, browser, frame, node);
}

bool ClientApp::OnProcessMessageReceived(
        CefRefPtr<CefBrowser> browser,
        CefProcessId source_process,
        CefRefPtr<CefProcessMessage> message) {
    ASSERT(source_process == PID_BROWSER);
    bool handled = false;
    RenderDelegateSet::iterator it = render_delegates_.begin();
    for (; it != render_delegates_.end() && !handled; ++it) {
        handled = (*it)->OnProcessMessageReceived(this, browser, source_process,
                                                  message);
    }
    if (handled)
        return true;
    return handled;
}
/**
 * @brief ClientApp::Execute
 * @param name - Name of the JavaScript function or method being called.
 * @param object - Self of the JavaScript method being called.
 * @param arguments - Argument list of the function being called.
 * @param retval - Value to return from the call.
 * @param exception - Exception to throw, if any.
 * @return
 */

bool ClientApp::Execute(const CefString& name,
                        CefRefPtr<CefV8Value> object,
                        const CefV8ValueList& arguments,
                        CefRefPtr<CefV8Value>& retval,
                        CefString& exception) {
    CSOUND *csound = csoundApiEnabled();
    if (name == "isPlaying" && arguments.size() == 0) {
        retval = CefV8Value::CreateBool(csound != 0);
        return true;
    }
    if (csound == 0) {
        return false;
    }
    if (name == "setControlChannel" && arguments.size() == 2) {
        std::string name = arguments.at(0)->GetStringValue().ToString();
        double value = arguments.at(1)->GetDoubleValue();
        csoundSetControlChannel(csound, name.c_str(), value);
        return true;
    }
    if (name == "inputMessage" && arguments.size() == 1) {
        std::string lines = arguments.at(0)->GetStringValue().ToString();
        csoundInputMessage(csound, lines.c_str());
        return true;
    }
    if (name == "getControlChannel" && arguments.size() == 1) {
        std::string name = arguments.at(0)->GetStringValue().ToString();
        int result = 0;
        double value = csoundGetControlChannel(csound, name.c_str(), &result);
        retval = CefV8Value::CreateDouble(value);
        return true;
    }
    if (name == "message" && arguments.size() == 1) {
        std::string text = arguments.at(0)->GetStringValue().ToString();
        csoundMessage(csound, text.c_str());
        return true;
    }
    if (name == "readScore" && arguments.size() == 1) {
        std::string code = arguments.at(0)->GetStringValue().ToString();
        csoundReadScore(csound, code.c_str());
        return true;
    }
    if (name == "getVersion" && arguments.size() == 0) {
        auto version = csoundGetVersion();
        retval = CefV8Value::CreateInt(version);
        return true;
    }
    if (name == "compileOrc" && arguments.size() == 1) {
        std::string code = arguments.at(0)->GetStringValue().ToString();
        int result = csoundCompileOrc(csound, code.c_str());
        retval = CefV8Value::CreateInt(result);
        return true;
    }
    if (name == "evalCode" && arguments.size() == 1) {
        std::string code = arguments.at(0)->GetStringValue().ToString();
        double value = csoundEvalCode(csound, code.c_str());
        retval = CefV8Value::CreateDouble(value);
        return true;
    }
    if (name == "getSr" && arguments.size() == 0) {
        double sr = csoundGetSr(csound);
        retval = CefV8Value::CreateDouble(sr);
        return true;
    }
    if (name == "getKsmps" && arguments.size() == 0) {
        uint32_t ksmps = csoundGetKsmps(csound);
        retval = CefV8Value::CreateInt(ksmps);
        return true;
    }
    if (name == "getNchnls" && arguments.size() == 0) {
        uint32_t nchnls = csoundGetNchnls(csound);
        retval = CefV8Value::CreateInt(nchnls);
        return true;
    }
    //exception = "Invalid method arguments.";
    return false;
}


