#include <algorithm>
#include <span>
#include <string_view>

#include <QCoreApplication>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QString>

namespace {

[[nodiscard]] bool hasSmokeArgument(int argc, char* argv[])
{
    const auto arguments = std::span {argv, static_cast<std::size_t>(argc)};
    return std::ranges::any_of(arguments, [](const char* argument) {
        return std::string_view {argument} == "--smoke-test";
    });
}

[[nodiscard]] bool isReady(const QQmlApplicationEngine& engine)
{
    if (engine.rootObjects().size() != 1) {
        return false;
    }

    const auto* root = engine.rootObjects().front();
    return root->property("ready").toBool()
        && root->findChild<QObject*>(QStringLiteral("homePage")) != nullptr
        && root->findChild<QObject*>(QStringLiteral("primaryAction")) != nullptr
        && root->findChild<QObject*>(QStringLiteral("statusPanel")) != nullptr;
}

}

int main(int argc, char* argv[])
{
    QGuiApplication application(argc, argv);
    auto applicationFont = QFontDatabase::systemFont(QFontDatabase::GeneralFont);
    const auto availableFamilies = QFontDatabase::families();
    if (!availableFamilies.contains(applicationFont.family())
        && !availableFamilies.isEmpty()) {
        applicationFont.setFamily(availableFamilies.front());
    }
    application.setFont(applicationFont);
    QQuickStyle::setStyle(QStringLiteral(MY_APP_QT_QUICK_CONTROLS_STYLE));

    QQmlApplicationEngine engine;
    engine.loadFromModule(QStringLiteral("MyApp"), QStringLiteral("Main"));

    if (hasSmokeArgument(argc, argv)) {
        QCoreApplication::processEvents();
        return isReady(engine) ? 0 : 1;
    }

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return application.exec();
}
