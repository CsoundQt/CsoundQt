#ifndef CLEARQUTECSOUNDPREFS_H
#define CLEARQUTECSOUNDPREFS_H

#include <QtGui/QMainWindow>

namespace Ui
{
    class ClearQuteCsoundPrefs;
}

class ClearQuteCsoundPrefs : public QMainWindow
{
    Q_OBJECT

public:
    ClearQuteCsoundPrefs(QWidget *parent = 0);
    ~ClearQuteCsoundPrefs();
    bool clearSettings();

private:
    Ui::ClearQuteCsoundPrefs *ui;
};

#endif // CLEARQUTECSOUNDPREFS_H
