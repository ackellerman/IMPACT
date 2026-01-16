# Literature Survey: IMPACT Precipitation Code Validation

## 1. Fang et al. (2010) Electron Impact Ionization Parameterization

### Primary Reference
**Fang, X., C. E. Randall, D. Lummerzheim, W. Wang, G. Lu, S. C. Solomon, and R. A. Frahm (2010)**, "Parameterization of monoenergetic electron impact ionization," *Geophysical Research Letters*, 37, L22106, doi:10.1029/2010GL045406.

### Key Equations and Their Sources

#### Equation 1: Normalized Atmospheric Column Mass
From Fang et al. (2010), Equation (1):
```latex
y = \frac{2}{E_{\text{mono}}} (\rho H)^{0.7} (6 \times 10^{-6})^{-0.7}
```

**Parameters:**
- $E_{\text{mono}}$ = incident electron energy (keV)
- $\rho$ = atmospheric mass density (g cm⁻³)
- $H$ = scale height (cm)

**Validity Range:** 100 eV ≤ E ≤ 1 MeV

**Physical Interpretation:** This equation normalizes atmospheric column mass to account for energy-dependent energy deposition profiles. The constant $6 \times 10^{-6}$ is a reference density value used for normalization purposes.

**Source:** Fang et al. (2010), Equation (1), Page L22106-2

#### Equation 2: Normalized Energy Dissipation
From Fang et al. (2010), Equation (3):
```latex
f = \frac{q_{\text{tot}} H}{Q_{\text{mono}}}
```

**Parameters:**
- $q_{\text{tot}}$ = total ionization rate (cm⁻³ s⁻¹)
- $Q_{\text{mono}}$ = incident electron energy flux (keV cm⁻² s⁻¹)
- $H$ = scale height (cm)

**Physical Interpretation:** This normalizes the energy dissipation profile by the incident energy flux and atmospheric scale height.

**Source:** Fang et al. (2010), Equation (3), Page L22106-2

#### Equation 3: Ionization Rate Calculation
From Fang et al. (2010), Equation (2) and surrounding text:
```latex
q_{\text{tot}} = \frac{Q_{\text{mono}} f}{D^* H}
```
where $D^* = 0.035$ keV (35 eV)

**Critical Constant Identification:**
- **Constant: 0.035 keV (35 eV)**
- **Code Location:** calc_ionization.m, line 35
- **Physical Meaning:** Mean energy loss per ion pair production
- **Literature Source:** Rees (1989), "Physics of the Upper Atmosphere"
- **Validation:** Laboratory measurements of electron ionization

**Note:** The 35 eV value is a well-established "rule of thumb" in atmospheric physics for high-energy electrons. However, Fang et al. (2010) note that this is "accurate for precipitating high-energy electrons but not for low-energy particles" (F08 refers to Fang et al. 2008).

**Source:** Fang et al. (2010), Page L22106-2, Section 2

#### Equation 4: Energy Dissipation Parameterization
From Fang et al. (2010), Equation (4):
```latex
f(y) = C_1 y^{C_2} \exp(-C_3 y^{C_4}) + C_5 y^{C_6} \exp(-C_7 y^{C_8})
```

**Parameters:**
- $C_i$ = energy-dependent coefficients (i = 1,...,8)
- $y$ = normalized atmospheric column mass

**Physical Interpretation:** This double exponential form captures the energy deposition profile shape, with separate terms for the primary and secondary ionization peaks.

**Source:** Fang et al. (2010), Equation (4), Page L22106-3

#### Equation 5: Coefficient Energy Dependence
From Fang et al. (2010), Equation (5):
```latex
C_i(E) = \exp\left(\sum_{j=0}^{3} P_{ij} [\ln(E)]^j\right)
```

**Parameters:**
- $P_{ij}$ = polynomial coefficients (i = 1,...,8; j = 0,...,3)
- $E$ = electron energy (keV)

**Source:** Fang et al. (2010), Equation (5), Page L22106-3

### Pij Coefficients (Table 1 from Fang et al. 2010)

| i\j | j=0 | j=1 | j=2 | j=3 |
|-----|-----|-----|-----|-----|
| 1 | 1.24616 | 1.45903 | -0.242269 | 0.0595459 |
| 2 | 2.23976 | -4.22918×10⁻⁷ | 0.0136458 | 0.00253332 |
| 3 | 1.41754 | 0.144597 | 0.0170433 | 0.000639717 |
| 4 | 0.248775 | -0.150890 | 6.30894×10⁻⁹ | 0.00123707 |
| 5 | -0.465119 | -0.105081 | -0.0895701 | 0.0122450 |
| 6 | 0.386019 | 0.00175430 | -0.000742960 | 0.000460881 |
| 7 | -0.645454 | 0.000849555 | -0.0428502 | -0.00299302 |
| 8 | 0.948930 | 0.197385 | -0.00250603 | -0.00206938 |

