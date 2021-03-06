function done = enthalpy(data, varargin)
%ENTHALPY.M
%
%   h = enthalpy(data, species, mass, T)
%
%Computes a 2-D array of enthalpy for various mixtures
%at various temperatures.  
%=================================================================
%data       -   janaaf data struct array 
%                    OR 
%               cell array containing multiple janaaf data struct arrays
%
%
%species    -   cell array of species names or a single species name
%
%mass       -   2-D array of mass fractions or absolute species masses
%               each row corresponds to an element in species (t.f. 
%               needs the same number of rows as species has elements)
%               In addition, each column in mass will correspond to a 
%               new set of data in the output.  In this way, one call
%               to THERMAL can return multiple mixture results.
%
%T          -   Temperature vector.  Must be a column vector of 
%               temperatures in K. 
%
%
%h     	    -   a 2-D numeric array containing the computed property values.
%               h(n,m) = enthalpy at temperature (n) and mixture (m)
%
% 
%HOT-tdb release 2.0
%(c) 2007-2009 Christopher R. Martin, Virginia Tech


% defaults
Tref = 298.15;


% check for a state structure
if isstruct(varargin{1})
    % if one is present, grab the relevant information
    statemode = 1;
    mass = varargin{1}.mass;
    species = varargin{1}.species;
    T = varargin{1}.T;
else
    statemode = 0;
    species = varargin{1};
    mass = varargin{2};
    T = varargin{3};
end



%check data
if iscell(data)    % if data is a single JANAAF library
    Ndset = length(data);
    fitflag = zeros(Ndset,1);
    for index = 1:Ndset
        fitflag(index) = isfield(data{index}, 'F');
    end
else
    fitflag = isfield(data, 'F');   % check to see if the library uses a fit function or lookup tables
    data = {data};  % force the non-cell into a single element cell array.
    Ndset = 1;
end

%check species
if iscell(species)
    Nspec = length(species);    % find the number of species
elseif ischar(species)
    species = {species};        % force the species string into a cell array
    Nspec = 1;
else
    error('Illegal species specifier.  Must be a string or cell array of strings.')
end

%check mass
if ~isnumeric(mass)
    error('Mass vector must be numeric')
elseif size(mass,1) ~= Nspec
    error('Mass vector must have the same number of rows as elements in the species cell array')
else
    Nmass = size(mass,2);
end

% check temperature
if isnumeric(T)
    Ntemp = numel(T);
    T = reshape(T,Ntemp,1);
else
    error('Illegal temperature vector - must be a numeric array.')
end


% initialize the output array.
done = zeros(Ntemp,Nmass);

% loop through the species (do this first to minimize the number of searches)
for specindex = 1:Nspec
    
    % search the libraries for the current specie
    libindex = 0;
    libsubindex = [];
    while isempty(libsubindex) & libindex < Ndset
        libindex = libindex+1;
        libsubindex = janfind(data{libindex}, 'species', species{specindex});
    end
    % if the specie doesn't exist in any of the libraries
    if isempty(libsubindex)
        error(['Specie , ''' species{specindex} ''', not found.'])
    elseif length(libsubindex)>1    % if multiple exist
        error(['Found more than one specie with the name, ''' species{specindex} '''.'])
    end
    
    % if the current library uses fit functions
    if fitflag(libindex) % if the containing library uses fit functions
        h= janfit(data{libindex}(libsubindex).C,data{libindex}(libsubindex).F,data{libindex}(libsubindex).T, T(:),'deriv',-1,'reference',Tref)+data{libindex}(libsubindex).hf;
    else % if the containing library uses lookup tables
        h= janlookup(data{libindex}(libsubindex),'h','T', T);
    end % if (fit index)
    
    
    for massindex = 1:Nmass
        % normalize the mass column (sloppy - this is self-redundant)
        mass(:,massindex) = mass(:,massindex) / norm(mass(:,massindex),1);
        
        done(:, massindex) = done(:,massindex) + mass(specindex,massindex)* h;
        
    end % for (mass index)
end % for (species index)
