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

#include "qutewidget.h"
#include "widgetlayout.h"

QuteWidget::QuteWidget(QWidget *parent):
	QWidget(parent)
{
	propertiesAct = new QAction(tr("&Properties"), this);
	propertiesAct->setStatusTip(tr("Open widget properties"));
	connect(propertiesAct, SIGNAL(triggered()), this, SLOT(openProperties()));

	addChn_kAct = new QAction(tr("Add chn_k to csd"),this);
	addChn_kAct->setStatusTip(tr("Add chn_k definitionto ;;channels section in editor"));
	connect(addChn_kAct, SIGNAL(triggered()), this, SLOT(addChn_k()));

	m_value = 0.0;
	m_value2 = 0.0;
	m_stringValue = "";
	m_valueChanged = false;
	m_value2Changed = false;
	m_locked = false;

	this->setMinimumSize(2,2);
	this->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels

	setProperty("QCS_x", 0);
	setProperty("QCS_y", 0);
    //setProperty("width", 20);
    //setProperty("height", 20);
    setProperty("QCS_width", 20);
    setProperty("QCS_height", 20);
    setProperty("QCS_uuid", QUuid::createUuid().toString());
	setProperty("QCS_visible", true);
	setProperty("QCS_midichan", 0);
	setProperty("QCS_midicc", -3);
}

QuteWidget::~QuteWidget()
{
}

void QuteWidget::setWidgetGeometry(int x, int y, int w, int h)
{
	//  qDebug() << "QuteWidget::setWidgetGeometry" <<x<<y<<w<<h;
	Q_ASSERT(w > 0 && h > 0);
	//	Q_ASSERT(x > 0 && y > 0 and w > 0 && h > 0);
	this->setGeometry(QRect(x,y,w,h));
	m_widget->blockSignals(true);
	m_widget->setGeometry(QRect(0,0,w,h));
	m_widget->blockSignals(false);
	//  this->markChanged();  // It's better not to have geometry changes trigger markChanged as geometry changes can occur for various reasons (e.g. when calling applyInternalProperties)
}