**Source:** Fang et al. (2010), Table 1, Page L22106-4

### Critical Constants Summary

| Constant | Value | Code Location | Literature Source | Equation | Type |
|----------|-------|---------------|-------------------|----------|------|
| 0.035 | 0.035 keV | calc_ionization.m:35 | Rees (1989), Fang et al. (2010) | Eq. (2) | Physical |
| 6×10⁻⁶ | 6×10⁻⁶ g/cm³ | calc_Edissipation.m:33 | Fang et al. (2010) | Eq. (1) | Normalization |
| 0.7 | exponent | calc_Edissipation.m:33 | Fang et al. (2010) | Eq. (1) | Empirical |
| Pij[1,1] | 1.24616 | coeff_fang10.mat | Fang et al. (2010) | Table 1 | Empirical |
| (etc for all Pij coefficients) | | | | | |

## 2. MSIS 2.0/2.1 Atmospheric Model Documentation

### Primary References

#### NRLMSISE-00
**Picone, J. M., A. E. Hedin, D. P. Drob, and A. C. Aikin (2002)**, "NRLMSISE-00 empirical model of the atmosphere: Statistical comparisons and scientific issues," *Journal of Geophysical Research*, 107(A12), 1468, doi:10.1029/2002JA009430.

#### NRLMSIS 2.0
**Emmert, J. T., D. P. Drob, J. M. Picone, D. E. Siskind, M. Jones, M. G. Mlynczak, P. F. Bernath, X. Chu, E. Doornbos, B. Funke, L. P. Goncharenko, M. E. Hervig, M. J. Schwartz, P. E. Sheese, F. Vargas, B. P. Williams, and T. Yuan (2021)**, "NRLMSIS 2.0: A Whole-Atmosphere Empirical Model of Temperature and Neutral Species Densities," *Earth and Space Science*, 8, e2020EA001321, doi:10.1029/2020EA001321.

### Model Specifications

#### Validity Domains
- **Altitude Range:** 0 km to 1000 km (ground to exobase)
- **Latitude:** -90° to +90°
- **Longitude:** 0° to 360°
- **Time Coverage:** 1957-present (with various data constraints)

#### Input Parameters
- **Year and Day of Year**
- **Time of Day** (UT)
- **Geodetic Altitude** (km)
- **Geodetic Latitude** (degrees)
- **Longitude** (degrees)
- **F10.7 Solar Flux** (sfu) - daily and 81-day average
- **Ap Geomagnetic Index** (daily)

#### Output Variables
- **Total Mass Density** (kg m⁻³)
- **Temperature** (K) at specified altitude
- **Individual Species Densities** (cm⁻³): N, O, O₂, N₂, Ar, H, He
- **Scale Height** (km) - derived from density gradient

#### Units and Conversions
- **Mass Density:** kg m⁻³ (code uses g cm⁻³, conversion factor: 1 kg m⁻³ = 10⁻³ g cm⁻³)
- **Scale Height:** km (code uses cm, conversion factor: 1 km = 10⁵ cm)

### Atmospheric Composition Effects
The MSIS models account for:
- Solar cycle variations (F10.7 dependence)
- Geomagnetic activity (Ap dependence)
- Seasonal variations (day of year)
- Latitudinal asymmetries
- Longitudinal variations
- Altitude-dependent composition changes

**Source:** Picone et al. (2002); Emmert et al. (2021)

## 3. Dipole Bounce Period Theory

### Primary Reference

**Roederer, J. G. (1970)**, *Dynamics of Geomagnetically Trapped Radiation*, Springer-Verlag, Berlin.

### Relativistic Bounce Period Formula

#### Exact Formula
```latex
T_b = 4 \frac{R_E}{c} \frac{L}{\gamma \beta} \int_0^{\alpha_{eq}} \frac{\cos\alpha \, d\alpha}{\sqrt{1 - \frac{B_{eq}}{B_m(\alpha)} \sin^2\alpha}}
```

where:
- $R_E$ = Earth radius (6371 km)
- $c$ = speed of light
- $L$ = magnetic shell parameter
- $\gamma$ = Lorentz factor
- $\beta$ = v/c
- $\alpha_{eq}$ = equatorial pitch angle
- $B_{eq}$ = equatorial magnetic field
- $B_m$ = mirror point magnetic field

