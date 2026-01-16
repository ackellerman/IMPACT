# Task 3.5: Phase 3.5: Integration Logic and Edge Cases

## Objectives

Validate precipitation loss calculation, numerical methods, and edge case handling in the precipitation model, ensuring physical correctness and numerical stability.

## Element 3.5.0: Validate precipitation loss calculation (fang10_precip.m)

### Specific Literature References to Check

**Fang et al. (2010) - Precipitation loss mechanism**
- Section on precipitation loss calculation and boundary conditions
- Equations for loss factor and time evolution
- Edge case handling (mirror altitude below/atmospheric boundary)

### Equations and Line Numbers to Validate

From `fang10_precip.m`:

**Line 102**: Loss factor calculation
```matlab
loss_factor = q_to_mirror / q_top;
```

**Expected from Fang 2010**:
```
Loss factor: Φ_loss = ∫_top^mirror q(z) dz / ∫_top^∞ q(z) dz

Where:
- q(z): local ionization rate at altitude z
- q_to_mirror: cumulative ionization from top to mirror point
- q_top: total ionization from top to infinity (or below atmosphere)
- Physical interpretation: fraction of energy deposited before mirroring
```

**Line 116**: Time evolution over half bounce period
```matlab
dQe_dt = 2 * Qe_loss / t_b;
```

**Expected from Fang 2010**:
```
Energy loss rate: dQ_e/dt = 2·Q_e_loss / τ_bounce

Where:
- Q_e_loss: energy lost in one half-bounce (mirroring in atmosphere)
- τ_bounce: full bounce period (seconds)
- Factor 2: accounts for half-bounce loss (particle arrives at atmosphere, loses energy, then completes second half of bounce)
- Physical units: [dQ_e/dt] = energy flux / time (erg/cm²/s² or equivalent)
```

**Lines 16-18**: Energy range enforcement
```matlab
% Energy range 100 eV - 1 MeV
if E < 0.1 || E > 1000 % keV
    error('Energy out of valid range');
end
```

**Expected from Fang 2010**:
- Valid energy range: 100 eV (0.1 keV) - 1 MeV (1000 keV)
- This matches valid parameter range for f(z,E) function
- Check if literature specifies physical reasons for this range

**Boundary conditions** (verify exact implementation):
```matlab
% Mirror altitude checks
if mirror_altitude < 0 % Below Earth's surface
    % Particle is fully absorbed (set loss factor = 1)
    loss_factor = 1;
elseif mirror_altitude > 1000 % Above loss cone
    % Particle doesn't enter atmosphere (set loss factor = 0)
    loss_factor = 0;
elseif isnan(mirror_altitude) % Invalid calculation
    % Handle error (set loss factor = 0 or flag error)
    loss_factor = 0;
end
```

**Expected from Fang 2010**:
- Mirror altitude < 0 km: Particle mirrors below Earth's surface → complete loss (Φ_loss = 1)
- Mirror altitude > 1000 km: Particle mirrors above dense atmosphere → no significant loss (Φ_loss ≈ 0)
- Invalid/NaN: Numerical error → handle with error or set to boundary value
- Check if Fang 2010 specifies exact altitude thresholds (1000 km or different)

### Expected Values from Literature

**Typical loss factors** (from Fang 2010 or similar studies):

**Quiet conditions (α_eq close to 90°, L > 4)**:
- Mirror altitude > 1000 km
- Loss factor Φ_loss ≈ 0 (no precipitation)

**Active conditions (α_eq small, L = 2-4)**:
- Mirror altitude < 500 km (dense atmosphere)
- Loss factor Φ_loss ≈ 0.5-1 (significant precipitation)

**Storm conditions (α_eq = α_LC, L < 2)**:
- Mirror altitude < 100 km (very dense)
- Loss factor Φ_loss ≈ 1 (complete precipitation)

**Time evolution example**:
- Bounce period τ_b ≈ 1 s
- Energy lost in half-bounce Q_e_loss ≈ 10% of Q_e
- dQ_e/dt ≈ 2 × 0.1 × Q_e / 1 s = 0.2 Q_e/s (20% loss per second)

### Verification Criteria

