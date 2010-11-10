/*
    Copyright (C) 2010 Andres Cabrera
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

#include "basedocument.h"

#include "widgetlayout.h"
#include "baseview.h"
#include "csoundengine.h"
#include "qutecsound.h"
#include "qutebutton.h"


BaseDocument::BaseDocument(QWidget *parent, OpEntryParser *opcodeTree) :
    QObject(parent), m_opcodeTree(opcodeTree), m_csEngine(0)
{
  m_view = 0;
  m_csEngine = new CsoundEngine();
  m_widgetLayouts.append(newWidgetLayout());
  m_csEngine->setWidgetLayout(m_widgetLayouts[0]);  // Pass first widget layout to engine
//  m_view->setOpcodeNameList(opcodeNameList);
//  m_view->setOpcodeTree(m_opcodeTree);
}

BaseDocument::~BaseDocument()
{
  disconnect(m_csEngine, 0,0,0);
  //  disconnect(m_widgetLayout, 0,0,0);
  m_csEngine->stop();
  m_csEngine->freeze();
  while (!m_widgetLayouts.isEmpty()) {
    WidgetLayout *wl = m_widgetLayouts.takeLast();
    wl->deleteLater();  //FIXME Still crashing ocassionally?
  }
  m_csEngine->deleteLater();
  //  m_view->deleteLater();   // Crashes. Already destroyed?
  //  m_widgetLayout->setParent(0);  //To make sure the widget panel from the main application doesn't attempt to delete it as its child
}

void BaseDocument::init(QWidget *parent, OpEntryParser *opcodeTree)
{
  qDebug() << "BaseDocument::init";
//  m_view = createView(parent, opcodeTree);
  m_view = new BaseView(parent, opcodeTree);
  m_view->setFileType(0);
}

int BaseDocument::parseTextString(QString &text)
{
//  qDebug() << "---- BaseDocument::setTextString";
  int ret = 0;
  bool xmlFormatFound = false;
  QString xmlPanels = QString();
  while (text.contains("<bsbPanel") and text.contains("</bsbPanel>")) {
    QString panel = text.right(text.size()-text.indexOf("<bsbPanel"));
    panel.resize(panel.indexOf("</bsbPanel>") + 11);
    if (text.indexOf("</bsbPanel>") + 11 < text.size() and text[text.indexOf("</bsbPanel>") + 13] == '\n')
      text.remove(text.indexOf("</bsbPanel>") + 13, 1); //remove final line break
    if (text.indexOf("<bsbPanel") > 0 and text[text.indexOf("<bsbPanel") - 1] == '\n')
      text.remove(text.indexOf("<bsbPanel") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<bsbPanel"), panel.size());
    xmlFormatFound = true;
    xmlPanels += panel;
    // TODO enable creation of several panels
  }
  if (xmlFormatFound) {
    //FIXME allow multiple layouts
    m_widgetLayouts[0]->loadXmlWidgets(xmlPanels);
    m_widgetLayouts[0]->markHistory();
    if (text.contains("<bsbPresets>") and text.contains("</bsbPresets>")) {
      QString presets = text.right(text.size()-text.indexOf("<bsbPresets>"));
      presets.resize(presets.indexOf("</bsbPresets>") + 13);
      if (text.indexOf("</bsbPresets>") + 13 < text.size() and text[text.indexOf("</bsbPresets>") + 15] == '\n')
        text.remove(text.indexOf("</bsbPresets>") + 15, 1); //remove final line break
      if (text.indexOf("<bsbPresets>") > 0 and text[text.indexOf("<bsbPresets>") - 1] == '\n')
        text.remove(text.indexOf("<bsbPresets>") - 1, 1); //remove initial line break
      text.remove(text.indexOf("<bsbPresets>"), presets.size());
      //FIXME allow multiple
      m_widgetLayouts[0]->loadXmlPresets(presets);
    }
    ret = 1;
  }
  return ret;
}

WidgetLayout* BaseDocument::newWidgetLayout()
{
  WidgetLayout* wl = new WidgetLayout(0);
//  qDebug() << "BaseDocument::newWidgetLayout()" << wl->windowFlags();
  wl->setWindowFlags(Qt::Window | wl->windowFlags());
  connect(wl, SIGNAL(queueEventSignal(QString)),this,SLOT(queueEvent(QString)));
  connect(wl, SIGNAL(registerButton(QuteButton*)),
          this, SLOT(registerButton(QuteButton*)));
  return wl;
}

//void BaseDocument::setOpcodeNameList(QStringList opcodeNameList)
//{
//  m_view->setOpcodeNameList(opcodeNameList);
//}

WidgetLayout *BaseDocument::getWidgetLayout()
{
  //FIXME allow multiple layouts
  return m_widgetLayouts[0];
}

int BaseDocument::play(CsoundOptions *options)
{
  if (!m_csEngine->isRunning()) {
    foreach (WidgetLayout *wl, m_widgetLayouts) {
      wl->flush();   // Flush accumulated values
      wl->clearGraphs();
    }
  }
  return m_csEngine->play(options);
}

void BaseDocument::pause()
{
  m_csEngine->pause();
}

void BaseDocument::stop()
{
//  qDebug() << "BaseDocument::stop()";
  if (m_csEngine->isRunning()) {
    m_csEngine->stop();
    foreach (WidgetLayout *wl, m_widgetLayouts) {
      wl->engineStopped();  // TODO only needed to flush graph buffer, but this should be moved to this class
    }
  }
}

int BaseDocument::record(int format)
{
  return m_csEngine->startRecording(format, "output.wav");
}

void BaseDocument::stopRecording()
{
  m_csEngine->stopRecording();
}

void BaseDocument::queueEvent(QString eventLine, int delay)
{
//   qDebug("WidgetPanel::queueEvent %s", eventLine.toStdString().c_str());
  m_csEngine->queueEvent(eventLine, delay);  //TODO  implement passing of timestamp
}

//void BaseDocument::playParent()
//{
//  static_cast<qutecsound *>(parent())->play();
//}
//
//void BaseDocument::renderParent()
//{
//  static_cast<qutecsound *>(parent())->render();
//}

//void BaseDocument::registerButton(QuteButton *b)
//{
//  connect(b, SIGNAL(play()), static_cast<qutecsound *>(parent()), SLOT(play()));
//  connect(b, SIGNAL(render()), static_cast<qutecsound *>(parent()), SLOT(render()));
//  connect(b, SIGNAL(pause()), static_cast<qutecsound *>(parent()), SLOT(pause()));
//  connect(b, SIGNAL(stop()), static_cast<qutecsound *>(parent()), SLOT(stop()));
//}
