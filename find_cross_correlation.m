clear all;
close all;
clc;

%% Documentations
% Data given by Emma
% Note that the dimensions of the matrices are as below:
%   Data are in the time domain. 
%   The format of the two files is a 3D matrix whose dimensions are (285 x 2000 x 855)
%       285 is the number of nodes over the surface.
%       2000 is the number of time steps. The time vector goes from 0 to 0.08 s. 
%       The time step is 4e-5 s.
%       855 is the number of snapshots (corresponding to the number of realizations).

%% Load all the simulation data
load( "p_time_nodes_int.mat" );
load( "p_time_nodes_ext.mat" );

%% Transform the data
% 1st dim: snapshot
% 2nd dim: sensor/node
% 3rd dim: sample/t
p_time_nodes_ext = permute( p_time_nodes_ext, [ 3, 1, 2 ] );
p_time_nodes_int = permute( p_time_nodes_int, [ 3, 1, 2 ] );

%% Do the calculations
[pp, vp] = cross_correlation_gpu( p_time_nodes_ext, p_time_nodes_int, 4e-5 );
clear p_time_nodes_ext; clear p_time_nodes_int;

%% save the results to disk
save( 'post_impedance_workspace.mat', 'pp', 'vp', '-v7.3' );