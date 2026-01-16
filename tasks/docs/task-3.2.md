# Task 3.2: Phase 3.2: Bounce and Mirror Mechanics Validation

## Objectives

Validate magnetic dipole bounce period and mirror altitude calculations against standard magnetospheric physics references, ensuring relativistic effects and dipole approximations are correctly implemented.

## Element 3.2.0: Validate bounce period equation (bounce_time_arr.m)

### Specific Literature References to Check

**Standard magnetospheric physics textbooks and papers:**

- Roederer (1970) - Dynamics of Geomagnetically Trapped Radiation
- Walt (1994) - Introduction to Geomagnetically Trapped Radiation
- Schulz and Lanzerotti (1974) - Particle Diffusion in the Radiation Belts
- Lyons and Williams (1984) - Quantitative Aspects of Magnetospheric Physics

### Equations and Line Numbers to Validate

From `bounce_time_arr.m`:

**Relativistic bounce period calculation** (verify exact lines/sections)
```matlab
% Relativistic factor
gamma = 1 + E / (mc2);

% Bounce period formula
% Tb = 4 * L * Re / (v) * I(alpha_eq)
```

**Expected literature form** (Roederer 1970, Eq. 2.XX):
```
T_b = (4 L R_E) / v × I(α_eq)

Where:
- L: L-shell parameter (dimensionless, Earth radii)
- R_E: Earth radius (6371 km)
- v: particle velocity = c√(1 - 1/γ²)
- γ: Lorentz factor = 1 + E/(mc²)
- I(α_eq): bounce period integral, function of equatorial pitch angle
- For α_eq = 90°, I ≈ 0.35 (purely equatorial mirroring)
```

**Constants to verify**:
- Rest energy: mc² = 0.511 MeV for electrons (e⁻)
- Rest energy: mc² = 938 MeV for protons (p⁺)
- Speed of light: c = 3×10⁸ m/s

### Expected Values from Literature

**For α_eq = 90° (equatorial mirroring)**:
- I(α_eq ≈ 90°) ≈ 0.35 (from Roederer 1970)
- Bounce period T_b ≈ 0.117 × L × R_E / v (seconds)

**Typical values**:
- L = 4, E = 1 MeV: T_b ≈ 0.5-1 second (verify from literature)
- L = 6, E = 100 keV: T_b ≈ 1-2 seconds (verify from literature)

### Verification Criteria

- [ ] Rest energy constants (0.511 MeV e⁻, 938 MeV p⁺) match standard physics constants
- [ ] Lorentz factor calculation γ = 1 + E/(mc²) is correct
- [ ] Bounce period formula matches relativistic dipole formula from Roederer (1970)
- [ ] L-shell dependency (linear scaling with L) is correct
- [ ] Numerical implementation matches analytical solution for test cases
- [ ] Coordinate system: dipole vs full magnetic field model assumptions are documented

### Test Cases

```matlab
% Test case 1: 1 MeV electron at L = 4, α_eq = 90°
mc2 = 0.511; % MeV
E = 1.0; % MeV
L = 4;
alpha_eq = 90; % degrees
% Expected Tb from literature: ~0.5-1 s

% Test case 2: 100 keV proton at L = 6, α_eq = 45°
mc2 = 938; % MeV
E = 0.1; % MeV
L = 6;
alpha_eq = 45; % degrees
% Expected Tb from literature: ~1-3 s (verify)
```

### Dependencies

- Element 3.4.0: Physical constants must be validated first
- Element 3.4.1: Coordinate system and L-shell definition validation

---

## Element 3.2.1: Validate mirror altitude calculation (dipole_mirror_altitude.m)

### Specific Literature References to Check

**Dipole magnetic field theory:**

- Roederer (1970) - Chapter 2: Dipole field geometry
- Walt (1994) - Section 2.2: Mirror points and bounce motion
- Kivelson and Russell (1995) - Introduction to Space Physics

