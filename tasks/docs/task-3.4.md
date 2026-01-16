# Task 3.4: Phase 3.4: Unit Consistency and Constants

## Objectives

Validate physical constants, unit conversions, and coordinate system definitions across the precipitation code, ensuring consistent use of SI units and correct coordinate transformations.

## Element 3.4.0: Validate physical constants and unit conversions

### Specific Literature References to Check

**Standard physical constants:**

- NIST CODATA recommended values (latest available)
- NASA technical standards for space physics constants
- Solar System coordinate system documentation (IAU resolutions)
- MATLAB documentation for energy unit conversions

### Equations and Constants to Validate

**Earth radius (R_E)**:
```matlab
Re = 6371; % km
```

**Expected from literature**:
- Mean Earth radius: 6371.0 km (NIST reference)
- Equatorial radius: 6378.1 km (check which is used)
- Polar radius: 6356.8 km (oblate spheroid correction)
- Verify which radius is appropriate for dipole calculations
- **Decision**: Mean radius 6371 km is typically used for dipole models

**Bounce time formula constants** (from bounce_time_arr.m):
```matlab
mc2_electron = 0.511; % MeV
mc2_proton = 938;     % MeV
```

**Expected from literature** (NIST CODATA):
- Electron rest energy: mc² = 0.511 MeV = 511 keV (exact: 0.510998950 MeV)
- Proton rest energy: mc² = 938.272 MeV (verify if 938 is approximation)
- Verify if code uses exact values or rounded approximations

**Energy unit conversions** (keV ↔ MeV):
```matlab
% Conversion factors
keV_to_MeV = 1e-3;
MeV_to_keV = 1e3;
```

**Expected conversions**:
- 1 keV = 10⁻³ MeV
- Verify all energy inputs are consistent (calc_Edissipation.m uses keV, bounce_time uses MeV)
- Check if implicit conversions occur (e.g., in Lorentz factor calculation)

**Constant 6×10⁻⁶ in energy dissipation** (from calc_Edissipation.m line 33):
```matlab
y = (2./E) .* (rho.*H).^0.7 .* (6e-6)^(-0.7);
```

**Expected from Fang 2010**:
- Reference density: 6×10⁻⁶ kg/m³ (verify in Fang 2010)
- Units: Should be mass density (kg/m³)
- Physical interpretation: Reference density at specific altitude (which altitude? verify)

**Additional constants** (find in code):
- Speed of light: c = 3×10⁸ m/s (verify)
- Gravitational acceleration: g = 9.81 m/s² (verify)
- Boltzmann constant: k = 1.38×10⁻²³ J/K (verify)
- Elementary charge: e = 1.602×10⁻¹⁹ C (verify if used)

### Expected Values from Literature

**Standard physical constants** (NIST CODATA 2018 or latest):
```
c       = 2.99792458 × 10⁸ m/s (exact)
e       = 1.602176634 × 10⁻¹⁹ C (exact)
k       = 1.380649 × 10⁻²³ J/K (exact)
g       = 9.80665 m/s² (standard gravity)
m_e     = 9.1093837015 × 10⁻³¹ kg
m_p     = 1.67262192369 × 10⁻²⁷ kg
mc²_e   = 0.510998950 MeV (electron)
mc²_p   = 938.27208816 MeV (proton)
R_E     = 6371.0 km (mean Earth radius)
```

### Verification Criteria

- [ ] Earth radius 6371 km matches NIST mean value
- [ ] Electron rest energy 0.511 MeV is within 1% of NIST value (0.511 × 10⁻³ MeV tolerance)
- [ ] Proton rest energy 938 MeV is within 1% of NIST value (9.38 MeV tolerance)
- [ ] Energy conversions keV ↔ MeV are correct (factor 10³)
- [ ] Constant 6×10⁻⁶ kg/m³ is identified in Fang 2010 with altitude context
- [ ] All units are documented in code comments or documentation
- [ ] Consistent use of SI units (km for distance, keV/MeV for energy, kg/m³ for density)

### Test Cases

```matlab
% Test unit conversions
E_keV = 1000; % keV
E_MeV = E_keV * 1e-3; % should be 1.0 MeV

% Test Lorentz factor
mc2 = 0.511; % MeV (electron)
E = 100; % keV = 0.1 MeV
gamma = 1 + E / mc2; % should be ~1.196
v_c = sqrt(1 - 1/gamma^2); % should be ~0.548

% Test Earth radius usage
Re = 6371; % km
L = 4; % L-shell
r_eq = L * Re; % should be 25484 km
```

### Dependencies

- None (foundational task)

---

## Element 3.4.1: Validate coordinate systems and angular definitions

### Specific Literature References to Check

**Magnetospheric coordinate systems:**

- Roederer (1970) - Chapter 1: Coordinate systems
- Walt (1994) - Section 1.3: L-shell and pitch angle definitions
- Hargreaves (1992) - The Solar-Terrestrial Environment
- IAU/IRG standards for coordinate definitions

### Equations and Definitions to Validate

**Equatorial pitch angle definition** (verify usage in code):
```matlab
alpha_eq = input; % degrees
```

