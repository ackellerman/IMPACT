# Task 3.6: Phase 3.6: Cross-Component Validation

## Objectives

Validate consistency across energy and flux calculations, and atmospheric boundary integration, ensuring all components of the precipitation model are physically consistent and correctly coupled.

## Element 3.6.0: Validate energy and flux consistency

### Specific Literature References to Check

**Fang et al. (2010) - Energy and flux relationships**
- Sections on energy flux definitions and sign conventions
- Equations connecting energy dissipation to ionization rates
- Verification that Q_e = j·E is physically correct

### Equations and Relationships to Validate

From `fang10_precip.m`:

**Line 32**: Incident energy flux calculation
```matlab
Qe = j .* E; % Incident energy flux
```

**Expected from Fang 2010**:
```
Energy flux: Q_e = j · E

Where:
- j: particle flux (cm⁻²/s or m⁻²/s)
- E: particle energy (keV or MeV)
- Q_e: energy flux (erg/cm²/s or J/m²/s)

Units and conversion:
- j × E must have units of energy/(area·time)
- If j is in cm⁻²/s and E is in keV:
  Q_e (eV/cm²/s) = j (cm⁻²/s) × E (keV) × 10³ (keV to eV)
  Q_e (erg/cm²/s) = j (cm⁻²/s) × E (eV) × 1.602×10⁻¹² (eV to erg)
```

**Check sign convention**:
```
Sign of Q_e:
- Positive: Energy flowing into atmosphere (precipitation source)
- Negative: Energy flowing away (should not occur in this context)
Verify code handles sign correctly (or assumes positive values)
```

**Energy dissipation f(z,E) vs ionization q_tot connection** (calc_Edissipation.m → calc_ionization.m):
```matlab
% In calc_Edissipation.m:
f = energy_dissipation_rate; % Energy deposited per unit depth (keV/keV or dimensionless)

% In calc_ionization.m:
q_tot = Qe ./ 0.035 .* f ./ H; % Ionization rate (cm⁻³/s or similar units)
```

**Expected from Fang 2010**:
```
Energy dissipation to ionization conversion:
q_tot(z) = (Q_e / ε) × f(z,E) / H(z)

Where:
- Q_e: incident energy flux at top of atmosphere
- ε: ionization efficiency (≈ 35 eV per ion pair, constant 0.035 keV)
- f(z,E): fractional energy deposition profile from calc_Edissipation.m
- H(z): scale height (km) - normalizes energy deposition to local depth

Physical interpretation:
- f(z,E): What fraction of incident energy is deposited at depth corresponding to altitude z?
- Dividing by H: Converts energy per unit pressure/depth to per unit altitude
- Dividing by ε: Converts energy to number of ion pairs (energy/energy per ion = ions)
```

**Verify units**:
```
Units check:
Qe [erg/cm²/s] / ε [eV/ion] × f [dimensionless] / H [km]
= [erg/cm²/s] / [eV/ion] × [1] / [km]
= [erg/eV] × [ions/(cm²·s·km)]
= [1.602×10⁻¹²] × [ions/(cm²·s·km)]  (1 erg = 1.602×10⁻¹² eV)
= [ions/(cm²·s·km)] × 10⁻¹²

Need to verify expected final units of q_tot:
- Is q_tot in cm⁻³/s (local ionization rate)?
- Or in ions/(cm²·s) (cumulative flux)?
```

**Cumulative vs local ionization rate definitions** (verify in fang10_precip.m):
```matlab
% Local ionization rate
q_local = q_tot; % Ion pairs per volume per time

% Cumulative ionization from top to z
q_cum = cumtrapz(z, q_tot); % Ion pairs per area per time
```

**Expected from Fang 2010**:
```
Local ionization rate:
q(z) = dq_v/dt  [ions/(cm³·s)]

Cumulative ionization rate:
Q(z) = ∫_z^∞ q(z') dz'  [ions/(cm²·s)]

Relationship:
q(z) = -dQ/dz (for downward integration from top)
```

