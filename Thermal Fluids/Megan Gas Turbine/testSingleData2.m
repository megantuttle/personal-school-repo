%% last edited by Megan Tuttle on 4/3 at 9 am
% Test code on one data set to ensure all the calculations work for one set
% before it is placed in the function --> USED THIS ONE TO MAKE FUNCTION
clear
clc
close all

%% Path setup for getting table values from HOT Calc
addpath('/home/megan/Downloads/Gas Turbine/Jet Lab - 3-8-16/DaqViewDataEXCEL',...
    '/home/megan/Downloads/Gas Turbine/HOT Thermochemical Calculator/HOT_R2',...
    '/home/megan/Downloads/Gas Turbine/HOT Thermochemical Calculator/HOT_R2/HOT',...
    '/home/megan/Downloads/Gas Turbine/HOT Thermochemical Calculator/HOT_R2/utility');
%% Define geometry (areas in in^2)
A = [26.89  % bell inlet
    5.12	% compressor inlet
    6.63    % compressor exit
    11.01	% combustor exit
    4.34	% turbine exit	
    3.54]*.00064516;	% nozzle exit	
%% Inputs
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];
t_room = 20 + 273.15;      % assumed room temperature K
p_atm = 101325;            % assumed Pressure, Pa
s0 = entropy(data, air, m_air, t_room, p_atm);
rawdata = xlsread('49000.xlsx');
%% Calculate states
%       columns: 1=Compressor Inlet, 2=Compressor Exit, 3=Turbine Inlet,
%       4=Turbine Exit, 5=Exhaust Gas

P(1) = p_atm;  %because the P is the difference between stagnation press and P_atm 
T(1) = t_room;
H0(1) = (enthalpy(data, air, m_air, t_room) - enthalpy(data, air, m_air, 0))/1000; % convert J to kJ
S(1) = entropy(data, air, m_air, t_room, p_atm);
Y(1) = spratio(data, air, m_air, t_room);
rho(1) = density(data, air, m_air, T(1), P(1)+p_atm);

for i = 2:6
    % pressure
    P(i) = mean((rawdata(10:end,i+1) + 14.7).*6894.76);   % convert to psig to Pa
    %temperature
    T(i) = mean(rawdata(10:end,i+9) + 273.15);     % convert to K
    % entropy, enthalpy, "gamma" aka specific heat ratio, density (kg/m^3)
    S(i) = mean(entropy(data, air, m_air, T(i), P(i)));
    H0(i) = mean( (enthalpy(data, air, m_air, T(i)) - enthalpy(data, air, m_air, 0))/1000 );
    Y(i) = mean(spratio(data, air, m_air, T(i)));
    rho(i) = density(data, air, m_air, T(i), P(i));   
end

P(2) = mean((rawdata(10:end,3).*6894.76));

% ideal gas constant
R = igconstant(data, air, m_air);       

% other stuff
fuel_type = 0.797/0.26417;  % kg/gal
mdot_fuel = mean(rawdata(10:end,8))*fuel_type/3600;      % converted gal/hr to kg/s
RPM = mean(rawdata(10:end,9));
thrust = mean(rawdata(10:end,10)) * 4.44822;             % converted lbs to N

%% Calculations
% Mach number, inlet & exit velocity
coeff = 2/(Y(2)-1);
ratioP = p_atm/(p_atm - P(2));
powerY = (Y(2)-1)/Y(2);
Mach_inlet = sqrt(coeff * (ratioP^powerY - 1));     % Mach number, duh
Tstatic_inlet = T(2) /(1 + (Y(2)-1)/2 * Mach_inlet^2);      % local static temp
c = sqrt(Y(2) * R * Tstatic_inlet);                           % speed of sound in air (m/s)
V_inlet = Mach_inlet * c;                           % speed of the fluid (m/s)
mdot_air = rho(2) * V_inlet * A(2);           % Mdot, obvs. kg/s
f = mdot_fuel / mdot_air;               % air/fuel ratio
H_inlet = (enthalpy(data, air, m_air, Tstatic_inlet) - enthalpy(data, air, m_air, 0))/1000;

% assume we have the right mass flow and iterate to find temp
Tstatic_exit = 273;   % guess Tstatic for loop
err = 5;              % initialize error
while err > 0.01
    c_exit = sqrt(Y(6)*R*Tstatic_exit);
    V_exit = mdot_air/(rho(6)*A(6));
    Mach_exit = V_exit/c_exit;
    Tstatic = T(6) /(1 + (Y(6)-1)/2 * Mach_exit^2);
    err = abs(Tstatic - Tstatic_exit);
    Tstatic_exit = Tstatic;
end

H_exit = (enthalpy(data, air, m_air, Tstatic_exit) - enthalpy(data, air, m_air, 0))/1000; 

% Thrust
Ts = thrust / mdot_air;   % Specific Thrust
TSFC = mdot_fuel / thrust;      % Thrust Specific Fuel Consumption
%% Theoretical Calculations
ThThrust = mdot_air*(1+f)*V_exit - mdot_air*V_inlet;     % Theoretical thrust (N)
ThTs = (1+f)*V_exit - V_inlet;                                % Theoretical specific thrust
ThTSFC = f/ThTs;
%% For component efficiencies, calculate stagnation enthalpy at turbine and compressor exits
%   --> isentropic process determined by new pressure
state(1) = process(data, 'species', air, 'mass', m_air, 'P', P(3), 's', S(2));
T0(1) = state(1).T;
H0s_comp = (enthalpy(data, air, m_air, T0(1)) - enthalpy(data, air, m_air, 0))/1000;  % convert J to kJ

state(2) = process(data, 'species', air, 'mass', m_air, 'P', P(5), 's', S(4));
T0(2) = state(2).T;
H0s_turb = (enthalpy(data, air, m_air, T0(2)) - enthalpy(data, air, m_air, 0))/1000;

s4 = entropy(data, air, m_air, T0(2), P(5));
%% Performance
% Cycle Efficiency
q_comb = H0(4) - H0(3);
q_reheat = H0(5) - H0(6);
q_in = q_comb + q_reheat;
q_out = H0(6) - H0(2);
n_cycle = 1 - (q_out/q_in); 
% Power Match between compressor and turbine
PM = ((mdot_air+mdot_fuel) * (H0(4)-H0(5))) / (mdot_air * (H0(3)-H0(2))) ;
% Propulsive Efficiency --> had to convert kJ to m/s
n_prop = (thrust*V_inlet/1000) / ((mdot_air+mdot_fuel)*(H0(6) - H_exit) - (mdot_air*(H0(2) - H_inlet)));
% Combustor Efficiency
Qjeta = 42800;    % kJ/kg      http://hypertextbook.com/facts/2003/EvelynGofman.shtml
n_comb = ( (1+f)*H0(4) - H0(3)) / (f * Qjeta);
% Compressor Efficiency
n_comp =  (H0s_comp - H0(2)) / (H0(3) - H0(2));
% Turbine efficiency
n_turb = (H0(4) - H0(5)) / (H0(4) - H0s_turb);

%% Plot it <3
s_ideal = [s0 s0 s0 s4 s4 s4 s0];
figure()
hold on
plot(S, T,'o')
plot(s_ideal, [T, T(1)], '--')
legend('Experimental Data', 'Isentropic Case')
grid on
hold off

