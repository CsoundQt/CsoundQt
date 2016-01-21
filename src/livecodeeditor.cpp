#include "livecodeeditor.h"
#include "ui_livecodeeditor.h"

#include "documentview.h"

LiveCodeEditor::LiveCodeEditor(QWidget *parent, OpEntryParser *m_opcodeTree) :
    QWidget(parent),
    ui(new Ui::LiveCodeEditor)
{
	ui->setupUi(this);
	m_docView = new DocumentView(this, m_opcodeTree);
	m_docView->showLineArea(true);
	m_docView->setFullText("");

	ui->verticalLayout->addWidget(m_docView);

	connect(ui->modeComboBox, SIGNAL(currentIndexChanged(int)),
			this, SLOT(modeChanged(int)));
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

void LiveCodeEditor::setCsdMode(bool csdMode)
{
	if (csdMode) {
		ui->modeComboBox->setCurrentIndex(0);
	} else {
		ui->modeComboBox->setCurrentIndex(1);
	}
}

void LiveCodeEditor::modeChanged(int index)
{
	if (index == 0) {
		m_docView->setFileType(EDIT_CSOUND_MODE);
//		m_docView->setBackgroundColor(QColor(240, 230, 230));
		emit enableCsdMode(true);
	} else {
		m_docView->setFileType(EDIT_PYTHON_MODE);
//		m_docView->setBackgroundColor(QColor(230, 240, 230));
		emit enableCsdMode(false);
	}
}

void LiveCodeEditor::evaluateSlot(QString code)
{
	emit evaluate(code);
}
