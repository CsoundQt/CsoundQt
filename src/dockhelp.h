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

#ifndef DOCKHELP_H
#define DOCKHELP_H

#include <QDockWidget>
#include <QUrl>
#include "types.h"
#include <QTextDocument>

namespace Ui {
class DockHelp;
}

class DockHelp : public QDockWidget
{
	Q_OBJECT
public:
    explicit DockHelp(QWidget *parent);
	~DockHelp();

	bool hasFocus();
    void loadFile(QString fileName, QString anchor="");
	bool externalBrowser;
	QString docDir;
    void setTheme(QString theme);

private:
	QTextDocument::FindFlags findFlags;
	virtual void closeEvent(QCloseEvent * event);
    virtual void keyPressEvent(QKeyEvent *event);
	void findText(QString expr); // bool backward = false, bool caseSensitive = false, bool wholeWords = false);

protected:
	void resizeEvent(QResizeEvent *);

public slots:
	void showManual();
	void showGen();
	void showOverview();
	void showOpcodeQuickRef();
	void browseBack();
	void browseForward();
	void followLink(QUrl url);
	void copy();
	void onTextChanged();
	void onReturnPressed();
	void onNextButtonPressed();
	void onPreviousButtonPressed();
	void onWholeWordBoxChanged(int value);
	void onCaseBoxChanged(int value);
    void focusText();
    void setVisibleAndRaise(bool show) {
        setVisible(show);
        if(show)
            raise();
    }
    void toggleFindBarVisible(bool show);


private:
	Ui::DockHelp *ui;

    QString styleSheetLight;

signals:
	void Close(bool visible);
	void openManualExample(QString fileName);

};

#endif
