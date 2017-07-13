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

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/


// Code based partly on CsoundHtmlWrapper by Michael Gogins https://github.com/gogins/gogins.github.io/tree/master/csound_html5.
// This class must be safe against calling with a null or uninitialized CsoundEngine.

#include "csoundhtmlwrapper.h"
#include <QApplication>
#include <QDebug>

CsoundHtmlWrapper::CsoundHtmlWrapper(QObject *parent) :
    QObject(parent),
    m_csoundEngine(nullptr),
    message_callback(nullptr)
{
}

CSOUND *CsoundHtmlWrapper::getCsound()
{
    if(!m_csoundEngine) {
        return nullptr;
    }
    return m_csoundEngine->getCsound();
}

CsoundPerformanceThread *CsoundHtmlWrapper::getThread()
{
    if(!m_csoundEngine) {
        return nullptr;
    }
    return m_csoundEngine->getUserData()->perfThread;
}

CsoundUserData *CsoundHtmlWrapper::getUserData()
{
    if(!m_csoundEngine) {
        return nullptr;
    }
    return m_csoundEngine->getUserData();
}

void CsoundHtmlWrapper::setCsoundEngine(CsoundEngine *csEngine)
{
    m_csoundEngine = csEngine;
}

int CsoundHtmlWrapper::compileCsd(const QString &filename) {
    if (!m_csoundEngine) {
        return -1;
    }
#if CS_APIVERSION>=4
    return csoundCompileCsd(getCsound(), filename.toLocal8Bit());
#else
    return csoundCompileCsd(getCsound(), filename.toLocal8Bit().data());
#endif
}

int CsoundHtmlWrapper::compileCsdText(const QString &text) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundCompileCsdText(getCsound(), text.toLocal8Bit());
}

int CsoundHtmlWrapper::compileOrc(const QString &text) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundCompileOrc(getCsound(), text.toLocal8Bit());
}

double CsoundHtmlWrapper::evalCode(const QString &text) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundEvalCode(getCsound(), text.toLocal8Bit());
}

double CsoundHtmlWrapper::get0dBFS() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGet0dBFS(getCsound());
}

int CsoundHtmlWrapper::getApiVersion() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetAPIVersion();
}

double CsoundHtmlWrapper::getControlChannel(const QString &name) {
    if (!m_csoundEngine) {
        return -1;
    }
    int result = 0;
    double value = csoundGetControlChannel(getCsound(), name.toLocal8Bit(), &result);
    return value;
}

qint64 CsoundHtmlWrapper::getCurrentTimeSamples() { // FIXME: unknown type int64_t qint64
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetCurrentTimeSamples(getCsound());
}

QString CsoundHtmlWrapper::getEnv(const QString &name) { // not sure, if it works... test with setGlobalEnv
    if (!m_csoundEngine) {
        return QString();
    }
    return csoundGetEnv(getCsound(),name.toLocal8Bit());
}

int CsoundHtmlWrapper::getKsmps() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetKsmps(getCsound());
}

int CsoundHtmlWrapper::getNchnls() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetNchnls(getCsound());
}

int CsoundHtmlWrapper::getNchnlsInput() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetNchnlsInput(getCsound());
}

QString CsoundHtmlWrapper::getOutputName() {
    if (!m_csoundEngine) {
        return QString();
    }
    return QString(csoundGetOutputName(getCsound()));
}

double CsoundHtmlWrapper::getScoreOffsetSeconds() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetScoreOffsetSeconds(getCsound());
}

double CsoundHtmlWrapper::getScoreTime() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetScoreTime(getCsound());
}

int CsoundHtmlWrapper::getSr() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundGetSr(getCsound());
}

QString CsoundHtmlWrapper::getStringChannel(const QString &name) {
    if (!m_csoundEngine) {
        return QString();
    }
    char buffer[0x100];
    csoundGetStringChannel(getCsound(),name.toLocal8Bit(), buffer);
    return QString(buffer);
}

int CsoundHtmlWrapper::getVersion() {
    return csoundGetVersion();
}

bool CsoundHtmlWrapper::isPlaying() {
    if (!m_csoundEngine)
        return false;
    else
        return m_csoundEngine->isRunning();
}

int CsoundHtmlWrapper::isScorePending() {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundIsScorePending(getCsound());
}

void CsoundHtmlWrapper::message(const QString &text) {
    if (!m_csoundEngine) {
        return;
    }
    qDebug() << text;
    if (isPlaying()) {
        csoundMessage(getCsound(), "%s", text.toLocal8Bit().constData());
    }
}

