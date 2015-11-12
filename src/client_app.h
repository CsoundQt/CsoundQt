#ifndef CEFCLIENT_CLIENT_APP_H_
#define CEFCLIENT_CLIENT_APP_H_

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>
#include "include/cef_base.h"
#include "include/cef_app.h"
#include "include/cef_v8.h"
#include "qutecsound.h"
#include <csound.h>
#include "csoundengine.h"

class ClientApp : public CefApp,
        public CefResourceBundleHandler,
        public CefBrowserProcessHandler,
        public CefRenderProcessHandler,
        public CefV8Handler
{
public:
    virtual bool GetDataResourceForScale(int resource_id,
                                         ScaleFactor scale_factor,
                                         void*& data,
                                         size_t& data_size)
    {
        return false;
    }

    virtual bool Execute(const CefString& name,
                         CefRefPtr<CefV8Value> object,
                         const CefV8ValueList& arguments,
                         CefRefPtr<CefV8Value>& retval,
                         CefString& exception);
    // Interface for browser delegates. All BrowserDelegates must be returned via
    // CreateBrowserDelegates. Do not perform work in the BrowserDelegate
    // constructor. See CefBrowserProcessHandler for documentation.
    class BrowserDelegate : public virtual CefBase {
    public:
        virtual void OnContextInitialized(CefRefPtr<ClientApp> app) {}
        virtual void OnBeforeChildProcessLaunch(
                CefRefPtr<ClientApp> app,
                CefRefPtr<CefCommandLine> command_line) {}
        virtual void OnRenderProcessThreadCreated(
                CefRefPtr<ClientApp> app,
                CefRefPtr<CefListValue> extra_info) {}
    };
    typedef std::set<CefRefPtr<BrowserDelegate> > BrowserDelegateSet;
    // Interface for renderer delegates. All RenderDelegates must be returned via
    // CreateRenderDelegates. Do not perform work in the RenderDelegate
    // constructor. See CefRenderProcessHandler for documentation.
    class RenderDelegate : public virtual CefBase {
    public:
        virtual void OnRenderThreadCreated(CefRefPtr<ClientApp> app,
                                           CefRefPtr<CefListValue> extra_info) {}

        virtual void OnWebKitInitialized(CefRefPtr<ClientApp> app) {}

        virtual void OnBrowserCreated(CefRefPtr<ClientApp> app,
                                      CefRefPtr<CefBrowser> browser) {}

        virtual void OnBrowserDestroyed(CefRefPtr<ClientApp> app,
                                        CefRefPtr<CefBrowser> browser) {}

        virtual CefRefPtr<CefLoadHandler> GetLoadHandler(CefRefPtr<ClientApp> app) {
            return NULL;
        }
        virtual bool OnBeforeNavigation(CefRefPtr<ClientApp> app,
                                        CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefRequest> request,
                                        cef_navigation_type_t navigation_type,
                                        bool is_redirect) {
            return false;  // Allow the navigation to proceed.
        }
        virtual void OnContextCreated(CefRefPtr<ClientApp> app,
                                      CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame,
                                      CefRefPtr<CefV8Context> context)
        {
            qDebug() << "RenderDelegate::OnContextCreated:" << &app;
        }
        virtual void OnContextReleased(CefRefPtr<ClientApp> app,
                                       CefRefPtr<CefBrowser> browser,
                                       CefRefPtr<CefFrame> frame,
                                       CefRefPtr<CefV8Context> context) {}

        virtual void OnUncaughtException(CefRefPtr<ClientApp> app,
                                         CefRefPtr<CefBrowser> browser,
                                         CefRefPtr<CefFrame> frame,
                                         CefRefPtr<CefV8Context> context,
                                         CefRefPtr<CefV8Exception> exception,
                                         CefRefPtr<CefV8StackTrace> stackTrace) {}

        virtual void OnFocusedNodeChanged(CefRefPtr<ClientApp> app,
                                          CefRefPtr<CefBrowser> browser,
                                          CefRefPtr<CefFrame> frame,
                                          CefRefPtr<CefDOMNode> node) {}

        // Called when a process message is received. Return true if the message was
        // handled and should not be passed on to other handlers. RenderDelegates
        // should check for unique message names to avoid interfering with each
        // other.
        virtual bool OnProcessMessageReceived(
                CefRefPtr<ClientApp> app,
                CefRefPtr<CefBrowser> browser,
                CefProcessId source_process,
                CefRefPtr<CefProcessMessage> message) {
            return false;
        }
    };
    typedef std::set<CefRefPtr<RenderDelegate> > RenderDelegateSet;
    ClientApp();
    virtual void setMainWindow(CsoundQt *csound);
    CSOUND* csoundApiEnabled()
    {
        CefRefPtr<CefV8Context> currentContext = CefV8Context::GetCurrentContext();
        if (!currentContext) {
            return 0;
        }
        if (mainWindow == 0) {
            return 0;
        }
        CefRefPtr<CefV8Value> global = currentContext->GetGlobal();
        auto jcsound = global->GetValue("csound");
        if (!jcsound) {
            return 0;
        }
        auto csoundEngine = mainWindow->getEngine();
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
private:
    CsoundQt *mainWindow;
    // Creates all of the BrowserDelegate objects. Implemented in
    // client_app_delegates.
    static void CreateBrowserDelegates(BrowserDelegateSet& delegates);
    // Creates all of the RenderDelegate objects. Implemented in
    // client_app_delegates.
    static void CreateRenderDelegates(RenderDelegateSet& delegates);
    // Registers custom schemes. Implemented in client_app_delegates.
    static void RegisterCustomSchemes(CefRefPtr<CefSchemeRegistrar> registrar,
                                      std::vector<CefString>& cookiable_schemes);
    // CefApp methods.
    virtual void OnBeforeCommandLineProcessing(
            const CefString& process_type,
            CefRefPtr<CefCommandLine> command_line) OVERRIDE {
    }
    virtual void OnRegisterCustomSchemes(
            CefRefPtr<CefSchemeRegistrar> registrar) OVERRIDE {
        RegisterCustomSchemes(registrar, cookieable_schemes_);
    }
    virtual CefRefPtr<CefResourceBundleHandler> GetResourceBundleHandler()
    OVERRIDE { return this; }
    virtual CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler()
    OVERRIDE { return this; }
    virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler()
    OVERRIDE { return this; }

    // CefResourceBundleHandler methods.
    virtual bool GetLocalizedString(int message_id,
                                    CefString& string) OVERRIDE {
        return false; // Use the default translation.
    };
    virtual bool GetDataResource(int resource_id,
                                 void*& data,
                                 size_t& data_size) OVERRIDE {
        return false; // Use the default resource data.
    }
    // CefBrowserProcessHandler methods.
    virtual void OnContextInitialized() OVERRIDE;
    virtual void OnBeforeChildProcessLaunch(
            CefRefPtr<CefCommandLine> command_line) OVERRIDE;
    virtual void OnRenderProcessThreadCreated(CefRefPtr<CefListValue> extra_info)
    OVERRIDE;
    // CefRenderProcessHandler methods.
    virtual void OnRenderThreadCreated(CefRefPtr<CefListValue> extra_info)
    OVERRIDE;
    virtual void OnWebKitInitialized() OVERRIDE;
    virtual void OnBrowserCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;
    virtual void OnBrowserDestroyed(CefRefPtr<CefBrowser> browser) OVERRIDE;
    virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE;
    virtual bool OnBeforeNavigation(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefRequest> request,
                                    NavigationType navigation_type,
                                    bool is_redirect) OVERRIDE;
    virtual void OnContextCreated(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  CefRefPtr<CefV8Context> context) OVERRIDE;
    virtual void OnContextReleased(CefRefPtr<CefBrowser> browser,
                                   CefRefPtr<CefFrame> frame,
                                   CefRefPtr<CefV8Context> context) OVERRIDE;
    virtual void OnUncaughtException(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefV8Context> context,
                                     CefRefPtr<CefV8Exception> exception,
                                     CefRefPtr<CefV8StackTrace> stackTrace)
    OVERRIDE;
    virtual void OnFocusedNodeChanged(CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame,
                                      CefRefPtr<CefDOMNode> node) OVERRIDE;
    virtual bool OnProcessMessageReceived(
            CefRefPtr<CefBrowser> browser,
            CefProcessId source_process,
            CefRefPtr<CefProcessMessage> message) OVERRIDE;

    // Set of supported BrowserDelegates.
    BrowserDelegateSet browser_delegates_;

    // Set of supported RenderDelegates.
    RenderDelegateSet render_delegates_;

    // Schemes that will be registered with the global cookie manager.
    std::vector<CefString> cookieable_schemes_;
    IMPLEMENT_REFCOUNTING(ClientApp)
};

#endif  // CEFCLIENT_CLIENT_APP_H_
