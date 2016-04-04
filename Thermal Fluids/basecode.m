%% Gas Turbine - Team Fire Dragon - Base Code
clc
close all
clear all
%% Path and parameters setup for getting table values from HOT Calc
addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\Jet Lab - 3-8-16\DaqViewDataEXCEL');

addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/HOT',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/utility');
q = input('Load Janaf data (y/n)?','s');
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];

%% Call Jet Calcs
[P_49,T_49,S_49,H_49,Y_49 ] = JetCalcs( '49000', data, air, m_air );
[P_60,T_60,S_60,H_60,Y_60 ] = JetCalcs( '60000', data, air, m_air );
[P_69,T_69,S_69,H_69,Y_69 ] = JetCalcs( '69000', data, air, m_air );
[P_77,T_77,S_77,H_77,Y_77 ] = JetCalcs( '77000', data, air, m_air );

figure()
plot(S_49, T_49,'o')
legend('2','3','4','5','6')
xlabel('entropy')
ylabel('temperature')
title('49000 RPM')

figure()
plot(S_60, T_60,'o')
legend('2','3','4','5','6')
xlabel('entropy')
ylabel('temperature')
title('60000 RPM')

figure()
plot(S_77, T_77,'o')
legend('2','3','4','5','6')
xlabel('entropy')
ylabel('temperature')
title('77000 RPM')
