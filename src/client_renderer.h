#ifndef CEFCLIENT_CLIENT_RENDERER_H_
#define CEFCLIENT_CLIENT_RENDERER_H_
#pragma once

#include "include/cef_base.h"
#include "client_app.h"

namespace client_renderer {

// Message sent when the focused node changes.
extern const char kFocusedNodeChangedMessage[];

// Create the render delegate.
void CreateRenderDelegates(ClientApp::RenderDelegateSet& delegates);

}  // namespace client_renderer

#endif  // CEFCLIENT_CLIENT_RENDERER_H_