- [ ] Loss factor formula q_to_mirror/q_top matches Fang 2010 Equation [X]
- [ ] Time evolution dQ_e/dt = 2·Q_e_loss/τ_b matches Fang 2010 derivation
- [ ] Energy range 100 eV - 1 MeV is documented in Fang 2010
- [ ] Boundary conditions (< 0, > 1000, NaN) are correctly implemented
- [ ] Loss factor ranges from 0 (no loss) to 1 (complete loss)
- [ ] Time stepping integration uses correct factor of 2 for half-bounce

### Test Cases

```matlab
% Test case 1: No loss (mirror altitude > 1000 km)
q_to_mirror = 1e10; % arbitrary units
q_top = 1e10;
mirror_alt = 1500; % km
% Expected loss_factor = 0

% Test case 2: Partial loss (mirror altitude = 300 km)
q_to_mirror = 5e9; % half deposited before mirror
q_top = 1e10;
mirror_alt = 300; % km
% Expected loss_factor = 0.5

% Test case 3: Complete loss (mirror altitude < 0 km)
q_to_mirror = 1e10; % all deposited before mirror
q_top = 1e10;
mirror_alt = -100; % km (below surface)
% Expected loss_factor = 1

% Test case 4: Time evolution
Qe_loss = 1e4; % erg/cm²
t_b = 1.0; % seconds
dQe_dt = 2 * Qe_loss / t_b; % should be 2e4 erg/cm²/s
```

### Dependencies

- Element 3.1.1: Ionization rate calculation (q_tot, q_cum) must be validated first
- Element 3.2.0: Bounce period calculation (t_b) must be validated first
- Element 3.2.1: Mirror altitude calculation (mirror_alt) must be validated first

---

## Element 3.5.1: Validate numerical methods and stability

### Specific Literature References to Check

**Numerical methods in space physics:**

- Press et al. (2007) - Numerical Recipes (trapezoidal integration)
- Boyd (2001) - Chebyshev and Fourier Spectral Methods
- Space physics validation papers on numerical stability

### Equations and Methods to Validate

From `fang10_precip.m` and related scripts:

**Trapezoidal integration for q_cum** (verify in calc_ionization.m fang10_precip.m):
```matlab
% Cumulative ionization
q_cum = cumtrapz(z, q_tot); % MATLAB's cumulative trapezoidal rule
```

**Expected numerical method**:
```
Trapezoidal rule:

∫_a^b f(x) dx ≈ Δx/2 [f(a) + 2f(a+Δx) + 2f(a+2Δx) + ... + f(b)]

Cumulative form:
F(b) = ∫_a^b f(x) dx

MATLAB cumtrapz algorithm:
- Handles non-uniform grid spacing
- Accuracy: O(Δz²) for smooth functions
- Stable for monotonic functions (q_tot typically decreases with altitude)
```

**Expected accuracy for ionization profile**:
```
For typical ionization profile q_tot(z):
- Exponential-like decrease with decreasing altitude
- Altitude grid: Δz = 1-10 km (verify grid spacing)
- Integration error: < 1% for Δz ≤ 10 km (verify)
```

**Interpolation for mirror altitude lookup** (verify in dipole_mirror_altitude.m):
```matlab
% Interpolate to find mirror altitude
mirror_alt = interp1(B_inv, z, B_ratio_target, 'linear');
```

**Expected interpolation method**:
```
Linear interpolation:
Given (x₀, y₀) and (x₁, y₁):
y = y₀ + (y₁ - y₀) · (x - x₀) / (x₁ - x₀)

Expected accuracy:
- O(Δx) error for linear interpolation
- Should be < 1% error for reasonable grid spacing
- Alternative: spline interpolation (higher order, may overfit)
```

**Time stepping stability** (verify in fang10_precip.m time loop):
```matlab
% Time evolution loop
for t = 1:N_steps
    dQe_dt = 2 * Qe_loss(t) / t_b(t);
    Qe(t+1) = Qe(t) - dQe_dt * dt;
end
```

**Expected stability criteria**:
```
Explicit Euler integration:
Q_e(t+Δt) = Q_e(t) + (dQ_e/dt) · Δt

Stability condition (CFL-like):
Δt ≪ τ_characteristic

Where:
- τ_characteristic = τ_bounce / (2 · loss_fraction)
- For loss_fraction ≈ 0.1, τ_bounce ≈ 1 s: Δt ≪ 5 s (verify constraint)
- Typical dt: 0.1-1 s (check if fixed or adaptive)
```

