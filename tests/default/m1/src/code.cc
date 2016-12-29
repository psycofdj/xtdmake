#include "code.hh"

namespace m1 {

Code::Code(void) :
  m_member(1)
{
}

Code::~Code(void)
{
}


std::size_t
Code::method(std::size_t p_in)
{
  return p_in;
}

std::size_t
Code::uncalled(void)
{
  return 0;
}


}
