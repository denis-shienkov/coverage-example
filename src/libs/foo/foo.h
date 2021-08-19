#pragma once

#include <QByteArray>

class Foo
{
public:
    enum class Number { One, Two, Three };
    QByteArray encode(Number number) const;
};
