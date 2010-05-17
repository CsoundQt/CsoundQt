/*
    Copyright (C) 2008, 2009 Andres Cabrera
    mantaraya36@gmail.com

    This file is part of QuteCsound.

    QuteCsound is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    QuteCsound is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#include "qutetext.h"
#include <math.h>

QuteText::QuteText(QWidget *parent) : QuteWidget(parent)
{
  m_value = 0.0;
  m_widget = new QLabel(this);
  static_cast<QLabel*>(m_widget)->setWordWrap (true);
  static_cast<QLabel*>(m_widget)->setMargin (5);
//  static_cast<QLabel*>(m_widget)->setTextFormat(Qt::RichText);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  setMouseTracking(true);
//  canFocus(true);

//   connect(static_cast<QLabel*>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
  setProperty("QCS_label", "");
  setProperty("QCS_alignment", "left");
  setProperty("QCS_precision", 3);
  setProperty("QCS_font", "Arial");
  setProperty("QCS_fontsize", 12.0);
  setProperty("QCS_bgcolor", QColor());
  setProperty("QCS_bgcolormode", false);
  setProperty("QCS_color", Qt::black);
  setProperty("QCS_bordermode", "noborder");
  setProperty("QCS_borderradius", 1);
  setProperty("QCS_borderwidth", 1);

  m_fontScaling = 1.0;
  m_fontOffset = 1.0;
}

QuteText::~QuteText()
{
}

void QuteText::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
//  if (m_type == "display") {
  m_value = value;
  m_stringValue = QString::number(value, 'f', property("QCS_precision").toInt());
  m_valueChanged = true;
//  }
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteText::setValue(QString value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
//  setText(value);
  m_stringValue = value;
  m_value = value.toDouble();
  m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteText::setType(QString type)
{
  m_type = type;
}

void QuteText::setAlignment(QString alignment)
{
  qDebug() << "QuteText::setAlignment " <<  alignment;
  Qt::Alignment align;
  if (alignment == "left") {
    align = Qt::AlignLeft|Qt::AlignTop;
  }
  else if (alignment == "center") {
    align = Qt::AlignHCenter|Qt::AlignTop;
  }
  else if (alignment == "right") {
    align = Qt::AlignRight|Qt::AlignTop;
  }
  else {
      align = Qt::AlignLeft|Qt::AlignTop;
  }
  static_cast<QLabel* >(m_widget)->setAlignment(align);
}

void QuteText::setFont(QString font)
{
  setProperty("QCS_font", font);
}

void QuteText::setFontSize(int fontSize)
{
  qDebug() << "QuteText::setFontSize(int fontSize) " << fontSize;
  setProperty("QCS_fontsize", fontSize);
}

void QuteText::setTextColor(QColor textColor)
{
  // For old format only
  setProperty("QCS_color", textColor);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, textColor);
  m_widget->setPalette(palette);
}

void QuteText::setBgColor(QColor bgColor)
{
  // For old format only
  setProperty("QCS_bgcolor", bgColor);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::Window, bgColor);
  m_widget->setPalette(palette);
}

void QuteText::setBg(bool bg)
{
  // For old format only
  m_widget->setAutoFillBackground(bg);
}

void QuteText::setBorder(bool border)
{
  if (border)
    static_cast<QFrame*>(m_widget)->setFrameShape(QFrame::Box);
  else
    static_cast<QFrame*>(m_widget)->setFrameShape(QFrame::NoFrame);
}

void QuteText::setText(QString text)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif

  setProperty("QCS_label", text);
  QString displayText = text;
  m_stringValue = text;
  m_valueChanged = true;
  displayText.replace("\n", "<br />");
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif

  m_widget->blockSignals(true);
  static_cast<QLabel*>(m_widget)->setText(displayText);
  m_widget->blockSignals(false);
}

void QuteText::refreshWidget()
{
  setText(m_stringValue);
  m_valueChanged = false;
}

void QuteText::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
//  qDebug() << "QuteText::applyInternalProperties()";

  static_cast<QLabel*>(m_widget)->setText(property("QCS_label").toString());
  m_stringValue = property("QCS_label").toString();
  m_value = m_stringValue.toDouble();
  m_valueChanged = true;
//  qDebug() << "QuteText::applyInternalProperties()" << property("QCS_label").toString();
  Qt::Alignment align;
  QString alignText = property("QCS_alignment").toString();
  if (alignText == "left") {
    align = Qt::AlignLeft|Qt::AlignTop;
  }
  else if (alignText == "center") {
    align = Qt::AlignHCenter|Qt::AlignTop;
  }
  else if (alignText == "right") {
    align = Qt::AlignRight|Qt::AlignTop;
  }
  static_cast<QLabel*>(m_widget)->setAlignment(align);
  setTextColor(property("QCS_color").value<QColor>());
  QString borderStyle = (property("QCS_bordermode").toString() == "border" ? "solid": "none");
  m_widget->setStyleSheet("QLabel { font-family:\"" + property("QCS_font").toString()
                          + "\"; font-size: " + QString::number((property("QCS_fontsize").toDouble()*m_fontScaling)  + m_fontOffset) + "pt"
                          + (property("QCS_bgcolormode").toBool() ?
                                    QString("; background-color:") + property("QCS_bgcolor").value<QColor>().name() : QString("; "))
                          + "; color:" + property("QCS_color").value<QColor>().name()
                          + "; border-color:" + property("QCS_color").value<QColor>().name()
                          + "; border-radius:" + QString::number(property("QCS_borderradius").toInt()) + "px"
                          + "; border-width: " + QString::number(property("QCS_borderwidth").toInt()) + "px"
                          + "; border-style: " + borderStyle
                          + "; }");
//  qDebug() << property("QCS_bgcolormode").toBool();
//  qDebug() << "QuteText::applyInternalProperties() sylesheet" <<  m_widget->styleSheet();

#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteText::setFontScaling(double scaling)
{
  m_fontScaling = scaling;
  applyInternalProperties();
}

void QuteText::setFontOffset(double offset)
{
  m_fontOffset = offset;
  applyInternalProperties();
}

QString QuteText::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioText {" + QString::number(property("QCS_x").toInt()) + ", " + QString::number(property("QCS_y").toInt()) + "} ";
  line += "{"+ QString::number(property("QCS_width").toInt()) +", "+ QString::number(property("QCS_height").toInt()) +"} ";
  line += m_type + " ";
  line += QString::number(m_value, 'f', 6) + " 0.00100 \"" + m_channel + "\" ";
  QString alignment = "";
  if (((QLabel *)m_widget)->alignment() & Qt::AlignLeft)
    alignment = "left";
  else if (((QLabel *)m_widget)->alignment() & Qt::AlignCenter)
    alignment = "center";
  else if (((QLabel *)m_widget)->alignment() & Qt::AlignRight)
    alignment = "right";
  line += alignment + " ";
  line += "\"" + property("QCS_font").toString() + "\" " + QString::number(property("QCS_fontsize").toInt()) + " ";
  QColor color = m_widget->palette().color(QPalette::WindowText);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  color = m_widget->palette().color(QPalette::Window);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  line += m_widget->autoFillBackground()? "background ":"nobackground ";
  line += static_cast<QFrame*>(m_widget)->frameShape()==QFrame::NoFrame ? "noborder ": "border ";
//   line += ((QLabel *)m_widget)->toPlainText();
  QString outText = property("QCS_label").toString();
  outText.replace(QRegExp("[\n\r]"), "\u00AC");
  line += outText;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteText::getWidgetType()
{
  return QString("BSBLabel");
}

QString QuteText::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  s.writeTextElement("label", property("QCS_label").toString());
  s.writeTextElement("alignment", property("QCS_alignment").toString());

  s.writeTextElement("font", property("QCS_font").toString());
  s.writeTextElement("fontsize", QString::number(property("QCS_fontsize").toInt()));
  s.writeTextElement("precision", QString::number(property("QCS_precision").toInt()));

  QColor color = property("QCS_color").value<QColor>();
  s.writeStartElement("color");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  color = property("QCS_bgcolor").value<QColor>();
  s.writeStartElement("bgcolor");
  s.writeAttribute("mode", property("QCS_bgcolormode").toBool()? "background":"nobackground");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();

  s.writeTextElement("bordermode", property("QCS_bordermode").toString());
  s.writeTextElement("borderradius", QString::number(property("QCS_borderradius").toInt()));
  s.writeTextElement("borderwidth", QString::number(property("QCS_borderwidth").toInt()));
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

void QuteText::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  if (m_type == "label") {
    dialog->setWindowTitle("Label");
    channelLabel->hide();
    nameLineEdit->hide();
  }
  else if (m_type == "display") {
    dialog->setWindowTitle("Display");
  }

  QLabel *label = new QLabel(dialog);
  label->setText(tr("Text:"));
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QTextEdit(dialog);
  text->setAcceptRichText(false);
  text->setText(property("QCS_label").toString());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
  label = new QLabel(dialog);
  label->setText(tr("Text Color"));
  layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
  textColor = new QPushButton(dialog);
  layout->addWidget(textColor, 6,1, Qt::AlignLeft|Qt::AlignVCenter);
  connect(textColor, SIGNAL(released()), this, SLOT(selectTextColor()));
  label = new QLabel(dialog);
  label->setText(tr("Background Color"));
  layout->addWidget(label, 6, 2, Qt::AlignRight|Qt::AlignVCenter);
  bgColor = new QPushButton(dialog);
  layout->addWidget(bgColor, 6,3, Qt::AlignLeft|Qt::AlignVCenter);
  bg = new QCheckBox("Background", dialog);
  layout->addWidget(bg, 7,3, Qt::AlignLeft|Qt::AlignVCenter);
  border = new QCheckBox("Border", dialog);
  layout->addWidget(border, 7,2, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Font"));
  layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
  font = new QFontComboBox(dialog);
  layout->addWidget(font, 7, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Font Size"));
  layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
  fontSize = new QSpinBox(dialog);
  layout->addWidget(fontSize,8, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Border Radius"));
  layout->addWidget(label, 8, 2, Qt::AlignRight|Qt::AlignVCenter);
  borderRadius = new QSpinBox(dialog);
  layout->addWidget(borderRadius, 8, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Border Width"));
  layout->addWidget(label, 9, 2, Qt::AlignRight|Qt::AlignVCenter);
  borderWidth = new QSpinBox(dialog);
  layout->addWidget(borderWidth, 9, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Alignment"));
  layout->addWidget(label, 9, 0, Qt::AlignRight|Qt::AlignVCenter);
  alignment = new QComboBox(dialog);
  alignment->addItem(tr("Left", "Alignment"));
  alignment->addItem(tr("Center", "Alignment"));
  alignment->addItem(tr("Right", "Alignment"));
  layout->addWidget(alignment,9, 1, Qt::AlignLeft|Qt::AlignVCenter);
  connect(bgColor, SIGNAL(released()), this, SLOT(selectBgColor()));
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
//   QPixmap pixmap(64,64);
  QPixmap pixmap(64,64);
  pixmap.fill(property("QCS_color").value<QColor>());
  textColor->setIcon(pixmap);
  QPalette palette(property("QCS_color").value<QColor>());
  textColor->setPalette(palette);
  palette.color(QPalette::Window);
  pixmap.fill(property("QCS_bgcolor").value<QColor>());
  bgColor->setIcon(pixmap);
  palette = QPalette(property("QCS_bgcolor").value<QColor>());
  bgColor->setPalette(palette);
  palette.color(QPalette::Window);
  bg->setChecked(property("QCS_bgcolormode").toBool());
  border->setChecked(property("QCS_bordermode").toString() == "border");
  font->setCurrentFont(QFont(property("QCS_font").toString()));
  fontSize->setValue(property("QCS_fontsize").toInt());
  borderRadius->setValue(property("QCS_borderradius").toInt());
  borderWidth->setValue(property("QCS_borderwidth").toInt());
  QString currentAlignment = property("QCS_alignment").toString();
  int align;
  if (currentAlignment == "left") {
      align = 0;
  }
  else if (currentAlignment == "center") {
      align = 1;
  }
  else if (currentAlignment == "right") {
      align = 2;
  }
  else
    align = 0;
  alignment->setCurrentIndex(align);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteText::applyProperties()
{
  qDebug() << "QuteText::applyProperties()";
  setProperty("QCS_label", text->toPlainText());
  switch (alignment->currentIndex()) {
    case 0:
      setProperty("QCS_alignment", "left");
      break;
    case 1:
      setProperty("QCS_alignment", "center");
      break;
    case 2:
      setProperty("QCS_alignment", "right");
      break;
    default:
      setProperty("QCS_alignment", "");
  }
  setProperty("QCS_font", font->currentFont().family());
  setProperty("QCS_fontsize", fontSize->value());
  setProperty("QCS_bgcolor", bgColor->palette().color(QPalette::Window));
  setProperty("QCS_bgcolormode", bg->isChecked());
  setProperty("QCS_color", textColor->palette().color(QPalette::Window));
  setProperty("QCS_bordermode", border->isChecked() ? "border" : "noborder");
  setProperty("QCS_borderradius", borderRadius->value());
  setProperty("QCS_borderwidth", borderWidth->value());

  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteText::selectTextColor()
{
  QColor color = QColorDialog::getColor(m_widget->palette().color(QPalette::WindowText), this);
  if (color.isValid()) {
//    setTextColor(color);
//    setProperty("QCS_color", color);
    textColor->setPalette(QPalette(color));
    QPixmap pixmap(64,64);
    pixmap.fill(color);
    textColor->setIcon(pixmap);
  }
}

void QuteText::selectBgColor()
{
  QColor color = QColorDialog::getColor(m_widget->palette().color(QPalette::Window), this);
  if (color.isValid()) {
//    setBgColor(color);
//    setProperty("QCS_bgcolor", color);
    bgColor->setPalette(QPalette(color));
    QPixmap pixmap(64,64);
    pixmap.fill(color);
    bgColor->setIcon(pixmap);
  }
}

/* -----------------------------------------------------------------*/
/*               QuteLineEdit class                                 */
/* -----------------------------------------------------------------*/

