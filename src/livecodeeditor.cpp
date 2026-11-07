
#include "livecodeeditor.h"
#include "ui_livecodeeditor.h"

#include "documentview.h"

LiveCodeEditor::LiveCodeEditor(QWidget *parent, OpEntryParser *m_opcodeTree) :
    QWidget(parent),
    ui(new Ui::LiveCodeEditor)
{
	ui->setupUi(this);
	m_docView = new DocumentView(this, m_opcodeTree);
	// The codepad is always a Csound code editor. Use the standalone-orchestra
	// mode so the highlighter treats the whole text as Csound code (a full CSD
	// mode would wait for <CsInstruments> tags and highlight nothing).
	m_docView->setFileType(EDIT_ORC_MODE);
	// The codepad never shows line numbers.
	m_docView->showLineArea(false);
	m_docView->setFullText("");

	ui->verticalLayout->addWidget(m_docView);

	connect(m_docView, SIGNAL(evaluate(QString)), this, SLOT(evaluateSlot(QString)));
}

LiveCodeEditor::~LiveCodeEditor()
{
	delete ui;
}

DocumentView *LiveCodeEditor::getDocumentView()
{
	return m_docView;
}

void LiveCodeEditor::evaluateSlot(QString code)
{
	emit evaluate(code);
}
