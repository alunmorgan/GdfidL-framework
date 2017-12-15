function Testing_simple_buttons
% This code takes the STL files generated by the FreeCAD model generation
% code and writes input files for GdfidL and run the models.
%
% Example: Testing_pillbox_cavity

run_inputs = Tests_setup('simple_buttons');

%% Material parameters for the model geometry
% A lookup table of materials to component names
run_inputs.mat_list = {'beampipe_mat', 'beam pipe';...
    'block_mat','button block';...
    'button_mat', 'button';...
    'ceramic_mat', 'button ceramic';...
    'pin_mat', 'pin';...
    'shell_mat', 'button outer shell'};
% Material parameters sweeps can be defined here by
% passing a cell array of >1 value.
run_inputs.material_defs = {...
    {'beampipe_mat', {'steel316'}, 'Material of the beampipe.'},...   
    {'block_mat', {'steel316_2'}, 'Material the button block is made of.'},...
    {'button_mat', {'steel316_3'}, 'Material the button face is made of.'},...
    {'pin_mat', {'molybdenum'}, 'Material the button pin is made of.'},...
    {'ceramic_mat', {'aluminium_oxide'}, 'Material the button ceramic is made of.'},...
    {'shell_mat', {'steel304'}, 'Material of the outer casing of the button.'}...
    };

%% This is for setting up the simulation parameters.
run_inputs.simulation_defs.version = {'170509g'};
run_inputs.simulation_defs.beam_sigma = {'5E-3'}; %in m
run_inputs.simulation_defs.mesh_stepsize = {'250E-6'}; %in m
run_inputs.simulation_defs.wakelength = {'5'};
%Number of perfectly matched layers used.
run_inputs.simulation_defs.NPMLs = {'40'};
% calculation precision (double/ single).
run_inputs.simulation_defs.precision = {'double'};
% number of cores to use
run_inputs.simulation_defs.n_cores = '25';
% sim select - chooses which simulations to run
% (Wake/S-parameter/Eigenmode). Uses a string as input 'esw' will select
% all three.
run_inputs.simulation_defs.sim_select = 'wselr';
% specifies if there is an electron beam passing through the structure.
% if there is it is assumed to be passing between ports 1 and 2.
run_inputs.simulation_defs.beam = 'yes';
% Specifies the ports which the sparameter simulation will excite
% sequentially. (useful if symetry mean that not all ports need to be
% tried).
run_inputs.simulation_defs.s_param_ports = {'signal_1', 'signal_2', 'signal_3', 'signal_4'};
% Describes the S parameter port excitation.
% There needs to be very little power at 0Hz as this gives a DC component
% which is undesirable.
run_inputs.simulation_defs.s_param_excitation_f = 2.500E9;
run_inputs.simulation_defs.s_param_excitation_bw = 5E9;
% Determines the length of time the S parameter monitor is run for.
run_inputs.simulation_defs.s_param_tmax = 80E-9;
% When using symetry planes some ports are not within the mesh and are thus not
% counted. The port multiple is a way of taking these "hidden" ports into
% account when it come to calculating the losses.
run_inputs.simulation_defs.port_multiple = [1,1,1,1,1,1];
% in GdfidL if a port is cut by a symetry plane then only the section of the
% port within the mesh returns any signal. In order to get the signal for the
% full port one must divide by the fill factor.
run_inputs.simulation_defs.port_fill_factor = [1,1,1,1,1,1];
% In order to get the total energy values correct you have to say what fraction
% of the structure was simulated.
run_inputs.simulation_defs.volume_fill_factor =  1;
% Identifies port extensions so that the energy loss accounting is done
% correctly.The losses from these will be combined witht he port losses rather than
% the structure losses.
run_inputs.simulation_defs.extension_names = {'beampipe'};

% %%%%%%%%%%%%%%%%%%%%%%%%%% Running the models %%%%%%%%%%%%%%%%%%%
modelling_setups = run_inputs_setup_STL(run_inputs);
run_models(run_inputs, modelling_setups, 'STL')
