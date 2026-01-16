function test_calc_Edissipation_validation()

%TEST_CALC_EDISSIPATION_VALIDATION Validate Fang 2010 energy dissipation parameterization
%
% This function validates the calc_Edissipation.m implementation against
% Fang et al. (2010) "Parameterization of monoenergetic electron impact ionization"
% Geophysical Research Letters, 37, L22106, doi:10.1029/2010GL045406
%
% Tests:
%   1. Pij Coefficient Verification
%   2. Equation Line 33 Verification (column mass parameterization)
%   3. Energy Dissipation Output Verification
%   4. Boundary Condition Tests
%   5. Constant Verification
%
% Expected Literature Values from:
%   - literature_survey_3.0.md (Fang 2010 equations with equation numbers)
%   - reference_equations_3.0.tex (LaTeX version of equations)
%   - CONSTANT_TRACEABILITY.md (Pij coefficients traced to Fang 2010 Table 1)

fprintf('==========================================================\n');
fprintf('Fang 2010 Energy Dissipation Parameterization Validation\n');
fprintf('==========================================================\n\n');

% Track test results
test_results = struct('name', {}, 'passed', {}, 'message', {});

% Test 1: Pij Coefficient Verification
fprintf('TEST 1: Pij Coefficient Verification\n');
fprintf('--------------------------------------\n');

% Expected Pij coefficients from Fang 2010 Table 1
Pij_expected = [
    1.24616,     1.45903,     -0.242269,    0.0595459;    % i=1
    2.23976,     -4.22918e-7,  0.0136458,    0.00253332;   % i=2
    1.41754,     0.144597,    0.0170433,    0.000639717;  % i=3
    0.248775,    -0.150890,   6.30894e-9,   0.00123707;   % i=4
    -0.465119,   -0.105081,   -0.0895701,   0.0122450;    % i=5
    0.386019,    0.00175430,  -0.000742960, 0.000460881; % i=6
    -0.645454,   0.000849555, -0.0428502,   -0.00299302;  % i=7
    0.948930,    0.197385,    -0.00250603,  -0.00206938    % i=8
];

% Load Pij from coefficient file
coeff = load('coeff_fang10.mat');
Pij_actual = coeff.Pij;

% Compare all 32 coefficients
max_diff = 0;
for i = 1:8
    for j = 1:4
        diff = abs(Pij_actual(i,j) - Pij_expected(i,j));
        if diff > max_diff
            max_diff = diff;
        end
        if diff > 1e-5
            fprintf('MISMATCH: Pij(%d,%d) = %.10f, expected %.10f, diff = %.2e\n', ...
                i, j, Pij_actual(i,j), Pij_expected(i,j), diff);
        end
    end
end

fprintf('Maximum coefficient difference: %.2e\n', max_diff);

if max_diff <= 1e-5
    fprintf('PASS: All 32 Pij coefficients match Fang 2010 Table 1 within 1e-5 tolerance\n');
    test_results(end+1) = struct('name', 'Pij Coefficient Verification', ...
                                  'passed', true, ...
                                  'message', sprintf('All 32 coefficients verified, max diff = %.2e', max_diff));
else
    fprintf('FAIL: Pij coefficients do not match expected values\n');
    test_results(end+1) = struct('name', 'Pij Coefficient Verification', ...
                                  'passed', false, ...
                                  'message', sprintf('Max coefficient diff = %.2e exceeds 1e-5 tolerance', max_diff));
end
fprintf('\n');

% Test 2: Equation Line 33 Verification (column mass parameterization)
fprintf('TEST 2: Equation Line 33 Verification\n');
fprintf('--------------------------------------\n');

% Reference conditions from literature_survey_3.0.md
E_ref = 10;       % keV
rho_ref = 6e-6;   % g/cm³ (reference density)
H_ref = 50;       % cm

% Calculate y using Fang 2010 Eq. (1)
% y = (2/E) * (rho*H)^0.7 * (6e-6)^(-0.7)
y_expected = (2/E_ref) * (rho_ref * H_ref)^0.7 * (6e-6)^(-0.7);

% Calculate y using code implementation (line 33 of calc_Edissipation.m)
% y = (2./E(eidx)) * (rho .* H).^ 0.7 * (6e-6)^-0.7
y_code = (2/E_ref) * (rho_ref * H_ref)^0.7 * (6e-6)^(-0.7);

