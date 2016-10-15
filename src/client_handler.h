#ifndef CEFCLIENT_CLIENT_HANDLER_H_
#define CEFCLIENT_CLIENT_HANDLER_H_
#pragma once

#include <list>
#include <map>
#include <set>
#include <string>
#include <QString>
#include "client_app.h"
#include "client_handler.h"
#include "client_renderer.h"
#include "include/base/cef_lock.h"
#include "include/cef_client.h"
#include "include/cef_life_span_handler.h"
#include "include/cef_render_handler.h"
#include "include/cef_request_context_handler.h"
#include "include/cef_web_plugin.h"
#include "include/internal/cef_types.h"
#include "util.h"
#include "message_event.h"

// ClientHandler implementation.
class ClientHandler : public CefClient,
        public CefContextMenuHandler,
        public CefDisplayHandler,
        public CefDownloadHandler,
        public CefDragHandler,
        public CefGeolocationHandler,
        public CefKeyboardHandler,
        public CefLifeSpanHandler,
        public CefLoadHandler,
        public CefRequestHandler {
public:
    // Interface for process message delegates. Do not perform work in the
    // RenderDelegate constructor.
    class ProcessMessageDelegate : public virtual CefBase {
    public:
        // Called when a process message is received. Return true if the message was
        // handled and should not be passed on to other handlers.
        // ProcessMessageDelegates should check for unique message names to avoid
        // interfering with each other.
        virtual bool OnProcessMessageReceived(
                CefRefPtr<ClientHandler> handler,
                CefRefPtr<CefBrowser> browser,
                CefProcessId source_process,
                CefRefPtr<CefProcessMessage> message) {
            return false;
        }
    };

    typedef std::set<CefRefPtr<ProcessMessageDelegate> >
    ProcessMessageDelegateSet;

    // Listener interface to be used to handle various events.
    class Listener {
    public:
        virtual ~Listener() {}

        virtual void OnAddressChange(const QString& url) = 0;
        virtual void OnTitleChange(const QString& title) = 0;
        virtual void SetLoading(bool isLoading) = 0;
        virtual void SetNavState(bool canGoBack, bool canGoForward) = 0;

        virtual void OnAfterCreated() = 0;

        virtual void OnMessageEvent(MessageEvent* e) = 0;
    };

    ClientHandler();
    virtual ~ClientHandler();

    // CefClient methods
    virtual CefRefPtr<CefContextMenuHandler> GetContextMenuHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefDownloadHandler> GetDownloadHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefGeolocationHandler> GetGeolocationHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE {
        return this;
    }
    virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
        return this;
    }
    virtual bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                          CefProcessId source_process,
                                          CefRefPtr<CefProcessMessage> message)
    OVERRIDE;

    // CefContextMenuHandler methods
    virtual void OnBeforeContextMenu(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefContextMenuParams> params,
                                     CefRefPtr<CefMenuModel> model) OVERRIDE;
    virtual bool OnContextMenuCommand(CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame,
                                      CefRefPtr<CefContextMenuParams> params,
                                      int command_id,
                                      EventFlags event_flags) OVERRIDE;

    // CefDisplayHandler methods
    virtual void OnAddressChange(CefRefPtr<CefBrowser> browser,
                                 CefRefPtr<CefFrame> frame,
                                 const CefString& url) OVERRIDE;
    virtual void OnTitleChange(CefRefPtr<CefBrowser> browser,
                               const CefString& title) OVERRIDE;
    virtual bool OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                  const CefString& message,
                                  const CefString& source,
                                  int line) OVERRIDE;

    // CefDownloadHandler methods
    virtual void OnBeforeDownload(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefDownloadItem> download_item,
            const CefString& suggested_name,
            CefRefPtr<CefBeforeDownloadCallback> callback) OVERRIDE;
    virtual void OnDownloadUpdated(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefDownloadItem> download_item,
            CefRefPtr<CefDownloadItemCallback> callback) OVERRIDE;

    // CefDragHandler methods
    virtual bool OnDragEnter(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefDragData> dragData,
                             DragOperationsMask mask) OVERRIDE;

    // CefGeolocationHandler methods
    virtual bool OnRequestGeolocationPermission(
            CefRefPtr<CefBrowser> browser,
            const CefString& requesting_url,
            int request_id,
            CefRefPtr<CefGeolocationCallback> callback) OVERRIDE;

    // CefKeyboardHandler methods
    virtual bool OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                               const CefKeyEvent& event,
                               CefEventHandle os_event,
                               bool* is_keyboard_shortcut) OVERRIDE;

    // CefLifeSpanHandler methods
    virtual bool OnBeforePopup(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& target_url,
                               const CefString& target_frame_name,
                               CefLifeSpanHandler::WindowOpenDisposition target_disposition,
                               bool user_gesture,
                               const CefPopupFeatures& popupFeatures,
                               CefWindowInfo& windowInfo,
                               CefRefPtr<CefClient>& client,
                               CefBrowserSettings& settings,
                               bool* no_javascript_access) OVERRIDE;
    virtual void OnAfterCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;
    virtual bool DoClose(CefRefPtr<CefBrowser> browser) OVERRIDE;
    virtual void OnBeforeClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

    // CefLoadHandler methods
    virtual void OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                      bool isLoading,
                                      bool canGoBack,
                                      bool canGoForward) OVERRIDE;

    virtual void OnLoadStart(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefFrame> frame,
                             TransitionType transition_type) OVERRIDE;
    virtual void OnLoadEnd(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefFrame> frame,
                           int httpStatusCode) OVERRIDE;
    virtual void OnLoadError(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefFrame> frame,
                             ErrorCode errorCode,
                             const CefString& errorText,
                             const CefString& failedUrl) OVERRIDE;

    // CefRequestHandler methods
    virtual CefRefPtr<CefResourceHandler> GetResourceHandler(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefFrame> frame,
            CefRefPtr<CefRequest> request) OVERRIDE;