**Check integration direction**:
```
In fang10_precip.m:
- Integration from top (z = 1000 km) to mirror (z = mirror_altitude)
- q_cum(z) = ∫_top^z q_tot(z') dz'
- q_cum increases as z decreases (more energy deposited as particle descends)

Physical interpretation:
q_cum(mirror) = total energy deposited before mirror point
q_cum(top) = 0 (no energy deposited yet at top of atmosphere)
```

### Expected Values from Literature

**Energy flux example** (verify units and magnitudes):
```
Typical auroral energy flux:
j = 10⁸ cm⁻²/s (electron flux)
E = 10 keV (energy)
Q_e = 10⁸ cm⁻²/s × 10 keV = 10⁹ keV/(cm²·s)
= 10⁹ × 1.602×10⁻⁹ J/(cm²·s)
= 1.6 J/(cm²·s) = 1.6×10⁴ erg/(cm²·s)

Verify if code uses these magnitudes
```

**Ionization example** (verify conversion):
```
Assume:
Q_e = 10⁴ erg/(cm²·s)
ε = 35 eV/ion = 35 × 1.602×10⁻¹² erg/ion
f = 0.1 (10% of energy deposited at this altitude)
H = 50 km

q_tot = Q_e / ε × f / H
= 10⁴ / (5.6×10⁻¹¹) × 0.1 / 50
= 1.8×10¹⁴ × 0.1 / 50
= 3.6×10¹¹ ions/(cm²·s·km)

Need to verify expected units and magnitudes
```

**Cumulative ionization example**:
```
From top to mirror:
q_cum(top) = 0 (no energy deposited yet)
q_cum(mirror) = total energy deposited before mirror point
= Q_e × loss_fraction (if loss_fraction = q_cum(mirror)/q_total)

For loss_fraction = 0.5:
q_cum(mirror) = 0.5 × Q_e / ε (if integrated with proper normalization)
```

### Verification Criteria

- [ ] Q_e = j·E formula matches Fang 2010 Equation [X] (verify equation number)
- [ ] Units of Q_e are correct (erg/cm²/s or J/m²/s) and consistent throughout
- [ ] Sign convention for Q_e is documented (positive = energy into atmosphere)
- [ ] f(z,E) to q_tot conversion matches Fang 2010 derivation
- [ ] Ionization efficiency constant (0.035 keV/ion pair = 35 eV) is correct
- [ ] Cumulative ionization q_cum is correctly integrated from top to mirror
- [ ] Local vs cumulative ionization definitions are clearly distinguished
- [ ] Units consistency check: Q_e / ε × f / H yields physically meaningful q_tot units

### Test Cases

```matlab
% Test case 1: Energy flux calculation units
j = 1e8; % cm⁻²/s
E = 10; % keV
Qe = j * E; % keV/(cm²·s)
Qe_ergs = Qe * 1e3 * 1.602e-12; % erg/(cm²·s)
% Should be ~1.6 erg/(cm²·s)

% Test case 2: Ionization rate units
Qe = 1e4; % erg/(cm²·s)
epsilon = 35; % eV/ion = 35 * 1.602e-12 erg/ion
f = 0.1;
H = 50; % km
q_tot = Qe / epsilon * f / H; % should be ions/(cm²·s·km)
% Verify units: [erg/cm²/s] / [erg/ion] × [1] / [km] = [ions/(cm²·s·km)]

% Test case 3: Cumulative ionization consistency
z = 0:10:1000; % km
q_tot = 1e10 * exp(-z/100); % local ionization rate
q_cum = cumtrapz(z, q_tot); % cumulative
% Check: q_cum(end) = ∫_0^1000 q_tot(z) dz ≈ 1e10 * 100 = 1e12 ions/(cm²·s)
% Verify: q_cum(end) / (Qe/epsilon) should match loss_fraction

% Test case 4: Energy conservation
Qe = 1e4; % erg/(cm²·s)
epsilon = 35; % eV/ion
f = 1; % all energy deposited
H = 100; % km
q_tot = Qe / epsilon * f / H;
q_total = trapz(z, q_tot * H) * epsilon; % total energy deposited
% Should equal Qe (within numerical error)
```

