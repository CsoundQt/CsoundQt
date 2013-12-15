#ifndef DEBUGPANEL_H
#define DEBUGPANEL_H

#include <QDockWidget>
#include <QVariantList>
#include <QVector>

namespace Ui {
class DebugPanel;
}

class DebugPanel : public QDockWidget
{
    Q_OBJECT

public:
    explicit DebugPanel(QWidget *parent = 0);
    ~DebugPanel();
    QVector<double> breakpoints();
    void setDebugFilename(QString filename);
    void stop();

public slots:
    void setVariableList(QVector<QVariantList> varList);

private slots:
    void run();
    void pause();
    void continueDebug();
    void next();
    void newBreakpoint();
    void deleteBreakpoint();

private:
    Ui::DebugPanel *ui;

signals:
    void runSignal();
    void pauseSignal();
    void continueSignal();
    void nextSignal();
    void stopSignal();
    void addInstrumentBreakpoint(double instr);
    void removeInstrumentBreakpoint(double instr);
};

#endif // DEBUGPANEL_H
