function done = mweight(data, varargin)
%MWEIGHT.M
%
%   MW = mweight(data, species, mass)
%       or
%   MW = mweight(data, state)
%
%Computes a 1-D array of molecular weights for various mixtures.
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
%state      -   the state structure as generated by STATEGEN.
%
%MW   	    -   a 1-D numeric array containing the computed property values.
%               MW(1,m) = molecular weight for mixture (m)
%
% 
%HOT-tdb release 2.0
%(c) 2007-2009 Christopher R. Martin, Virginia Tech



% check for a state structure
if isstruct(varargin{1})
    % if one is present, grab the relevant information
    statemode = 1;
    mass = varargin{1}.mass;
    species = varargin{1}.species;
else
    statemode = 0;
    species = varargin{1};
    mass = varargin{2};
end



%check data
if iscell(data)    % if data is a single JANAAF library
    Ndset = length(data);
else
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


% initialize the output array.
done = zeros(1,Nmass);

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
    
    for massindex = 1:Nmass
        % normalize the mass column
        mass(:,massindex) = mass(:,massindex) / norm(mass(:,massindex),1);
        done(:, massindex) = done(:, massindex) + mass(specindex,massindex)/data{libindex}(libsubindex).MW;
    end % for (mass index)
end % for (species index)

done = 1./done;
