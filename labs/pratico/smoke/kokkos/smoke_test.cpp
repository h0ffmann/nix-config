#include <Kokkos_Core.hpp>
#include <gtest/gtest.h>
class KokkosEnv : public ::testing::Environment {
 public:
  void SetUp() override { Kokkos::initialize(); }
  void TearDown() override { Kokkos::finalize(); }
};
static ::testing::Environment* const kokkos_env = ::testing::AddGlobalTestEnvironment(new KokkosEnv);
// The kernel lives in a free function on purpose: GoogleTest compiles a TEST body into a private
// member function, and nvcc rejects an extended __host__ __device__ lambda there. Harmless with
// the host backends, required as soon as the same test is built against Kokkos' CUDA backend.
long long SumBelow(int n) {
  long long s = 0;
  Kokkos::parallel_reduce("smoke.arith", n, KOKKOS_LAMBDA(const int i, long long& acc) { acc += i; }, s);
  return s;
}
TEST(Smoke, ReduceMatchesClosedForm) {
  const int n = 1000;
  EXPECT_EQ(SumBelow(n), static_cast<long long>(n) * (n - 1) / 2);
}
