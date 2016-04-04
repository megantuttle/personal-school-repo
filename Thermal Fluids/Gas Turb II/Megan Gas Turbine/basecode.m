%% Gas Turbine - Team Fire Dragon - Base Code
% last updated by Megan on 3/31 at 5 pm
% last updated by Mike 4/3 at 11 pm
clc
close all
clear
%% Path and parameters setup for getting table values from HOT Calc
addpath('/home/megan/Downloads/Gas Turb II/Megan Gas Turbine/Jet Lab - 3-8-16/DaqViewDataEXCEL',...
    '/home/megan/Downloads/Gas Turb II/Megan Gas Turbine/HOT Thermochemical Calculator/HOT_R2',...
    '/home/megan/Downloads/Gas Turb II/Megan Gas Turbine/HOT Thermochemical Calculator/HOT_R2/HOT',...
    '/home/megan/Downloads/Gas Turb II/Megan Gas Turbine/HOT Thermochemical Calculator/HOT_R2/utility');
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];

%% Call Jet Calcs
% [P_amb, T_amb, S_amb, H_amb, Y_amb, Tsamb, TSFCamb, n_cycleamb, PMamb, n_propamb, n_combamb, n_compamb, mdot_air_inletamb, thrustamb, mdot_fuelamb, Qinamb, Qoutamb, combWorkamb, turbWorkamb] = ...
%     JetCalcs2( 'AMBIENTPOSITION', data, air, m_air );
[P_idle, T_idle, S_idle, H_idle, Y_idle, Tsidle, TSFCidle, n_cycleidle, PMidle, n_propidle, n_combidle, n_compidle, mdot_air_inletidle, thrustidle, mdot_fuelidle, Qinidle, Qoutidle, combWorkidle, turbWorkidle] = ...
    JetCalcs2( 'IDLEPOSITION', data, air, m_air );
[P_49, T_49, S_49, H_49, Y_49, Ts49, TSFC49, n_cycle49, PM49, n_prop49, n_comb49, n_comp49, mdot_air_inlet49, thrust49, mdot_fuel49, Qin49, Qout49, combWork49, turbWork49] = ...
    JetCalcs2( '49000', data, air, m_air );
[P_60, T_60, S_60, H_60, Y_60, Ts60, TSFC60, n_cycle60, PM60, n_prop60, n_comb60, n_comp60, mdot_air_inlet60, thrust60, mdot_fuel60, Qin60, Qout60, combWork60, turbWork60] = ...
    JetCalcs2( '60000', data, air, m_air );
[P_69, T_69, S_69, H_69, Y_69, Ts69, TSFC69, n_cycle69, PM69, n_prop69, n_comb69, n_comp69, mdot_air_inlet69, thrust69, mdot_fuel69, Qin69, Qout69, combWork69, turbWork69] = ...
    JetCalcs2( '69000', data, air, m_air );
[P_77, T_77, S_77, H_77, Y_77, Ts77, TSFC77, n_cycle77, PM77, n_prop77, n_comb77, n_comp77, mdot_air_inlet77, thrust77, mdot_fuel77, Qin77, Qout77, combWork77, turbWork77] = ...
    JetCalcs2( '77000', data, air, m_air );

%% Call Error Analysis

[ uMdotAir_amb, uTs_amb, uTSFC_amb, uNcyc_amb, uPM_amb, uNprop_amb, uComb_amb ] = Errorfunc( P_amb, T_amb,  mdot_air_inletamb, thrustamb, mdot_fuelamb, Qinamb, Qoutamb, combWorkamb, turbWorkamb  );
[ uMdotAir_idle, uTs_idle, uTSFC_idle, uNcyc_idle, uPM_idle, uNprop_idle, uComb_idle ] = Errorfunc( P_idle, T_idle, mdot_air_inletidle, thrustidle, mdot_fuelidle, Qinidle, Qoutidle, combWorkidle, turbWorkidle );
[ uMdotAir_49, uTs_49, uTSFC_49, uNcyc_49, uPM_49, uNprop_49, uComb_49 ] = Errorfunc( P_49, T_49, mdot_air_inlet49, thrust49, mdot_fuel49, Qin49, Qout49, combWork49, turbWork49);
[ uMdotAir_60, uTs_60, uTSFC_60, uNcyc_60, uPM_60, uNprop_60, uComb_60 ] = Errorfunc( P_60, T_60, mdot_air_inlet60, thrust60, mdot_fuel60, Qin60, Qout60, combWork60, turbWork60);
[ uMdotAir_69, uTs_69, uTSFC_69, uNcyc_69, uPM_69, uNprop_69, uComb_69 ] = Errorfunc( P_69, T_69, mdot_air_inlet69, thrust69, mdot_fuel69, Qin69, Qout69, combWork69, turbWork69);
[ uMdotAir_77, uTs_77, uTSFC_77, uNcyc_77, uPM_77, uNprop_77, uComb_77 ] = Errorfunc( P_77, T_77, mdot_air_inlet77, thrust77, mdot_fuel77, Qin77, Qout77, combWork77, turbWork77);




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
