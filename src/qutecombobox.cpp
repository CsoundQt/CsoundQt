/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "qutecombobox.h"
#include "selectcolorbutton.h"
#include "bundledfonts.h"

#include <QAbstractItemView>
#include <QPainter>
#include <QStyleOptionComboBox>

// Colour properties can be QColor (file/dialog) or strings (Csound outvalue).
static QColor menuColorFromProperty(const QVariant &value)
{
	QColor color = value.value<QColor>();
	if (!color.isValid())
		color = QColor(value.toString());
	return color;
}

FlatComboBox::FlatComboBox(QWidget *parent) : QComboBox(parent)
{
}

void FlatComboBox::setFlatProperties(bool flat, const QColor &background,
                                     const QColor &foreground, int borderWidth,
                                     int borderRadius,
                                     const QColor &borderColor)
{
	m_flat = flat;
	m_background = background.isValid() ? background : QColor("#eff0f1");
	m_foreground = foreground.isValid() ? foreground : QColor("#34393a");
	m_borderColor = borderColor.isValid() ? borderColor : QColor("#adbdc2");
	m_borderWidth = qMax(0, borderWidth);
	m_borderRadius = qMax(0, borderRadius);
	if (!m_flat) {
		if (view() != nullptr)
			view()->setStyleSheet(QString());
		if (m_styledPopup != nullptr) {
			m_styledPopup->setStyleSheet(QString());
			m_styledPopup.clear();
		}
	}
	update();
}

void FlatComboBox::paintEvent(QPaintEvent *event)
{
	if (!m_flat) {
		QComboBox::paintEvent(event);
		return;
	}

	QPainter painter(this);
	painter.setRenderHint(QPainter::Antialiasing);
	const qreal penWidth = m_borderWidth > 0 ? m_borderWidth : 0.0;
	QRectF body = QRectF(rect()).adjusted(penWidth / 2.0, penWidth / 2.0,
	                                      -penWidth / 2.0, -penWidth / 2.0);
	if (m_borderWidth > 0)
		painter.setPen(QPen(m_borderColor, m_borderWidth));
	else
		painter.setPen(Qt::NoPen);
	painter.setBrush(m_background);
	painter.drawRoundedRect(body, m_borderRadius, m_borderRadius);

	const int arrowWidth = 8;
	const int arrowHeight = 5;
	const int rightPadding = 7;
	const int leftPadding = m_borderWidth + 6;
	QRect textRect = rect().adjusted(leftPadding, 0,
	                                 -(rightPadding + arrowWidth + 2), 0);
	QColor textColor = m_foreground;
	if (!isEnabled())
		textColor.setAlpha(130);
	painter.setPen(textColor);
	painter.drawText(textRect, Qt::AlignLeft | Qt::AlignVCenter,
	                 fontMetrics().elidedText(currentText(), Qt::ElideRight,
	                                          textRect.width()));

	const QPointF arrowCenter(width() - rightPadding - arrowWidth / 2.0,
	                          height() / 2.0);
	QPolygonF arrow;
	arrow << QPointF(arrowCenter.x() - arrowWidth / 2.0,
	                 arrowCenter.y() - arrowHeight / 2.0)
	      << QPointF(arrowCenter.x() + arrowWidth / 2.0,
	                 arrowCenter.y() - arrowHeight / 2.0)
	      << QPointF(arrowCenter.x(), arrowCenter.y() + arrowHeight / 2.0);
	painter.setPen(Qt::NoPen);
	painter.setBrush(textColor);
	painter.drawPolygon(arrow);
}

void FlatComboBox::applyPopupStyle()
{
	QAbstractItemView *itemView = view();
	if (itemView == nullptr)
		return;
	itemView->setFont(font());
	const QString sheet = QStringLiteral(
	            "QListView { background-color: %1; color: %2;"
	            " border: %3px solid %4; outline: 0; }"
	            "QListView::item { padding: 3px 6px; }"
	            "QListView::item:selected { background-color: %2; color: %1; }")
	        .arg(m_background.name(), m_foreground.name())
	        .arg(m_borderWidth)
	        .arg(m_borderColor.name());
	itemView->setStyleSheet(sheet);
	if (QWidget *popup = itemView->window(); popup != this) {
		if (m_styledPopup != nullptr && m_styledPopup != popup)
			m_styledPopup->setStyleSheet(QString());
		m_styledPopup = popup;
		popup->setProperty("csqtFlatMenuPopup", true);
		popup->setStyleSheet(QStringLiteral(
		            "QFrame[csqtFlatMenuPopup=\"true\"] {"
		            " background-color: %1; border: 0px; }")
		        .arg(m_background.name()));
	}
}

