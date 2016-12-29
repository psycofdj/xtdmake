#ifndef DEFAULT_M1_CODE_HH_
# define DEFAULT_M1_CODE_HH_
# include <vector>

namespace m1 {

/**
 ** @brief Class doc
 ** @details
 ** Detailed doc
 */
class Code
{
public:
  /**
   ** @brief Ctor doc
   */
  Code(void);

  // undoc
  ~Code(void);

public:
  std::size_t method(std::size_t p_in);
  std::size_t uncalled(void);

protected:
  std::size_t m_member; //!< Doc member

  // undoc
  std::size_t m_undoc;
};


}

#endif // !DEFAULT_M1_CODE_HH_
