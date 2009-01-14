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
#ifndef NODE_H
#define NODE_H

#include <QString>
#include <QVector>

class Node;

class Port {
  public:
    Port() {};

    ~Port() {};
    QString name;
    QString argName; //parameter name
//     Node *node;
    bool optional; //optional parameter
    bool connected;
};

class Node{
  public:
    Node();

    ~Node();

    void clear();
    void setName(QString name);
    QString getName();
    void setComment(QString comment);
    QString getComment();
    void newInput(Port input);
    void newOutput(Port output);
    QVector<Port> getInputs();
    QVector<Port> getOutputs();
    void setInputs(QVector<Port> inputs);
    void setOutputs(QVector<Port> outputs);
    bool inputPortConnected(int portIndex);
    void setInputPortConnected(bool connected, int portIndex);
    bool outputPortConnected(int portIndex);
    void setOutputPortConnected(bool connected, int portIndex);

  protected:

    QString m_name;
    QString m_comment;
    QVector<Port> m_inputs;
    QVector<Port> m_outputs;
    //TODO in inherited graphics node add shape attribute
};

#endif
