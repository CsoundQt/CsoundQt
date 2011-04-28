#include "filebeditor.h"
#include "ui_filebeditor.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QTemporaryFile>
#include <QProcess>
#include <QDebug>


FileBEditor::FileBEditor(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::FileBEditor)
{
  ui->setupUi(this);
  connect(ui->saveAsButton, SIGNAL(released()), this, SLOT(saveAs()));
  connect(ui->addButton, SIGNAL(released()), this, SLOT(add()));
  connect(ui->removeButton, SIGNAL(released()), this, SLOT(remove()));
}

FileBEditor::~FileBEditor()
{
  delete ui;
}

void FileBEditor::appendText(QString &text)
{
  Q_ASSERT(text.contains("<CsFileB filename=")
           && text.contains("</CsFileB>") );
  FileB file;
  int index, len;
  index = text.indexOf("<CsFileB filename=") + 18;
  len = text.indexOf(">",index) - index;
  QString fullName = text.mid(index, len).remove("\"");
  text = text.right(text.size() - index - len - 1); // Now remove the tag before reusing the index variable
  if (text.startsWith("\n")) {
    text.remove(0,1);
  }
  index = fullName.lastIndexOf("/") + 1;
  if (index == -1) {
    index = 0;
  }
  file.fileName = fullName.mid(index);
  file.path = fullName.left(index);
  text.remove("</CsFileB>");
  text = text.trimmed(); // Remove initial and final line breaks
  file.encData = text;
  m_files.append(file);
  ui->fileListWidget->addItem(file.fileName);
}

QString FileBEditor::toPlainText()
{
  QString text;
  foreach(FileB file, m_files) {
    // FIXME should put quotes back once the fix in Csound is released
//    text += "<CsFileB filename=\"" + file.path + file.fileName + "\">\n";
    text += "<CsFileB filename=" + file.path + file.fileName + ">\n";
    text += file.encData + "\n";
    text += "</CsFileB>\n";
  }
  return text;
}

void FileBEditor::clear()
{
  ui->fileListWidget->clear();
  m_files.clear();
}

void FileBEditor::saveAs()
{
  QList<QListWidgetItem *> items = ui->fileListWidget->selectedItems();
  foreach(QListWidgetItem * item, items) {
    QString fileName =
        QFileDialog::getSaveFileName(this,
                                     tr("Select destination file name for file %1",
                                        "For saving binary encoded embedded file").arg(item->text()),
                                     item->text()
                                     );
    int row = ui->fileListWidget->row(item);
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly)) {
      QMessageBox::warning(this, tr("Saving embedded file"),
                           tr("Error saving embedded file. Aborting."));
      return;
    }
    QByteArray data = QByteArray::fromBase64(m_files[row].encData.toLocal8Bit());
    QDataStream s(&file);
    s.writeRawData(data, data.size());
    file.close();
  }
}

void FileBEditor::add()
{
  QStringList files = QFileDialog::getOpenFileNames(this, tr("Select files to embed"));
  foreach (QString file, files) {
    QStringList args;
    args << file;
    QProcess *encProcess = new QProcess();
    encProcess->start("csb64enc", args);
    bool finished = encProcess->waitForFinished(10000);
    if (!finished) {
      QMessageBox::warning(this, tr("Encoding file"),
                           tr("Error encoding file. Aborting."));
      return;
    }
    QString encText = QString(encProcess->readAllStandardOutput());
    appendText(encText);
  }
}

void FileBEditor::remove()
{
  QList<QListWidgetItem *> items = ui->fileListWidget->selectedItems();
  foreach(QListWidgetItem * item, items) {
    int row = ui->fileListWidget->row(item);
    m_files.remove(row);
    item = ui->fileListWidget->takeItem(row);
    delete item;
  }
}
