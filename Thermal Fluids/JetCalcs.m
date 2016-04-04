function [P,T,S,H,Y ] = JetCalcs( filename, data, air, m_air )
%% Preliminary code - Gas Turbine Lab - Team Fire Dragon
% Last updated 2:30pm by Michael Moralle
%% Path and parameters set up

t_room = 20 + 273.15;      % assumed room temperature K
p_atm = 101325;      % assumed Pressure, Pa
s_1 = entropy(data, air, m_air, t_room, p_atm);

%% Read measured data, calculate states
%       columns: 1=Compressor Inlet, 2=Compressor Exit, 3=Turbine Inlet,
%       4=Turbine Exit, 5=Exhaust Gas
rawdata = xlsread([filename,'.xlsx']); 

rawdata(:,3) = rawdata(:,3) * 0.0360912;    % convert inches water to psi for P1

for i = 1:5
    % pressure
    for n = 3:7
        P(:,i) = (rawdata(:,n)+14.7)*6894.76;   % convert to Pa
    end
    
    %temperature
    for n = 11:15
        T(:,i) = rawdata(:,n) + 273.15;     % convert to K
    end
    
    % entropy, enthalpy, "gamma" aka specific heat ratio
    S(:,i) = entropy(data, air, m_air, T(:,i), P(:,i));
    H(:,i) = enthalpy(data, air, m_air, T(:,i)) - enthalpy(data, air, m_air, 0);
    Y(:,i) = spratio(data, air, m_air, T(:,i));
    
    % density, kg/m^3
    for n = 1:length(T)
        rho(n,i) = Props('D', 'P',P(n,i)/1000, 'T',T(n,i), 'Air');      % had to convert P to kPa
    end
end

% ideal gas constant
R = igconstant(data, air, m_air);       

% other stuff
fuel_type = 0.797/0.26417;                    % kg/gal
mdot_fuel = rawdata(:,8)*fuel_type/3600;      % converted gal/hr to kg/s
RPM = rawdata(:,9);
thrust = rawdata(:,10) * 4.44822;             % converted lbs to N

%% Calculations
% Need to find Mach Number, T1, a1, V1, and mdot_air
Mach = sqrt(2/(Y-1).*((p_atm/P).^((Y-1)./Y)-1));   % local Mach number
T1 = T./(1+(Y-1)/2.*Mach.^2);      % local static temp
a1 = sqrt(Y.*R.*T1);
V1 = Mach.*a1;
mdot_air = rho.*V1.*A1;


% Specific Thrust
Ts = thrust/mdot_air;
% Thrust Specific Fuel Consumption
TSFC = mdot_fuel/thrust;








end


% %% Calculate state values 
% % Entropy Values at each state, modeled after Brayton cycle
% s_comp_in = entropy(data, air, m_air, T1, P1);  %s2
% s_comp_ex = entropy(data, air, m_air, T2, P2);  %s3
% s_turb_in = entropy(data, air, m_air, T3, P3);  %s4
% s_turb_ex = entropy(data, air, m_air, T4, P4);  %s5
% s_nozz_ex = entropy(data, air, m_air, T5, P5);      %s6
% 
% % Enthalpy Values at each state, modeled after Brayton cycle
% h_comp_in = enthalpy(data, air, m_air, T1) - enthalpy(data, air, m_air, 0);  %h2
% h_comp_ex = enthalpy(data, air, m_air, T2) - enthalpy(data, air, m_air, 0);  %h3
% h_turb_in = enthalpy(data, air, m_air, T3) - enthalpy(data, air, m_air, 0);  %h4
% h_turb_ex = enthalpy(data, air, m_air, T4) - enthalpy(data, air, m_air, 0);  %h5
% h_nozz_ex = enthalpy(data, air, m_air, T5) - enthalpy(data, air, m_air, 0);      %h6
% 
% % Specific heat ratio values at each state
% y_comp_in = spratio(data, air, m_air, T1);  %y2
% y_comp_ex = spratio(data, air, m_air, T2);  %y3
% y_turb_in = spratio(data, air, m_air, T3);  %y4
% y_turb_ex = spratio(data, air, m_air, T4);  %y5
% y_nozz_ex = spratio(data, air, m_air, T5);      %y6

% % Organize arrays into matrices for output
% P = [P1, P2, P3, P4, P5];
% T = [T1, T2, T3, T4, T5];
% S = [s_comp_in, s_comp_ex, s_turb_in, s_turb_ex, s_nozz_ex];
% H = [h_comp_in, h_comp_ex, h_turb_in, h_turb_ex, h_nozz_ex];
% Y = [y_comp_in, y_comp_ex, y_turb_in, y_turb_ex, y_nozz_ex];





