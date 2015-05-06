#ifndef CEFCLIENT_MESSAGE_EVENT_H
#define CEFCLIENT_MESSAGE_EVENT_H
#pragma once

#include <QEvent>
#include <QString>
#include <QVariant>

class MessageEvent : public QEvent {
 public:
  static const QEvent::Type MessageEventType;

  MessageEvent(const QString& name, const QVariantList& args);
  ~MessageEvent(void);

  QString name() const;
  QVariantList args() const;

 private:
  QString name_;
  QVariantList args_;
};

#endif  // CEFCLIENT_MESSAGE_EVENT_H