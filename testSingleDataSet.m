%% last edited by Megan Tuttle on 3/30 at 9 pm
% Test code on one data set to ensure all the calculations work for one set
% before it is placed in the function
clear
clc
close all

%% Path setup for getting table values from HOT Calc
addpath('/home/brownlab/MeganWorkingDir/personal-school-repo/Jet Lab - 3-8-16/DaqViewDataEXCEL');

addpath('/home/brownlab/MeganWorkingDir/personal-school-repo/HOT Thermochemical Calculator/HOT_R2',...
    '/home/brownlab/MeganWorkingDir/personal-school-repo/HOT Thermochemical Calculator/HOT_R2/HOT',...
    '/home/brownlab/MeganWorkingDir/personal-school-repo/HOT Thermochemical Calculator/HOT_R2/utility');
%% Define geometry (areas in in^2)
%A0 = 26.89; % Inlet bell entrance
A0 = 0.0167;
A = [4.51	% compressor inlet
    6.63    % compressor exit
    11.01	% combustor exit
    4.34	% turbine exit	
    3.54]*.00064516;	% nozzle exit	

%% Inputs
q = input('Load Janaf data (y/n)?','s');
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

rawdata(:,3) = rawdata(:,3) * 0.0360912;    % convert inches water to psi

for i = 1:5
    % pressure
    P(:,i) = (rawdata(:,i+2) + 14.7).*6894.76;   % convert to psig to Pa
    
    %temperature
    T(:,i) = rawdata(:,i+10) + 273.15;     % convert to K
    
    % entropy, enthalpy, "gamma" aka specific heat ratio
    S(:,i) = entropy(data, air, m_air, T(:,i), P(:,i));
    H(:,i) = (enthalpy(data, air, m_air, T(:,i)) - enthalpy(data, air, m_air, 0));
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
% velocity (V1), and mass flow of air
coeff = 2./(Y(:,1)-1);
ratioP = P(:,1)./p_atm;
%ratioP = p_atm/(P(1)-p_atm);
powerY = (Y(:,1)-1)./Y(:,1);
Mach = sqrt(coeff.*(ratioP.^powerY - 1));
T1 = t_room./(1+(Y(:,1)-1)/2.*Mach.^2);      % local static temp
a1 = sqrt(Y(:,1).*R.*T1);
V1 = Mach.*a1;
mdot_air = rho(:,1).*V1.*A0;

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
n_prop = (thrust.*V1)./((mdot_air+mdot_fuel).*(h0(5)-H(:,4))-(mdot_air.*(h0(2)-H(:,1)))) ;

% Combustor Efficiency
f = mdot_fuel./mdot_air;
Qjeta = 43008 ;    %kJ/kg
n_comb = ((1+f)*h0(3)-h0(2))./(f*Qjeta);

% Compressor Efficiency
n_comp = (h0(3)-h0(2))/((mean(H(:,2))-mean(H(:,1)))/1000) ;

s_ideal = [s0 s0 s0 s4 s4 s4 s0];
figure()
hold on
plot(S, T,'o')
plot(s_ideal, [T0,T0(1)])
legend('2', '3', '4', '5', '6')
grid on
title('T S plot of data and ideal')
hold off
