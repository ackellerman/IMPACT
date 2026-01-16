program test_msis_utils_dp

  use msis_constants
  use msis_utils

  implicit none

  integer :: i
  real(kind=rp) :: result
  real(8) :: lat, alt, gph, alt_result

  ! Test 1: dilog edge cases in double precision mode
  print *, "=== DILOG EDGE CASE TESTS (DBLE MODE) ==="

  ! Test x = 0.0
  result = dilog(0.0_rp)
  print *, "dilog(0.0) = ", result, " (expected: 0.0)"

  ! Test x = 0.5
  result = dilog(0.5_rp)
  print *, "dilog(0.5) = ", result

  ! Test x = 0.999
  result = dilog(0.999_rp)
  print *, "dilog(0.999) = ", result

  ! Test x = 1.0 (expected to cause runtime error)
  print *, "dilog(1.0) - expecting runtime error:"
  result = dilog(1.0_rp)
  print *, "dilog(1.0) = ", result

  ! Test x = 1.5 (expected to cause runtime error)
  print *, "dilog(1.5) - expecting runtime error:"
  result = dilog(1.5_rp)
  print *, "dilog(1.5) = ", result

  ! Test x = -0.5 (expected to cause runtime error)
  print *, "dilog(-0.5) - expecting runtime error:"
  result = dilog(-0.5_rp)
  print *, "dilog(-0.5) = ", result

  ! Test 2: gph2alt convergence behavior in double precision
  print *, ""
  print *, "=== GPH2ALT CONVERGENCE TESTS (DBLE MODE) ==="

  lat = 45.0_8  ! 45 degrees latitude
  alt = 100.0_8 ! 100 km altitude
  gph = alt2gph(lat, alt)
  print *, "lat = ", lat, " deg, alt = ", alt, " km"
  print *, "gph = ", gph, " km"
  alt_result = gph2alt(lat, gph)
  print *, "alt from gph2alt = ", alt_result, " km"
  print *, "difference = ", alt_result - alt, " km"

  ! Test with different altitudes
  do i = 1, 10
    alt = real(i * 100, 8)
    gph = alt2gph(lat, alt)
    alt_result = gph2alt(lat, gph)
    print *, "alt = ", alt, " km -> gph = ", gph, " km -> alt_result = ", alt_result, " km, diff = ", alt_result - alt, " km"
  end do

end program test_msis_utils_dp