void FlatComboBox::showPopup()
{
	if (m_flat)
		applyPopupStyle();
	QComboBox::showPopup();
}

QuteComboBox::QuteComboBox(QWidget *parent) : QuteWidget(parent)
{
    m_widget = new FlatComboBox(this);
    m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
	//  canFocus(false);
	//   connect((QComboBox *)m_widget, SIGNAL(released()), this, SLOT(buttonReleased()));
    connect(static_cast<QComboBox *>(m_widget), SIGNAL(currentIndexChanged(int)),
            this, SLOT(indexChanged(int)));
	setProperty("CSQT_selectedIndex", 0);
	setProperty("CSQT_randomizable", false);
	setProperty("CSQT_randomizableGroup", 0);

	// Flat menu defaults. Light-panel colours are the fallback; creation
	// replaces them with dark-panel colours when needed.
	setProperty("CSQT_flatStyle", false);
	setProperty("CSQT_bgcolor", QColor("#eff0f1"));
	setProperty("CSQT_foreground", QColor("#34393a"));
	setProperty("CSQT_bordercolor", QColor("#adbdc2"));
	setProperty("CSQT_borderWidth", 2);
	setProperty("CSQT_borderRadius", 0);

	QFont comboFont = m_widget->font();
	int fontSize = comboFont.pointSize();
	if (fontSize <= 0)
		fontSize = qRound(comboFont.pointSizeF());
	if (fontSize <= 0)
		fontSize = 10;
	setProperty("CSQT_font", BundledFonts::defaultFamily());
	setProperty("CSQT_fontsize", fontSize);
}

QuteComboBox::~QuteComboBox()
{
}

QuteWidgetType QuteComboBox::getWidgetTypeID() { return QuteWidgetType::DROPDOWN; } 


QString QuteComboBox::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "combobox channel(\"" + m_channel + "\"),  ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	line += "value(" + QString::number(m_value) + "), ";
	line += "items(\"" + itemList() + "\")";
	if (property("CSQT_midicc").toInt() >= 0 && property("CSQT_midichan").toInt()>0) { // insert only if midi channel is above 0
		line += ", midiCtrl(\"" + QString::number(property("CSQT_midichan").toInt()) + ",";
		line +=  QString::number(property("CSQT_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteComboBox::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	s.writeStartElement("bsbDropdownItemList");
	for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
		s.writeStartElement("bsbDropdownItem");
		s.writeTextElement("name", static_cast<QComboBox *>(m_widget)->itemText(i));
		s.writeTextElement("value", QString::number(static_cast<QComboBox *>(m_widget)->itemData(i).toInt()) );
		s.writeTextElement("stringvalue", stringValues[i]);
		s.writeEndElement();
	}
	s.writeEndElement();
	s.writeTextElement("selectedIndex", QString::number(((QComboBox *)m_widget)->currentIndex()));
	s.writeTextElement("font", property("CSQT_font").toString());
	s.writeTextElement("fontsize", QString::number(property("CSQT_fontsize").toInt()));
	s.writeTextElement("flatStyle", property("CSQT_flatStyle").toBool() ? "true" : "false");
	writeColorElement(s, "bgcolor", menuColorFromProperty(property("CSQT_bgcolor")));
	writeColorElement(s, "foreground", menuColorFromProperty(property("CSQT_foreground")));
	writeColorElement(s, "bordercolor", menuColorFromProperty(property("CSQT_bordercolor")));
	s.writeTextElement("borderWidth", QString::number(property("CSQT_borderWidth").toInt()));
	s.writeTextElement("borderRadius", QString::number(property("CSQT_borderRadius").toInt()));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("CSQT_randomizableGroup").toInt()));
	s.writeCharacters(property("CSQT_randomizable").toBool() ? "true": "false");
	s.writeEndElement();
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteComboBox::getWidgetType()
{
	return QString("BSBDropdown");
}

