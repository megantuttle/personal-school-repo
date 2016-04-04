%% Check the assumptions, some may not be valid 
%% Unit problem 

%%
clc
clear 
close all

%Path and parameters set up
addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\Jet Lab - 3-8-16\DaqViewDataEXCEL');

addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/HOT',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/utility');
q = input('Load Janaf data (y/n)?','s');
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];

filename={'49000','60000','69000','77000','AMBIENTPOSITION','IDLEPOSITION'};
trialsub={'49','60','69','77','amb','idl'};

k_psig_pa=6894.75728;
k_F_K=5/9;

% at point 1 of the T-S diagram 
t_1= 20+273.15;  % assumed room temperature K
p_1= 101325;      % assumed Pa
s_1=entropy(data, air, m_air, t_1, p_1);

for i=1:length(filename)
    %% Read acquired data
    rawdata_temp=xlsread([filename{i},'.xlsx']);
        
    % convert into Pa
    p_turbe_temp=rawdata_temp(:,6)*k_psig_pa;
    p_ne_temp=rawdata_temp(:,2)*k_psig_pa;

    mdot_temp=rawdata_temp(:,3);
    rpm_temp=rawdata_temp(:,4);
    thrust_temp=rawdata_temp(:,5);
    
    % convert into K
    t_compin_temp=(rawdata_temp(:,6)+459.67)*k_F_K;
    t_compe_temp=(rawdata_temp(:,7)+459.67)*k_F_K;
    t_turbin_temp=(rawdata_temp(:,8)+459.67)*k_F_K;
    t_turbe_temp=(rawdata_temp(:,9)+459.67)*k_F_K;
    t_egt_temp=(rawdata_temp(:,10)+459.67)*k_F_K;
    t_plot_temp=[t_compin_temp,t_compe_temp,t_turbin_temp,t_turbe_temp,t_egt_temp,t_compin_temp];
    %% thermodynamic calculations 
    % isentropic from diffuser inlet to compressor inlet 
    s_compin_temp=s_1.*t_compin_temp.^(0);
       
    s_turbe_temp=entropy(data, air, m_air, t_turbe_temp, p_turbe_temp);
    % assume isentropic from turb in to out 
    s_turbin_temp=s_turbe_temp;
    
    % isobaric from compressor out to turb in
    turbin_temp = process(data, 'species', air, 'mass', m_air, 'T', t_turbin_temp, 's',s_turbin_temp);
    p_turbin_temp = turbin_temp.P;
    p_compe_temp=p_turbin_temp;
    s_compe_temp=entropy(data, air, m_air, t_compe_temp, p_compe_temp);
    
    s_egt_temp=entropy(data, air, m_air, t_egt_temp, p_ne_temp);
    s_plot_temp=[s_compin_temp,s_compe_temp,s_turbin_temp,s_turbe_temp,s_egt_temp,s_compin_temp];
    
%     plot(s_plot_temp,t_plot_temp,'x')
    
    
    %% save the temp variable into variable into workspace
    assignin('base',['p_turbe_',trialsub{i}],p_turbe_temp);
    assignin('base',['p_ne_',trialsub{i}],p_ne_temp);
    assignin('base',['mdot_',trialsub{i}],mdot_temp);
    assignin('base',['rpm_',trialsub{i}],rpm_temp);
    assignin('base',['thrust_',trialsub{i}],thrust_temp);
    assignin('base',['t_compin_',trialsub{i}],t_compin_temp);
    assignin('base',['t_compe_',trialsub{i}],t_compe_temp);
    assignin('base',['t_turbin_',trialsub{i}],t_turbin_temp);
    assignin('base',['t_turbe_',trialsub{i}],t_turbe_temp);
    assignin('base',['t_egt_',trialsub{i}],t_egt_temp);
end
    