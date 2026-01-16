% Quick verification of Mav calculation

% From MSIS output at 1.0 km altitude (from actual msisoutputs.txt)
nHe = 0.1249e15;
nO = 0.9999e-37;
nN2 = 0.1876e20;
nO2 = 0.5030e19;
nAr = 0.2242e18;
nH = 0.9999e-37;
nN = 0.9999e-37;  % N is negligible at 1 km
nOa = 0.9999e-37;
nNO = 0.9999e-37;  % NO is negligible at 1 km

amu_kg = 1.66e-27;

% MATLAB implementation (includes NO, excludes N)
M_matlab = amu_kg * (nHe*4.0 + nO*16.0 + nN2*28.02 + nO2*32.0 + nAr*39.95 + ...
    nH*1.0 + nOa*16.0 + nNO*30.0) ./ (nHe + nO + nN2 + nO2 + nAr + nH + nOa + nNO);

fprintf('MATLAB Mav: %.4e kg/molecule\n', M_matlab);

% Correct implementation (excludes both N and NO from mass calc)
M_correct = amu_kg * (nHe*4.0 + nO*16.0 + nN2*28.02 + nO2*32.0 + nAr*39.95 + ...
    nH*1.0 + nOa*16.0) ./ (nHe + nO + nN2 + nO2 + nAr + nH + nOa);

fprintf('Correct Mav: %.4e kg/molecule\n', M_correct);

% Relative difference
rel_diff = abs(M_matlab - M_correct) / M_correct;
fprintf('Relative difference: %.6f%%\n', rel_diff * 100);

% Check if difference is significant
if rel_diff < 0.001
    fprintf('Difference is negligible (< 0.1%%)\n');
elseif rel_diff < 0.01
    fprintf('Difference is small (< 1%%) but worth noting\n');
else
    fprintf('Difference is significant (>= 1%%) - should be fixed\n');
end
