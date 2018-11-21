function modelling_inputs = run_inputs_setup_STL(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: modelling_inputs = run_inputs_setup_STL(mi)

model_num = 0;

%% Building up a set of inputs to be passed to the EM simulator.
[defs, ~] = construct_defs(mi.material_defs);
% The geometry variations are already defined,
for fdhs = 1:length(mi.model_names)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs});
    if fdhs ~= mi.base_model_ind
        modelling_inputs{model_num}.set_name = regexprep(mi.model_names{fdhs}, ...
            [mi.base_model_name, '_(.*)?_value_.*'], '$1' );
    else
        modelling_inputs{model_num}.set_name ='Base';
    end %if
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.geometry_defs = ...
        get_parameters_from_sidecar_file(...
        fullfile(mi.paths.input_file_path, mi.model_names{fdhs},...
        [mi.model_names{fdhs}, '_parameters.txt']));
end %for

% Setting up the material variations off the base model.
for awh = 2:length(defs)
    model_num = model_num +1;
    def = defs{awh};
    def = regexp(def, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
    def = def{1}{1};
    % The inputs of the current geometry before any simulation
    % parameter sweeps.
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.set_name = def{1};
    modelling_inputs{model_num}.defs = defs{awh};
    modelling_inputs{model_num}.model_name = [...
        mi.base_model_name, '_', def{1}, '_', def{2}];
    modelling_inputs{model_num}.geometry_defs = ...
        get_parameters_from_sidecar_file(...
        fullfile(mi.paths.input_file_path, mi.model_names{mi.base_model_ind},...
        [mi.model_names{mi.base_model_ind}, '_parameters.txt']));
end %for

% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
sim_param_sweeps = {'beam_sigma', 'mesh_stepsize', 'wakelength', ...
    'NPMLs', 'precision', 'version'};
for nw = 1:length(sim_param_sweeps)
    for mss = 2:length(mi.simulation_defs.(sim_param_sweeps{nw}))
        model_num = model_num +1;
        modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
        modelling_inputs{model_num}.(sim_param_sweeps{nw}) = mi.simulation_defs.(sim_param_sweeps{nw}){mss};
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_', sim_param_sweeps{nw}, '_', ...
            num2str(modelling_inputs{model_num}.(sim_param_sweeps{nw}))];
        modelling_inputs{model_num}.defs = defs{1};
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(...
            fullfile(mi.paths.input_file_path, mi.model_names{mi.base_model_ind},...
            [mi.model_names{mi.base_model_ind}, '_parameters.txt']));
    end %for
end %for

% Now setup which fractional geometries to use
for uned = 2:length(mi.simulation_defs.geometry_fractions)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    tne = find(mi.simulation_defs.volume_fill_factor == mi.simulation_defs.geometry_fractions(uned));
    modelling_inputs{model_num}.geometry_fraction = mi.simulation_defs.geometry_fractions(uned);
    modelling_inputs{model_num}.port_fill_factor = mi.simulation_defs.port_fill_factor{tne};
    modelling_inputs{model_num}.port_multiple = mi.simulation_defs.port_multiple{tne};
    modelling_inputs{model_num}.volume_fill_factor = mi.simulation_defs.volume_fill_factor(tne);
    modelling_inputs{model_num}.ports = mi.simulation_defs.ports(1:end-tne +1);
    modelling_inputs{model_num}.port_location = mi.simulation_defs.port_location(1:end-tne +1);
    modelling_inputs{model_num}.port_modes = mi.simulation_defs.port_modes(1:end-tne +1);
    temp = [...
        mi.base_model_name, '_', 'Geometry_fraction', '_', ...
        num2str(mi.simulation_defs.geometry_fractions(uned))];
    temp = regexprep(temp, '\.','p');
    modelling_inputs{model_num}.model_name = temp;
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.geometry_defs = ...
        get_parameters_from_sidecar_file(...
        fullfile(mi.paths.input_file_path, mi.model_names{mi.base_model_ind},...
        [mi.model_names{mi.base_model_ind}, '_parameters.txt']));
end %for
