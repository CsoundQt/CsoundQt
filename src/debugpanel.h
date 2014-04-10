/*
	Copyright (C) 2013 Andres Cabrera
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

#ifndef DEBUGPANEL_H
#define DEBUGPANEL_H

#include <QDockWidget>
#include <QVariantList>
#include <QVector>

namespace Ui {
class DebugPanel;
}

class DebugPanel : public QDockWidget
{
    Q_OBJECT

public:
    explicit DebugPanel(QWidget *parent = 0);
    ~DebugPanel();
    QVector<QVariantList> getBreakpoints();
    QVector<QVariant> getInstrument();
    void setDebugFilename(QString filename);

public slots:
    void setVariableList(QVector<QVariantList> varList);
    void setInstrumentList(QVector<QVariantList> instrumentList);
    void stopDebug();

private slots:
    void runToggle(bool run);
    void run();
    void pause();
    void continueDebug();
    void next();
    void newBreakpoint();
    void deleteBreakpoint();
    void cellChanged(int row, int column);
    void currentCellChanged(int currentRow, int currentColumn, int previousRow, int previousColumn);

private:
    Ui::DebugPanel *ui;

    double m_previousCellValue;

signals:
    void runSignal();
    void pauseSignal();
    void continueSignal();
    void nextSignal();
    void stopSignal();
    void addInstrumentBreakpoint(double instr, int skip);
    void removeInstrumentBreakpoint(double instr);
};

#endif // DEBUGPANEL_H