### Equations and Line Numbers to Validate

From `dipole_mirror_altitude.m`:

**Line 14**: Magnetic field ratio calculation
```matlab
B_ratio = B0 / B_mirror;
```

**Expected from dipole theory**:
```
sin²α_m = B_eq / B_m

Where:
- α_m: mirror pitch angle at mirror point
- α_eq: equatorial pitch angle
- B_eq: magnetic field at equator
- B_m: magnetic field at mirror point
```

**Line 27**: Mirror radial distance calculation
```matlab
r_mirror = L * Re * cos(alpha_mirror).^2;
```

**Expected dipole geometry**:
```
r = L·R_E·cos²(λ)

Where:
- r: radial distance from Earth center
- L: L-shell parameter (distance to equatorial crossing in Earth radii)
- R_E: Earth radius (6371 km)
- λ: magnetic latitude
- Relationship: cos²(λ) = B_eq / B(r) for dipole field
```

**Line 24**: Interpolation method (verify accuracy)
```matlab
% Interpolation to find mirror altitude from magnetic field ratio
```

**Expected from literature**:
- Verify method for finding mirror point: solve B(r)/B_eq = 1/sin²α_eq
- Check interpolation accuracy vs analytical solution: r = L·R_E·cos²α_eq

### Expected Values from Literature

**Dipole field relation**:
```
B(r) = B₀ / L³ × (1 + 3 sin²λ)/cos⁶λ ≈ B₀ / L³ at equator

At mirror point:
B_m / B_eq = 1 / sin²α_eq

Therefore:
sin²α_m = sin²(90° - α_eq) = cos²α_eq
r_mirror = L·R_E·cos²α_eq
```

**Mirror altitude above Earth's surface**:
```
h_mirror = r_mirror - R_E

For L = 4, α_eq = 45°:
r_mirror = 4 × 6371 km × cos²(45°) = 4 × 6371 × 0.5 = 12742 km
h_mirror = 12742 - 6371 = 6371 km
```

### Verification Criteria

- [ ] Magnetic field ratio B_ratio = B_eq/B_m = sin²α_eq is correct
- [ ] Dipole field formula B(r) ∝ 1/r³ is correctly implemented
- [ ] Mirror radius r = L·R_E·cos²α_eq matches dipole geometry
- [ ] Interpolation method yields results within 1% of analytical solution
- [ ] Altitude calculation includes Earth radius correction
- [ ] Boundary conditions: h_mirror < 0 (below surface), h_mirror > 1000 km (loss cone)

### Test Cases

```matlab
% Test case 1: L = 4, α_eq = 45°
L = 4;
alpha_eq = 45; % degrees
% Expected: mirror altitude ≈ 6371 km (verify)

% Test case 2: L = 6, α_eq = 90° (equatorial mirroring)
L = 6;
alpha_eq = 90; % degrees
% Expected: mirror altitude = L*Re - Re = 5*6371 = 31855 km (verify)

% Test case 3: Loss cone check - α_eq small
L = 4;
alpha_eq = 10; % degrees
% Expected: mirror altitude < 1000 km (loss into atmosphere)
```

### Dependencies

- Element 3.4.0: Earth radius (6371 km) must be verified
- Element 3.4.1: Pitch angle and L-shell coordinate definitions

### Files to Validate

- `IMPACT_MATLAB/bounce_time_arr.m` - Bounce period calculation
- `IMPACT_MATLAB/dipole_mirror_altitude.m` - Mirror altitude calculation
- Roederer (1970) - Chapters 2-3 for dipole theory
- Walt (1994) - Sections 2.1-2.3 for bounce motion

### References

- Roederer (1970) - Eq. 2.15 (bounce period), Eq. 2.20 (mirror point)
- Walt (1994) - Eq. 2.7 (magnetic moment) - Section 2.3 (bounce period)
- Lyons and Williams (1984) - Section 2.2 for relativistic corrections