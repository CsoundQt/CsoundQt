/*
	Copyright (C) 2011 Andres Cabrera
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

#include "scoreeditor.h"
#include <QHBoxLayout>

ScoreEditor::ScoreEditor(QWidget *parent) :
	QWidget(parent)
{
	m_textEditor = new TextEditor(this);
	m_textEditor->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
	m_sheet = new EventSheet(this);
	m_textEditor->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
	setMode(1); // Text view by default
	setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);

	connect(m_sheet, SIGNAL(modified()), this, SLOT(modified()));
	connect(m_textEditor, SIGNAL(textChanged()), this, SLOT(modified()));
	QHBoxLayout *layout = new QHBoxLayout;
	layout->setContentsMargins (5,5,5,5);
	layout->addWidget(m_textEditor);
	layout->addWidget(m_sheet);

	setLayout(layout);
}

void ScoreEditor::setMode(int mode)
{
	m_mode = mode;
	switch (m_mode) {
	case 0:
		m_textEditor->show();
		m_sheet->hide();
		this->setFocusProxy(m_textEditor);
		break;
	case 1:
		m_sheet->show();
		m_textEditor->hide();
		this->setFocusProxy(m_sheet);
		break;
	default:
		break;
	}
}

void ScoreEditor::setPlainText(QString text)
{
	switch (m_mode) {
	case 0:
		m_textEditor->setPlainText(text);
		break;
	case 1:
		m_sheet->clear();
		m_sheet->setFromText(text);
		break;
	default:
		break;
	}
}

void ScoreEditor::setFontPointSize(float size)
{
	m_textEditor->setFontPointSize(size);
}

void ScoreEditor::setTabStopWidth(int width)
{
	m_textEditor->setTabStopWidth(width);
}

void ScoreEditor::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
	m_textEditor->setLineWrapMode(mode);
}

QString ScoreEditor::getPlainText()
{
	QString text;
	switch (m_mode) {
	case 0:
		text = m_textEditor->toPlainText();
		break;
	case 1:
		text = m_sheet->getPlainText();
		break;
	default:
		break;
	}
	return text;
}

QString ScoreEditor::getSelection()
{
	QString text;
	switch (m_mode) {
	case 0:
		text = m_textEditor->textCursor().selectedText();
		break;
	case 1:
		text = m_sheet->getPlainText();
		break;
	default:
		break;
	}
	return text;
}

void ScoreEditor::clearUndoRedoStacks()
{
	// TODO implement
}

void ScoreEditor::modified()
{
	emit textChanged();
}

void ScoreEditor::cut()
{
	switch (m_mode) {
	case 0:
		m_textEditor->cut();
		break;
	case 1:
		m_sheet->cut();
		break;
	default:
		break;
	}
}

void ScoreEditor::copy()
{
	switch (m_mode) {
	case 0:
		m_textEditor->copy();
		break;
	case 1:
		m_sheet->copy();
		break;
	default:
		break;
	}
}

void ScoreEditor::paste()
{
	switch (m_mode) {
	case 0:
		m_textEditor->paste();
		break;
	case 1:
		m_sheet->paste();
		break;
	default:
		break;
	}
}

void ScoreEditor::undo()
{
	switch (m_mode) {
	case 0:
		m_textEditor->undo();
		break;
	case 1:
		m_sheet->undo();
		break;
	default:
		break;
	}
}

void ScoreEditor::redo()
{
	switch (m_mode) {
	case 0:
		m_textEditor->redo();
		break;
	case 1:
		m_sheet->redo();
		break;
	default:
		break;
	}
}
