function [nodes_x_total,nodes_y_total,nodes_z_total,nnodes] = nodes_coordinate_surface_cylinder(N,e)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% N : expected number of nodes (it will not be exactly this number)
% e : (m) distance between nodes and actual surface of the cylinder

% nodes_x_total : (m) nodes' coordinates along x-axis
% nodes_y_total : (m) nodes' coordinates along y-axis 
% nodes_z_total : (m) nodes' coordinates along z-axis
% nnodes : actual number of nodes


%% parameters
% shell dimensions
L = 0.61; %Length of the cylinder (m)
a = 0.1525; % radius of the shell (m)

% positions of nodes
a_nodes = a+e;
L_nodes = L/2+e;
L_min = -L/2-e;



%% 3D mesh - the center of the cartesian is in the center of the cylinder

% areas 
A_endcap = pi*a^2;
A_cyl = 2*pi*a*L;
A_total = A_cyl+2*A_endcap; %(m^2)
A_cyl_ratio = A_cyl/A_total; % 80% of the total area belong to the cylindrical section

% number of nodes
gamma = sqrt(A_total/N);

nphi = round(2*pi*a/gamma);
gamma = 2*pi*a/nphi;

nline = round((L+2*a)/gamma)+1;
nodes_z_temp = linspace(-L/2-a,L/2+a,nline);
indmin = min(find(nodes_z_temp>=-L/2));
indmax = max(find(nodes_z_temp<=L/2));

% Surface node polar angles
phi_temp = linspace(-180,180,nphi+1);
phi = phi_temp(1:nphi);
phi = phi.*pi./180;

% Set of surface nodes on the cylindrical section
nodes_x_cyl = a_nodes.*cos(phi);
nodes_y_cyl = a_nodes.*sin(phi);
nodes_z_cyl = nodes_z_temp(indmin:indmax);
nz = length(nodes_z_cyl);

% Set of surface nodes on the endcaps
n_line_endcaps = indmin-1;
amax_endcap = a-(gamma-(L/2-nodes_z_temp(indmax)));
a_temp =  linspace(0,amax_endcap,n_line_endcaps);

Nnodes_endcap = floor(a_temp*2*pi/gamma);
Nnodes_endcap(1)=1;


for ii = 1:length(Nnodes_endcap)
    phi_endcap_temp = linspace(-180,180,Nnodes_endcap(ii)+1);
    phi_endcap = phi_endcap_temp(1:Nnodes_endcap(ii));
    phi_endcap = phi_endcap.*pi./180;

    
    nodes_x_endcap_temp1 = a_temp(ii).*cos(phi_endcap);
    nodes_y_endcap_temp1 = a_temp(ii).*sin(phi_endcap);
    
    if (ii == 1)
        nodes_x_endcap_temp = nodes_x_endcap_temp1;
        nodes_y_endcap_temp = nodes_y_endcap_temp1;
    else
        nodes_x_endcap_temp = cat(2, nodes_x_endcap_temp,nodes_x_endcap_temp1);
        nodes_y_endcap_temp = cat(2, nodes_y_endcap_temp,nodes_y_endcap_temp1);
    end
   
end

nodes_x_endcap = repmat(nodes_x_endcap_temp, [1 2]);
nodes_y_endcap = repmat(nodes_y_endcap_temp, [1 2]);
nodes_z_endcap = cat(2, repmat(L_min, [1 length(nodes_y_endcap_temp)]),repmat(L_nodes, [1 length(nodes_y_endcap_temp)]));

nodes_xx_cyl = repmat(nodes_x_cyl, [1 nz]);
nodes_yy_cyl = repmat(nodes_y_cyl, [1 nz]);
nodes_zz_cyl = reshape(repmat(nodes_z_cyl', [1 nphi]).',[1 nz*nphi]);

nodes_x_total = cat(2,nodes_xx_cyl,nodes_x_endcap);
nodes_y_total = cat(2,nodes_yy_cyl,nodes_y_endcap);
nodes_z_total = cat(2,nodes_zz_cyl,nodes_z_endcap);
nnodes = length(nodes_x_total);

end