void QuteWidget::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	m_value = value;
	m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteWidget::setValue2(double value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	m_value2 = value;
	m_value2Changed = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteWidget::setValue(QString value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	m_stringValue = value;
	m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteWidget::setMidiValue(int /* value */)
{
    qDebug() << "Not available for this widget." << this;
}

void QuteWidget::setMidiValue2(int /* value */)
{
    qDebug() << "Not available for this widget." << this;
}

void QuteWidget::widgetMessage(QString path, QString text)
{
    qDebug() << text;
	if (property(path.toLocal8Bit()).isValid()) {
		setProperty(path.toLocal8Bit(), text);
		//    applyInternalProperties();
	}
}

void QuteWidget::widgetMessage(QString path, double value)
{
    qDebug() << value;
	if (property(path.toLocal8Bit()).isValid()) {
		setProperty(path.toLocal8Bit(), value);
		//    applyInternalProperties();
	}
}

QString QuteWidget::getChannelName()
{
	//  widgetLock.lockForRead();
	QString name = m_channel;
	//  widgetLock.unlock();
	return name;
}

QString QuteWidget::getChannel2Name()
{
	//  widgetLock.lockForRead();
	QString name = m_channel2;
	//  widgetLock.unlock();
	return name;
}

QString QuteWidget::getCabbageLine()
{
	//Widgets return empty strings when not supported
	return QString("");
}

void QuteWidget::createXmlWriter(QXmlStreamWriter &s)
{
	s.setAutoFormatting(true);
	s.writeStartElement("bsbObject");
	s.writeAttribute("type", getWidgetType());

	s.writeAttribute("version", QCS_CURRENT_XML_VERSION);  // Only for compatibility with blue (absolute values)

	s.writeTextElement("objectName", m_channel);
	s.writeTextElement("x", QString::number(x()));
	s.writeTextElement("y", QString::number(y()));
	s.writeTextElement("width", QString::number(width()));
	s.writeTextElement("height", QString::number(height()));
	s.writeTextElement("uuid", property("QCS_uuid").toString());
	s.writeTextElement("visible", property("QCS_visible").toBool() ? "true":"false");
	s.writeTextElement("midichan", QString::number(property("QCS_midichan").toInt()));
	s.writeTextElement("midicc", QString::number(property("QCS_midicc").toInt()));
}

double QuteWidget::getValue()
{
	// When reimplementing this, remember to use the widget mutex to protect data, as this can be called from many different places
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	double value = m_value;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return value;
}

double QuteWidget::getValue2()
{
	// When reimplementing this, remember to use the widget mutex to protect data, as this can be called from many different places
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	double value = m_value2;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return value;
}

QString QuteWidget::getStringValue()
{
	// When reimplementing this, remember to use the widget mutex to protect data, as this can be called from many different places
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString value = m_stringValue;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return value;
}

QString QuteWidget::getCsladspaLine()
{
	//Widgets return empty strings when not supported
	return QString("");
}

QString QuteWidget::getQml()
{
    //Widgets return empty strings when not supported
    return QString("");
}

QString QuteWidget::getUuid()
{
	if (property("QCS_uuid").isValid())
		return property("QCS_uuid").toString();
	else
		return QString();
}

void QuteWidget::applyInternalProperties()
{
	//  qDebug() << "QuteWidget::applyInternalProperties()";
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	int x,y,width, height;
	x = property("QCS_x").toInt();
	y = property("QCS_y").toInt();
	width = property("QCS_width").toInt();
	height = property("QCS_height").toInt();
	setWidgetGeometry(x,y,width, height);
	m_channel = property("QCS_objectName").toString();
	m_channel2 = property("QCS_objectName2").toString();
	m_midicc = property("QCS_midicc").toInt();
	m_midichan = property("QCS_midichan").toInt();
	setVisible(property("QCS_visible").toBool());
	m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteWidget::markChanged()
{
	emit widgetChanged(this);
}

void QuteWidget::canFocus(bool can)
{
	if (can) {
		this->setFocusPolicy(Qt::StrongFocus);
		m_widget->setFocusPolicy(Qt::StrongFocus);
	}
	else {
		this->setFocusPolicy(Qt::NoFocus);
		m_widget->setFocusPolicy(Qt::NoFocus);
	}
}

void QuteWidget::updateDialogWindow(int cc, int channel) // to update values from midi Learn window to widget properties' dialog
{
	if (dialog->isVisible() && acceptsMidi()) {
		midiccSpinBox->setValue(cc);
		midichanSpinBox->setValue(channel);
		//qDebug()<<"Updated MIDI values in properties dialog"<<cc<<channel;
	}
}

void QuteWidget::contextMenuEvent(QContextMenuEvent *event)
{
	popUpMenu(event->globalPos());
}

void QuteWidget::popUpMenu(QPoint pos)
{
	//  qDebug() << "QuteWidget::popUpMenu";
	if (m_locked) {
		return;
	}
	QMenu menu(this);
	menu.addAction(propertiesAct);
	menu.addSeparator();

	if (!m_channel.isEmpty() || !m_channel2.isEmpty()) {
		menu.addAction(addChn_kAct);
		menu.addSeparator();
	}

	QList<QAction *> actionList = getParentActionList();

	for (int i = 0; i < actionList.size(); i++) {
		menu.addAction(actionList[i]);
	}
	WidgetLayout *layout = static_cast<WidgetLayout *>(this->parentWidget());
	layout->setCurrentPosition(layout->mapFromGlobal(pos));

	menu.addSeparator();
	QMenu createMenu(tr("Create New", "Menu name in widget right-click menu"),&menu);
	createMenu.addAction(layout->createSliderAct);
	createMenu.addAction(layout->createLabelAct);
	createMenu.addAction(layout->createDisplayAct);
	createMenu.addAction(layout->createScrollNumberAct);
	createMenu.addAction(layout->createLineEditAct);
	createMenu.addAction(layout->createSpinBoxAct);
	createMenu.addAction(layout->createButtonAct);
	createMenu.addAction(layout->createKnobAct);
	createMenu.addAction(layout->createCheckBoxAct);
	createMenu.addAction(layout->createMenuAct);
	createMenu.addAction(layout->createMeterAct);
	createMenu.addAction(layout->createConsoleAct);
	createMenu.addAction(layout->createGraphAct);
	createMenu.addAction(layout->createScopeAct);

	menu.addMenu(&createMenu);

	menu.addSeparator();
	menu.addAction(layout->storePresetAct);
	menu.addAction(layout->newPresetAct);
	menu.addAction(layout->recallPresetAct);
	menu.addSeparator();

	QMenu presetMenu(tr("Presets"),&menu);

	QList<int> list = layout->getPresetNums();
	for (int i = 0; i < list.size(); i++) {
		QAction *act = new QAction(layout->getPresetName(list[i]), &menu);
		act->setData(i);
		connect(act, SIGNAL(triggered()), layout, SLOT(loadPresetFromAction()));
		presetMenu.addAction(act);
	}

	menu.exec(pos);
}

void QuteWidget::openProperties()
{
	createPropertiesDialog();

	connect(acceptButton, SIGNAL(released()), dialog, SLOT(accept()));
	connect(dialog, SIGNAL(accepted()), this, SLOT(apply()));
	connect(applyButton, SIGNAL(released()), this, SLOT(apply()));
	connect(cancelButton, SIGNAL(released()), dialog, SLOT(close()));
	if (acceptsMidi()) {
		connect(midiLearnButton, SIGNAL(released()),this, SLOT(openMidiDialog()));
	}
	dialog->exec();
	if (dialog->result() != QDialog::Accepted) {
		qDebug() << "QuteWidget::openProperties() dialog not accepted";
	}
	//  dialog->deleteLater();
	parentWidget()->setFocus(Qt::OtherFocusReason); // For some reason focus is grabbed away from the layout, but this doesn't solve the problem...
}


void QuteWidget::deleteWidget()
{
	//   qDebug("QuteWidget::deleteWidget()");
	emit(deleteThisWidget(this));
}

void QuteWidget::openMidiDialog()
{
	emit showMidiLearn(this);
}

void QuteWidget::addChn_k()
{
	//qDebug()<<Q_FUNC_INFO << m_channel << m_channel2;
	if (!m_channel.isEmpty()) {
		emit addChn_kSignal(m_channel);
	}
	if (!m_channel2.isEmpty()) {
		emit addChn_kSignal(m_channel2);
	}
}

void QuteWidget::createPropertiesDialog()
{
//	qDebug() << "QuteWidget::createPropertiesDialog()---Dynamic Properties:\n" << dynamicPropertyNames ();
	dialog = new QDialog(this);
	dialog->resize(300, 300);
	//  dialog->setModal(true);
	layout = new QGridLayout(dialog);
	QLabel *label = new QLabel(dialog);
	label->setText("X =");
	layout->addWidget(label, 0, 0, Qt::AlignRight|Qt::AlignVCenter);
	xSpinBox = new QSpinBox(dialog);
	xSpinBox->setMaximum(9999);
	layout->addWidget(xSpinBox, 0, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Y =");
	layout->addWidget(label, 0, 2, Qt::AlignRight|Qt::AlignVCenter);
	ySpinBox = new QSpinBox(dialog);
	ySpinBox->setMaximum(9999);
	layout->addWidget(ySpinBox, 0, 3, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText(tr("Width ="));
	layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
	wSpinBox = new QSpinBox(dialog);
	wSpinBox->setMaximum(9999);
	layout->addWidget(wSpinBox, 1, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText(tr("Height ="));
	layout->addWidget(label, 1, 2, Qt::AlignRight|Qt::AlignVCenter);
	hSpinBox = new QSpinBox(dialog);
	hSpinBox->setMaximum(9999);
	layout->addWidget(hSpinBox, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);
	channelLabel = new QLabel(dialog);
	channelLabel->setText(tr("Channel name ="));
	channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(channelLabel, 3, 0, Qt::AlignLeft|Qt::AlignVCenter);
	nameLineEdit = new QLineEdit(dialog);
	nameLineEdit->setFocus(Qt::OtherFocusReason);
	nameLineEdit->selectAll();
	layout->addWidget(nameLineEdit, 3, 1, Qt::AlignLeft|Qt::AlignVCenter);
	if (acceptsMidi()) { // only when MIDI-enabled widgets
		label = new QLabel(dialog);
		label->setText("MIDI CC =");
		layout->addWidget(label, 14, 0, Qt::AlignRight|Qt::AlignVCenter);
		midiccSpinBox = new QSpinBox(dialog);
		midiccSpinBox->setRange(0,119);
		layout->addWidget(midiccSpinBox, 14,1, Qt::AlignLeft|Qt::AlignVCenter);
		label = new QLabel(dialog);
		label->setText("MIDI Channel =");
		layout->addWidget(label, 14, 2, Qt::AlignRight|Qt::AlignVCenter);
		midichanSpinBox = new QSpinBox(dialog);
		midichanSpinBox->setRange(0,127);
		layout->addWidget(midichanSpinBox, 14,3, Qt::AlignLeft|Qt::AlignVCenter);

		midiLearnButton = new QPushButton(tr("Midi learn"));
		layout->addWidget(midiLearnButton,14,4, Qt::AlignLeft|Qt::AlignVCenter);
	}
	acceptButton = new QPushButton(tr("Ok"));
	acceptButton->setDefault(true);
	layout->addWidget(acceptButton, 15, 3, Qt::AlignCenter|Qt::AlignVCenter);
	applyButton = new QPushButton(tr("Apply"));
	layout->addWidget(applyButton, 15, 1, Qt::AlignCenter|Qt::AlignVCenter);
	cancelButton = new QPushButton(tr("Cancel"));
	layout->addWidget(cancelButton, 15, 2, Qt::AlignCenter|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	xSpinBox->setValue(this->x());
	ySpinBox->setValue(this->y());
	wSpinBox->setValue(this->width());
	hSpinBox->setValue(this->height());
	nameLineEdit->setText(getChannelName());
	if (acceptsMidi()) {
		midiccSpinBox->setValue(this->m_midicc);
		midichanSpinBox->setValue(this->m_midichan);
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteWidget::applyProperties()
{
//	qDebug();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	setProperty("QCS_objectName", nameLineEdit->text());
	setProperty("QCS_x", xSpinBox->value());
	setProperty("QCS_y",ySpinBox->value());
	setProperty("QCS_width", wSpinBox->value());
	setProperty("QCS_height", hSpinBox->value());
	if (acceptsMidi()) {
		setProperty("QCS_midicc", midiccSpinBox->value());
		setProperty("QCS_midichan", midichanSpinBox->value());
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	applyInternalProperties();
	//  setChannelName(nameLineEdit->text());
	//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());

	//  this->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
	emit(widgetChanged(this));
	emit propertiesAccepted();
	parentWidget()->setFocus(Qt::PopupFocusReason); // For some reason focus is grabbed away from the layout
	m_valueChanged = true;
}

QList<QAction *> QuteWidget::getParentActionList()
{
	QList<QAction *> actionList;
	// A bit of a kludge... Must get the Widget Panel, which is the parent to the widget which
	// holds the actual QuteWidgets
	WidgetLayout *layout = static_cast<WidgetLayout *>(this->parentWidget());
	actionList.append(layout->copyAct);
	actionList.append(layout->pasteAct);
	actionList.append(layout->cutAct);
	actionList.append(layout->deleteAct);
	actionList.append(layout->duplicateAct);
	actionList.append(layout->alignLeftAct);
	actionList.append(layout->alignRightAct);
	actionList.append(layout->alignTopAct);
	actionList.append(layout->alignBottomAct);
	actionList.append(layout->sendToBackAct);
	actionList.append(layout->distributeHorizontalAct);
	actionList.append(layout->distributeVerticalAct);
	actionList.append(layout->alignCenterHorizontalAct);
	actionList.append(layout->alignCenterVerticalAct);
	// FIXME put edit action in menu
	//  actionList.append(layout->editAct);
	return actionList;
}

void QuteWidget::apply()
{
	applyProperties();
}