QuteLineEdit::QuteLineEdit(QWidget* parent) : QuteText(parent)
{
  delete m_widget; //delete widget created by parent constructor
  m_widget = new QLineEdit(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  connect(static_cast<QLineEdit*>(m_widget), SIGNAL(textEdited(QString)),
          this, SLOT(textEdited(QString)));
//   connect(static_cast<QLineEdit*>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
  m_type = "edit";
  setProperty("QCS_bordermode", QVariant()); // Remove these property
  setProperty("QCS_borderradius", QVariant()); // Remove these property
  setProperty("QCS_borderwidth", QVariant()); // Remove these property
}

QuteLineEdit::~QuteLineEdit()
{
}

void QuteLineEdit::setText(QString text)
{
  setProperty("QCS_label", text);
  int cursorPos = static_cast<QLineEdit*>(m_widget)->cursorPosition();
  m_widget->blockSignals(true);
  static_cast<QLineEdit*>(m_widget)->setText(text);
  m_widget->blockSignals(false);
  static_cast<QLineEdit*>(m_widget)->setCursorPosition(cursorPos);
}

QString QuteLineEdit::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioText {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type + " ";
  line += QString::number(m_value, 'f', 6) + " 0.00100 \"" + m_channel + "\" ";
  line += property("QCS_alignmet").toString() + " ";
  line += "\"" + property("QCS_font").toString() + "\" " + QString::number(property("QCS_fontsize").toInt()) + " ";
  QColor color = property("QCS_color").value<QColor>();
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  color = property("QCS_bgcolor").value<QColor>();
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  line += property("QCS_bgcolormode").toBool() ? "true":"false";
  line += "noborder ";
  line += static_cast<QLineEdit*>(m_widget)->text();
//   qDebug("QuteLineEdit::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteLineEdit::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif

  s.writeTextElement("label",  static_cast<QLineEdit *>(m_widget)->text());
  s.writeTextElement("alignment", property("QCS_alignment").toString());

  s.writeTextElement("font", property("QCS_font").toString());
  s.writeTextElement("fontsize", QString::number(property("QCS_fontsize").toInt()));
  s.writeTextElement("precision", QString::number(property("QCS_precision").toInt()));

  QColor color = m_widget->palette().color(QPalette::WindowText);
  s.writeStartElement("color");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  color = m_widget->palette().color(QPalette::Window);
  s.writeStartElement("bgcolor");
  s.writeAttribute("mode", m_widget->autoFillBackground()? "background":"nobackground");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();

  s.writeTextElement("background", m_widget->autoFillBackground()? "background":"nobackground");
//  s.writeTextElement("border", "border");
//
//  s.writeTextElement("bordermode", property("QCS_bordermode").toString());
//  s.writeTextElement("borderradius", QString::number(property("QCS_borderradius").toInt()));
//  s.writeTextElement("randomizable", "");
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

QString QuteLineEdit::getWidgetType()
{
  return QString("BSBLineEdit");
}

QString QuteLineEdit::getStringValue()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString stringValue = static_cast<QLineEdit *>(m_widget)->text();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return stringValue;
}

double QuteLineEdit::getValue()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  double value = static_cast<QLineEdit *>(m_widget)->text().toDouble();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
   return value;
}

