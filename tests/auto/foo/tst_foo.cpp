#include <foo/foo.h>

#include <QtTest>

Q_DECLARE_METATYPE(Foo::Number)

class tst_Foo final : public QObject
{
    Q_OBJECT

private slots:
    void encode_data();
    void encode();
};


void tst_Foo::encode_data()
{
    QTest::addColumn<Foo::Number>("number");
    QTest::addColumn<QByteArray>("name");

    QTest::newRow("one") << Foo::Number::One  << QByteArray("one");
    //QTest::newRow("two") << Foo::Number::Two  << QByteArray("two");
    //QTest::newRow("three") << Foo::Number::Three  << QByteArray("three");
    //QTest::newRow("unknown") << static_cast<Foo::Number>(123) << QByteArray("unknown");
}

void tst_Foo::encode()
{
    QFETCH(Foo::Number, number);
    QFETCH(QByteArray, name);

    Foo foo;
    const auto encoded = foo.encode(number);
    QCOMPARE(encoded, name);
}

QTEST_MAIN(tst_Foo)
#include "tst_foo.moc"
