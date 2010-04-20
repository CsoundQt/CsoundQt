#include "clearqutecsoundprefs.h"
#include "ui_clearqutecsoundprefs.h"
#include <QtGui>

ClearQuteCsoundPrefs::ClearQuteCsoundPrefs(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::ClearQuteCsoundPrefs)
{
  ui->setupUi(this);
  if (!clearSettings()) {
    ui->label->setText("Error clearing preferences.");
  }
}

ClearQuteCsoundPrefs::~ClearQuteCsoundPrefs()
{
    delete ui;
}

bool ClearQuteCsoundPrefs::clearSettings()
{
  QString fileName = "ClearQuteCsoundPrefs";
  while (QFile::exists(fileName + ".log")) {
    fileName.append("-");
  }
  QFile reportFile(fileName + ".log");
  if (!reportFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
    qDebug() << "Error clearing preferences.";
    return false;
  }
  QTextStream out(&reportFile);

  QSettings settings("csound", "qutecsound");
  QStringList keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.beginGroup("GUI");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toByteArray() << "\n";
  }
  settings.beginGroup("Shortcuts");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.endGroup();
  settings.endGroup();
  settings.beginGroup("Options");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.beginGroup("Editor");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("Run");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("Environment");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("External");
  keys = settings.allKeys();
  foreach (QString key,keys) {
    out << "[" << key << "]\n" << settings.value(key,QVariant()).toString() << "\n";
  }
  settings.remove("");
  settings.endGroup();
  settings.endGroup();
  return true;
}
