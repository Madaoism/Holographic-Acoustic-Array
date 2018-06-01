%% Load workspace variables
load( "post_impedance_workspace" );

%% DEFINE SOME CONSTANTS HERE
% define some constant variables, which might need to be changed

dist_surface = 0.005; % distance between the surface and sensor in meter (?)  
dist_sensor = 2 * dist_surface; % distance between the sensors
density = 1.25; % density of the medium, which is air
speed_sound = 343; % speed of sound in air
z_ref = density * speed_sound; % impedance value reference
    
%% Plot some data in frequency domain
sensor_id = 200;
snapshot_id = 100;
figure;
hold on;
p1 = plot( raw_omega_vec, abs( permute( p_s(snapshot_id,sensor_id,: ), [3,2,1] ) ) );
p2 = plot( raw_omega_vec, abs( fft( permute( p_time_nodes(snapshot_id,sensor_id,: ), [3,2,1] ),numel(raw_omega_vec) ) ) );
title( 'Frequency Domain Data at the Surface of Cylinder' );
xlabel( 'omega = 2*pi*f (rad/s)' );
ylabel( 'ABS(DFT) ' );
legend([p1, p2], {'calculated data', 'simulation data'} );
hold off;

%% Plot some data in time domain
sensor_id = 123;
snapshot_id = 413;
figure;
hold on;
t = linspace(0, 0.00004*2000, 2000);
p1 = plot( t, ifft( permute( p_s(snapshot_id,sensor_id,:), [3,2,1] ) ));
p2 = plot( t, permute( p_time_nodes(snapshot_id,sensor_id,:), [3,2,1] ) );
title( 'Time Domain Data at the Surface of Cylinder' );
xlabel( 't (sec)' );
ylabel( 'amplitude' );
legend([p1, p2], {'calculated data', 'simulation data'} );
hold off;

%% plot 3 velocities based on the 3 pressure differences, against frequencies
[count_snapshot, count_sensor, count_sample] = size(p_time_nodes_ext);
omega_mat = repmat( raw_omega_vec, count_snapshot, 1 ,count_sensor );
omega_mat = permute( omega_mat, [1, 3, 2] );
p_a = fft(p_time_nodes_ext, count_sample, 3);
p_b = fft(p_time_nodes_int, count_sample, 3);
v_sa = ( (p_s - p_a) ./ ( density * dist_surface ) ) ./ (1i * omega_mat);
v_bs = ( (p_b - p_s) ./ ( density * dist_surface ) ) ./ (1i * omega_mat);

sensor_id = 222;
snapshot_id = 412;

figure;
hold on;
p1 = plot( raw_omega_vec, permute(v_sa( snapshot_id, sensor_id, : ),[3,2,1]) );
p2 = plot( raw_omega_vec, permute(v_bs( snapshot_id, sensor_id, : ),[3,2,1]) );
p3 = plot( raw_omega_vec, permute(v_s( snapshot_id, sensor_id, : ),[3,2,1]) );
hold off;
title( 'Velocity Data' );
xlabel( 'omega = 2*pi*f (rad/s)' );
ylabel( 'velocity (m/s)' );
legend([p1, p2, p3], {'Midpoint of surface and exterior', 'Midpoint of interior and surface', 'Midpoint of exterior and interior'} );