#### Simplified Non-Relativistic Form
```latex
T_b \approx 4 \frac{L R_E}{v} \times T(\alpha_{eq})
```

where $T(\alpha_{eq})$ is the pitch angle integration factor.

### T_pa Polynomial Parameterization

#### Code Implementation
From bounce_time_arr.m, lines 46-47:
```matlab
T_pa = 1.38 + 0.055 .* y.^(1.0/3.0) - 0.32 .* y.^(1.0/2.0) - 0.037 .* y.^(2.0/3.0) - 0.394 ...
    .* y + 0.056 .* y.^(4.0/3.0);
```
where y = sin(pa)

#### Polynomial Coefficient Coefficients
| | Value | Power of sin(α) |
|-------------|-------|-----------------|
| C₀ | 1.38 | sin⁰(α) |
| C₁ | 0.055 | sin¹/³(α) |
| C₂ | -0.32 | sin¹/²(α) |
| C₃ | -0.037 | sin²/³(α) |
| C₄ | -0.394 | sin¹(α) |
| C₅ | 0.056 | sin⁴/³(α) |

#### Critical Open Question
**T_pa coefficients source:** While this polynomial form is consistent with standard dipole bounce period theory (Roederer 1970), the specific coefficients (1.38, 0.055, -0.32, -0.037, -0.394, 0.56) are not explicitly traced to a specific publication in the code comments. This requires further investigation.

**Potential Sources:**
1. Roederer (1970) - "Dynamics of Geomagnetically Trapped Radiation"
2. Schulz and Lanzerotti (1974) - "Particle Diffusion in the Radiation Belts"
3. Subsequent computational implementations and curve fitting

**Type:** **Empirical/Algorithmic** - The polynomial form appears to be a numerical approximation to the exact bounce period integral.

### Particle Mass Dependence

**Electrons:**
- $m_e c^2$ = 0.511 MeV
- Code location: bounce_time_arr.m, line 26

**Protons:**
- $m_p c^2$ = 938.272 MeV  
- Code location: bounce_time_arr.m, line 28

The bounce period scales as $1/pc$ where $p$ is momentum, so protons have much longer bounce periods than electrons at the same kinetic energy.

**Source:** Roederer (1970); Schulz and Lanzerotti (1974)

## 4. Particle Loss Cone Theory

### Primary References

#### Standard Loss Cone Theory
**Roederer, J. G. (1970)**, *Dynamics of Geomagnetically Trapped Radiation*, Springer-Verlag, Berlin.

**Schulz, M., and L. J. Lanzerotti (1974)**, *Particle Diffusion in the Radiation Belts*, Springer-Verlag, Berlin.

### Loss Cone Angle Formula

#### Equatorial Loss Cone
```latex
\sin^2(\alpha_{LC}) = \frac{B_{eq}}{B_m}
```

**Parameters:**
- $\alpha_{LC}$ = loss cone angle at equator
- $B_{eq}$ = equatorial magnetic field strength
- $B_m$ = magnetic field at mirror point

**Physical Interpretation:** Particles with equatorial pitch angles less than $\alpha_{LC}$ will mirror below the atmosphere and be lost.

#### Atmospheric Boundary Condition
Precipitation occurs when mirror altitude < 1000 km, which corresponds to:
- $B_m/B_{eq} \gtrsim 10-15$ for typical L-shells
- $\alpha_{LC} \approx 5-10$ degrees depending on L-shell

### Mirror Point Calculations

#### Dipole Field Equation
From dipole_mirror_altitude.m, line 14:
```latex
\frac{B}{B_{eq}} = \frac{\cos^6\lambda}{\sqrt{1 + 3\sin^2\lambda}}
```

**Parameters:**
- $\lambda$ = magnetic latitude
- $B$ = magnetic field at latitude $\lambda$
- $B_{eq}$ = equatorial magnetic field

#### Mirror Altitude Relationship
```latex
r = L R_E \cos^2\lambda
```

where $r$ is radial distance from Earth's center and $\lambda$ is magnetic latitude.

**Source:** Roederer (1970); Schulz and Lanzerotti (1974)

### Precipitation Loss Mechanisms

1. **Atmospheric Collisions**: Direct loss when particles scatter into the loss cone
2. **Wave-Particle Interactions**: Pitch angle scattering by plasma waves
3. **Coulomb Collisions**: Energy loss and pitch angle diffusion
4. **Atmospheric Backscatter**: Some fraction of particles scatter back up

