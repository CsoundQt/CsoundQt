#ifndef CEFCLIENT_CLIENT_RENDERER_H_
#define CEFCLIENT_CLIENT_RENDERER_H_
#pragma once

#ifdef QCS_HTML5
#include "include/cef_base.h"
#include "client_app.h"
#endif
namespace client_renderer {

// Message sent when the focused node changes.
extern const char kFocusedNodeChangedMessage[];

// Create the render delegate.
void CreateRenderDelegates(ClientApp::RenderDelegateSet& delegates);

}  // namespace client_renderer

#endif  // CEFCLIENT_CLIENT_RENDERER_H_
