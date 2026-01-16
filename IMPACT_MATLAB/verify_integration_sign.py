#!/usr/bin/env python3
"""
Targeted test to understand the flip/cumtrapz/flip sequence behavior
"""

import numpy as np

def test_flip_cumtrapz_flip():
    """Test the exact flip/cumtrapz/flip sequence from calc_ionization.m"""
    
    print("Testing flip/cumtrapz/flip sequence from calc_ionization.m:38")
    print("=" * 70)
    
    # Test case 1: Decreasing altitude [300, 250, 200, 150, 100] km
    print("\nTest Case 1: Decreasing altitude [300, 250, 200, 150, 100] km")
    z = np.array([300, 250, 200, 150, 100])  # km (decreasing)
    z_cm = z * 1e5  # Convert to cm
    q_tot = np.array([0.1, 0.5, 1.5, 3.0, 5.0])  # cm^-3 s^-1 (increasing downward)
    
    print(f"z (km): {z}")
    print(f"z_cm (cm): {z_cm}")
    print(f"q_tot: {q_tot}")
    print()
    
    # Apply flip/cumtrapz/flip sequence from MATLAB line 38
    z_flipped = np.flip(z_cm)
    q_tot_flipped = np.flip(q_tot)
    
    print(f"flip(z_cm): {z_flipped}")
    print(f"flip(q_tot): {q_tot_flipped}")
    
    # Manual cumtrapz simulation
    cumtrapz_result = np.zeros_like(q_tot_flipped)
    for i in range(1, len(z_flipped)):
        dz = z_flipped[i] - z_flipped[i-1]
        # Note: In cumtrapz(X, Y), X is the coordinate, Y is the function
        # For positive dz, this integrates from low index to high index
        cumtrapz_result[i] = cumtrapz_result[i-1] + 0.5 * (q_tot_flipped[i] + q_tot_flipped[i-1]) * dz
    
    print(f"cumtrapz(flip(z), flip(q_tot)): {cumtrapz_result}")
    
    result_before_neg = np.flip(cumtrapz_result)
    print(f"flip(cumtrapz(...)): {result_before_neg}")
    
    q_cum_with_neg = -result_before_neg
    q_cum_no_neg = result_before_neg
    
    print(f"With negative sign: {q_cum_with_neg}")
    print(f"Without negative sign: {q_cum_no_neg}")
    
    print()
    print("Analysis:")
    print(f"Original z order: z[1]={z[0]} km (TOP), z[end]={z[-1]} km (BOTTOM)")
    print()
    
    print("With negative sign:")
    print(f"  q_cum(1) = {q_cum_with_neg[0]} (should be ~0 for top)")
    print(f"  q_cum(end) = {q_cum_with_neg[-1]} (should be total ionization for bottom)")
    
    print("Without negative sign:")
    print(f"  q_cum(1) = {q_cum_no_neg[0]} (should be ~0 for top)")
    print(f"  q_cum(end) = {q_cum_no_neg[-1]} (should be total ionization for bottom)")
    
    # Calculate expected total ionization manually
    total_expected = np.sum(q_tot * np.abs(np.diff(z_cm)))
    print(f"Expected total ionization: {total_expected:.2e} cm^-2 s^-1")
    
    print()
    print("Conclusion:")
    print("The flip/cumtrapz/flip sequence with negative sign appears to have")
    print("the wrong sign. The correct implementation should be:")
    print("  q_cum = flip(cumtrapz(flip(z), flip(q_tot, 1), 1), 1)  (NO negative)")
    print()
    print("This will give q_cum(end) ≈ 0 (top) and q_cum(1) = total (bottom)")
    
    return q_cum_no_neg

if __name__ == "__main__":
    test_flip_cumtrapz_flip()