**Negative value enforcement** (verify line 123 in fang10_precip.m):
```matlab
% Ensure energy flux is non-negative
if Qe < 0
    Qe = 0; % Clamp to zero
end
```

**Expected physical constraint**:
- Energy flux must be non-negative (can't have negative precipitation)
- Numerical instability can cause small negative values (rounding errors)
- Clamping to zero is physically correct and numerically stable

### Expected Numerical Accuracy

**Integration accuracy**:
- Trapezoidal rule: Error ∼ O(Δz²)
- For Δz = 10 km, integration error < 1% (verify with analytical test cases)
- Comparison with analytical solution: f(z) = f₀·exp(-z/H) should integrate to f₀·H

**Interpolation accuracy**:
- Linear interpolation: Error ∼ O(Δz)
- For Δz = 10 km, lookup error < 1% (verify)
- Test case: linear function should be interpolated exactly

**Time stepping stability**:
- Explicit Euler: Conditionally stable
- For loss_fraction < 1, Δt < τ_bounce/2 is sufficient
- Verify code uses appropriate dt or implements adaptive stepping

### Verification Criteria

- [ ] Trapezoidal integration (cumtrapz) is appropriate for q_tot(z) profile
- [ ] Cumulative ionization error < 1% for expected grid spacing
- [ ] Interpolation method (linear) is accurate to < 1% for mirror altitude lookup
- [ ] Time stepping is stable with chosen dt (no unphysical oscillations)
- [ ] Negative values are clamped to zero (non-negative constraint enforced)
- [ ] Grid spacing (Δz, Δt) is documented and appropriate for accuracy

### Test Cases

```matlab
% Test case 1: Trapezoidal integration accuracy (analytical test)
z = 0:10:1000; % km
q_tot = 1e10 * exp(-z/100); % exponential decay
q_cum_analytical = 1e10 * 100 * (1 - exp(-z/100)); % exact integral
q_cum_numerical = cumtrapz(z, q_tot);
% Check: max(abs((q_cum_numerical - q_cum_analytical) / q_cum_analytical)) < 0.01

% Test case 2: Interpolation accuracy (linear function)
z = 0:10:1000;
B_inv = 1 ./ (z + 6371)^3; % dipole field approximation
mirror_altitude = interp1(B_inv, z, 0.01, 'linear');
% Should be close to analytical solution (verify)

% Test case 3: Time stepping stability
dt = 0.1; % s
Qe = 1e5; % erg/cm²/s
Qe_loss = 1000; % loss per half-bounce
t_b = 1.0; % s
for t = 1:100
    dQe_dt = 2 * Qe_loss / t_b;
    Qe = Qe - dQe_dt * dt;
    if Qe < 0
        Qe = 0; % clamp
        break;
    end
end
% Check: Qe decreases smoothly to 0 without oscillations

% Test case 4: Grid spacing sensitivity
for dz = [1, 5, 10, 20, 50] % km
    z = 0:dz:1000;
    q_tot = 1e10 * exp(-z/100);
    q_cum = cumtrapz(z, q_tot);
    % Check error vs analytical solution
end
% Error should decrease with dz (verify O(dz²) trend)
```

### Dependencies

- Element 3.1.0: Energy dissipation f(z,E) provides q_tot input
- Element 3.1.1: Ionization rate calculation defines q_tot profile
- Element 3.5.0: Time evolution loop integration

### Files to Validate

- `IMPACT_MATLAB/calc_ionization.m` - Trapezoidal integration (cumtrapz)
- `IMPACT_MATLAB/dipole_mirror_altitude.m` - Interpolation method
- `IMPACT_MATLAB/fang10_precip.m` - Time stepping and negative value enforcement
- Press et al. (2007) - Numerical Recipes chapters on integration and interpolation

### References

- Press et al. (2007) - Numerical Recipes (trapezoidal rule, interpolation)
- Trefethen (2000) - Spectral Methods in MATLAB (for higher-order methods)
- Boyd (2001) - Chebyshev and Fourier Spectral Methods (accurate interpolation)
- Space physics validation studies on numerical stability (check if referenced in Fang 2010)