QString QuteComboBox::getQml()
{
	QString qml = QString();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif

	// create model
	QString list = "";
	for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
		list += "\"" + static_cast<QComboBox *>(m_widget)->itemText(i) + "\",";
	}
	list.chop(1); //remove last comma

	qml = QString(R"(
				  ComboBox {
					  property string channel: "%1"
					  x: %2 * scaleItem.scale
					  y: %3 * scaleItem.scale
					  width: %4 * scaleItem.scale
					  height: %5 * scaleItem.scale
					  model: [ %6 ]
					  currentIndex: %7
					  onCurrentIndexChanged: if (typeof(csound)!='undefined') csound.setControlChannel(channel, currentIndex);
				  }
	)").arg(m_channel).arg(x()).arg(y()).arg(width()).arg(height()).
			arg(list).arg(((QComboBox *)m_widget)->currentIndex());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return qml;
}

void QuteComboBox::setMidiValue(int value)
{
	QComboBox * cb = static_cast<QComboBox *>(m_widget);

	int index = int (value/127.0 * (cb->count()-1));
	cb->setCurrentIndex(index);

	// not sure if this is necessary
	double newval = static_cast<double>(index);
	setValue( newval );
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);

}

QString QuteComboBox::itemList()
{
	// For old format
	QString list = "";
	for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
		list += static_cast<QComboBox *>(m_widget)->itemText(i) + ",";
	}
	list.chop(1); //remove last comma
	return list;
}

void QuteComboBox::setText(QString text)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	clearItems();
	QStringList items = text.split(",");
	int counter = 0;
	foreach (QString item, items) {
		addItem(item, counter++, "");
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteComboBox::clearItems()
{
	m_widget->blockSignals(true);
	static_cast<QComboBox *>(m_widget)->clear();
	m_widget->blockSignals(false);
}

void QuteComboBox::addItem(QString text, double value, QString stringvalue)
{
	m_widget->blockSignals(true);
	static_cast<QComboBox *>(m_widget)->addItem(text, value);
	stringValues.append(stringvalue);
	m_widget->blockSignals(false);
}

void QuteComboBox::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	int val = (int) m_value;
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	m_widget->blockSignals(true);
	static_cast<QComboBox *>(m_widget)->setCurrentIndex(val);
	m_widget->blockSignals(false);
}

