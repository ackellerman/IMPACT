program test_msis_utils

  use msis_constants
  use msis_utils

  implicit none

  integer :: i
  real(kind=rp) :: result
  real(8) :: lat, alt, gph, alt_result
  character(len=100) :: fmt_str

  ! Test 1: dilog edge cases
  print *, "=== DILOG EDGE CASE TESTS ==="

  ! Test x = 0.0
  result = dilog(0.0_rp)
  print *, "dilog(0.0) = ", result, " (expected: ~1.644934)"

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

  ! Test 2: gph2alt convergence behavior
  print *, ""
  print *, "=== GPH2ALT CONVERGENCE TESTS ==="

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

  ! Test with different latitudes
  print *, ""
  print *, "=== GPH2ALT LATITUDE TESTS ==="
  do i = 0, 9
    lat = real(i * 10, 8)
    alt = 500.0_8
    gph = alt2gph(lat, alt)
    alt_result = gph2alt(lat, gph)
    print *, "lat = ", lat, " deg, gph = ", gph, " km -> alt = ", alt_result, " km, diff = ", alt_result - alt, " km"
  end do

  ! Test 3: Precision inconsistency verification
  print *, ""
  print *, "=== PRECISION CONSISTENCY CHECK ==="

  print *, "alt2gph type: real(8) - always double precision"
  print *, "gph2alt type: real(8) - always double precision"
  print *, "bspline type: kind=rp - depends on DBLE flag"
  print *, "dilog type: kind=rp - depends on DBLE flag"
  print *, ""
  print *, "With DBLE undefined: single precision for bspline/dilog"
  print *, "With DBLE defined: double precision for all"

end program test_msis_utils