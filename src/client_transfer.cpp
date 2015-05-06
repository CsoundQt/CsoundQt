#include "client_transfer.h"
#include "util.h"

namespace cefclient {

// Transfer a V8 value to a List index.
void SetListValue(CefRefPtr<CefListValue> list, int index,
                  CefRefPtr<CefV8Value> value) {
  if (value->IsArray()) {
    CefRefPtr<CefListValue> new_list = CefListValue::Create();
    SetList(value, new_list);
    list->SetList(index, new_list);
  } else if (value->IsString()) {
    list->SetString(index, value->GetStringValue());
  } else if (value->IsBool()) {
    list->SetBool(index, value->GetBoolValue());
  } else if (value->IsInt()) {
    list->SetInt(index, value->GetIntValue());
  } else if (value->IsDouble()) {
    list->SetDouble(index, value->GetDoubleValue());
  }
}

// Transfer a V8 array to a List.
void SetList(CefRefPtr<CefV8Value> source, CefRefPtr<CefListValue> target) {
  ASSERT(source->IsArray());

  int arg_length = source->GetArrayLength();
  if (arg_length == 0)
    return;

  // Start with null types in all spaces.
  target->SetSize(arg_length);

  for (int i = 0; i < arg_length; ++i)
    SetListValue(target, i, source->GetValue(i));
}

// Transfer a V8 list to a List.
void SetList(const CefV8ValueList& source, CefRefPtr<CefListValue> target) {
  int arg_length = source.size();
  if (arg_length == 0)
    return;

  for (int i = 0; i < arg_length; ++i)
    SetListValue(target, i, source.at(i));
}

// Transfer a List value to a V8 array index.
void SetListValue(CefRefPtr<CefV8Value> list, int index,
                  CefRefPtr<CefListValue> value) {
  CefRefPtr<CefV8Value> new_value;

  CefValueType type = value->GetType(index);
  switch (type) {
    case VTYPE_LIST: {
      CefRefPtr<CefListValue> list = value->GetList(index);
      new_value = CefV8Value::CreateArray(static_cast<int>(list->GetSize()));
      SetList(list, new_value);
      } break;
    case VTYPE_BOOL:
      new_value = CefV8Value::CreateBool(value->GetBool(index));
      break;
    case VTYPE_DOUBLE:
      new_value = CefV8Value::CreateDouble(value->GetDouble(index));
      break;
    case VTYPE_INT:
      new_value = CefV8Value::CreateInt(value->GetInt(index));
      break;
    case VTYPE_STRING:
      new_value = CefV8Value::CreateString(value->GetString(index));
      break;
    default:
      break;
  }

  if (new_value.get()) {
    list->SetValue(index, new_value);
  } else {
    list->SetValue(index, CefV8Value::CreateNull());
  }
}

// Transfer a List to a V8 array.
void SetList(CefRefPtr<CefListValue> source, CefRefPtr<CefV8Value> target) {
  ASSERT(target->IsArray());

  int arg_length = static_cast<int>(source->GetSize());
  if (arg_length == 0)
    return;

  for (int i = 0; i < arg_length; ++i)
    SetListValue(target, i, source);
}

#ifdef QT_CORE_LIB
// Transfer a List value to a QVariant array index.
void SetListValue(QVariantList& list, int index,
                  CefRefPtr<CefListValue> value) {
  QVariant new_value;

  CefValueType type = value->GetType(index);
  switch (type) {
    case VTYPE_LIST: {
      CefRefPtr<CefListValue> list = value->GetList(index);
      QVariantList new_list;
      SetList(list, new_list);
      new_value = new_list;
      } break;
    case VTYPE_BOOL:
      new_value = QVariant(value->GetBool(index));
      break;
    case VTYPE_DOUBLE:
      new_value = QVariant(value->GetDouble(index));
      break;
    case VTYPE_INT:
      new_value = QVariant(value->GetInt(index));
      break;
    case VTYPE_STRING: {
      std::wstring str = value->GetString(index).ToWString();
      new_value = QVariant(QString::fromStdWString(str));
      } break;
    default:
      break;
  }

  list.append(new_value);
}

// Transfer a List to a QVariant array. (append)
void SetList(CefRefPtr<CefListValue> source, QVariantList& target) {
  int arg_length = static_cast<int>(source->GetSize());
  if (arg_length == 0)
    return;

  for (int i = 0; i < arg_length; ++i)
    SetListValue(target, i, source);
}
#endif

}  // namespace cefclient