**Source:** Roederer (1970); Schulz and Lanzerotti (1974)

## 5. Summary of Literature Domains Covered

### ✅ Fang et al. (2010) Model
- **Status:** ✅ Complete
- **Key Equations:** 5 equations with equation numbers
- **Critical Constants:** 0.035 traced to Rees (1989); Pij coefficients fully documented
- **Reference:** Fang et al. (2010), doi:10.1029/2010GL045406

### ✅ MSIS 2.0/2.1 Documentation  
- **Status:** ✅ Complete
- **Model Specifications:** Full documentation of validity domains and outputs
- **References:** Picone et al. (2002); Emmert et al. (2021)

### ✅ Dipole Theory
- **Status:** ⚠️ Partial
- **Key Equations:** Complete bounce period formula documented
- **T_pa coefficients:** ⚠️ **OPEN QUESTION** - Source not definitively identified
- **Reference:** Roederer (1970) primary source

### ✅ Loss Cone Theory
- **Status:** ✅ Complete
- **Key Equations:** Complete loss cone and mirror point formulas
- **References:** Roederer (1970); Schulz and Lanzerotti (1974)

## 6. Critical Open Questions Identified

### Question 1: T_pa Polynomial Source
**Status:** ⚠️ **NOT TRACED**

The T_pa polynomial coefficients (1.38, 0.055, -0.32, -0.037, -0.394, 0.056) used in bounce_time_arr.m have no explicit literature citation in the code. While the polynomial form is consistent with standard dipole theory (Roederer 1970), the specific coefficients need to be traced to their original source.

**Recommended Action:** Search for Roederer (1970) original publication or subsequent implementations that document these specific coefficients.

### Question 2: 6×10⁻⁶ Constant Origin
**Status:** ✅ **TRACED**

The constant $6 \times 10^{-6}$ g/cm³ is identified as a normalization reference density used in the Fang et al. (2010) parameterization. It does not represent a physical constant but rather a scaling factor for the normalized column mass calculation.

**Source:** Fang et al. (2010), Equation (1)

### Question 3: 0.035 Constant Validation
**Status:** ✅ **TRACED**

The constant 0.035 keV (35 eV) represents the mean energy loss per ion pair production and is traced to laboratory measurements by Rees (1989).

**Note:** Fang et al. (2010) note that this value is accurate for high-energy electrons but not for low-energy particles.

**Source:** Rees (1989); Fang et al. (2010)

## 7. Complete Reference List

1. Emmert, J. T., D. P. Drob, J. M. Picone, D. E. Siskind, M. Jones, M. G. Mlynczak, P. F. Bernath, X. Chu, E. Doornbos, B. Funke, L. P. Goncharenko, M. E. Hervig, M. J. Schwartz, P. E. Sheese, F. Vargas, B. P. Williams, and T. Yuan (2021), NRLMSIS 2.0: A Whole-Atmosphere Empirical Model of Temperature and Neutral Species Densities, *Earth and Space Science*, 8, e2020EA001321, doi:10.1029/2020EA001321.

2. Fang, X., C. E. Randall, D. Lummerzheim, W. Wang, G. Lu, S. C. Solomon, and R. A. Frahm (2010), Parameterization of monoenergetic electron impact ionization, *Geophysical Research Letters*, 37, L22106, doi:10.1029/2010GL045406.

3. Fang, X., C. E. Randall, D. Lummerzheim, S. C. Solomon, M. J. Mills, D. R. Marsh, C. H. Jackman, W. Wang, and G. Lu (2008), Electron impact ionization: A new parameterization for 100 eV to 1 MeV electrons, *Journal of Geophysical Research*, 113, A09302, doi:10.1029/2008JA013384.

4. Picone, J. M., A. E. Hedin, D. P. Drob, and A. C. Aikin (2002), NRLMSISE-00 empirical model of the atmosphere: Statistical comparisons and scientific issues, *Journal of Geophysical Research*, 107(A12), 1468, doi:10.1029/2002JA009430.

5. Rees, M. H. (1989), *Physics and Chemistry of the Upper Atmosphere*, Cambridge University Press, Cambridge.

6. Roederer, J. G. (1970), *Dynamics of Geomagnetically Trapped Radiation*, Springer-Verlag, Berlin.

7. Schulz, M., and L. J. Lanzerotti (1974), *Particle Diffusion in the Radiation Belts*, Springer-Verlag, Berlin.

---
**Document Version:** 1.0  
**Date:** January 16, 2026  
**Status:** Complete with 1 open question (T_pa coefficients source)