bool QuteComboBox::applyProperty(const QString &name)
{
	if (name == "CSQT_selectedIndex") {
		setValue(property("CSQT_selectedIndex").toInt());
		return true;
	}
	if (name == "CSQT_flatStyle" || name == "CSQT_bgcolor"
			|| name == "CSQT_foreground" || name == "CSQT_bordercolor"
			|| name == "CSQT_borderWidth" || name == "CSQT_borderRadius") {
		updateFlatStyle();
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteComboBox::updateFlatStyle()
{
	auto *combo = static_cast<FlatComboBox *>(m_widget);

	QFont font = combo->font();
	const QString family = property("CSQT_font").toString().trimmed();
	if (!family.isEmpty())
		font.setFamily(BundledFonts::resolveFamily(family));
	int fontSize = property("CSQT_fontsize").toInt();
	if (fontSize <= 0)
		fontSize = 10;
	font.setPointSize(fontSize);
	combo->setFont(font);
	if (combo->view() != nullptr)
		combo->view()->setFont(font);

	combo->setFlatProperties(property("CSQT_flatStyle").toBool(),
	                         menuColorFromProperty(property("CSQT_bgcolor")),
	                         menuColorFromProperty(property("CSQT_foreground")),
	                         property("CSQT_borderWidth").toInt(),
	                         property("CSQT_borderRadius").toInt(),
	                         menuColorFromProperty(property("CSQT_bordercolor")));
}

void QuteComboBox::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
    setValue(property("CSQT_selectedIndex").toInt());
	updateFlatStyle();
}

void QuteComboBox::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Menu");
	int row = 4;

	QLabel *label = new QLabel(dialog);

    auto spacer = new QSpacerItem(20, 20, QSizePolicy::Expanding);
    layout->addItem(spacer, row, 4, Qt::AlignLeft);
	++row;

	label = new QLabel(dialog);
    label->setText("Items (comma-separated)");
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

	text = new QLineEdit(dialog);
    text->setToolTip("Items in the menu, separated by commas");
    text->setMinimumWidth(420);
    text->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    layout->addWidget(text, row,1,1,4, Qt::AlignLeft|Qt::AlignVCenter);
    // text->setSizePolicy()
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	text->setText(itemList());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

	++row;
	label = new QLabel(tr("Font"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	fontComboBox = new QComboBox(dialog);
	fontComboBox->setMaximumWidth(200);
	fontComboBox->addItems(BundledFonts::allFamilies());
	fontComboBox->setCurrentText(
	            BundledFonts::resolveFamily(property("CSQT_font").toString()));
	layout->addWidget(fontComboBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(tr("Size"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	fontSizeSpinBox = new QSpinBox(dialog);
	fontSizeSpinBox->setRange(1, 200);
	fontSizeSpinBox->setValue(property("CSQT_fontsize").toInt());
	layout->addWidget(fontSizeSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);

	// Flat-menu appearance. The controls are only meaningful when the flat
	// style is enabled, so they are disabled otherwise.
	++row;
	flatStyleCheckBox = new QCheckBox(tr("Flat style"), dialog);
	flatStyleCheckBox->setToolTip(tr("Draw the menu with explicit colours and border "
	                                 "instead of the native widget style."));
	flatStyleCheckBox->setChecked(property("CSQT_flatStyle").toBool());
	layout->addWidget(flatStyleCheckBox, row, 0, 1, 2,
	                  Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	label = new QLabel(tr("Background"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	backgroundColorButton = new SelectColorButton(dialog);
	{
		QColor color = menuColorFromProperty(property("CSQT_bgcolor"));
		backgroundColorButton->setColor(color.isValid() ? color : QColor("#eff0f1"));
	}
	layout->addWidget(backgroundColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(tr("Foreground"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	foregroundColorButton = new SelectColorButton(dialog);
	{
		QColor color = menuColorFromProperty(property("CSQT_foreground"));
		foregroundColorButton->setColor(color.isValid() ? color : QColor("#34393a"));
	}
	layout->addWidget(foregroundColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	label = new QLabel(tr("Border"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	borderColorButton = new SelectColorButton(dialog);
	{
		QColor color = menuColorFromProperty(property("CSQT_bordercolor"));
		borderColorButton->setColor(color.isValid() ? color : QColor("#adbdc2"));
	}
	layout->addWidget(borderColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(tr("Border Width"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	borderWidthSpinBox = new QSpinBox(dialog);
	borderWidthSpinBox->setRange(0, 20);
	borderWidthSpinBox->setValue(property("CSQT_borderWidth").toInt());
	layout->addWidget(borderWidthSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	label = new QLabel(tr("Border Radius"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	borderRadiusSpinBox = new QSpinBox(dialog);
	borderRadiusSpinBox->setRange(0, 50);
	borderRadiusSpinBox->setValue(property("CSQT_borderRadius").toInt());
	layout->addWidget(borderRadiusSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

	const QList<QWidget *> flatControls = {
		backgroundColorButton, foregroundColorButton, borderColorButton,
		borderWidthSpinBox, borderRadiusSpinBox
	};
	const auto refreshFlatControls = [this, flatControls]() {
		const bool flat = flatStyleCheckBox->isChecked();
		for (QWidget *widget : flatControls)
			widget->setEnabled(flat);
	};
	connect(flatStyleCheckBox, &QCheckBox::toggled, this, refreshFlatControls);
	refreshFlatControls();
}

void QuteComboBox::applyProperties()
{
	setText(text->text()); // This line can't be locked, as itlocks itself internally

	if (fontComboBox != nullptr) {
		setProperty("CSQT_font", fontComboBox->currentText());
		setProperty("CSQT_fontsize", fontSizeSpinBox->value());
	}
	if (flatStyleCheckBox != nullptr) {
		setProperty("CSQT_flatStyle", flatStyleCheckBox->isChecked());
		setProperty("CSQT_bgcolor", backgroundColorButton->getColor());
		setProperty("CSQT_foreground", foregroundColorButton->getColor());
		setProperty("CSQT_bordercolor", borderColorButton->getColor());
		setProperty("CSQT_borderWidth", borderWidthSpinBox->value());
		setProperty("CSQT_borderRadius", borderRadiusSpinBox->value());
	}

	//#ifdef  USE_WIDGET_MUTEX
	//#endif
	//  widgetLock.lockForWrite();
	//  widgetLock.unlock();
	//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
	QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
}


void QuteComboBox::indexChanged(int value)
{
	//  qDebug() << "QuteComboBox::indexChanged" << value;

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_value = value;
	m_valueChanged = true;
	QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

	emit newValue(channelValue);
}
