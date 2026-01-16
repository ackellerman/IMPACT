function [f] = calc_Edissipation(rho,H,E)

%CALC_EDISSIPATION Calculate energy dissipation profile for monoenergetic electrons
%
%   f = calc_Edissipation(rho, H, E) computes the altitude-dependent 
%   energy dissipation rate, f(z, E) for a set of monoenergetic electron beams
%   precipitating into the atmosphere. The calculation follows the parameterization 
%   described in Fang et al. (2010) and is valid for electron energies from 
%   100 eV to 1 MeV.
%
%   INPUTS:
%       rho(z) - Vector of atmospheric mass densities (g cm^-3) as a function of altitude
%       H(z)   - Vector of atmospheric scale heights (cm) as a function of altitude
%       E(n)   - Vector of electron energies (keV)
%
%   OUTPUT:
%       f(z, n) - 2D array of energy dissipation rates as a function of altitude 
%                 and incident electron energy. 
%                 Dimensions: [num_altitudes x num_energies]
%
% CITATION:
%   Fang, X., C. E. Randall, D. Lummerzheim, W. Wang, G. Lu, S. C. Solomon, 
%   and R. A. Frahm (2010), Parameterization of monoenergetic electron impact 
%   ionization, Geophys. Res. Lett., 37, L22106, doi:10.1029/2010GL045406.

    %load Pij from file
    coeff = load('coeff_fang10.mat');

    f=nan(length(rho),length(E));

    for eidx=1:length(E)
        
        % Validate energy range (100 eV - 1 MeV)
        if E(eidx) < 0.1 || E(eidx) > 1000
            warning('calc_Edissipation:EnergyRange', ...
                'Energy %.2f keV outside valid range [0.1, 1000] keV. Results may be unreliable.', E(eidx));
        end

        y = (2./E(eidx)) * (rho .* H).^ 0.7 * (6e-6)^-0.7; %column mass as function of altitude
    
        %calculate each coefficient Ci(i=1,...8)
        c = zeros(1,8);
        for i=1:8
            cij = zeros(1,4);
            for j=0:3
                cij(j+1) = coeff.Pij(i,j+1)*(log(E(eidx)))^j ; %need to use j+1 for index since j is defining third order polynomial (i.e. 0-3)
            end  
            c(i) = exp(sum(cij));
        end
        
        %calculate f
        f(:,eidx) = c(1) * y.^c(2) .* exp(-c(3) * y.^c(4)) + ...
            c(5) * y.^c(6) .* exp(-c(7) * y.^c(8) );
    end


end

