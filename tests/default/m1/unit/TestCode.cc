#include "TestCode.hh"
#include "code.hh"
#include <cppunit/ui/text/TestRunner.h>

CPPUNIT_TEST_SUITE_REGISTRATION(TestCode);

void
TestCode::oktest(void)
{
  m1::Code l_code;
  CPPUNIT_ASSERT(l_code.method(2) == 2);
}

void
TestCode::kotest(void)
{
  m1::Code l_code;
  CPPUNIT_ASSERT(l_code.method(2) == 4);
}


int main(int, char**)
{
  CppUnit::TextUi::TestRunner   l_runner;
  CppUnit::TestFactoryRegistry& l_registry  = CppUnit::TestFactoryRegistry::getRegistry();

  l_runner.addTest(l_registry.makeTest());
  return !l_runner.run("", false, true, false);
}
