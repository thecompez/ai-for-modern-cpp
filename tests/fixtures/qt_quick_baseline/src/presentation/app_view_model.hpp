#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QString>

class AppViewModel : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString status READ status CONSTANT)

public:
    explicit AppViewModel(QObject* parent = nullptr);

    [[nodiscard]] QString status() const;
};
