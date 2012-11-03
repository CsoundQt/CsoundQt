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
