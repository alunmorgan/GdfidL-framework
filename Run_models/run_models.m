function run_models(mi)


if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

force_pp = 'no_skip';

%%%% Generating mappings %%%%%
for nwe = 1:length(mi.mat_params) 
    % Structure is {stl file name, material name, order to apply the stl files}
mi.stl_part_mapping{nwe,1} = [mi.base_model_name, '-', mi.mat_params{nwe}{1}];
mi.stl_part_mapping{nwe,2} = mi.mat_params{nwe}{2};
mi.stl_part_mapping{nwe,3} = mi.mat_params{nwe}{6};
end %for
% A lookup table of materials to component names
ck = 1;
for nes = 1:length(mi.mat_params)
    if ~strcmp(mi.mat_params{nes}{2}, 'vacuum')
        mi.mat_list{ck, 1} = mi.mat_params{nes}{2};
        mi.mat_list{ck, 2} = mi.mat_params{nes}{3};
        mi.material_defs{ck} = {mi.mat_params{nes}{2}, ...
            mi.mat_params{nes}{5}, mi.mat_params{nes}{4}};
        ck = ck +1;
    end %if
end %for


modelling_inputs = run_inputs_setup_STL(mi);

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    % Making the directory to store the run data in.
    if ~exist(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name),'file')
    mkdir(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name))
    end %if
    ow_behaviour = '';
    % Write update to the command line
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'w'))
        try
            GdfidL_run_simulation('wake', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'wake')
        end %try
        try
            model_name = modelling_inputs{awh}.model_name;
            GdfidL_post_process_models(mi.paths, model_name, force_pp);
        catch ERR
            display_postprocessing_error(ERR, 'wake')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 's'))
        try
            GdfidL_run_simulation('s-parameter', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'e'))
        try
            GdfidL_run_simulation('eigenmode', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'l'))
        try
            GdfidL_run_simulation('lossy eigenmode', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'r'))
        try
            GdfidL_run_simulation('shunt', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end %try
    end %if
end %for
