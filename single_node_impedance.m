%% Load workspace variables
load( "p_time_nodes" );
load( "p_time_nodes_int" );
load( "p_time_nodes_ext" );

%% DEFINE SOME CONSTANTS HERE
dist_surface = 0.005; % distance between the surface and sensor in meter (?)  
dist_sensor = 2 * dist_surface; % distance between the sensors
density = 1.225; % density of the medium, which is air
speed_sound = 343; % speed of sound in air
z_ref = density * speed_sound; % impedance value reference
[count_snapshot, count_sensor, count_sample] = size(p_time_nodes_ext);
delta_t = 0.00004;

%% Calculate pressures and velocities for a single node
p_ext = fft( p_time_nodes_ext, count_sample, 3 );
clear p_time_nodes_ext;
p_int = fft( p_time_nodes_int, count_sample, 3 );
clear p_time_nodes_int;
p_surface = fft( p_time_nodes, count_sample, 3 );
clear p_time_nodes;

% Calculate the surface pressure based on the interior & exterior pressures
p_surface_calculated = (p_ext + p_int) ./ 2;
clear p_ext; clear p_int;

% Find the omega values
f_delta = 1 / (delta_t * count_sample);
fs = 1 / delta_t;
raw_count_omega = count_sample ;
raw_omega_vec = 2 * pi * linspace(0, fs - f_delta, raw_count_omega );
omega_mat = repmat( raw_omega_vec, count_snapshot, 1 ,count_sensor );
omega_mat = permute( omega_mat, [1, 3, 2] );

% Find the surface velocity
v_surface = (p_ext - p_int) ./ (density * dist_sensor) ./ (-1i * omega_mat);

% Clear temps
clear omega_mat; clear raw_omega_vec; clear raw_count_omega; clear f_delta; clear fs;

%%
node_ id = 161;
freq_id = 130; % about 1.6k hz

impedance_snapshot = p_surface( :, node_id, freq_id ) ./ v_surface( :, node_id, freq_id );
figure;
hist( real( impedance_snapshot ) );
mean_impedance_snapshot = mean( real(impedance_snapshot) );
std_impedance_snapshot = std( real(impedance_snapshot) );

%% 
snapshot_id = 321;
impedance_node_freq = p_surface( snapshot_id, :, : ) ./ v_surface( snapshot_id, :, : );
figure;
hist (real ( impedance_node_freq(:) ) );

%% Find the impedance of a single sensor, picked at random
% sensor_id = 214;
% impedance_single = p_surface_calculated(:, sensor_id, :) ./ v_surface(:, sensor_id, :);
% impedance_single = permute( impedance_single, [1,3,2] );
% 
% %% Check the matrix
% mean_impedance_single = mean( real( impedance_single(:) ) );
% std_impedance_single = std( real( impedance_single(:) ) );
% 
% %% Find the mean across the theta
% average_across_theta = mean( impedance_single, 2 );
% 
% figure;
% hist ( real( average_across_theta ) );
% median_theta_averages = median( real( average_across_theta ) );