void QuteLineEdit::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteLineEdit::applyInternalProperties()";

//  static_cast<QLineEdit*>(m_widget)->setText(property("QCS_label").toString());
  m_stringValue = property("QCS_label").toString();
  m_valueChanged = true;
  Qt::Alignment align;
  QString alignText = property("QCS_alignment").toString();
  if (alignText == "left") {
    align = Qt::AlignLeft|Qt::AlignTop;
  }
  else if (alignText == "center") {
    align = Qt::AlignHCenter|Qt::AlignTop;
  }
  else if (alignText == "right") {
    align = Qt::AlignRight|Qt::AlignTop;
  }
  static_cast<QLineEdit*>(m_widget)->setAlignment(align);
  setTextColor(property("QCS_color").value<QColor>());
  QString borderStyle = (property("QCS_bordermode").toString() == "border" ? "solid": "none");
  m_widget->setStyleSheet("QLabel { font-family:\"" + property("QCS_font").toString()
                          + "\"; font-size: " + QString::number((property("QCS_fontsize").toDouble()*m_fontScaling)  + m_fontOffset)  + "pt"
                          + (property("QCS_bgcolormode").toBool() ?
                                    QString("; background-color:") + property("QCS_bgcolor").value<QColor>().name() : QString("; "))
                          + "; color:" + property("QCS_color").value<QColor>().name()
                          + "; border-color:" + property("QCS_color").value<QColor>().name()
                          + "; border-radius:" + QString::number(property("QCS_borderradius").toInt()) + "px"
                          + "; border-width:" + QString::number(property("QCS_borderwidth").toInt()) + "px"
                          + "; border-style: " + borderStyle
                          + "; }");