### Dependencies

- Element 3.1.0: Energy dissipation f(z,E) must be validated first
- Element 3.1.1: Ionization rate calculation q_tot must be validated first
- Element 3.5.0: Cumulative ionization q_cum must be validated first

---

## Element 3.6.1: Validate atmospheric boundary integration

### Specific Literature References to Check

**Fang et al. (2010) - Atmospheric boundary integration**
- Section on integration bounds and boundary conditions
- Physical interpretation of integrating from top to mirror
- Discussion of atmospheric penetration depth

### Equations and Methods to Validate

From `fang10_precip.m`:

**Integration from top of atmosphere downward**:
```matlab
% Integration bounds
alt_top = 1000; % km (top of dense atmosphere)
z = alt_top:-1:0; % descending altitude array
q_cum = cumtrapz(z, q_tot); % integrate from top downward
```

**Expected from Fang 2010**:
```
Integration: Q(z) = ∫_z^∞ q(z') dz'

Implemented numerically:
q_cum(z) = ∫_z_top^z q_tot(z') dz'

Integration direction:
- From z_top (1000 km) to z_bottom (0 km or mirror_altitude)
- Cumulative sum increases as z decreases
- q_cum(z_top) = 0 (no energy deposited at top)
- q_cum(mirror) = total energy deposited before mirror point
```

**Physical interpretation**:
```
Why integrate from top downward?
- Particle enters from top (high altitude)
- Deposits energy as it penetrates deeper
- Mirrors at altitude where magnetic field reflects it
- Only energy deposited below top and above mirror contributes to loss

Alternative perspective:
- q_cum(z) = total energy deposited from top to z
- Loss occurs if mirror altitude < top (particle enters atmosphere)
- Loss fraction = q_cum(mirror) / q_cum(bottom_of_integration)
```

**Mirror altitude as lower integration bound** (verify in fang10_precip.m):
```matlab
% Find ionization deposited before mirror point
idx_mirror = find(z <= mirror_altitude, 1, 'last');
q_to_mirror = q_cum(idx_mirror);

% Total ionization (bottom of atmosphere or extrapolated)
q_top = q_cum(end); % or extrapolated to z -> infinity
```

**Expected from Fang 2010**:
```
Lower integration bound:
- z_lower = mirror_altitude (if mirror_altitude > 0)
- z_lower = 0 (if mirror_altitude < 0, particle hits surface)

Total ionization reference:
- q_total = ∫_0^∞ q_tot(z) dz (full atmospheric penetration)
- Or q_total = ∫_top^bottom q_tot(z) dz (bounded by top/bottom of atmosphere)
- Check if Fang 2010 defines "total ionization" differently

Loss factor:
Φ_loss = q_to_mirror / q_total
```

**Physical interpretation of cumulative ionization**:
```
What does q_cum(z) represent?

Interpretation 1: Energy deposited from top to depth z
- q_cum(z) = total energy lost by particle between z_top and z
- Physically: particle loses energy via collisions as it descends
- Energy lost = energy deposited in atmosphere (converted to ionization, heating, etc.)

Interpretation 2: Ionization produced from top to depth z
- q_cum(z) = total ion pairs produced between z_top and z
- Physically: energy deposition creates ion pairs at rate 1 ion / 35 eV
- q_cum(z) = q_energy(z) / ε (where ε = 35 eV/ion)

Verify which interpretation is used in Fang 2010 (likely Interpretation 1, converted to 2 in calc_ionization.m)
```

**Boundary conditions** (verify):
```matlab
% At top of atmosphere (z = 1000 km)
q_cum(z_top) = 0 (particle hasn't entered yet, no energy deposited)

% At mirror altitude (z = mirror_altitude)
q_cum(mirror) = total energy deposited before mirroring
- If mirror_altitude < 0: q_cum(mirror) ≈ q_total (complete penetration)
- If mirror_altitude > 1000: q_cum(mirror) = 0 (no penetration)

% At bottom of atmosphere (z = 0 km)
q_cum(bottom) = total energy deposited if particle reaches surface
```

