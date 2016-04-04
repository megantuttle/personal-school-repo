function [P, T, S, H, Y, Ts, TSFC, n_cycle, PM, n_prop, n_comb, n_comp] = JetCalcs( filename, data, air, m_air )
%% Preliminary code - Gas Turbine Lab - Team Fire Dragon aka Megan and Mike and Willem <3
% Last updated 2:30pm by Michael Moralle
% Last updated at 4:11pm on thursday by Willem Ytsma
% Last updated on 3/31 at 5 pm by Megan 
%% Define geometry (areas in in^2)
%A0 = 26.89; % Inlet bell entrance
A0 = 0.0167;
A = [4.51	% compressor inlet
    6.63    % compressor exit
    11.01	% combustor exit
    4.34	% turbine exit	
    3.54]*.00064516;	% nozzle exit	

%% Path and parameters set up
t_room = 20 + 273.15;      % assumed room temperature K
p_atm = 101325;            % assumed Pressure, Pa
s0 = entropy(data, air, m_air, t_room, p_atm);
%% Read in raw data and turn it into nice variables
rawdata = xlsread([filename,'.xlsx']);
rawdata(:,3) = rawdata(:,3) * 0.0360912;    % convert inches water to psi

for i = 1:5
    % pressure
    P(:,i) = (rawdata(:,i+2) + 14.7).*6894.76;   % convert to psig to Pa
    
    %temperature
    T(:,i) = rawdata(:,i+10) + 273.15;     % convert to K
    
    % entropy, enthalpy, "gamma" aka specific heat ratio
    S(:,i) = entropy(data, air, m_air, T(:,i), P(:,i));
    H(:,i) = enthalpy(data, air, m_air, T(:,i)) - enthalpy(data, air, m_air, 0);
    Y(:,i) = spratio(data, air, m_air, T(:,i));
    
    % density, kg/m^3
    for n = 1:length(T)
        rho(n,i) = density(data, air, m_air, T(n,i), P(n,i));
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
% find Mach Number, local static temp (T1), local speed of sound (a1), flow
% velocity (V2), and mass flow of air
st = 2; % the state that we are calculating all this for
coeff = 2./(Y(:,st)-1);
ratioP = (p_atm+P(:,st))/p_atm;
%ratioP = p_atm/(P(1)-p_atm);
powerY = (Y(:,st)-1)./Y(:,st);
Mach = sqrt(coeff.*(ratioP.^powerY - 1));
T1 = t_room./(1+(Y(:,st)-1)/2.*Mach.^2);      % local static temp
a2 = sqrt(Y(:,st).*R.*T1);
V2 = Mach.*a2;
mdot_air = rho(:,st).*V2.*A(1);

% determine thermodynamic efficiency from stagnation properties 
%   --> isentropic process determined by new pressure
state = process(data, 'species', air, 'mass', m_air, 'P', p_atm, 's', s0);
T0 = state.T;
h0(1) = (enthalpy(data, air, m_air, T0) - enthalpy(data, air, m_air, 0))/1000;

for i = 2:6
    state(i) = process(data, 'species', air, 'mass', m_air, 'P', P(1,i-1), 's', S(1,i-1));
    T0(i) = state(i).T;
    h0(i) = (enthalpy(data, air, m_air, T0(i)) - enthalpy(data, air, m_air, 0))/1000;
end

s4 = entropy(data, air, m_air, T0(4),mean(P(:,3)));
    
% Specific Thrust
Ts = thrust./mdot_air;

% Thrust Specific Fuel Consumption
TSFC = mdot_fuel./thrust;

% Cycle Efficiency
n_cycle = 1-((h0(4)-h0(5))/(h0(3)-h0(2)));
%n_cycle_data = 1-((mean(H(:,3))-mean(H(:,4)))/(mean(H(:,2))-mean(H(:,1))));

% Power Match between compressor and turbine
PM = ((mdot_air+mdot_fuel).*(h0(4)-h0(5)))./(mdot_air.*(h0(3)-h0(2))) ;
%PM_data = ((mdot_air+mdot_fuel)*(mean(H(:,3))-mean(H(:,4))))/(mdot_air.*(mean(H(:,2))-mean(H(:,2))));
% Propulsive Efficiency
n_prop = (thrust.*V2)./((mdot_air+mdot_fuel).*(h0(5)-mean(H(:,4)/1000))-(mdot_air.*(h0(2)-mean(H(:,1)/1000)))) ;

% Combustor Efficiency
f = mdot_fuel./mdot_air;
Qjeta = 43008 ;    %kJ/kg
n_comb = ((1+f)*h0(3)-h0(2))./(f*Qjeta);

% Compressor Efficiency
n_comp = (h0(3)-h0(2))/((mean(H(:,2))-mean(H(:,1)))/1000); % convert J to kJ 

s_ideal = [s0 s0 s0 s4 s4 s4 s0];
figure()
hold on
plot(S, T,'o')
plot(s_ideal, [T0,T0(1)])
legend('2', '3', '4', '5', '6')
grid on
title(filename)
xlabel 'Entropy, s (J/kg)'
ylabel 'Temperature, T (K)'
hold off

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% dummy params to test function
% % Path and parameters setup for getting table values from HOT Calc
% addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\Jet Lab - 3-8-16\DaqViewDataEXCEL');
% 
% addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2',...
%     '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/HOT',...
%     '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/utility');
% q = input('Load Janaf data (y/n)?\n','s');
% data = janload('nasa.fit','sort','species');
% air = {'N2', 'O2'};
% m_air = [3.29; 1];
% 
% filename = '49000';

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





