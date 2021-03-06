%% cross_correlation_gpu
% pressure and velocity are the surface pressure and velocity calculated,
%   they can be passed in as gpuArray
% Each is a 3D matrix with the following dimension definition:
    % 1st dim: snapshot
    % 2nd dim: sensor/node
    % 3rd dim: frequency

% convert_to_cpu should be passed in as true if the output is to be
%   converted to a CPU array
function [pp, vp] = cross_correlation_gpu( pressure, velocity, convert_to_cpu )    
    %% Check if convert_to_cpu exists
    if ~exist('convert_to_cpu', 'var')
       convert_to_cpu = false;
    end

    %% CHECK THE MATRIX SIZES
    % check if the two matrices have the same size
    [count_snapshot, count_sensor, count_omega] = size(pressure);
    [count_snapshot_b, count_sensor_b, count_omega_b] = size(velocity);
    if count_snapshot ~= count_snapshot_b ...
            || count_sensor ~= count_sensor_b ...
            || count_omega ~= count_omega_b 
        
        fprintf("The size of input matrices do not match\n");
        pp = 0; vp = 0;
        return;
    end
    
    %% Byte size of matlab variables that we will be dealing with
    double_size = 8; 
    complex_size = double_size * 2;
    device = gpuDevice();
    
    %% Pre-allocate memory for <P, P*> and <V, P*>    
    % Preallocate them in gpu if there's enough memory       
    if ( ~isa(pressure, 'gpuArray' ) )
        if ( count_sensor * count_snapshot * count_omega * complex_size < device.AvailableMemory )
            pressure = gpuArray(pressure);
        end
    end 
    
    if ( ~isa(velocity, 'gpuArray' ) )
        if ( count_sensor * count_snapshot * count_omega * complex_size < device.AvailableMemory )
            velocity = gpuArray(velocity);
        end
    end 
    
    if ( count_sensor * count_sensor * count_omega * complex_size * 2 < device.AvailableMemory)
        pp =  zeros( count_sensor, count_sensor, count_omega, 'gpuArray' ) ;
        vp =  zeros( count_sensor, count_sensor, count_omega, 'gpuArray' ) ;         
    else
        pp =  zeros( count_sensor, count_sensor, count_omega ) ;
        vp =  zeros( count_sensor, count_sensor, count_omega ) ; 
        if ( isa( pressure, 'gpuArray' ) )
            pressure = gather(pressure);
            velocity = gather(velocity);
        end
    end
    
    %% Find the cross correlation in the form of <p, p*> and <p, v*>
    tic;
    
    % Perform the cross-correlation
    for idx_omega = 1:count_omega
        
        p_mat = pressure( :, :, idx_omega);
        v_mat = velocity( :, :, idx_omega);
        
        pp(:, :, idx_omega) = p_mat.' * p_mat;
        vp(:, :, idx_omega) = v_mat.' * p_mat;

    end
    
    % Average out the pp and vp over snapshot
    pp = pp ./ count_snapshot;
    vp = vp ./ count_snapshot;
    
    %% Gather the information back to CPU
    if (isa(pp, 'gpuArray') && convert_to_cpu == true)
        pp = gather(pp);
        vp = gather(vp);
    end
    
    %% Report the time used to find the cross correlations
    time_cross = toc;
    fprintf("\ntime to find <p,p*> and <p,v*>: " + time_cross + "sec\n");
    
    return;
end