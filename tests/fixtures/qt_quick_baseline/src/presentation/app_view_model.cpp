#include "app_view_model.hpp"

import my.app.domain;

AppViewModel::AppViewModel(QObject* parent)
    : QObject(parent)
{
}

QString AppViewModel::status() const
{
    const auto text = my::app::domain::statusText();
    return QString::fromUtf8(text.data(), static_cast<qsizetype>(text.size()));
}
