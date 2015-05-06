#ifndef CEFCLIENT_CLIENT_TRANSFER_H
#define CEFCLIENT_CLIENT_TRANSFER_H
#pragma once

#include "include/cef_v8.h"
#ifdef QT_CORE_LIB
#include <QVariant>
#endif

namespace cefclient {

// Transfer a V8 array to a List.
void SetList(CefRefPtr<CefV8Value> source, CefRefPtr<CefListValue> target);
// Transfer a V8 list to a List.
void SetList(const CefV8ValueList& source, CefRefPtr<CefListValue> target);

// Transfer a List to a V8 array.
void SetList(CefRefPtr<CefListValue> source, CefRefPtr<CefV8Value> target);
#ifdef QT_CORE_LIB
// Transfer a List to a QVariant array. (append)
void SetList(CefRefPtr<CefListValue> source, QVariantList& target);
#endif

}  // namespace cefclient

#endif  // CEFCLIENT_CLIENT_TRANSFER_H