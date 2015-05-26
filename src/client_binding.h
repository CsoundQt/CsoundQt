#ifndef CEFCLIENT_CLIENT_BINDING_H
#define CEFCLIENT_CLIENT_BINDING_H
#pragma once

#include "client_handler.h"

namespace client_binding {

// Delegate creation. Called from ClientHandler.
void CreateProcessMessageDelegates(
    ClientHandler::ProcessMessageDelegateSet& delegates);

}  // namespace client_binding

#endif  // CEFCLIENT_CLIENT_BINDING_H
