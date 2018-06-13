%% Load workspace
%load("post_impedance_workspace", "pp", "vp");

%% Define constants
density = 1.225; % density of the medium, which is air
speed_sound = 343; % speed of sound in air
z_ref = density * speed_sound; % impedance value reference
[ count_sensor, count_sensor2, count_omega ] = size(pp);
zs = zeros( count_sensor, count_sensor, count_omega );
count_sample = count_omega * 2;

%% Find the omega values
% find the frequency values of the results of fft
% the omega should be in the range of 0 to 1/delta_t or 1/delta_t/2
delta_t = 4e-5;
f_delta = 1 / (delta_t * count_sample);
fs = 1 / delta_t;
raw_count_omega = count_sample ;
raw_omega_vec = 2 * pi * linspace(0, fs - f_delta, raw_count_omega );

% truncate the vectors
count_omega = uint32( raw_count_omega/2 );
omega_vec = raw_omega_vec( 1 : count_omega );

%% Calculate the points of the cylinder itself
N = 300;
e = 0.0;
[nodes_x_cyl, nodes_y_cyl, nodes_z_cyl, nnodes] = nodes_coordinate_surface_cylinder( N, e );
nodes_coord = zeros( nnodes, 3);
nodes_coord(:, 1) = nodes_x_cyl;
nodes_coord(:, 2) = nodes_y_cyl;
nodes_coord(:, 3) = nodes_z_cyl;
[ mesh ] = MyCrustOpen(nodes_coord);

%% Find the distances between each cylinder
distances = (nodes_x_cyl - nodes_x_cyl.').^2 + (nodes_y_cyl - nodes_y_cyl.').^2 + (nodes_z_cyl - nodes_z_cyl.').^2 ;
distances = sqrt(distances); % The distance between each pair of nodes at index i and j

%% Find the impedance values
% the impedance of each frequence between each pair of sensor
for freq_idx = 1 : count_omega
   
    zs( :, :, freq_idx ) = pp_sort_dist( :, :, freq_idx ) / vp_sort_dist( :, :, freq_idx );
    %zs( :, :, freq_idx ) = zs( :, :, freq_idx ) ./ distances ;
    
end

%% Do a random color plot of the values
freq_idx = 453;
sensor_idx = 134;
figure;
hold on;

trisurf(mesh,nodes_coord(:,1),nodes_coord(:,2),nodes_coord(:,3),...
    log10( abs(  pp(:, sensor_idx, freq_idx)) ) );

scatter3(nodes_x_cyl(sensor_idx), ...
    nodes_y_cyl(sensor_idx), ...
    nodes_z_cyl(sensor_idx), 144, ...
    [1,0,0], 'filled');

colorbar;
hold off;

%% PLOT AGAINST DISTANCE
freq_idx = 500;
%lambda = speed_sound / (omega_vec(freq_idx) / 2 /pi);

p_relative = zeros( 285, 285 );
dist_sorted = zeros( 285, 285 );

for idx_sensor = 1:285
    
    temp_p = log10( abs( pp_sort_dist(:, idx_sensor, freq_idx ) ) );
    temp_p = temp_p(:);
    
    temp_dist = distances(:, idx_sensor);
    temp_dist = sort(temp_dist);
    
    
    p_relative( :, idx_sensor ) = temp_p;
    dist_sorted( :, idx_sensor ) = temp_dist;

end

p_relative = p_relative - max(p_relative(:));

figure;
hold on;

s = scatter( dist_sorted(:), p_relative(:), 1 );

% plot the theoretical pressure values against distance
p_sensor = p_sphere( distances(:) , (omega_vec(freq_idx) ./(2* pi)) , speed_sound);
theo = zeros( 285^2, 2 );
theo(:,1) = distances(:);
theo(:,2) = abs(p_sensor(:));
theo = sortrows(theo);
p = plot( theo(:,1), log10( theo(:,2 ) ) );

hold off;
title( "Pressure vs Distance at "+ num2str( omega_vec(freq_idx) / 2 / pi ) );
legend( [ s, p], [ "Calculated Pressure Values", "Theoretical Pressure Values" ] );
xlabel( "Distance" );
ylabel( "log_{10}(Pressure)" );