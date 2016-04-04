function [ uMdotAir, uTs, uTSFC, uNcyc, uPM, uNprop, uComb ] = Errorfunc( Press, Temp, mdot_air, thrust, mdot_fuel, Qin, Qout, compWork, turbWork  )
%% Measurement uncertainties
u_P1 = 0.0014*Press(1);    % percent FS, 1.26E-03 psi
u_P2 = 0.0025*Press(2);    % percent FS, 1.25E-01 psi
u_P3 = 0.0025*Press(3);    % percent FS, 1.25E-01 psi
u_P4 = 0.0025*Press(4);    % percent FS, 1.25E-02 psi
u_P5 = 0.0025*Press(5);    % percent FS, 1.25E-02 psi
u_FuelFlow = 1;            % percent FS, 1.50E-01 gal/hr
u_RPM = 0.6;               % percent FS, 600 RPM
u_Thrust = 1;              % percent FS, 1 lb

for i = 1:5   
    u_T(i) = 0.0075*Temp(i);    % greater of 2.2 C or 0.75 percent
    if u_T(i) < 2.2
        u_T(i) = 2.2;
    else
        u_T(i) = u_T(i);
    end
end

%% Specific thrust uncertainty
% find partial derivatives for mass flow of air
% syms P T rho Y P0 R A
% Mdot_air = rho * sqrt( (2/(Y-1)) * ( (P0/P)^( (Y-1)/Y ) - 1 ) * Y*R*T ) * A;
% find uncertainty in mass flow

dMdotAir_dT = 1/Press(1);    % convert Pa to kPa
dMdotAir_dP = 1/Temp(1);
uMdotAir = sqrt( (dMdotAir_dT * u_T(1))^2 + (dMdotAir_dP * u_P1)^2 );

% find uncertainty in specific thrust
dTs_dThrust = mdot_air;
dTs_dMdotAir = 1/thrust;
uTs = sqrt( (dTs_dThrust * u_Thrust)^2 + (dTs_dMdotAir * uMdotAir)^2 );

%% TSFC uncertainty
dTSFC_dThrust = mdot_air;
dTSFC_dMdotFuel = 1/thrust;
uTSFC = sqrt( (dTSFC_dThrust * u_Thrust)^2 + (dTSFC_dMdotFuel * u_FuelFlow)^2 );

%% Cycle uncertainty
u_Qin = sqrt( u_P2^2 + u_P3^2 + u_P4^2 + u_P5^2 + u_T(2)^2 + u_T(3)^2 + u_T(4)^2 + u_T(5)^2 );
u_Qout = sqrt( u_P1^2 + u_P5^2 + u_T(1)^2 + u_T(5)^2 );
dnCyc_dQin = 1/Qout;
dnCyc_dQout = 1/Qin;
uNcyc = sqrt( (dnCyc_dQin * u_Qin)^2 + (dnCyc_dQout * u_Qout)^2 );

%% Power match uncertainty
dPM_dMdotAir = 1/compWork;
dPM_dFuel = 1/turbWork;
dPM_dTurb = mdot_fuel + mdot_air;
dPM_dComp = mdot_air;
u_Comp = sqrt( u_P1^2 + u_P2^2 + u_T(1)^2 + u_T(2)^2 );
u_turb = sqrt( u_P3^2 + u_P4^2 + u_T(3)^2 + u_T(4)^2 );
uPM = sqrt( (dPM_dMdotAir * uMdotAir)^2 + (dPM_dFuel * u_FuelFlow)^2 + (dPM_dTurb * u_turb)^2 + (dPM_dComp * u_Comp)^2 );

%% Propulsive efficiency uncertainty
dnProp_dMdotAir = 1/thrust;
dnProp_dFuel = 1/thrust;
dnProp_dTurb = mdot_air + mdot_fuel;
dnProp_dComp = mdot_air;
uNprop = sqrt( (dnProp_dMdotAir * uMdotAir)^2 + (dnProp_dFuel * u_FuelFlow)^2 + (dnProp_dTurb * u_turb)^2 + (dnProp_dComp * u_Comp)^2 );

%% Combustor efficiency uncertainty
uComb = sqrt( u_P2^2 + u_P3^2 + u_T(2)^2 + u_T(3)^2 );

end

