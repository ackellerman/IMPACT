# Task 3.1: Phase 3.1: Fang 2010 Model Core Validation

## Objectives

Validate the core calculations from Fang et al. (2010) paper, specifically focusing on energy dissipation parameterization and ionization rate calculations in the precipitation model.

## Element 3.1.0: Validate energy dissipation parameterization (calc_Edissipation.m)

### Specific Literature References to Check

**Fang et al. (2010) - Primary source for energy dissipation function**

- Locate equation for energy dissipation rate f(z,E) in Fang 2010
- Verify parameter ranges and validity domains

### Equations and Line Numbers to Validate

From `calc_Edissipation.m`:

**Line 33**: Energy dissipation parameterization
```matlab
y = (2./E) .* (rho.*H).^0.7 .* (6e-6)^(-0.7);
```

**Expected literature form**:
- Equation: f(z,E) = (2/E)(ρ·H)^0.7(6×10⁻⁶)^(-0.7)
- Where:
  - E: particle energy (keV)
  - ρ: atmospheric mass density (kg/m³)
  - H: scale height (km)
  - 6×10⁻⁶: reference density (kg/m³) - verify literature source

**Lines 36-43**: Coefficient calculation
```matlab
% Coefficients
coeff1 = exp(-log(2)./(E./5.536));
coeff2 = exp(-log(2)./(E./18.06));
```

**Expected from literature**:
- Verify exponential form and coefficients (5.536, 18.06) in keV
- Check if these represent energy-dependent penetration parameters

**Lines 46-47**: Final energy dissipation function
```matlab
% Energy dissipation f(z,E)
f = coeff1 .* y .* (1 - exp(-coeff2 .* H ./ y));
```

**Expected literature form**:
- f(z,E) calculation should match Fang 2010 Equation [X]
- Verify physical interpretation: energy deposited per unit depth

### Expected Values from Literature

- **Valid energy range**: 100 eV - 1 MeV (per Fang 2010 Section [X])
- **Reference density**: 6×10⁻⁶ kg/m³ - verify if this is sea-level or reference altitude density
- **Exponential coefficients** (5.536, 18.06) - check if these match published values
- **Units**: Energy E in keV, density ρ in kg/m³, scale height H in km

### Verification Criteria

- [ ] Equation on line 33 matches Fang 2010 Equation [X] with correct constants
- [ ] Coefficient values 5.536 and 18.06 keV are verified in literature
- [ ] Final f(z,E) formula (lines 46-47) matches Fang 2010
- [ ] Energy range enforcement (100 eV - 1 MeV) is documented in Fang 2010
- [ ] Reference density 6×10⁻⁶ kg/m³ is correctly identified in literature

### Test Cases

```matlab
% Test at reference conditions
E = 10; % keV
rho = 6e-6; % kg/m³
H = 50; % km
% Expected f(z,E) value from Fang 2010 Table [X] or Figure [X]
```

### Dependencies

- Element 3.0.0: Literature references must be collected first

---

## Element 3.1.1: Validate ionization rate calculation (calc_ionization.m)

### Specific Literature References to Check

**Fang et al. (2010) - Primary source for ionization rate**

- Locate equation for total ionization rate q_tot in Fang 2010
- Verify constant 0.035 ionization efficiency

### Equations and Line Numbers to Validate

From `calc_ionization.m`:

**Line 35**: Total ionization rate constant
```matlab
q_tot = Qe ./ 0.035 .* f ./ H;
```

**Expected literature form**:
- Equation: q_tot = (Q_e / 0.035) × (f / H)
- Where:
  - Q_e: incident energy flux (erg/cm²/s or other units - verify)
  - f: energy dissipation rate from calc_Edissipation.m
  - H: scale height (km)
  - 0.035: ionization efficiency (energy per ion pair in eV)

**Line 38**: Cumulative ionization calculation
```matlab
q_cum = cumtrapz(z, q_tot); % Cumulative ionization from top down
```

**Expected literature form**:
- Integration direction: from top of atmosphere to mirror altitude
- Cumulative ionization concept matches Fang 2010 description

### Expected Values from Literature

- **Ionization constant**: 0.035 should represent ~35 eV per ion pair
- Verify if this matches standard atmospheric ionization physics (~35 eV for air)
- Check if constant varies with altitude or is altitude-independent
- **Q_e units**: Should be energy flux (verify if erg/cm²/s or J/m²/s)

### Verification Criteria

- [ ] Constant 0.035 is verified in Fang 2010 Table [X] or Section [X]
- [ ] q_tot formula matches Fang 2010 Equation [X]
- [ ] Integration direction matches Fang 2010 (top-down)
- [ ] Units are consistent across Q_e, f, H, and q_tot
- [ ] Physical interpretation: 35 eV per ion pair is standard for air

### Test Cases

```matlab
% Test with known flux values
Qe = 1e5; % erg/cm²/s or appropriate units
f = 0.1; % from calc_Edissipation.m
H = 50; % km
% Expected q_tot from Fang 2010 Table [X]
```

### Dependencies

- Element 3.1.0: Energy dissipation must be validated first
- Element 3.3.0: MSIS data retrieval provides inputs (ρ, H)

### Files to Validate

- `IMPACT_MATLAB/calc_Edissipation.m` - Energy dissipation function
- `IMPACT_MATLAB/calc_ionization.m` - Ionization rate calculation
- Fang et al. (2010) paper - Primary reference

### References

- Fang et al. (2010) - Sections [X]-[X], Equations [X]-[X]
- Rees (1989) - Auroral ionization rates (for 35 eV/ion pair)
- Solomon and Qian (2005) - Ionization efficiency in upper atmosphere