int CsoundHtmlWrapper::perform() {
    if (!m_csoundEngine) {
        return -1;
    }
    if (getThread()) {
        qDebug() << "Stopping existing Csound performance thread.";
        getThread()->Stop();
        getThread()->Join();
        delete getThread();
    }
    getUserData()->perfThread = new CsoundPerformanceThread(getCsound());
    getThread()->SetProcessCallback(CsoundEngine::csThread, (void*)getUserData());
    getThread()->Play();
    return 0;
}

int CsoundHtmlWrapper::readScore(const QString &text) {
    if (!m_csoundEngine) {
        return -1;
    }
    if (isPlaying()) {
        return csoundReadScore(getCsound(), text.toLocal8Bit());
    }
    return -1;
}

void CsoundHtmlWrapper::reset() {
    if (!m_csoundEngine) {
        return;
    }
    csoundReset(getCsound());
}

void CsoundHtmlWrapper::rewindScore() {
    if (!m_csoundEngine) {
        return;
    }
    csoundRewindScore(getCsound());
}

int CsoundHtmlWrapper::runUtility(const QString &command, int argc, char **argv) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundRunUtility(getCsound(), command.toLocal8Bit(), argc, argv); // probably does not work from JS due char **
}

int CsoundHtmlWrapper::scoreEvent(char type, const double *pFields, long numFields) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundScoreEvent(getCsound(),type, pFields, numFields);
}

void CsoundHtmlWrapper::setControlChannel(const QString &name, double value) {
    if (!m_csoundEngine) {
        return;
    }
    csoundSetControlChannel(getCsound(),name.toLocal8Bit(), value);
}

int CsoundHtmlWrapper::setGlobalEnv(const QString &name, const QString &value) {
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundSetGlobalEnv(name.toLocal8Bit(), value.toLocal8Bit());
}

void CsoundHtmlWrapper::setInput(const QString &name){
    if (!m_csoundEngine) {
        return;
    }
#if CS_APIVERSION>=4
    csoundSetInput(getCsound(), name.toLocal8Bit());
#else
    csoundSetInput(getCsound(), name.toLocal8Bit().data());
#endif
}

void CsoundHtmlWrapper::setMessageCallback(QObject *callback){
    qDebug();
    callback->dumpObjectInfo();
}

int CsoundHtmlWrapper::setOption(const QString &name){
    if (!m_csoundEngine) {
        return -1;
    }
#if CS_APIVERSION>=4
    return csoundSetOption(getCsound(), name.toLocal8Bit());
#else
    return csoundSetOption(getCsound(), name.toLocal8Bit().data());
#endif
}

void CsoundHtmlWrapper::setOutput(const QString &name, const QString &type, const QString &format){
    if (!m_csoundEngine) {
        return;
    }
#if CS_APIVERSION>=4
    csoundSetOutput(getCsound(), name.toLocal8Bit(), type.toLocal8Bit(), format.toLocal8Bit());
#else
    csoundSetOutput(getCsound(), name.toLocal8Bit().data(), type.toLocal8Bit().data(), format.toLocal8Bit().data());
#endif
}

void CsoundHtmlWrapper::setScoreOffsetSeconds(double value){
    if (!m_csoundEngine) {
        return;
    }
    csoundSetScoreOffsetSeconds(getCsound(), value);
}

void CsoundHtmlWrapper::setScorePending(bool value){
    if (!m_csoundEngine) {
        return;
    }
    csoundSetScorePending(getCsound(),(int) value);
}

void CsoundHtmlWrapper::setStringChannel(const QString &name, const QString &value){
    if (!m_csoundEngine) {
        return;
    }
    csoundSetStringChannel(getCsound(),  name.toLocal8Bit(), value.toLocal8Bit().data());
}

int CsoundHtmlWrapper::start(){
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundStart(getCsound());
}

void CsoundHtmlWrapper::stop(){
    if (!m_csoundEngine) {
        return;
    }
    csoundStop(getCsound());
}

double CsoundHtmlWrapper::tableGet(int table_number, int index){
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundTableGet(getCsound(), table_number, index);
}

int CsoundHtmlWrapper::tableLength(int table_number){
    if (!m_csoundEngine) {
        return -1;
    }
    return csoundTableLength(getCsound(), table_number);
}

void CsoundHtmlWrapper::tableSet(int table_number, int index, double value){
    if (!m_csoundEngine) {
        return;
    }
    csoundTableSet(getCsound(), table_number, index, value);
}