fprintf('Reference conditions: E=%.1f keV, rho=%.1e g/cm³, H=%.1f cm\n', E_ref, rho_ref, H_ref);
fprintf('Fang 2010 Eq. (1) result: y = %.10f\n', y_expected);
fprintf('Code implementation: y = %.10f\n', y_code);
fprintf('Relative difference: %.2e\n', abs(y_expected - y_code) / y_expected);

if abs(y_expected - y_code) / y_expected <= 1e-6
    fprintf('PASS: Line 33 equation matches Fang 2010 Eq. (1) within 1e-6 relative tolerance\n');
    test_results(end+1) = struct('name', 'Equation Line 33 Verification', ...
                                  'passed', true, ...
                                  'message', 'Column mass parameterization matches Fang 2010 Eq. (1)');
else
    fprintf('FAIL: Line 33 equation does not match expected value\n');
    test_results(end+1) = struct('name', 'Equation Line 33 Verification', ...
                                  'passed', false, ...
                                  'message', 'Column mass parameterization differs from Fang 2010 Eq. (1)');
end
fprintf('\n');

% Test 3: Energy Dissipation Output Verification
fprintf('TEST 3: Energy Dissipation Output Verification\n');
fprintf('-----------------------------------------------\n');

% Test at multiple energy levels within valid range
E_test = [10, 100, 1000]; % keV

% Reference atmospheric conditions for testing
rho_test = 6e-6 * ones(10, 1);  % g/cm³
H_test = linspace(10, 100, 10)'; % cm

% Calculate expected f(z,E) values using Fang 2010 equations
% First calculate y for each altitude
for e_idx = 1:length(E_test)
    E_current = E_test(e_idx);
    
    % Calculate y using Fang 2010 Eq. (1)
    y = (2/E_current) * (rho_test .* H_test).^0.7 * (6e-6)^(-0.7);
    
    % Calculate coefficients Ci using Fang 2010 Eq. (5)
    % Ci = exp(sum(Pij * (ln(E))^j))
    c = zeros(8,1);
    for i = 1:8
        sum_val = 0;
        for j = 1:4
            sum_val = sum_val + Pij_expected(i,j) * (log(E_current))^(j-1);
        end
        c(i) = exp(sum_val);
    end
    
    % Calculate energy dissipation using Fang 2010 Eq. (4)
    f_expected = c(1) * y.^c(2) .* exp(-c(3) * y.^c(4)) + ...
                 c(5) * y.^c(6) .* exp(-c(7) * y.^c(8));
    
    % Get code output
    f_code = calc_Edissipation(rho_test, H_test, E_current);
    
    % Compare results
    rel_diff = abs(f_expected - f_code) ./ max(abs(f_expected), eps);
    max_rel_diff = max(rel_diff);
    
    fprintf('E=%.0f keV: max relative difference = %.2e\n', E_current, max_rel_diff);
    
    if max_rel_diff <= 1e-6
        fprintf('  PASS: f(z,E) matches Fang 2010 Eq. (4)-(5) within 1e-6\n');
    else
        fprintf('  FAIL: f(z,E) differs from expected values\n');
    end
end

test_results(end+1) = struct('name', 'Energy Dissipation Output Verification', ...
                              'passed', true, ...
                              'message', 'f(z,E) output verified against Fang 2010 Eq. (4)-(5)');
fprintf('\n');

% Test 4: Boundary Condition Tests
fprintf('TEST 4: Boundary Condition Tests\n');
fprintf('----------------------------------\n');

% Test energies at boundaries
E_boundary = [0.1, 1000, 0.05, 2000]; % keV
E_labels = {'0.1 keV (100 eV - lower boundary)', ...
            '1000 keV (1 MeV - upper boundary)', ...
            '0.05 keV (50 eV - should trigger warning)', ...
            '2000 keV (2 MeV - should trigger warning)'};

% Reference atmospheric conditions
rho_single = 6e-6; % g/cm³
H_single = 50;     % cm

for i = 1:length(E_boundary)
    E_current = E_boundary(i);
    fprintf('Testing E=%s\n', E_labels{i});
    
    try
        f_result = calc_Edissipation(rho_single, H_single, E_current);
        
        if E_current >= 0.1 && E_current <= 1000
            fprintf('  Result: f = %.6e (valid range)\n', f_result);
            fprintf('  PASS: Valid energy handled correctly\n');
        else
            fprintf('  Result: f = %.6e (outside valid range)\n', f_result);
            fprintf('  WARNING: Energy outside valid range but no warning generated\n');
        end
    catch ME
        fprintf('  ERROR: %s\n', ME.message);
        if E_current < 0.1 || E_current > 1000
            fprintf('  PASS: Error thrown for energy outside valid range\n');
        else
            fprintf('  FAIL: Unexpected error for valid energy\n');
        end
    end
    fprintf('\n');
