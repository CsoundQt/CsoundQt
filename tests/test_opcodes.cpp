/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#include <QtTest>
#include <QGuiApplication>
#include <QHash>

#include "opentryparser.h"

#ifndef OPENTRIES_XML_PATH
#define OPENTRIES_XML_PATH "../../src/opcodes.xml"
#endif

class TestOpcodes : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        m_parser = new OpEntryParser(OPENTRIES_XML_PATH);
        if (m_parser->opcodeList.isEmpty())
            QSKIP("no opcodes.xml found");
        // isOpcode() looks at the user defined opcodes as well.
        m_udos.clear();
        m_parser->setUdos(&m_udos);
    }

    void parsesTheOpcodes()
    {
        QVERIFY(m_parser->isOpcode(QStringLiteral("oscili")));
        QVERIFY(m_parser->isOpcode(QStringLiteral("0dbfs")));
        QVERIFY(!m_parser->isOpcode(QStringLiteral("not_an_opcode")));
        QVERIFY(m_parser->opcodeList.size() > 1000);
    }

    // The out-arguments are the text before the opcode name, the in-arguments
    // the text after it.
    void readsTheArguments()
    {
        const QList<QPair<QString, QString>> signatures = signaturesOf("oscili");
        QVERIFY(signatures.contains({QStringLiteral("ares ="),
                                    QStringLiteral("(xamp, xcps[, ifn, iphs])")}));
        QVERIFY(signatures.contains({QStringLiteral("kres ="),
                                    QStringLiteral("(kamp, kcps[, ifn, iphs])")}));

        const QList<QPair<QString, QString>> zeroDbfs = signaturesOf("0dbfs");
        QVERIFY(zeroDbfs.contains({QString(), QStringLiteral("= iarg")}));
    }

    // The quick reference is built from the parsed data: every syntax variant
    // the manual lists, then the description.
    void buildsAQuickReference()
    {
        const QString html = m_parser->quickReferenceHtml(QStringLiteral("oscili"));
        // The variants share one block, so no empty line separates them.
        QVERIFY(html.contains(QStringLiteral(
            "<pre><code>ares = oscili(xamp, xcps[, ifn, iphs])\n"
            "kres = oscili(kamp, kcps[, ifn, iphs])</code></pre>")));
        QVERIFY(html.contains(QStringLiteral(
            "<p>A simple oscillator with linear interpolation.</p>")));
        QVERIFY(m_parser->quickReferenceHtml(QStringLiteral("not_an_opcode")).isEmpty());

        // A long option has no syntax, only the description added with it.
        const QString flag = m_parser->quickReferenceHtml(
                    QStringLiteral("use-system-sr"));
        QVERIFY(flag.contains(QStringLiteral(
            "Use the samplerate defined by the realtime audio backend")));
        QVERIFY(!flag.contains(QStringLiteral("<pre>")));

        // The generated opcodes.xml already joins the manual's repeated
        // optional groups into one, and the name is followed by the arguments
        // without a space, as in a call.
        const QString comb = m_parser->quickReferenceHtml(QStringLiteral("comb"));
        QVERIFY(comb.contains(QStringLiteral(
            "<pre><code>ares = comb(asig, krvt, ilpt [,iskip, insmps])</code></pre>")));
        QVERIFY(m_parser->getSyntax(QStringLiteral("comb")).startsWith(
            QStringLiteral("ares = comb(asig, krvt, ilpt [,iskip, insmps])<br />")));

        // More than two groups keep merging into the same one.
        const QString vco2 = m_parser->quickReferenceHtml(QStringLiteral("vco2"));
        QVERIFY(vco2.contains(QStringLiteral(
            "<pre><code>ares = vco2(kamp, kcps [,imode, kpw, kphs, inyx])</code></pre>")));
    }

    // The names an opcode had before it was renamed are known, but they are
    // not listed in the menu.
    void knowsTheLegacyNames()
    {
        QVERIFY(m_parser->isOpcode(QStringLiteral("ATSadd")));
        const Opcode legacy = m_parser->findOpcode(QStringLiteral("ATSadd"));
        QVERIFY(legacy.deprecated);
        QCOMPARE(legacy.outArgs, m_parser->findOpcode(QStringLiteral("atsadd")).outArgs);

        bool listed = false;
        for (int i = 0; i < m_parser->getCategoryCount(); ++i) {
            const QList<Opcode> opcodes = m_parser->getOpcodeList(i);
            for (const Opcode &opcode : opcodes) {
                if (opcode.opcodeName == QLatin1String("ATSadd"))
                    listed = true;
            }
        }
        QVERIFY2(!listed, "a legacy name should not be listed in the menu");
    }

    // The manual marks the deprecated opcodes; they stay in their category.
    void readsTheDeprecatedFlag()
    {
        QVERIFY2(m_parser->findOpcode(QStringLiteral("bformdec")).deprecated,
                 "bformdec is deprecated in the manual");
        QVERIFY(!m_parser->findOpcode(QStringLiteral("oscili")).deprecated);
    }

private:
    // The signatures an opcode has in the menu.
    QList<QPair<QString, QString>> signaturesOf(const QString &name) const
    {
        QList<QPair<QString, QString>> signatures;
        for (int i = 0; i < m_parser->getCategoryCount(); ++i) {
            const QList<Opcode> opcodes = m_parser->getOpcodeList(i);
            for (const Opcode &opcode : opcodes) {
                if (opcode.opcodeName == name)
                    signatures.append({opcode.outArgs, opcode.inArgs});
            }
        }
        return signatures;
    }

    OpEntryParser *m_parser = nullptr;
    QHash<QString, Opcode> m_udos;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    TestOpcodes test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_opcodes.moc"
