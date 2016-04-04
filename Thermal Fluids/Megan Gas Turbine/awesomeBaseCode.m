% Gas Turbine - Team Fire Dragon - Base Code
close all
clear

data = janload('nasa.fit','sort','species');

[RPMi, nCyclei, PMi, nPropi, nCompi, nCombi, nTurbi, nNozzi, thrusti,...
    Tsi, TSFCi, ThThrusti, ThTsi, ThTSFCi, uTsi, uTSFCi, uNcyci, uPMi, uNpropi, uCombi,...
    uNozzi, u_RPMi ] = meganIsAwesome('idle', data);
[RPM49, nCycle49, PM49, nProp49, nComp49, nComb49, nTurb49, nNozz49, thrust49,...
    Ts49, TSFC49, ThThrust49, ThTs49, ThTSFC49, uTs49, uTSFC49, uNcyc49, uPM49, uNprop49, uComb49,...
    uNozz49, u_RPM49 ] = meganIsAwesome('49000', data);
[RPM60, nCycle60, PM60, nProp60, nComp60, nComb60, nTurb60, nNozz60, thrust60,...
    Ts60, TSFC60, ThThrust60, ThTs60, ThTSFC60, uTs60, uTSFC60, uNcyc60, uPM60, uNprop60, uComb60,...
    uNozz60, u_RPM60 ] = meganIsAwesome('60000', data);
[RPM69, nCycle69, PM69, nProp69, nComp69, nComb69, nTurb69, nNozz69, thrust69,...
    Ts69, TSFC69, ThThrust69, ThTs69, ThTSFC69, uTs69, uTSFC69, uNcyc69, uPM69, uNprop69, uComb69,...
    uNozz69, u_RPM69 ] = meganIsAwesome('69000', data);
[RPM77, nCycle77, PM77, nProp77, nComp77, nComb77, nTurb77, nNozz77, thrust77,...
    Ts77, TSFC77, ThThrust77, ThTs77, ThTSFC77, uTs77, uTSFC77, uNcyc77, uPM77, uNprop77, uComb77,...
    uNozz77, u_RPM77 ] = meganIsAwesome('77000', data);

figure()
hold on
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nCyclei, nCycle49, nCycle60, nCycle69, nCycle77], '+', 'LineWidth', 2)
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nPropi, nProp49, nProp60, nProp69, nProp77], 'x', 'LineWidth', 2)
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nCompi, nComp49, nComp60, nComp69, nComp77], 'o', 'LineWidth', 2)
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nCombi, nComb49, nComb60, nComb69, nComb77], 'd', 'LineWidth', 2)
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nTurbi, nTurb49, nTurb60, nTurb69, nTurb77], 's', 'LineWidth', 2)
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [nNozzi, nNozz49, nNozz60, nNozz69, nNozz77], 'v', 'LineWidth', 2)
grid on
xlabel 'RPM'
ylabel '\eta'
legend('\eta_{cycle}', '\eta_{propulsive}', '\eta_{compressor}', '\eta_{combustor}', '\eta_{turbine}', '\eta_{nozzle}')
hold off

figure()
plot([RPMi, RPM49, RPM60, RPM69, RPM77], [thrusti, thrust49, thrust60, thrust69, thrust77], '+', 'LineWidth', 2)
xlabel 'RPM'
ylabel 'Thrust (N)'