**Expected from literature**:
```
Pitch angle α: Angle between particle velocity and magnetic field vector
At equatorial crossing: α_eq = arccos(v_parallel / |v|)

Domains:
- α_eq = 0°: Particle moving parallel to field (no mirroring)
- α_eq = 90°: Particle moving perpendicular to field (equatorial mirror)
- α_eq < α_LC: Particle is in loss cone (mirrors below atmosphere)
- Typical range: 0° - 90° (or 90° - 180° - check usage)
```

**Code should handle**:
- 0-90° vs 90-180° pitch angle conventions
- Verify if code uses α_eq or α_m (mirror pitch angle)
- Check if pitch angle is converted to radians for calculations

**L-shell definition** (verify in code):
```matlab
L = distance / Re; % Earth radii
```

**Expected from dipole theory**:
```
L-shell: L = r_eq / R_E

Where:
- r_eq: Equatorial crossing distance from Earth center (km)
- R_E: Earth radius (6371 km)
- L is dimensionless (Earth radii)
- For dipole field: B ∝ 1/L³ at equator
```

**Verification**:
- Check if L-shell input is:
  - A value (e.g., L = 4)
  - Derived from geocentric distance (L = r/R_E)
  - Derived from magnetic coordinates (L = r / cos²λ for dipole)

**Mirror latitude relationship** (from dipole_mirror_altitude.m):
```matlab
r = L * Re * cos(alpha_eq)^2;
lambda_mirror = acos(sqrt(r / (L * Re)));
```

**Expected from dipole geometry**:
```
Magnetic latitude λ: Angle between radius vector and equatorial plane
For dipole field: sin²λ = B_eq / B(r)

Mirror point condition:
sin²α_m = B_mirror / B_eq = 1 / sin²α_eq

Therefore:
r_mirror = L·R_E·cos²α_eq
λ_mirror = arccos[√(r_mirror / (L·R_E))] = α_eq (check)
```

**Coordinate system inputs** (verify in scripts):
- Latitude: Geographic vs geomagnetic (which is used?)
- Longitude: Geographic vs geomagnetic (which is used?)
- Altitude: Above mean sea level or above Earth surface (same concept)
- Check if transformations are applied (geomagnetic to geographic conversion)

### Expected Definitions from Literature

**Pitch angle domains**:
```
Convention 1: 0° ≤ α_eq ≤ 90° (symmetric about 90°)
Convention 2: 0° ≤ α_eq ≤ 180° (full range)

Most space physics uses Convention 1 (0-90°), treating α and 180°-α as symmetric
Verify which convention is used in code
```

**L-shell coordinate**:
```
In real magnetic field: L parameter is calculated from magnetic field models (IGRF)
In dipole approximation: L = r / cos²λ
For equatorial field lines: L = r_eq / R_E

Check if code uses:
- Dipole L: L = r/R_E
- Real L: from IGRF or T89 model
```

### Verification Criteria

- [ ] Pitch angle α_eq uses 0-90° domain (or 0-180° if explicitly documented)
- [ ] L-shell definition L = r_eq/R_E matches dipole theory
- [ ] Mirror latitude formula λ_mirror = arccos[√(r_mirror/(L·R_E))] is correct
- [ ] Coordinate system (geographic vs geomagnetic) is documented
- [ ] No implicit coordinate transformations without documentation
- [ ] Angle units (degrees vs radians) are consistent throughout calculations
  - Trigonometric functions: input in radians (matlab `sin`, `cos`, `acos` use radians)
  - User inputs: typically in degrees (check if converted to radians)

### Test Cases

```matlab
% Test case 1: Pitch angle handling
alpha_eq_deg = 45; % degrees
alpha_eq_rad = deg2rad(alpha_eq_deg); % 0.785 rad
sin_alpha = sin(alpha_eq_rad); % should be 0.707

% Test case 2: Loss cone calculation
alpha_LC = asind(sqrt(B_eq / B_surface)); % degrees
% For L = 4, B_eq / B_surface = 1/64 = 0.0156
% alpha_LC ≈ asind(sqrt(0.0156)) ≈ 7.2° (verify)

% Test case 3: Mirror latitude relationship
L = 4;
alpha_eq = 30; % degrees
r_mirror = L * Re * cosd(alpha_eq)^2; % should be 4 * 6371 * 0.75 = 19113 km
lambda_mirror = acosd(sqrt(r_mirror / (L * Re))); % should be 30° (same as alpha_eq)
```

### Dependencies

- Element 3.4.0: Physical constants (R_E) must be validated first
- Element 3.2.0: Bounce period depends on coordinate system definitions

### Files to Validate

- `IMPACT_MATLAB/bounce_time_arr.m` - Coordinate usage in bounce calculations
- `IMPACT_MATLAB/dipole_mirror_altitude.m` - Mirror latitude calculations
- `IMPACT_MATLAB/fang10_precip.m` - Input coordinate handling
- Roederer (1970) - Coordinate system definitions
- Walt (1994) - L-shell and pitch angle geometry

### References

- Roederer (1970) - Chapter 1: Coordinate systems and invariants
- Walt (1994) - Sections 1.2-1.3: L-shell definitions
- Tsyganenko (1987, 1989) - Magnetic field models (IGRF, T89)
- Laundal and Richmond (2017) - Coordinate transformations in space physics
- Richmond (1995) - Ionospheric coordinate systems