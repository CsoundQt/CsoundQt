/*
    Copyright (C) 2008-2016 Andres Cabrera
    mantaraya36@gmail.com

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy o    ScoreEvent *event = 0;
    while (!csound_event_queue.try_dequeue(event)) {
        delete event;
    }
    char *score_text = 0;
    while (!csound_score_queue.try_dequeue(score_text)) {
        free(score_text);
    }
f the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/


#include "CsoundHtmlOnlyWrapper.h"
#include "console.h"
#include <QApplication>
#include <QDebug>

CsoundHtmlOnlyWrapper::CsoundHtmlOnlyWrapper(QObject *parent) :
    QObject(parent),
    message_callback(nullptr)
{
    csound.SetHostData(this);
    csound.SetMessageCallback(CsoundHtmlOnlyWrapper::csoundMessageCallback_);
}

CsoundHtmlOnlyWrapper::~CsoundHtmlOnlyWrapper() {
}

void CsoundHtmlOnlyWrapper::registerConsole(ConsoleWidget *console_){
    console = console_;
    if (console != nullptr) {
             connect(this, SIGNAL(passMessages(QString)), console, SLOT(appendMessage(QString)));
    }
}

int CsoundHtmlOnlyWrapper::compileCsd(const QString &filename) {
    return csound.CompileCsd(filename.toLocal8Bit());
}

int CsoundHtmlOnlyWrapper::compileCsdText(const QString &text) {
    return csound.CompileCsdText(text.toLocal8Bit());
}

int CsoundHtmlOnlyWrapper::compileOrc(const QString &text) {
    return csound.CompileOrc(text.toLocal8Bit());
}

double CsoundHtmlOnlyWrapper::evalCode(const QString &text) {
    return csound.EvalCode(text.toLocal8Bit());
}

double CsoundHtmlOnlyWrapper::get0dBFS() {
    return csound.Get0dBFS(); //cs->Get0dBFS();
}

int CsoundHtmlOnlyWrapper::getApiVersion() {
    return csound.GetAPIVersion();
}

double CsoundHtmlOnlyWrapper::getControlChannel(const QString &name) {
    int result = 0;
    double value = csound.GetControlChannel(name.toLocal8Bit(), &result);
    return value;
}

qint64 CsoundHtmlOnlyWrapper::getCurrentTimeSamples() { // FIXME: unknown type int64_t qint64
    return csound.GetCurrentTimeSamples();
}

QString CsoundHtmlOnlyWrapper::getEnv(const QString &name) { // not sure, if it works... test with setGlobalEnv
    return csound.GetEnv(name.toLocal8Bit());
}

int CsoundHtmlOnlyWrapper::getKsmps() {
    return csound.GetKsmps();
}

int CsoundHtmlOnlyWrapper::getNchnls() {
    return csound.GetNchnls();
}

int CsoundHtmlOnlyWrapper::getNchnlsInput() {
    return csound.GetNchnlsInput();
}

QString CsoundHtmlOnlyWrapper::getOutputName() {
    return QString(csound.GetOutputName());
}

double CsoundHtmlOnlyWrapper::getScoreOffsetSeconds() {
    return csound.GetScoreOffsetSeconds();
}

double CsoundHtmlOnlyWrapper::getScoreTime() {
    return csound.GetScoreTime();
}

int CsoundHtmlOnlyWrapper::getSr() {
    return csound.GetSr();
}

QString CsoundHtmlOnlyWrapper::getStringChannel(const QString &name) {
    char buffer[0x100];
    csound.GetStringChannel(name.toLocal8Bit(), buffer);
    return QString(buffer);
}

int CsoundHtmlOnlyWrapper::getVersion() {
    return csound.GetVersion();
}

bool CsoundHtmlOnlyWrapper::isPlaying() {
    return csound.IsPlaying();
}

int CsoundHtmlOnlyWrapper::isScorePending() {
    return csound.IsScorePending();
}

void CsoundHtmlOnlyWrapper::message(const QString &text) {
    csound.Message("%s", text.toLocal8Bit().constData());
}

int CsoundHtmlOnlyWrapper::perform() {
    // Perform in a separate thread of execution.
    return csound.Perform();
}

int CsoundHtmlOnlyWrapper::readScore(const QString &text) {
    csound.ReadScore(text.toLocal8Bit());
    return 0;
}

void CsoundHtmlOnlyWrapper::reset() {
    csound.Reset();
}

void CsoundHtmlOnlyWrapper::rewindScore() {
    csound.RewindScore();
}

int CsoundHtmlOnlyWrapper::runUtility(const QString &command, int argc, char **argv) {
    return csound.RunUtility(command.toLocal8Bit(), argc, argv); // probably does not work from JS due char **
}

int CsoundHtmlOnlyWrapper::scoreEvent(char opcode, const double *pfields, long field_count) {
    csound.ScoreEvent(opcode, pfields, field_count);
    return 0;
}

void CsoundHtmlOnlyWrapper::setControlChannel(const QString &name, double value) {
    csound.SetControlChannel(name.toLocal8Bit(), value);
}

int CsoundHtmlOnlyWrapper::setGlobalEnv(const QString &name, const QString &value) {
    return csound.SetGlobalEnv(name.toLocal8Bit(), value.toLocal8Bit());
}

void CsoundHtmlOnlyWrapper::setInput(const QString &name){
    csound.SetInput(name.toLocal8Bit());
}

void CsoundHtmlOnlyWrapper::setMessageCallback(QObject *callback){
    qDebug() << "CsoundHtmlOnlyWrapper::setMessageCallback: " << callback;
    message_callback = callback;
    message_callback->dumpObjectInfo();
}

int CsoundHtmlOnlyWrapper::setOption(const QString &name){
    return csound.SetOption(name.toLocal8Bit().data());
}

void CsoundHtmlOnlyWrapper::setOutput(const QString &name, const QString &type, const QString &format){
    csound.SetOutput(name.toLocal8Bit(), type.toLocal8Bit(), format.toLocal8Bit());
}

void CsoundHtmlOnlyWrapper::setScoreOffsetSeconds(double value){
    csound.SetScoreOffsetSeconds(value);
}

void CsoundHtmlOnlyWrapper::setScorePending(bool value){
    csound.SetScorePending((int) value);
}

void CsoundHtmlOnlyWrapper::setStringChannel(const QString &name, const QString &value){
    csound.SetStringChannel(name.toLocal8Bit(), value.toLocal8Bit().data());
}

int CsoundHtmlOnlyWrapper::start(){
    int result = 0;
    result = csound.Start();
    return result;
}

void CsoundHtmlOnlyWrapper::stop(){
    csound.Stop();
    csound.Join();
}

double CsoundHtmlOnlyWrapper::tableGet(int table_number, int index){
    return csound.TableGet(table_number, index);
}

int CsoundHtmlOnlyWrapper::tableLength(int table_number){
    return csound.TableLength(table_number);
}

void CsoundHtmlOnlyWrapper::tableSet(int table_number, int index, double value){
    csound.TableSet(table_number, index, value);
}

void CsoundHtmlOnlyWrapper::csoundMessageCallback_(CSOUND *csound,
                                         int attributes,
                                         const char *format,
                                         va_list args) {
    return reinterpret_cast<CsoundHtmlOnlyWrapper *>(csoundGetHostData(csound))->csoundMessageCallback(attributes, format, args);
}

void CsoundHtmlOnlyWrapper::csoundMessageCallback(int attributes,
                           const char *format,
                           va_list args)
{
    QString message = QString::vasprintf(format, args);
    qDebug() << message;
    passMessages(message);
    // TODO: Now call the JavaScript callback with the message.
}


