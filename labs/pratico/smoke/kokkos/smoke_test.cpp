#include <Kokkos_Core.hpp>
#include <gtest/gtest.h>
class KokkosEnv : public ::testing::Environment {
 public:
  void SetUp() override { Kokkos::initialize(); }
  void TearDown() override { Kokkos::finalize(); }
};
static ::testing::Environment* const kokkos_env = ::testing::AddGlobalTestEnvironment(new KokkosEnv);
TEST(Smoke, ReduceMatchesClosedForm) {
  const int n = 1000;
  long long s = 0;
  Kokkos::parallel_reduce("smoke.arith", n, KOKKOS_LAMBDA(const int i, long long& acc) { acc += i; }, s);
  EXPECT_EQ(s, static_cast<long long>(n) * (n - 1) / 2);
}
