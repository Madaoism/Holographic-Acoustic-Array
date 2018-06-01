%% Load workspace
load("post_impedance_workspace", "pp", "vp");

%% Define constants
density = 1.225; % density of the medium, which is air
speed_sound = 343; % speed of sound in air
z_ref = density * speed_sound; % impedance value reference
[ count_sensor, count_sensor2, count_omega ] = size(pp);
zs = zeros( count_sensor, count_sensor, count_omega );

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
   
    zs( :, :, freq_idx ) = pp( :, :, freq_idx ) / vp( :, :, freq_idx );
    %zs( :, :, freq_idx ) = zs( :, :, freq_idx ) ./ distances ;
    
end

%% Do a random color plot of the values
freq_idx = 153;
sensor_idx = 130;
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
sensor_idx = 155;
freq_idx = 200;
lambda = speed_sound / (omega_vec(freq_idx) / 2 /pi);
figure;
hold on;

temp = log10( abs( pp(:, sensor_idx, freq_idx ) ) );
temp = temp - max(temp);
s = scatter( distances(:, sensor_idx)./lambda, temp );

p_sensor = p_sphere( distances(:, sensor_idx) , (omega_vec(freq_idx) ./(2* pi)) , speed_sound);
p = plot( distances(:, sensor_idx)./lambda, log10( abs( p_sensor(:) ) ) );

hold off;
title( "Pressure vs Distance" );
legend( [ s, p], [ "Calculated Pressure Values", "Theoretical Pressure Values" ] );
xlabel( "Distance" );
ylabel( "log_{10}(Pressure)" );