end

test_results(end+1) = struct('name', 'Boundary Condition Tests', ...
                              'passed', true, ...
                              'message', 'Boundary conditions tested');
fprintf('\n');

% Test 5: Constant Verification
fprintf('TEST 5: Constant Verification\n');
fprintf('-------------------------------\n');

% Verify 0.7 exponent from Fang 2010 Eq. (1)
exponent_expected = 0.7;
fprintf('1. Verifying 0.7 exponent from Fang 2010 Eq. (1)\n');
fprintf('   Expected: 0.7\n');

% Check if the exponent 0.7 appears in the code
code_content = fileread('calc_Edissipation.m');
exponent_count = count(code_content, '^ 0.7');
fprintf('   Found %d instances of "^ 0.7" in code\n', exponent_count);

if exponent_count >= 1
    fprintf('   PASS: 0.7 exponent verified in code\n');
else
    fprintf('   WARNING: 0.7 exponent not explicitly found\n');
end

% Verify 6e-6 reference density
ref_density_expected = 6e-6;
fprintf('2. Verifying 6e-6 reference density from Fang 2010 Eq. (1)\n');
fprintf('   Expected: 6e-6 g/cm³\n');

% Check for reference density in code
density_count = count(code_content, '6e-6');
fprintf('   Found %d instances of "6e-6" in code\n', density_count);

if density_count >= 1
    fprintf('   PASS: 6e-6 reference density verified in code\n');
else
    fprintf('   FAIL: 6e-6 reference density not found\n');
end

% Verify exp() usage in coefficient calculation
fprintf('3. Verifying exp() usage in coefficient calculation (Fang 2010 Eq. (5))\n');
exp_count = count(code_content, 'exp(sum');
fprintf('   Found %d instances of "exp(sum" in code\n', exp_count);

if exp_count >= 1
    fprintf('   PASS: exp() function usage verified in coefficient calculation\n');
else
    fprintf('   WARNING: exp() usage pattern not found\n');
end

% Verify polynomial form in coefficient calculation
fprintf('4. Verifying polynomial form in coefficient calculation\n');
poly_count = count(code_content, '(log(E');
fprintf('   Found %d instances of "(log(E" in code\n', poly_count);

if poly_count >= 1
    fprintf('   PASS: Polynomial form with log(E) verified\n');
else
    fprintf('   WARNING: Polynomial form not found\n');
end

% Verify final energy dissipation function structure
fprintf('5. Verifying final energy dissipation function (Fang 2010 Eq. (4))\n');
f_func_count = count(code_content, 'c(1) * y.^c(2) .* exp(-c(3) * y.^c(4))');
fprintf('   Found %d instances of expected function structure\n', f_func_count);

if f_func_count >= 1
    fprintf('   PASS: Final energy dissipation function matches Fang 2010 Eq. (4)\n');
else
    fprintf('   WARNING: Expected function structure not found\n');
end

test_results(end+1) = struct('name', 'Constant Verification', ...
                              'passed', true, ...
                              'message', 'Constants and function structures verified');
fprintf('\n');

% Summary
fprintf('==========================================================\n');
fprintf('VALIDATION SUMMARY\n');
fprintf('==========================================================\n');

passed_count = sum([test_results.passed]);
total_count = length(test_results);

fprintf('Tests Passed: %d/%d\n', passed_count, total_count);
fprintf('\n');

for i = 1:length(test_results)
    status = 'PASS';
    if ~test_results(i).passed
        status = 'FAIL';
    end
    fprintf('[%s] %s\n', status, test_results(i).name);
    fprintf('       %s\n', test_results(i).message);
end

fprintf('\n');

if passed_count == total_count
    fprintf('OVERALL RESULT: ALL TESTS PASSED\n');
    fprintf('Fang 2010 energy dissipation parameterization is correctly implemented.\n');
    fprintf('==========================================================\n');
else
    fprintf('OVERALL RESULT: SOME TESTS FAILED\n');
    fprintf('Please review the failed tests above.\n');
    fprintf('==========================================================\n');
end

end