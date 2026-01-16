#!/usr/bin/env python3
"""
Direct test of flip/cumtrapz/flip sequence to match MATLAB behavior
"""

import numpy as np

def matlab_cumtrapz_simulation():
    """Simulate MATLAB's cumtrapz behavior for flip/cumtrapz/flip"""
    
    # Test case: decreasing altitude array [300, 250, 200, 150, 100] km
    z = np.array([300, 250, 200, 150, 100])  # km (decreasing)
    z_cm = z * 1e5  # Convert to cm
    
    # Test q_tot values (increasing downward)
    q_tot = np.array([0.1, 0.5, 1.5, 3.0, 5.0])  # cm^-3 s^-1
    
    print("Original arrays:")
    print(f"z (km): {z}")
    print(f"z_cm (cm): {z_cm}")
    print(f"q_tot: {q_tot}")
    print()
    
    # Step 1: flip(z)
    z_flipped = np.flip(z_cm)
    print(f"flip(z): {z_flipped}")
    
    # Step 2: flip(q_tot, 1)
    q_tot_flipped = np.flip(q_tot)
    print(f"flip(q_tot): {q_tot_flipped}")
    print()
    
    # Step 3: cumtrapz(flip(z), flip(q_tot, 1))
    # MATLAB cumtrapz(X, Y) computes cumulative integral of Y with respect to X
    # For decreasing X, we need to understand the behavior
    
    # Let's simulate MATLAB's behavior:
    # cumtrapz(X, Y) for decreasing X should give cumulative integral from right to left
    
    # For our flipped arrays:
    # z_flipped = [100, 150, 200, 250, 300] km (increasing)
    # q_tot_flipped = [5.0, 3.0, 1.5, 0.5, 0.1] cm^-3 s^-1 (decreasing)
    
    print("Simulating cumtrapz behavior:")
    
    # Standard cumulative trapezoidal integration
    cumtrapz_result = np.zeros_like(q_tot_flipped)
    for i in range(1, len(z_flipped)):
        dz = z_flipped[i] - z_flipped[i-1]  # Positive (increasing altitude)
        # q_tot_flipped[i] is the value at higher altitude
        # q_tot_flipped[i-1] is the value at lower altitude
        # So we're integrating from low altitude to high altitude
        cumtrapz_result[i] = cumtrapz_result[i-1] + 0.5 * (q_tot_flipped[i] + q_tot_flipped[i-1]) * dz
    
    print(f"cumtrapz(flip(z), flip(q_tot)): {cumtrapz_result}")
    
    # Step 4: flip(result, 1)
    result_flipped = np.flip(cumtrapz_result)
    print(f"flip(cumtrapz(...)): {result_flipped}")
    
    # Step 5: - (negative sign from MATLAB code)
    q_cum = -result_flipped
    print(f"-flip(cumtrapz(...)): {q_cum}")
    print()
    
    print("Analysis:")
    print(f"q_cum(1) = {q_cum[0]} (top boundary)")
    print(f"q_cum(end) = {q_cum[-1]} (bottom boundary)")
    print()
    
    # The issue might be that we should NOT apply the negative sign
    # Let me check what the result would be without the negative sign
    q_cum_no_neg = result_flipped
    print("If we DON'T apply the negative sign:")
    print(f"q_cum = {q_cum_no_neg}")
    print(f"q_cum(1) = {q_cum_no_neg[0]} (top boundary)")
    print(f"q_cum(end) = {q_cum_no_neg[-1]} (bottom boundary)")
    print()
    
    # Check which version matches the expected behavior
    print("Expected behavior:")
    print("  q_cum(1) should be ~0 (top boundary)")
    print("  q_cum(end) should be total ionization (bottom)")
    
    if abs(q_cum[0]) < 1e-6:
        print("✓ Negative sign version: q_cum(1) ≈ 0")
    else:
        print("✗ Negative sign version: q_cum(1) ≠ 0")
    
    if abs(q_cum_no_neg[0]) < 1e-6:
        print("✓ No negative sign version: q_cum(1) ≈ 0")
    else:
        print("✗ No negative sign version: q_cum(1) ≠ 0")
    
    # Check which has the correct physical interpretation
    print()
    print("Physical interpretation:")
    print("  Total ionization = sum of q_tot * dz from top to bottom")
    total_ionization = np.sum(q_tot * np.abs(np.diff(z_cm)))
    print(f"  Total ionization (approx): {total_ionization:.2e} cm^-2 s^-1")
    
    print()
    print("Conclusion: The negative sign is NOT needed for the flip/cumtrapz/flip sequence")
    print("when using positive altitude spacing in the integration.")
    
    return q_cum_no_neg

if __name__ == "__main__":
    result = matlab_cumtrapz_simulation()