//  qDebug() << "QuteLineEdit::applyInternalProperties() sylesheet" <<  m_widget->styleSheet();
}

void QuteLineEdit::dropEvent(QDropEvent *event)
{
  qDebug("QuteLineEdit::dropEvent");
  QWidget::dropEvent(event);
}

void QuteLineEdit::createPropertiesDialog()
{
  QuteText::createPropertiesDialog();
  dialog->setWindowTitle("Line Edit");
  fontSize->hide();
  font->hide();
  border->hide();
  bg->hide();
  textColor->hide();
  bgColor->hide();
  borderRadius->hide();
  borderWidth->hide();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  text->setText(property("QCS_label").toString());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteLineEdit::applyProperties()
{
  setProperty("QCS_label", text->toPlainText());
  switch (alignment->currentIndex()) {
    case 0:
      setProperty("QCS_alignment", "left");
      break;
    case 1:
      setProperty("QCS_alignment", "center");
      break;
    case 2:
      setProperty("QCS_alignment", "right");
      break;
    default:
      setProperty("QCS_alignment", "");
  }
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteLineEdit::textEdited(QString text)
{
  m_stringValue = text;
  m_valueChanged = true;
}

/* -----------------------------------------------------------------*/
/*               QuteScrollNumber class                             */
/* -----------------------------------------------------------------*/

QuteScrollNumber::QuteScrollNumber(QWidget* parent) : QuteText(parent)
{
  delete m_widget; //delete widget created by parent constructor
  m_widget = new ScrollNumberWidget(this);
//  connect(static_cast<ScrollNumberWidget*>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
  connect(static_cast<ScrollNumberWidget*>(m_widget), SIGNAL(addValue(double)), this, SLOT(addValue(double)));
  connect(static_cast<ScrollNumberWidget*>(m_widget), SIGNAL(setValue(double)), this, SLOT(setValueFromWidget(double)));
  m_type = "scroll";

  setProperty("QCS_value", (double) 0.0);
  setProperty("QCS_resolution", (double) 0.01);
  setProperty("QCS_minimum",(double)  -999999999999.0);
  setProperty("QCS_maximum", (double) 99999999999999.0);
  setProperty("QCS_randomizable", false);
  setProperty("QCS_label", QVariant()); // Remove this property which is part of parent class.
  setProperty("QCS_precision", QVariant()); // Remove this property which is part of parent class.
  setProperty("QCS_mouseControl", "continuous");
//  setProperty("QCS_mouseControlAct", "jump");
  m_places = 2;
}

QuteScrollNumber::~QuteScrollNumber()
{
}

void QuteScrollNumber::setResolution(double resolution)
{
//  qDebug() << "QuteScrollNumber::setResolution " << resolution;
  static_cast<ScrollNumberWidget*>(m_widget)->setResolution(resolution);
  int i;
  for (i = 0; i < 8; i++) {
//     Check for used decimal places.
    if ((resolution * pow(10, i)) == (int) (resolution * pow(10,i)) )
      break;
  }
  m_places = i;
}

void QuteScrollNumber::setAlignment(int alignment)
{
//   qDebug("QuteText::setAlignment %i", alignment);
  Qt::Alignment align;
  switch (alignment) {
    case 0:
      align = Qt::AlignLeft|Qt::AlignTop;
      break;
    case 1:
      align = Qt::AlignHCenter|Qt::AlignTop;
      break;
    case 2:
      align = Qt::AlignRight|Qt::AlignTop;
      break;
    default:
      align = Qt::AlignLeft|Qt::AlignTop;
  }
  static_cast<ScrollNumberWidget*>(m_widget)->setAlignment(align);
}

//void QuteScrollNumber::setText(QString text)
//{
//  qDebug() << "QuteScrollNumber::setText" << text;
////  m_text = text;
////  int size;
////  if (m_fontSize >= QCS_XXLARGE)
////    size = 7;
////  else if (m_fontSize >= QCS_XLARGE)
////    size = 6;
////  else if (m_fontSize >= QCS_LARGE)
////    size = 5;
////  else if (m_fontSize >= QCS_MEDIUM)
////    size = 4;
////  else if (m_fontSize >= QCS_SMALL)
////    size = 3;
////  else if (m_fontSize >= QCS_XSMALL)
////    size = 2;
////  else
////    size = 1;
////  text.prepend("<font face=\"" + property("QCS_font").toString() + "\" size=\""
////               + QString::number(property("QCS_fontsize").toInt()) + "\">");
////  text.append("</font>");
//
////  setProperty("QCS_label", text);
//  setValue(text.toDouble());
////  m_widget->blockSignals(true);
////  static_cast<ScrollNumberWidget*>(m_widget)->setText(text);
////  m_widget->blockSignals(false);
//
//}

QString QuteScrollNumber::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioText {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type + " ";
  line += QString::number(m_value, 'f', 6) + " ";
  line += QString::number(property("QCS_resolution").toDouble(), 'f', 6);
  line += + " \"" + m_channel + "\" ";
  line += property("QCS_alignment").toString() + " ";
  line += "\"" + property("QCS_font").toString() + "\" "
          + QString::number(property("QCS_fontsize").toInt()) + " ";
  QColor color = property("QCS_color").value<QColor>();
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  color = property("QCS_bgcolor").value<QColor>();
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  line += property("QCS_bgcolormode").toBool() ? "background ":"nobackground ";
  line += property("QCS_bordermode").toBool() ? "noborder ": "border ";
  QString outText = property("QCS_label").toString();
  outText.replace(QRegExp("[\n\r]"), "\u00AC");
  line += outText;
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteScrollNumber::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ControlPort=" + m_channel + "|" + m_channel + "\n";
  line += "Range=9999|9999";
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteScrollNumber::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  s.writeTextElement("alignment", property("QCS_alignment").toString());
  s.writeTextElement("font", property("QCS_font").toString());
  s.writeTextElement("fontsize", QString::number(property("QCS_fontsize").toInt()));

  QColor color = property("QCS_color").value<QColor>();
  s.writeStartElement("color");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  color = property("QCS_bgcolor").value<QColor>();
  s.writeStartElement("bgcolor");
  s.writeAttribute("mode", property("QCS_bgcolormode").toBool()? "background":"nobackground");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();

  s.writeTextElement("value", QString::number(m_value, 'f', 8));
  s.writeTextElement("resolution", QString::number(property("QCS_resolution").toDouble(), 'f', 8));
  s.writeTextElement("minimum", QString::number(property("QCS_minimum").toDouble(), 'f', 8));
  s.writeTextElement("maximum", QString::number(property("QCS_maximum").toDouble(), 'f', 8));
  s.writeTextElement("bordermode", property("QCS_bordermode").toString());
  s.writeTextElement("borderradius", QString::number(property("QCS_borderradius").toInt()));
  s.writeTextElement("borderwidth", QString::number(property("QCS_borderwidth").toInt()));
  s.writeTextElement("randomizable", property("QCS_randomizable").toBool() ? "true": "false");
  s.writeStartElement("mouseControl");
  s.writeAttribute("act", property("QCS_mouseControl").toString());
  s.writeEndElement();

  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

QString QuteScrollNumber::getWidgetType()
{
  return QString("BSBScrollNumber");
}

//QString QuteScrollNumber::getStringValue()
//{
//#ifdef  USE_WIDGET_MUTEX
//  widgetLock.lockForRead();
//#endif
//  QString string = static_cast<ScrollNumberWidget *>(m_widget)->text();
//#ifdef  USE_WIDGET_MUTEX
//  widgetLock.unlock();
//#endif
//  return string;
//}

//double QuteScrollNumber::getValue()
//{
//  return QuteText::getValue();
//}

void QuteScrollNumber::refreshWidget()
{
//  qDebug() << "QuteScrollNumber::refreshWidget " << m_stringValue;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString text = m_stringValue;
  m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  m_widget->blockSignals(true);
  static_cast<ScrollNumberWidget*>(m_widget)->setText(text);
  m_widget->blockSignals(false);
}

void QuteScrollNumber::createPropertiesDialog()
{
//   qDebug("QuteScrollNumber::createPropertiesDialog()");
  QuteText::createPropertiesDialog();

  text->setText(QString::number(m_value, 'f', 8));
  dialog->setWindowTitle("Scroll Number");
  QLabel *label = new QLabel(dialog);
  label->setText("Resolution");
  layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
  resolutionSpinBox = new QDoubleSpinBox(dialog);
  resolutionSpinBox->setDecimals(6);
  layout->addWidget(resolutionSpinBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif

  resolutionSpinBox->setValue(property("QCS_resolution").toDouble());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteScrollNumber::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  setProperty("QCS_resolution", resolutionSpinBox->value());
  setProperty("QCS_value",text->toPlainText().toDouble());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//  setValue(m_value);
  QuteText::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteScrollNumber::applyInternalProperties()
{
//  qDebug() << "QuteScrollNumber::applyInternalProperties()";

  QuteWidget::applyInternalProperties();
  setResolution(property("QCS_resolution").toDouble());
  setValue(property("QCS_value").toDouble());
//  static_cast<QLabel*>(m_widget)->setText(property("QCS_label").toString());
  Qt::Alignment align;
  QString alignText = property("QCS_alignment").toString();
  if (alignText == "left") {
    align = Qt::AlignLeft|Qt::AlignTop;
  }
  else if (alignText == "center") {
    align = Qt::AlignHCenter|Qt::AlignTop;
  }
  else if (alignText == "right") {
    align = Qt::AlignRight|Qt::AlignTop;
  }
  static_cast<ScrollNumberWidget*>(m_widget)->setAlignment(align);
  setTextColor(property("QCS_color").value<QColor>());
  QString borderStyle = (property("QCS_bordermode").toString() == "border" ? "solid": "none");
  m_widget->setStyleSheet("QLabel { font-family:\"" + property("QCS_font").toString()
                          + "\"; font-size: " + QString::number((property("QCS_fontsize").toDouble()*m_fontScaling)  + m_fontOffset)  + "pt"
                          + (property("QCS_bgcolormode").toBool() ?
                                    QString("; background-color:") + property("QCS_bgcolor").value<QColor>().name() : QString("; "))
                          + "; color:" + property("QCS_color").value<QColor>().name()
                          + "; border-color:" + property("QCS_color").value<QColor>().name()
                          + "; border-radius:" + QString::number(property("QCS_borderradius").toInt()) + "px"
                          + "; border-width:" + QString::number(property("QCS_borderwidth").toInt()) + "px"
                          + "; border-style: " + borderStyle
                          + "; }");
//  qDebug() << property("QCS_bgcolormode").toBool();
//  qDebug() << "QuteScrollNumber::applyInternalProperties() sylesheet" <<  m_widget->styleSheet();
  m_valueChanged = true;
}

void QuteScrollNumber::addValue(double delta)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  double value = m_value + delta;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//  m_resolution = static_cast<ScrollNumberWidget*>(m_widget)->getResolution();
//   qDebug("QuteScrollNumber::addValue places = %i resolution = %f", places, m_resolution);
  setValue(value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}

void QuteScrollNumber::setValue(double value)
{
//  qDebug() << "QuteScrollNumber::setValue " << value;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  m_value = value;
  m_stringValue = QString::number(m_value, 'f', m_places);
  m_valueChanged = true;
//   qDebug("QuteScrollNumber::setValue places = %i value = %f", m_places, m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//  valueChanged(value);
//  emit widgetChanged(this);
}

void QuteScrollNumber::setValueFromWidget(double value)
{
//  qDebug() << "QuteScrollNumber::setValueFromWidget";
  setValue(value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}
