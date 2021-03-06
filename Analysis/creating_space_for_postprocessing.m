function creating_space_for_postprocessing(pp_directory, sim_type, model_name)
% Create the appropriate folder structure for the postprocessed data to go.
% If data is already present and the no_skip option has been selected then the
% old data is moved to another folder.
%
% Example: creating_space_for_postprocessing('wake', model_name)
if exist(pp_directory, 'dir') == 7
    disp(['Moving old ', sim_type, ' postprocessing data for ',model_name])
    old_store = ['old_data', datestr(now,30)];
    mkdir('pp_link', old_store)
    movefile(pp_directory, fullfile('pp_link', old_store))
end %if
disp(['Creating ', sim_type, ' postprocessing folder for ',model_name])
[~] = system(['mkdir ', pp_directory]);

