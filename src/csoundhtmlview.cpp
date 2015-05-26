#ifdef QCS_HTML5

#include "documentpage.h"
#include "csoundhtmlview.h"
#include "ui_html5guidisplay.h"
#include <QLabel>
#include <QVBoxLayout>
#include <QWaitCondition>

CsoundHtmlView::CsoundHtmlView(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::Html5GuiDisplay),
    documentPage(0),
    webView(0)
{
    ui->setupUi(this);
    webView = new QCefWebView(this);
    setWidget(webView);
    //webView->loadFromUrl(QUrl("http://csound.github.io/docs/manual/indexframes.html"));
    webView->sizePolicy().setVerticalPolicy(QSizePolicy::Policy::Expanding);
    layout()->setMargin(0);
}

void CsoundHtmlView::closeEvent(QCloseEvent *event)
{
    qDebug() << __FUNCTION__;
    if (webView) {
        webView->close();
    }
}



CsoundHtmlView::~CsoundHtmlView()
{
    delete ui;
}

QString getElement(const QString &text, const QString &tag)
{
    QString::SectionFlags sectionflags = QString::SectionIncludeLeadingSep | QString::SectionIncludeTrailingSep | QString::SectionCaseInsensitiveSeps;
    QString element = text.section("<" + tag, 1, 1, sectionflags);
    element = element.section("</" + tag + ">", 0, 0, sectionflags);
    return element;
}

/**
 * @brief Html5GuiDisplay.play
 * @param documentPage
 *
 * Save the <html> element, if it exists,
 * to filename xxx.csd.html, and load it into the CEF web view.
 */
void CsoundHtmlView::play(DocumentPage *documentPage_)
{
    documentPage = documentPage_;
    qDebug() << "CsoundHtmlView::play()...";
    auto text = documentPage.load()->getFullText();
    auto filename = documentPage.load()->getFileName();
    QFile csdfile(filename);
    csdfile.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&csdfile);
    out << text;
    csdfile.close();
    auto html = getElement(text, "html");
    if (html.size() > 0) {
        QString htmlfilename = filename + ".html";
        QFile htmlfile(htmlfilename);
        htmlfile.open(QIODevice::WriteOnly | QIODevice::Text);
        QTextStream out(&htmlfile);
        out << html;
        htmlfile.close();
        webView->loadFromUrl(QUrl::fromLocalFile(htmlfilename));
    } else {
        webView->loadFromUrl(QUrl("about:blank"));
    }
    repaint();
}

void CsoundHtmlView::stop()
{
    documentPage = 0;
    qDebug() << "CsoundHtmlView::stop()...";
}

void CsoundHtmlView::loadFromUrl(const QUrl &url)
{
    qDebug() << "CsoundHtmlView::loadFromUrl()...";
    if(webView != 0) {
        //webView->evaluateJavaScript("debugger;");
        webView->loadFromUrl(url);
    }
}

#endif
