%% Gas Turbine - Team Fire Dragon - Base Code
% last updated by Megan on 3/31 at 5 pm
clc
close all
clear all
%% Path and parameters setup for getting table values from HOT Calc
addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\Jet Lab - 3-8-16\DaqViewDataEXCEL',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/HOT',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/utility');
q = input('Load Janaf data (y/n)?\n','s');
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];

%% Call Jet Calcs
[P_amb, T_amb, S_amb, H_amb, Y_amb, Tsamb, TSFCamb, n_cycleamb, PMamb, n_propamb, n_combamb, n_compamb] = ...
    JetCalcs( 'AMBIENTPOSITION', data, air, m_air );
[P_idle, T_idle, S_idle, H_idle, Y_idle, Tsidle, TSFCidle, n_cycleidle, PMidle, n_propidle, n_combidle, n_compidle] = ...
    JetCalcs( 'IDLEPOSITION', data, air, m_air );
[P_49, T_49, S_49, H_49, Y_49, Ts49, TSFC49, n_cycle49, PM49, n_prop49, n_comb49, n_comp49] = ...
    JetCalcs( '49000', data, air, m_air );
[P_60, T_60, S_60, H_60, Y_60, Ts60, TSFC60, n_cycle60, PM60, n_prop60, n_comb60, n_comp60] = ...
    JetCalcs( '60000', data, air, m_air );
[P_69, T_69, S_69, H_69, Y_69, Ts69, TSFC69, n_cycle69, PM69, n_prop69, n_comb69, n_comp69] = ...
    JetCalcs( '69000', data, air, m_air );
[P_77, T_77, S_77, H_77, Y_77, Ts77, TSFC77, n_cycle77, PM77, n_prop77, n_comb77, n_comp77] = ...
    JetCalcs( '77000', data, air, m_air );

% figure()
% plot(S_49, T_49,'o')
% legend('2','3','4','5','6')
% xlabel('entropy')
% ylabel('temperature')
% title('49000 RPM')
% 
% figure()
% plot(S_60, T_60,'o')
% legend('2','3','4','5','6')
% xlabel('entropy')
% ylabel('temperature')
% title('60000 RPM')
% 
% figure()
% plot(S_77, T_77,'o')
% legend('2','3','4','5','6')
% xlabel('entropy')
% ylabel('temperature')
% title('77000 RPM')
