/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifndef UTILITIESDIALOG_H
#define UTILITIESDIALOG_H

#include "ui_utilitiesdialog.h"

class Options;
class ConfigLists;

class UtilitiesDialog : public QDialog, private Ui::UtilitiesDialog
{
  Q_OBJECT
  public:
    UtilitiesDialog(QWidget *parent, Options *options, ConfigLists *m_configlist);

    ~UtilitiesDialog();

//     QString cvInput;
//     QString cvOutput;
//     QString cvSr;
//     QString cvBegin;
//     QString cvDuration;
//     QString cvChannel;
//
//     QString hetInput;
//     QString hetOutput;
//     QString hetSr;
//     QString hetChannel;
//     QString hetBegin;
//     QString hetDuration;
//     QString hetStart;
//     QString hetPartials;
//     QString hetMax;
//     QString hetMin;
//     QString hetBreakpoints;
//     QString hetCutoff;
//
//     QString lpInput;
//     QString lpOutput;
//     QString lpSr;
//     QString lpChannel;
//     QString lpBegin;
//     QString lpDuration;
//     QString lpPoles;
//     QString lpHopSize;
//     QString lpLowest;
//     QString lpMax;
//     int lpVerbosity;
//     bool lpAlternate;
//
//     QString pvInput;
//     QString pvOutput;
//     QString pvSr;
//     QString pvChannel;
//     QString pvBegin;
//     QString pvDuration;
//     QString pvFrame;
//     QString pvOverlap;
//     QString pvLowest;
//     QString pvMax;
//     int pvWindow;
//     QString pvBeta;
//
//     QString atsaInput;
//     QString atsaOutput;
//     QString atsaSr;
//     QString atsaBegin;
//     QString atsaEnd;
//     QString atsaLowest;
//     QString atsaHighest;
//     QString atsaDeviation;
//     QString atsaCycle;
//     QString atsaHopSize;
//     QString atsaMagnitude;
//     QString atsalength;
//     QString atsaMinSegment;
//     QString atsaMinGap;
//     QString atsaThreshold;
//     QString atsaSmr;
//     int atsaFileType;
//     int atsaWindow;

  private:
    Options *m_options;
    QString m_helpDir; // Html help directory

    void browseFile(QString &destination, QString extension ="");
    void browseDir(QString &destination);
    void changeHelp(QString filename);

  private slots:
    void changeTab(int tab);
    void runAtsa();
    void resetAtsa();
    void runPvanal();
    void resetPvanal();
    void runHetro();
    void resetHetro();
    void runLpanal();
    void resetLpanal();
    void runCvanal();
    void resetCvanal();
    void browseAtsaInput();
    void browseAtsaOutput();
    void browsePvInput();
    void browsePvOutput();
    void browseHetInput();
    void browseHetOutput();
    void browseLpInput();
    void browseLpOutput();
    void browseCvInput();
    void browseCvOutput();

  signals:
    void runUtility(QString flags);
};

#endif
