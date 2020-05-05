function output = condition_timeseries(temp_data, sweep_length, start_time, end_time, timestep)
% move onto common timestep.
if ~all(isnan(temp_data))
tmp_timebase = linspace(temp_data(1,1),temp_data(end,1),(temp_data(end,1) - temp_data(1,1))/timestep + 1);
% find the data length required.
trimmed = find(tmp_timebase <= (sweep_length / 3E8), 1, 'last');
if isempty(trimmed)
    warning(['Sweep length ', num2str(sweep_length) ,' not found.'])
end %if
tmp_timebase = tmp_timebase(1:trimmed);
data = interp1(temp_data(:,1), temp_data(:,2),tmp_timebase ) ;

full_timebase = linspace(start_time, end_time,(end_time - start_time)/timestep + 1);
output = interp1(tmp_timebase, data, full_timebase);
% The output signal for the extended timescale is zero
output(isnan(output) == 1) = 0;
else
    full_timebase = linspace(start_time, end_time,(end_time - start_time)/timestep + 1);
    output = zeros(size(full_timebase,1), size(full_timebase,2));
end %if
% 
% [ ~, temp_data] = ...
%     pad_data(tmp_timebase, temp_data, end_time, 'time');
% output = interp1(temp_data(:,1), temp_data(:,2),tmp_timebase ) ;

% pad to 1 revolution length

% disp(['output length', num2str(length(output)), ' start ', ...
%     num2str(tmp_timebase(1)),' end ', num2str(tmp_timebase(end))]) 