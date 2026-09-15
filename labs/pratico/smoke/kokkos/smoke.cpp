// pratico smoke: Kokkos links, initialises, and runs one parallel_reduce on the default host backend.
#include <Kokkos_Core.hpp>
#include <cstdio>
int main(int argc, char** argv) {
  Kokkos::initialize(argc, argv);
  {
    const int n = 1 << 20;
    double sum = 0.0;
    Kokkos::parallel_reduce("smoke.sum", n, KOKKOS_LAMBDA(const int i, double& acc) { acc += 1.0 / (1.0 + i); }, sum);
    // Kokkos 5.2 has no KOKKOS_VERSION_STRING; the numeric macros are the stable spelling.
    std::printf("kokkos %d.%d.%d backend=%s sum=%.6f\n", KOKKOS_VERSION_MAJOR, KOKKOS_VERSION_MINOR,
                KOKKOS_VERSION_PATCH, Kokkos::DefaultExecutionSpace::name(), sum);
  }
  Kokkos::finalize();
  return 0;
}
