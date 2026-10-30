#ifndef WIDGETPROPERTYINFO_H
#define WIDGETPROPERTYINFO_H

#include <QString>

// Whether a name is a value property or a callable "method" (a transitory
// property that performs an action and is never saved).
enum class WidgetPropertyKind { Property, Method };

// Metadata for a property that can be addressed from Csound as
// "<widget channel>/<property>".
struct WidgetPropertyInfo
{
    QString name;
    QString type;
    QString description;
    WidgetPropertyKind kind = WidgetPropertyKind::Property;
};

#endif // WIDGETPROPERTYINFO_H
