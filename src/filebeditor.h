#ifndef FILEBEDITOR_H
#define FILEBEDITOR_H

#include <QWidget>
#include <QString>

namespace Ui {
  class FileBEditor;
}

class FileB
{
public:
  QString fileName;
  QString path;
  QString encData;
};

class FileBEditor : public QWidget
{
  Q_OBJECT

public:
  explicit FileBEditor(QWidget *parent = 0);
  ~FileBEditor();
  void appendText(QString &text);
  QString toPlainText();
  void clear();

private slots:
  void saveAs();
  void add();
  void remove();

private:
  Ui::FileBEditor *ui;
  QVector<FileB> m_files;
};

#endif // FILEBEDITOR_H
