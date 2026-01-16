#!/usr/bin/env python3
"""Debug script for non-uniform grid integration - understanding MATLAB behavior"""

import numpy as np
from scipy import integrate

def integrate_from_top_v1(z, q_tot):
    """Original version that should match MATLAB behavior."""
    z_flipped = np.flip(z)
    q_flipped = np.flip(q_tot)
    q_cum_flipped = integrate.cumulative_trapezoid(q_flipped, z_flipped, initial=0)
    q_cum = -np.flip(q_cum_flipped)
    return q_cum

# Parameters
A = 1e10
H = 100

# Test with simple case first
print("=== Simple test with uniform grid ===")
z_uniform = np.array([0, 10, 20, 30])  # Simple uniform grid
q_tot_uniform = A * np.exp(-z_uniform / H)

print(f"z_uniform = {z_uniform}")
print(f"q_tot_uniform = {q_tot_uniform}")

# What does the MATLAB code compute?
q_cum_uniform = integrate_from_top_v1(z_uniform, q_tot_uniform)
print(f"q_cum_uniform (numerical) = {q_cum_uniform}")

# Let's understand what this represents:
# q_cum_uniform[0] = ∫_z[0]^z_top q_tot(x) dx
# q_cum_uniform[1] = ∫_z[1]^z_top q_tot(x) dx
# etc.

# For uniform grid, let's compute the analytical solution
z_top = z_uniform[-1]
print(f"z_top = {z_top}")

# Analytical: q_cum(z) = ∫_z^z_top A*exp(-x/H) dx = A*H*[exp(-z/H) - exp(-z_top/H)]
q_cum_analytical_uniform = A * H * (np.exp(-z_uniform / H) - np.exp(-z_top / H))
print(f"q_cum_analytical_uniform = {q_cum_analytical_uniform}")

# Calculate error
error_uniform = np.abs((q_cum_uniform - q_cum_analytical_uniform) / (q_cum_analytical_uniform + 1e-10))
print(f"error_uniform = {error_uniform}")
print(f"max_error_uniform = {np.max(error_uniform)*100:.4f}%")

# Now test with the non-uniform grid
print("\n=== Non-uniform grid test ===")
z = np.array([0, 0.5, 1.5, 3.5, 7.5, 15.5, 30.5, 60.5, 120.5, 240.5, 480.5, 980.5, 1000])
q_tot = A * np.exp(-z / H)

q_cum_numerical = integrate_from_top_v1(z, q_tot)
print(f"q_cum_numerical = {q_cum_numerical}")

# Analytical solution
z_top = z[-1]
q_cum_analytical = A * H * (np.exp(-z / H) - np.exp(-z_top / H))
print(f"q_cum_analytical = {q_cum_analytical}")

# Error
error = np.abs((q_cum_numerical - q_cum_analytical) / (q_cum_analytical + 1e-10))
print(f"error = {error}")
print(f"max_error = {np.max(error)*100:.4f}%")

# Let's try a different analytical approach
# Maybe the MATLAB integration includes both endpoints differently?
print("\n=== Alternative analytical approach ===")
# For the trapezoidal rule: ∫_a^b f(x)dx ≈ (b-a)*(f(a)+f(b))/2
# For cumulative: q_cum[i] = ∫_z[i]^z_top q_tot(x)dx

# Let's compute this manually for the non-uniform grid
def analytical_cumulative_manual(z, q_tot):
    """Manually compute cumulative integral using trapezoidal rule."""
    n = len(z)
    q_cum = np.zeros(n)
    
    # Start from top and work down
    for i in range(n-2, -1, -1):
        dz_local = z[i+1] - z[i]  # This should be positive for increasing z
        if dz_local != 0:
            area = 0.5 * (q_tot[i] + q_tot[i+1]) * dz_local
            q_cum[i] = q_cum[i+1] + area
    
    return q_cum

q_cum_manual = analytical_cumulative_manual(z, q_tot)
print(f"q_cum_manual = {q_cum_manual}")
error_manual = np.abs((q_cum_numerical - q_cum_manual) / (q_cum_manual + 1e-10))
print(f"max_error vs manual = {np.max(error_manual)*100:.4f}%")