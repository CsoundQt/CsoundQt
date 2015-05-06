#include "message_event.h"

const QEvent::Type MessageEvent::MessageEventType = (QEvent::Type)QEvent::registerEventType();

MessageEvent::MessageEvent(const QString& name, const QVariantList& args)
    : name_(name),
      args_(args),
      QEvent(MessageEventType) {
}

MessageEvent::~MessageEvent(void) {
}

QString MessageEvent::name() const {
  return name_;
}

QVariantList MessageEvent::args() const {
  return args_;
}