%% Preliminary code - Gas Turbine Lab - Team Fire Dragon
% Last updated 2:30pm by Michael Moralle
%%

%Path and parameters set up
addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\Jet Lab - 3-8-16\DaqViewDataEXCEL');
addpath('\\samba.lafayette.edu\shared\me_drive\ME 475 Thermal Properties\CoolProps for PC')
addpath('\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/HOT',...
    '\\samba.lafayette.edu\shared\me_475_1b\Gas Turbine\HOT Thermochemical Calculator\HOT_R2/utility');
q = input('Load Janaf data (y/n)?','s');
data = janload('nasa.fit','sort','species');
air = {'N2', 'O2'};
m_air = [3.29; 1];

filename={'49000','60000','69000','77000','AMBIENTPOSITION','IDLEPOSITION'};
trialsub={'49','60','69','77','AMB','IDLE'};

k_psig_pa=6894.75728;
k_K=273.15;

% at point 1 of the T-S diagram 
t_1= 20+k_K;  % assumed room temperature K
p_1= 101325;      % assumed Pa
s_1=entropy(data, air, m_air, t_1, p_1);

for i=1:length(filename)
    %% Read acquired data
    rawdata=xlsread([filename{i},'.xlsx']);
        
    % convert Pressures into Pa
    p_comp_in = rawdata(:,3)*k_psig_pa;
    p_comp_ex = rawdata(:,4)*k_psig_pa;
    p_turb_in = rawdata(:,5)*k_psig_pa;
    p_turb_ex = rawdata(:,6)*k_psig_pa;
    p_nozz_ex = rawdata(:,7)*k_psig_pa;
    
    % convert Temperatures into K
    t_comp_in = rawdata(:,11)+k_K;
    t_comp_ex = rawdata(:,12)+k_K;
    t_turb_in = rawdata(:,13)+k_K;
    t_turb_ex = rawdata(:,14)+k_K;
    t_EGT = rawdata(:,15)+k_K;          % Exhaust gas temperature
    
    mdot_fuel=rawdata(:,8);        %gal/hour - convert?
    RPM=rawdata(:,9);
    thrust=rawdata(:,10);          %lbs


    %% Calculate state valyes 
    % Entropy Values at each state, modeled after Brayton cycle
    s_comp_in = entropy(data, air, m_air, t_comp_in, p_comp_in);  %s2
    s_comp_ex = entropy(data, air, m_air, t_comp_ex, p_comp_ex);  %s3
    s_turb_in = entropy(data, air, m_air, t_turb_in, p_turb_in);  %s4
    s_turb_ex = entropy(data, air, m_air, t_turb_ex, p_turb_ex);  %s5
    s_nozz_ex = entropy(data, air, m_air, t_EGT, p_nozz_ex);      %s6
    % Enthalpy Values at each state, modeled after Brayton cycle
    
    % Display data in workspace for each trial
    % Pressures
    assignin('base',['p_comp_in',trialsub{i}],p_comp_in);
    assignin('base',['p_comp_ex',trialsub{i}],p_comp_ex);
    assignin('base',['p_turb_in',trialsub{i}],p_turb_in);
    assignin('base',['p_turb_ex',trialsub{i}],p_turb_ex);
    assignin('base',['p_nozz_ex',trialsub{i}],p_nozz_ex);
    % Temperatures
    assignin('base',['t_comp_in',trialsub{i}],t_comp_in);
    assignin('base',['t_comp_ex',trialsub{i}],t_comp_ex);
    assignin('base',['t_turb_in',trialsub{i}],t_turb_in);
    assignin('base',['t_turb_ex',trialsub{i}],t_turb_ex);
    assignin('base',['t_EGT',trialsub{i}],t_EGT);
    % Other
    assignin('base',['mdot_fuel',trialsub{i}],mdot_fuel);
    assignin('base',['RPM_',trialsub{i}],RPM);
    assignin('base',['thrust_',trialsub{i}],thrust);
    % Entropy
    assignin('base',['s_comp_in',trialsub{i}],s_comp_in);
    assignin('base',['s_comp_ex',trialsub{i}],s_comp_ex);
    assignin('base',['s_turb_in',trialsub{i}],s_turb_in);
    assignin('base',['s_turb_ex',trialsub{i}],s_turb_ex);
    assignin('base',['s_nozz_ex',trialsub{i}],s_nozz_ex);
end

s_49 = [s_comp_in49, s_comp_ex49, s_turb_in49, s_turb_ex49, s_nozz_ex49];
t_49 = [t_comp_in49, t_comp_ex49, t_turb_in49, t_turb_ex49, t_EGT49];

plot(s_49, t_49,'o')
legend('2','3','4','5','6')
xlabel('entropy')
ylabel('temperature')




    