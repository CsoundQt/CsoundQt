#include "clearqutecsoundprefs.h"
#include "ui_clearqutecsoundprefs.h"
#include <QSettings>

ClearQuteCsoundPrefs::ClearQuteCsoundPrefs(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::ClearQuteCsoundPrefs)
{
  clearSettings();
  ui->setupUi(this);
}

ClearQuteCsoundPrefs::~ClearQuteCsoundPrefs()
{
    delete ui;
}

void ClearQuteCsoundPrefs::clearSettings()
{
  QSettings settings("csound", "qutecsound");
  settings.remove("");
  settings.beginGroup("GUI");
  settings.beginGroup("Shortcuts");
  settings.remove("");
  settings.endGroup();
  settings.endGroup();
  settings.beginGroup("Options");
  settings.remove("");
  settings.beginGroup("Editor");
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("Run");
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("Environment");
  settings.remove("");
  settings.endGroup();
  settings.beginGroup("External");
  settings.remove("");
  settings.endGroup();
  settings.endGroup();
}