### Expected Values from Literature

**Integration bounds** (verify from Fang 2010):
```
Top of integration:
- z_top = 1000 km (dense atmosphere)
- Or z_top = infinity (magnetospheric boundary)
- Check which is used in Fang 2010

Bottom of integration:
- z_bottom = 0 km (Earth's surface)
- Or z_bottom = -R_E (below Earth's center, for mirroring below surface)
- Check if Fang 2010 extrapolates or clamps to surface

Typical integration domain:
- 0 km ≤ z ≤ 1000 km (main precipitation region)
- May extend to 1500 km or higher (atmospheric tail)
```

**Cumulative ionization profiles** (expected shape):
```
For exponential energy deposition q_tot(z) = q₀·exp(-z/H):
q_cum(z) = ∫_z^∞ q₀·exp(-z'/H) dz' = q₀·H·exp(-z/H)

Profile shape:
- Exponentially decreasing with increasing altitude
- q_cum(0) = q₀·H (maximum at surface)
- q_cum(1000 km) ≈ 0 (minimum at top)
- Characteristic scale: H (scale height, ~50-100 km)

Check if Fang 2010 confirms this profile shape
```

### Verification Criteria

- [ ] Integration bounds (1000 km to mirror) match Fang 2010 specification
- [ ] Integration direction (top to bottom) is correctly implemented
- [ ] q_cum(1000 km) = 0 (no energy deposited at top)
- [ ] q_cum(mirror_altitude) increases as mirror altitude decreases
- [ ] Physical interpretation of q_cum(z) is documented in code comments
- [ ] Boundary conditions (mirror < 0, mirror > 1000) are correctly handled
- [ ] Loss factor = q_cum(mirror) / q_total is consistent with Fang 2010

### Test Cases

```matlab
% Test case 1: Integration direction
z = 1000:-1:0; % top-down array
q_tot = 1e10 * exp(-z/100); % decreasing with depth
q_cum = cumtrapz(z, q_tot);
% Check: q_cum(1) ≈ 0 (at top)
% Check: q_cum(end) = ∫_0^1000 q_tot(z) dz ≈ 1e10 * 100 = 1e12 ions/(cm²·s)

% Test case 2: Mirror altitude integration
mirror_alt = 300; % km
idx = find(z <= mirror_alt, 1, 'last');
q_to_mirror = q_cum(idx);
q_total = q_cum(end);
loss_factor = q_to_mirror / q_total;
% Check: loss_factor increases as mirror_altitude decreases

% Test case 3: Boundary conditions
for mirror_alt = [1500, 800, 300, -100] % km
    if mirror_alt > 1000
        % No penetration, loss factor = 0
    elseif mirror_alt < 0
        % Full penetration, loss factor = 1
    else
        % Partial penetration, 0 < loss_factor < 1
    end
end

% Test case 4: Consistency check
q_tot = 1e10 * exp(-z/100);
q_cum = cumtrapz(z, q_tot);
% Energy conservation: ∫ q_tot(z)dz should equal q_cum(0)
total_energy = trapz(z, q_tot);
cumulative_at_surface = q_cum(end);
% Check: abs(total_energy - cumulative_at_surface) / total_energy < 0.001
```

### Dependencies

- Element 3.1.1: Ionization rate profile q_tot(z) must be validated first
- Element 3.2.1: Mirror altitude calculation provides integration lower bound
- Element 3.5.0: Loss factor calculation uses q_cum values

### Files to Validate

- `IMPACT_MATLAB/calc_ionization.m` - Ionization rate profile and cumulative integration
- `IMPACT_MATLAB/fang10_precip.m` - Integration bounds and loss factor calculation
- Fang et al. (2010) - Sections on atmospheric penetration and integration

### References

- Fang et al. (2010) - Sections [X]-[X] on integration bounds and boundary conditions
- Rees (1989) - Auroral ionization rates and atmospheric penetration
- Solomon and Abreu (1989) - Auroral electron energy transport
- Strickland et al. (1993) - Atmospheric energy deposition modeling