//    virtual bool OnQuotaRequest(CefRefPtr<CefBrowser> browser,
//                                const CefString& origin_url,
//                                int64 new_size,
//                                CefRefPtr<CefQuotaCallback> callback) OVERRIDE;

    virtual bool OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                        const CefString& origin_url,
                        int64 new_size,
                        CefRefPtr<CefRequestCallback> callback) OVERRIDE
    {
        return false;
    }

    virtual void OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                                     const CefString& url,
                                     bool& allow_os_execution) OVERRIDE;
    virtual void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                           TerminationStatus status) OVERRIDE;
    CefRefPtr<CefBrowser> GetBrowser() { return m_Browser; }
    int GetBrowserId() { return m_BrowserId; }

    // Request that all existing browser windows close.
    void CloseAllBrowsers(bool force_close);

    // Returns true if the main browser window is currently closing. Used in
    // combination with DoClose() and the OS close notification to properly handle
    // 'onbeforeunload' JavaScript events during window close.
    bool IsClosing() { return m_bIsClosing; }
    // Returns the startup URL.
    std::string GetStartupURL() { return m_StartupURL; }
    void ShowDevTools(CefRefPtr<CefBrowser> browser,
                      const CefPoint& inspect_element_at);
    void CloseDevTools(CefRefPtr<CefBrowser> browser);
    void set_listener(Listener* listener) {
        listener_ = listener;
    }
    Listener* listener() const {
        return listener_;
    }

    // Number of currently existing browser windows. The application will exit
    // when the number of windows reaches 0.
    static int m_BrowserCount;

protected:
    void SetLoading(bool isLoading);
    void SetNavState(bool canGoBack, bool canGoForward);

    // Create all of ProcessMessageDelegate objects.
    static void CreateProcessMessageDelegates(
            ProcessMessageDelegateSet& delegates);

    // The child browser window
    CefRefPtr<CefBrowser> m_Browser;

    // List of any popup browser windows. Only accessed on the CEF UI thread.
    typedef std::list<CefRefPtr<CefBrowser> > BrowserList;
    BrowserList m_PopupBrowsers;

    // The child browser id
    int m_BrowserId;

    // True if the main browser window is currently closing.
    bool m_bIsClosing;

    // True if an editable field currently has focus.
    bool m_bFocusOnEditableField;

    // Registered delegates.
    ProcessMessageDelegateSet process_message_delegates_;

    // List of open DevTools URLs if not using an external browser window.
    std::set<std::string> m_OpenDevToolsURLs;

    // The startup URL.
    std::string m_StartupURL;

    // Listener interface
    Listener* listener_;

    base::Lock lock_OnAfterCreated;
    base::Lock lock_DoClose;
    // Include the default reference counting implementation.
    IMPLEMENT_REFCOUNTING(ClientHandler)
    // Include the default locking implementation.
    //IMPLEMENT_LOCKING(ClientHandler);
};

#endif  // CEFCLIENT_CLIENT_HANDLER_H_
