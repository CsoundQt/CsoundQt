#ifndef LIVECODEEDITOR_H
#define LIVECODEEDITOR_H

#include <QWidget>

#include "documentview.h"

namespace Ui {
class LiveCodeEditor;
}

class LiveCodeEditor : public QWidget
{
	Q_OBJECT

public:
	explicit LiveCodeEditor(QWidget *parent, OpEntryParser *m_opcodeTree);
	~LiveCodeEditor();

	DocumentView *getDocumentView();

public slots:
	void setCsdMode(bool csdMode);
	void modeChanged(int index);
	void evaluateSlot(QString code);

private:
	Ui::LiveCodeEditor *ui;
	DocumentView *m_docView;

signals:
	void evaluate(QString code);
	void enableCsdMode(bool enable);
};

#endif // LIVECODEEDITOR_H
