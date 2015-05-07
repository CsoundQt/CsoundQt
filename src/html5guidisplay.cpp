#ifdef QCS_HTML5

#include "documentpage.h"
#include "html5guidisplay.h"
#include "ui_html5guidisplay.h"
#include <QLabel>
#include <QVBoxLayout>

Html5GuiDisplay::Html5GuiDisplay(QWidget *parent) :
    QDockWidget(parent),
    ui(new Ui::Html5GuiDisplay),
    documentPage(nullptr)
{
    ui->setupUi(this);
    webView = new QCefWebView(this);
    setWidget(webView);
    //webView->loadFromUrl(QUrl("http://csound.github.io/docs/manual/indexframes.html"));
    webView->sizePolicy().setVerticalPolicy(QSizePolicy::Policy::Expanding);
    layout()->setMargin(0);
}

Html5GuiDisplay::~Html5GuiDisplay()
{
    delete ui;
}

QString getElement(const QString &text, const QString &tag)
{
    QString element = text.section("<" + tag + ">", 1, 1);
    element = element.section("</" + tag + ">", 0, 0);
    return element;
}

/**
 * @brief Html5GuiDisplay.play
 * @param documentPage
 *
 * Save the <CsHtml5> element, if it exists,
 * to filename xxx.csd.html, and load it into the CEF web view.
 */
void Html5GuiDisplay::play(DocumentPage *documentPage_)
{
    documentPage = documentPage_;
    auto text = documentPage->getFullText();
    auto filename = documentPage->getFileName();
    QFile csdfile(filename);
    csdfile.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&csdfile);
    out << text;
    csdfile.close();
    auto html = getElement(text, "CsHtml5");
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

#endif
