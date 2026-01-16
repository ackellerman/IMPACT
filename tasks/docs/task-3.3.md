# Task 3.3: Phase 3.3: Atmospheric Data and MSIS Integration

## Objectives

Validate MSIS atmospheric data retrieval and integration with precipitation model, ensuring correct usage of solar flux inputs, altitude ranges, and physical units.

## Element 3.3.0: Validate MSIS data retrieval (get_msis_dat.m)

### Specific Literature References to Check

**MSIS model documentation:**

- NRLMSIS-00 model documentation (Picone et al., 2002)
- MSIS-2 model documentation (Emmert et al., 2020)
- User manuals for NRLMSISE-00 and MSIS-2
- Technical reports on MSIS model physics and validity domains

### Equations and Line Numbers to Validate

From `get_msis_dat.m`:

**F10.7 and Ap index usage** (verify exact usage in script)
```matlab
% Solar flux and magnetic activity inputs
F107 = ... % Daily F10.7 solar flux (solar flux units)
Ap = ...   % Ap geomagnetic index (dimensionless)
```

**Expected from MSIS documentation**:
- F10.7: 10.7 cm solar radio flux in solar flux units (sfu = 10⁻²² W/m²/Hz)
  - Typical range: 70-300 sfu (solar minimum to maximum)
  - May use 27-day averaged F107 (F107a) and daily F107
- Ap: 3-hour geomagnetic index (dimensionless)
  - Typical range: 0-400 (quiet to storm conditions)
  - May convert to Kp index (Ap ≈ Kp × 10)
- Verify if script uses daily, monthly, or climatological averages

**Altitude range validity** (lines to verify)
```matlab
% Altitude array (should be 0-1000 km in main script)
altitudes = 0:1000; % km
```

**Expected from MSIS documentation**:
- MSIS-00 validity: 0-1000 km altitude
- MSIS-2 extended validity: 0-2000+ km
- Below 0 km: MSIS model extrapolates (check if used in code)
- Above 1000 km: MSIS may have reduced accuracy (check if used)

**Output variables and units** (verify lines)
```matlab
% Get atmospheric profiles
[T, O, N2, O2, He, Ar, H, N] = msis_run(...); % NRLMSIS interface
```

**Expected outputs**:
- Temperature T (K)
- Species densities: O, N₂, O₂, He, Ar, H, N (cm⁻³ or kg/m³ - verify)
- Total mass density: ρ = Σ(n_i × m_i) where n_i is number density, m_i is mass (kg)

**Mass density and scale height units** (verify calculation)
```matlab
% Mass density
rho_total = sum([O*m_O, N2*m_N2, O2*m_O2, ...]); % kg/m³

% Scale height
H = k*T / (M*g); % km (verify units)
```

**Expected from atmospheric physics**:
```
Scale height: H = kT / (Mg)

Where:
- k: Boltzmann constant (1.38×10⁻²³ J/K)
- T: Temperature (K)
- M: Mean molecular mass (kg/mol)
- g: Gravitational acceleration (9.81 m/s²)
- H: Scale height (m, convert to km)
```

### Expected Values from Literature

**Altitude 300 km, quiet conditions** (typical auroral altitude):
- Temperature: T ≈ 700-1000 K (solar minimum to maximum)
- Mass density: ρ ≈ 10⁻¹² - 10⁻¹¹ kg/m³
- Scale height: H ≈ 50-80 km

**Altitude 100 km (mesosphere)**:
- Temperature: T ≈ 200 K (mesopause)
- Mass density: ρ ≈ 10⁻⁹ - 10⁻⁸ kg/m³
- Scale height: H ≈ 5-10 km

**Reference density 6×10⁻⁶ kg/m³**:
- This appears to be sea-level density (1.225 kg/m³) scaled down
- Verify if this matches MSIS output at a specific altitude
- Check Fang 2010 for density reference altitude

### Verification Criteria

- [ ] F10.7 solar flux inputs match MSIS documentation (units: sfu, range: 70-300)
- [ ] Ap index usage matches MSIS documentation (units: dimensionless, range: 0-400)
- [ ] Altitude range 0-1000 km is within MSIS validity domain
- [ ] Mass density units are kg/m³ (not cm⁻³ number density)
- [ ] Scale height formula H = kT/(Mg) is correctly implemented
- [ ] Species concentrations use atomic masses from NIST periodic table
- [ ] Coordinate system inputs (latitude, longitude, UT time) match MSIS API

### Test Cases

```matlab
% Test case 1: Solar minimum, quiet conditions
F107 = 70; % sfu
Ap = 4;    % quiet conditions
alt = 300; % km
lat = 70;  % auroral latitude
% Expected from MSIS: T ≈ 700 K, ρ ≈ 10⁻¹² kg/m³, H ≈ 50 km

% Test case 2: Solar maximum, storm conditions
F107 = 250; % sfu
Ap = 100;   % minor storm
alt = 100;  % km
lat = 70; % auroral latitude
% Expected from MSIS: T ≈ 700 K, ρ ≈ 10⁻⁸ kg/m³, H ≈ 5 km

% Test case 3: Verify reference density
alt = ?; % find altitude where ρ ≈ 6×10⁻⁶ kg/m³
% Expected: match Fang 2010 reference density altitude (verify from paper)
```

### Dependencies

- Element 3.4.0: Physical constants (k, g) must be validated first
- Element 3.0.0: MSIS documentation must be collected and reviewed

### Files to Validate

- `IMPACT_MATLAB/get_msis_dat.m` - MSIS data retrieval script
- `/work/projects/IMPACT/nrlmsis2.1/msis2.1_test.F90` - MSIS Fortran interface
- MSIS-00/MSIS-2 source code - Reference implementation
- Picone et al. (2002) - NRLMSISE-00 technical report
- Emmert et al. (2020) - MSIS-2 documentation

### References

- Picone et al. (2002) - NRLMSISE-00 empirical model
- Emmert et al. (2020) - MSIS-2 advancements
- Hedin et al. (1991) - Revised global model of thermospheric winds
- Fleming et al. (1988) - Thermospheric general circulation models