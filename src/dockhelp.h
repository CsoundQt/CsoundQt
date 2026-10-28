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

#include "litehtmlview.h"

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
    // Renders a page that is not part of the manual, e.g. a UDO docstring.
    // title is plain text; html is the rendered document body.
    void showHtml(const QString &title, const QString &html);
    void clear();
	bool externalBrowser;
	QString docDir;
    void setIconTheme(QString theme);
    void changeFontSize(int change);
    void addSearchRoot(const QString &rootPath, const QString &label);
    void removeSearchRoot(const QString &rootPath);

private:
	LiteHtmlView *m_view;
	virtual void closeEvent(QCloseEvent * event);
    virtual void keyPressEvent(QKeyEvent *event);

protected:
	void resizeEvent(QResizeEvent *);
	void contextMenuEvent(QContextMenuEvent *event) override;

public slots:
	void showManual();
	void showGen();
	void showOverview();
	void showOpcodeQuickRef();
	void browseBack();
	void browseForward();
	void followLink(QUrl url);
	void copy();
    void focusText();
    void setVisibleAndRaise(bool show) {
        setVisible(show);
        if(show)
            raise();
    }
    void toggleFindBarVisible(bool show);
    void findNext();
    void findPrevious();


private:
	Ui::DockHelp *ui;

	QWidget *m_hiddenTitleBar = nullptr;  // Empty title bar used to hide the dock title when docked

private slots:
	void updateTitleBar(bool floating);

signals:
	void Close(bool visible);
	void openManualExample(QString fileName);
    void requestExternalBrowser(QUrl url);

};

#endif
