#include "foo.h"

QByteArray Foo::encode(Number number) const
{
    switch (number) {
    case Number::One:
        return "one";
    case Number::Two:
        return "two";
    case Number::Three:
        return "three";
    default:
        return "unknown";
    }
}
