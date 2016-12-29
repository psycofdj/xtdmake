#ifndef DEFAULT_M1_TESTCODE_HH_
# define DEFAULT_M1_TESTCODE_HH_
# include <cppunit/TestFixture.h>
# include <cppunit/TestFixture.h>
# include <cppunit/extensions/HelperMacros.h>

class TestCode : public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(TestCode);
  CPPUNIT_TEST(oktest);
  CPPUNIT_TEST(kotest);
  CPPUNIT_TEST_SUITE_END();

public:
  void oktest(void);
  void kotest(void);
};






#endif // !DEFAULT_M1_TESTCODE_HH_
