#ifndef WIDGETPROPERTYINFO_H
#define WIDGETPROPERTYINFO_H

#include <QString>

// Metadata for a property that can be addressed from Csound as
// "<widget channel>/<property>".
struct WidgetPropertyInfo
{
    QString name;
    QString type;
    QString description;
};

#endif // WIDGETPROPERTYINFO_H
