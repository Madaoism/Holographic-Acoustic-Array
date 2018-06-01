clear all;
close all;
clc

%% Calculate the points of the cylinder itself
N = 300;
e = 0.0;
e1 = 0.005;
e2 = -0.005;
[nodes_x_cyl, nodes_y_cyl, nodes_z_cyl, nnodes] = nodes_coordinate_surface_cylinder( N, e );
[nodes_x_cyl_ext, nodes_y_cyl_ext, nodes_z_cyl_ext, ~] = nodes_coordinate_surface_cylinder( N, e1 );
[nodes_x_cyl_int, nodes_y_cyl_int, nodes_z_cyl_int, ~] = nodes_coordinate_surface_cylinder( N, e2 );

figure;
hold on;
scatter3( nodes_x_cyl, nodes_y_cyl, nodes_z_cyl, 20, [1,0,0], 'filled' );
scatter3( nodes_x_cyl_int, nodes_y_cyl_int, nodes_z_cyl_int, 20, [0,1,0], 'filled' );
scatter3( nodes_x_cyl_ext, nodes_y_cyl_ext, nodes_z_cyl_ext, 20, [0,0,1], 'filled' );
hold off;
title( "Location of simulation nodes" );