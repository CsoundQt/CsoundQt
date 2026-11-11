/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.
*/

#include <QtTest>
#include <QFile>
#include <QTemporaryDir>

#include "embeddedfiles.h"

using namespace Qt::StringLiterals;

class TestEmbeddedFiles : public QObject
{
    Q_OBJECT

private slots:
    void testParse();
    void testParseUnquoted();
    void testSerializeRoundTrip();
    void testMakeBlock();
    void testDecodeInvalid();
    void testDecodedSize();
    void testValidateName();
    void testExtract();
    void testExtractOverwrite();
};

void TestEmbeddedFiles::testParse()
{
    const QString text =
            u"<CsFileB filename=\"one.wav\">\n"
            "QUJD\n"
            "</CsFileB>\n"
            "<CsFileB filename=\"two\">\n"
            "REVG\n"
            "</CsFileB>\n"_s;

    const QVector<EmbeddedFile> files = EmbeddedFiles::parse(text);
    QCOMPARE(files.size(), 2);
    QCOMPARE(files.at(0).name, u"one.wav"_s);
    QCOMPARE(files.at(0).payload.trimmed(), u"QUJD"_s);
    QCOMPARE(files.at(0).decodedSize, qint64(3));
    QCOMPARE(files.at(1).name, u"two"_s);
    QCOMPARE(files.at(1).payload.trimmed(), u"REVG"_s);
    QCOMPARE(files.at(1).decodedSize, qint64(3));
}

void TestEmbeddedFiles::testParseUnquoted()
{
    const QString text =
            u"<CsFileB filename=plain.txt>\n"
            "QQ==\n"
            "</CsFileB>\n"_s;

    const QVector<EmbeddedFile> files = EmbeddedFiles::parse(text);
    QCOMPARE(files.size(), 1);
    QCOMPARE(files.at(0).name, u"plain.txt"_s);
    QCOMPARE(files.at(0).decodedSize, qint64(1));
}

void TestEmbeddedFiles::testSerializeRoundTrip()
{
    const QString text =
            u"<CsFileB filename=\"one.wav\">\n"
            "QUJD\n"
            "</CsFileB>\n"
            "<CsFileB filename=\"two.wav\">\n"
            "REVG\n"
            "</CsFileB>\n"_s;

    const QVector<EmbeddedFile> files = EmbeddedFiles::parse(text);
    QCOMPARE(EmbeddedFiles::serialize(files), text);
}

void TestEmbeddedFiles::testMakeBlock()
{
    const QByteArray data("hello, embedded world");
    const QString block = EmbeddedFiles::makeBlock(u"hello.txt"_s, data);

    QVERIFY(block.startsWith(u"<CsFileB filename=\"hello.txt\">\n"_s));
    QVERIFY(block.endsWith(u"</CsFileB>\n"_s));

    const QVector<EmbeddedFile> files = EmbeddedFiles::parse(block);
    QCOMPARE(files.size(), 1);
    QCOMPARE(files.at(0).name, u"hello.txt"_s);
    QCOMPARE(files.at(0).decodedSize, qint64(data.size()));

    QByteArray decoded;
    QVERIFY(EmbeddedFiles::decode(files.at(0), &decoded));
    QCOMPARE(decoded, data);
}

void TestEmbeddedFiles::testDecodeInvalid()
{
    EmbeddedFile file;
    file.name = u"bad.bin"_s;
    file.payload = u"not base64 !!!"_s;

    QByteArray data;
    QString error;
    QVERIFY(!EmbeddedFiles::decode(file, &data, &error));
    QVERIFY(!error.isEmpty());
}

void TestEmbeddedFiles::testDecodedSize()
{
    QCOMPARE(EmbeddedFiles::decodedSize(u""_s), qint64(0));
    QCOMPARE(EmbeddedFiles::decodedSize(u"QQ=="_s), qint64(1));
    QCOMPARE(EmbeddedFiles::decodedSize(u"QUI="_s), qint64(2));
    QCOMPARE(EmbeddedFiles::decodedSize(u"QUJD"_s), qint64(3));
    QCOMPARE(EmbeddedFiles::decodedSize(u"QUJD\nREVG\n"_s), qint64(6));
}

void TestEmbeddedFiles::testValidateName()
{
    QVERIFY(EmbeddedFiles::validateName(u"sample.wav"_s).isEmpty());
    QVERIFY(EmbeddedFiles::validateName(u"with space.wav"_s).isEmpty());

    QVERIFY(!EmbeddedFiles::validateName(QString()).isEmpty());
    QVERIFY(!EmbeddedFiles::validateName(u"folder/sample.wav"_s).isEmpty());
    QVERIFY(!EmbeddedFiles::validateName(u"folder\\sample.wav"_s).isEmpty());
    QVERIFY(!EmbeddedFiles::validateName(u"bad\"name"_s).isEmpty());
    QVERIFY(!EmbeddedFiles::validateName(u"bad>name"_s).isEmpty());
    QVERIFY(!EmbeddedFiles::validateName(u" bad.wav"_s).isEmpty());
}

void TestEmbeddedFiles::testExtract()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    const QByteArray data("payload");
    EmbeddedFile file;
    file.name = u"sample.bin"_s;
    file.payload = QString::fromLatin1(data.toBase64());
    file.rawBlock = EmbeddedFiles::makeBlock(file.name, data);

    QString error;
    QVERIFY(EmbeddedFiles::extract(file, dir.path(), false, &error));
    QVERIFY2(error.isEmpty(), qPrintable(error));

    QFile out(dir.filePath(u"sample.bin"_s));
    QVERIFY(out.open(QIODevice::ReadOnly));
    QCOMPARE(out.readAll(), data);
    out.close();

    // A second extraction without overwrite must fail.
    QVERIFY(!EmbeddedFiles::extract(file, dir.path(), false, &error));
    QVERIFY(!error.isEmpty());
}

void TestEmbeddedFiles::testExtractOverwrite()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QFile out(dir.filePath(u"sample.bin"_s));
    QVERIFY(out.open(QIODevice::WriteOnly));
    out.write("old");
    out.close();

    const QByteArray data("new");
    EmbeddedFile file;
    file.name = u"sample.bin"_s;
    file.payload = QString::fromLatin1(data.toBase64());
    file.rawBlock = EmbeddedFiles::makeBlock(file.name, data);

    QString error;
    QVERIFY(EmbeddedFiles::extract(file, dir.path(), true, &error));
    QVERIFY2(error.isEmpty(), qPrintable(error));

    QVERIFY(out.open(QIODevice::ReadOnly));
    QCOMPARE(out.readAll(), data);
}

QTEST_GUILESS_MAIN(TestEmbeddedFiles)
#include "test_embeddedfiles.moc"
