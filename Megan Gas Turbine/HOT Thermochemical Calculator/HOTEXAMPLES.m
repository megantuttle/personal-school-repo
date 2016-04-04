

% Analysis Uses the %HOT% Thermochemical calculator Package

addpath('HOT_R2', 'HOT_R2/HOT','HOT_R2/utility')
%You only need to load the NASA Data once (unless you clear your workspace)
%load NASA DATA

q = input('Load Janaf data (y/n)?','s');
if q=='y'
data = janload('nasa.fit','sort','species');
end

%definitions
%This thermochemical calculator uses mixtures of ideal gases
%The mixtures are based on mass fractions

%Air would be specified in the following way

air = {'N2', 'O2'};
m_air = [3.29; 1];


%Since air is mainly build up of N2 and O2 with that mass ratio
%It is important to note that the values are masses and not moles. 
%Also, the code autmoatically normalizes the mass fractions so you could
%have also have specified

m_air = [6.58; 2]

%having the same effect

% You can then use the code directly for

%Specific heat ratio (T is in Kelvin)
k = spratio(data, air, m_air, T);

%Density (in kg/m^3 - T is in Kelvin, P is in Pascals)
rho = density(data, air, m_air, T, P);

%Gas Constant (in J/kg-K)
R = igconstant(data, air, m_air);

%Specific Heat (J/kg-K, T in Kelvin)
cp = spheat(data, air, m_air, T);

%Enthalpy (in units of J/kg, since the enthalpies include energy from chemical bonds you need
%to subtract out the enthalpy at zero degrees Kelvin)
h = enthalpy(data, air, m_air, T)- enthalpy(data, air, m_air, 0);

%Entropy( in units of J/kg-K, T is in Kelvin, P is in Pascals)
s = entropy(data, air, m_air, T, P);

%You can also use the package to backsolve thermodynamic states
%Example: Knowing a process is constant entropy and has a new pressure I
%would like to figure out the temperature

qq = process(data, 'species', air, 'mass', m_air, 'P', P, 's',s);
T = qq.T;

%Here the output of qq contains information about the species, mass,
%temperature and pressure. 
%qq.h would enthalpy
%qq.rho would be density
%etc. 