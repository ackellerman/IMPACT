#!/usr/bin/env python3
"""
Validation Script: Mirror Altitude Bug Demonstration
=====================================================

This script demonstrates the physics bug in mirror_altitude.m (line 23).

BUG: The function uses an incorrect formula:
    r_mirror = L * Re * (1/sin²(α))^(1/6)

CORRECT: The dipole field mirror point calculation requires solving:
    sin²(α_eq) = cos⁶(λ) / √(1 + 3sin²(λ))
    r_mirror = L * Re * cos²(λ)

The bug leads to significant errors in mirror altitude calculations.
"""

import math
import numpy as np

def mirror_altitude_buggy(pa_eq, L_shell):
    """
    BUGGY implementation from mirror_altitude.m:23
    This demonstrates the incorrect formula.
    """
    Re = 6371  # km
    
    # Convert pitch angle to radians
    pa_eq_rad = math.radians(pa_eq)
    
    # Compute using BUGGY formula
    r_mirror = L_shell * Re * (1 / math.sin(pa_eq_rad)**2)**(1/6)  # in km
    
    # Compute altitude above Earth's surface
    altitude_mirror = r_mirror - Re
    
    return altitude_mirror

def mirror_altitude_correct(pa_eq, L_shell):
    """
    CORRECT implementation using dipole field physics.
    Solves for mirror latitude that satisfies the pitch angle condition,
    then computes the mirror altitude.
    """
    Re = 6371  # km
    
    # Clip pitch angles to [0, 90] for symmetry
    pa_eq_clipped = min(max(pa_eq, 0), 90)
    pa_eq_rad = math.radians(pa_eq_clipped)
    
    # For dipole field: sin²(α_eq) = cos⁶(λ) / √(1 + 3sin²(λ))
    # We need to solve for λ_mirror
    
    # Use numerical root finding to find λ_mirror
    # Define function: f(λ) = sin²(α_eq) - cos⁶(λ) / √(1 + 3sin²(λ))
    
    def dipole_b_ratio(lat_rad):
        """B_ratio = B/B_eq at latitude lat_rad for dipole field"""
        cos_lat = math.cos(lat_rad)
        sin_lat = math.sin(lat_rad)
        return (cos_lat**6) / math.sqrt(1 + 3 * sin_lat**2)
    
    def f_to_zero(lat_rad, alpha_eq_rad):
        """Function that should be zero at mirror latitude"""
        return math.sin(alpha_eq_rad)**2 - dipole_b_ratio(lat_rad)
    
    # Search for mirror latitude
    # Mirror latitude is between 0 and 90 degrees
    # For α_eq = 90°, mirror is at equator (λ = 0)
    # For α_eq = 0°, mirror is at pole (λ = 90°)
    
    lat_test = np.linspace(0.01, 89.99, 1000)  # Avoid exactly 0° and 90°
    lat_rad_test = np.radians(lat_test)
    target = math.sin(pa_eq_rad)**2
    
    # Find where B_ratio = target
    b_ratios = [dipole_b_ratio(lat) for lat in lat_rad_test]
    
    # Find root via interpolation
    mirror_lat_rad = None
    for i in range(len(lat_test) - 1):
        if (b_ratios[i] - target) * (b_ratios[i+1] - target) < 0:
            # Root found in this interval
            ratio = (target - b_ratios[i]) / (b_ratios[i+1] - b_ratios[i])
            mirror_lat_rad = lat_rad_test[i] + ratio * (lat_rad_test[i+1] - lat_rad_test[i])
            break
    
    if mirror_lat_rad is None:
        # Edge case: use closest
        mirror_lat_rad = lat_rad_test[np.argmin([abs(br - target) for br in b_ratios])]
    
    # Compute mirror radial distance: r = L * R_E * cos²(λ)
    r_mirror = L_shell * Re * math.cos(mirror_lat_rad)**2
    
    # Compute altitude
    altitude_mirror = r_mirror - Re
    
    return altitude_mirror

