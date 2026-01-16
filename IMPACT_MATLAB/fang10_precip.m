% Model for electron loss due to atmospheric precipitation
% Fang 2010 model is used to represent loss rates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ToDO: energy and pitch angles will be defined through input data
%ForNow:define energy and pitch angle grid, Lshell, and time steps:

Lshell=3;
E = linspace(1, 1000, 100); % Energy in keV
pa = linspace(0, 180, 1000); % Pitch angle in deg
time = linspace(0, 0.0001, 10000); %time 
dt = time(2)-time(1); %timestep
j=def_testdata(E,pa,time); %define number flux cm^-2 s^-1 

% Enforce energy range to ensure within valid limits of Fang+2010 ionisation model. 
if any(E < 1) || any(E > 1000)
    error('Energy range contains values outside of the valid range (100 eV - 1 MeV). ');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define MSIS inputs (F107 & Ap index) and Altitudes to sample atmosphere
alt   = 0:1:1000; %(altitude in km)
%Fornow: define F107 and Ap as constant
f107a  = ones(length(time),1)*50.0;
f107   = ones(length(time),1)*50.0;
Ap     = ones(length(time),1)*5.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate incident energy flux Qe of dimension [nt,nE,nPa]:
E_grid = reshape(E, 1, 1, length(E));
Qe = j .* E_grid;  % units: keV cm^-2 s^-1 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate bounce orbit times for an energy and pitch angle grid:

%repeat pa and E to arrays of dimensions [nPa x nE]
[E_arr,pa_arr] = meshgrid(E,pa);
%calculate bounce time
t_b = bounce_time_arr(Lshell,E_arr./1000,deg2rad(pa_arr),'e');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate mirror altitude for pitch angle and L shell:
mirr_alt = dipole_mirror_altitude(pa,Lshell);


%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%leving these here as it makes testing faster
%     %calculate energy dissipation for the specified energy grid:
%     %NOTE: If code needs to speed up, and F107/Ap are constant, then this can be taken out of time loop
%     %specify atmospheric conditions through MSIS
%     [rho,H] = get_msis_dat(alt,f107a(1),f107(1),Ap(1), false); 
%     %calculate energy dissipation for the specified energy grid
%     q_diss = calc_Edissipation(rho,H,E); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loop over time to calculate and apply loss rates to Qe:

for t=1:length(time)-1%length(time)-1


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate energy dissipation for the specified energy grid:
    %NOTE: If code needs to speed up, and F107/Ap are constant, then this can be taken out of time loop
    %specify atmospheric conditions through MSIS
    [rho,H] = get_msis_dat(alt,f107a(t),f107(t),Ap(t), false); 
    %calculate energy dissipation for the specified energy grid
    q_diss = calc_Edissipation(rho,H,E); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate loss factor:

    %initialize loss rate array (nalpha x nE)
    lossfactor = zeros(length(pa),length(E));

    %loop over pitch angle
    for a=1:length(pa)
        if isnan(mirr_alt(a))
            %check the mirror altitude is real 
            % (can become nan at 180 and 0 in dipole)   
            lossfactor(a,:) = ones(1,length(E));
        else
            %calculate loss rates for electrons mirroring within the atmosphere
            if mirr_alt(a) > 1000.
                %if mirror altitude above 1000km, set loss rate to zero
                lossfactor(a,:) = zeros(1,length(E));
            elseif mirr_alt(a) <= 0.
                %if mirror altitude at or below the ground, set loss rate to one
                lossfactor(a,:) = ones(1,length(E));
            else    
         
                % Find index closest to mirr_alt
                [~, idx] = min(abs(alt - mirr_alt(a)));
                  
                %calculate cumulative ionization as function of altitude
                [q_cum,q_tot] = calc_ionization(Qe(t,a,:),alt,q_diss,H); 
                 
                % Get cumulative ionization rate down to mirr_alt
                q_to_mirr_alt = q_cum(idx,:);
                 
                %calculate the fraction flux lost
                lossfactor(a,:) = q_to_mirr_alt./q_cum(1,:); 
    
            end
        end



  
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate loss rate by assuming electrons lost over half bounce period:
    Qe_Evol = squeeze(Qe(t,:,:));
    Qe_tmp = squeeze(lossfactor.*Qe_Evol); 
    dQedt = abs(2*Qe_tmp./t_b);  
    %if uneven time steps, here define dt=time(t+1)-time(t) 
    
    %subtract loss from distribution at each time step of simulation 
    Qe(t+1,:,:) = Qe_Evol - dQedt.*dt; 

    %check if Qe becomes negative and set to zero
    Qe(Qe<0) = 0;

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% test ionization profiles %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     semilogx(q_tot(:,1),alt)
%     hold on
%     for e=2:length(E)
%         semilogx(q_tot(:,e),alt)
%     end    
%     
%     xlim([10,1e5])
%     ylim([50,400])
%     
%     % Axis labels
%     xlabel('Ionization Rate (cm^{-3} s^{-1})')
%     ylabel('Altitude (km)')
%     
%     % Add minor ticks
%     ax = gca;               % get current axes handle
%     ax.YMinorTick = 'on';   % turn on minor ticks on y-axis
%     ax.XMinorTick = 'on';   % optional — minor ticks on x-axis too
%     
%     legendStrings = strings(1,length(E));
%     for n = 1:length(E)
%         legendStrings(n) = sprintf('%.1f keV', E(n));
%     end
%     legend(legendStrings, 'Location', 'best')
%     
%     title('f_{10.7} = 50.0, Ap = 5.0, incident energy flux = 1 erg cm^{-2} s^{-1}')
%     
%     hold off




