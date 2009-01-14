/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
#include "node.h"

Node::Node()
{
}


Node::~Node()
{
}

void Node::clear()
{
  m_inputs.clear();
  m_outputs.clear();
  m_name = "";
}

void Node::setName(QString name)
{
  m_name = name;
}

QString Node::getName()
{
  return m_name;
}

void Node::setComment(QString comment)
{
  m_comment = comment;
}

QString Node::getComment()
{
  return m_comment;
}

void Node::newInput(Port input)
{
  m_inputs.append(input);
}

void Node::newOutput(Port output)
{
  m_outputs.append(output);
}

QVector<Port> Node::getInputs()
{
  return m_inputs;
}

QVector<Port> Node::getOutputs()
{
  return m_outputs;
}

void Node::setInputs(QVector<Port> inputs)
{
  m_inputs = inputs;
}

void Node::setOutputs(QVector<Port> outputs)
{
  m_outputs = outputs;
}

bool Node::inputPortConnected(int portIndex)
{
  if (portIndex >= m_inputs.size())
    return false;
  return m_inputs[portIndex].connected;
}

void Node::setInputPortConnected(bool connected, int portIndex)
{
  if (portIndex >= m_inputs.size()) {
    qDebug("Node::setInputPortConnected port out of range");
    return;
  }
  m_inputs[portIndex].connected = connected;
}

bool Node::outputPortConnected(int portIndex)
{
  if (portIndex >= m_outputs.size())
    return false;
  return m_outputs[portIndex].connected;
}

void Node::setOutputPortConnected(bool connected, int portIndex)
{
  if (portIndex >= m_outputs.size()) {
    qDebug("Node::setOutputPortConnected port out of range");
    return;
  }
  m_outputs[portIndex].connected = connected;
}