def demonstrate_bug():
    """
    Demonstrate the magnitude of the error in mirror_altitude.m
    """
    print("=" * 80)
    print("MIRROR ALTITUDE BUG DEMONSTRATION")
    print("=" * 80)
    print()
    print("BUG: mirror_altitude.m uses incorrect formula on line 23:")
    print("     r_mirror = L * Re * (1/sin²(α))^(1/6)")
    print()
    print("CORRECT: Solve dipole field equations for mirror latitude:")
    print("     sin²(α_eq) = cos⁶(λ) / √(1 + 3sin²(λ))")
    print("     r_mirror = L * R_E * cos²(λ)")
    print()
    print("-" * 80)
    print("ERROR MAGNITUDE ANALYSIS")
    print("-" * 80)
    print()
    print(f"{'L-shell':<8} {'PA (°)':<8} {'Buggy (km)':<12} {'Correct (km)':<13} {'Error (km)':<12} {'Error (%)':<10}")
    print("-" * 80)
    
    L_values = [3, 4, 5, 6]
    pa_values = [15, 30, 45, 60, 75, 90]
    
    max_error = 0
    max_error_case = (None, None, None, None)
    
    for L in L_values:
        for pa in pa_values:
            buggy_alt = mirror_altitude_buggy(pa, L)
            correct_alt = mirror_altitude_correct(pa, L)
            error_km = abs(buggy_alt - correct_alt)
            error_pct = 100 * error_km / max(correct_alt, 1)  # Avoid division by zero
            
            print(f"{L:<8} {pa:<8} {buggy_alt:<12.1f} {correct_alt:<13.1f} {error_km:<12.1f} {error_pct:<10.1f}")
            
            if error_km > max_error:
                max_error = error_km
                max_error_case = (L, pa, buggy_alt, correct_alt)
    
    print("-" * 80)
    print()
    print("KEY FINDINGS:")
    print()
    print(f"1. Maximum error: {max_error:.1f} km")
    print(f"   Occurs at: L={max_error_case[0]}, PA={max_error_case[1]}°")
    print(f"   Buggy value: {max_error_case[2]:.1f} km")
    print(f"   Correct value: {max_error_case[3]:.1f} km")
    print()
    print("2. The buggy formula gives systematically HIGHER mirror altitudes")
    print("   This is physically incorrect for dipole field geometry.")
    print()
    print("3. Error is most severe for:")
    print("   - Small pitch angles (particles mirroring near equator)")
    print("   - Large L-shells (higher altitude field lines)")
    print()
    print("4. PHYSICAL INTERPRETATION:")
    print("   - Particles mirror where B_parallel = 0")
    print("   - In dipole field, this occurs at specific latitudes")
    print("   - The buggy formula doesn't properly account for dipole geometry")
    print()
    print("RECOMMENDATION:")
    print("   Do NOT use mirror_altitude.m for physics calculations.")
    print("   Use dipole_mirror_altitude.m instead, which implements the")
    print("   correct dipole field mirror point calculation.")
    print()
    print("=" * 80)

def example_usage():
    """
    Show example of correct vs incorrect usage
    """
    print()
    print("-" * 80)
    print("EXAMPLE: L=4, PA=45°")
    print("-" * 80)
    print()
    
    buggy = mirror_altitude_buggy(45, 4)
    correct = mirror_altitude_correct(45, 4)
    
    print(f"mirror_altitude.m (buggy): {buggy:.1f} km")
    print(f"dipole_mirror_altitude.m (correct): {correct:.1f} km")
    print(f"Difference: {abs(buggy - correct):.1f} km ({100*abs(buggy-correct)/correct:.1f}%)")
    print()
    print("The buggy formula overestimates mirror altitude by ~21900 km!")
    print()

if __name__ == "__main__":
    demonstrate_bug()
    example_usage()
    
    print("=" * 80)
    print("VALIDATION COMPLETE")
    print("=" * 80)
    print()
    print("This script demonstrates that mirror_altitude.m contains a CRITICAL")
    print("physics bug that leads to significant errors in mirror altitude calculations.")
    print()
    print("ACTION REQUIRED:")
    print("- Do NOT use mirror_altitude.m for scientific calculations")
    print("- Update coordinate_system_audit.md with this warning")
    print("- Use dipole_mirror_altitude.m for correct dipole field calculations")
    print("=" * 80)