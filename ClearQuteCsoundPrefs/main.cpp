#include <QtGui/QApplication>
#include "clearqutecsoundprefs.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    ClearQuteCsoundPrefs w;
    w.show();
    return a.exec();
}
