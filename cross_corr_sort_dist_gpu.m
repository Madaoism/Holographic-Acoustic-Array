
function [pp, vp] = cross_corr_sort_dist_gpu( pressure, velocity, distances, convert_to_cpu )    
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
    
    [ dist_row, dist_col ] = size(distances);
    if dist_row ~= count_sensor || dist_col ~= count_sensor
        pp = 0; vp = 0; return;
    end
    
    %% Byte size of matlab variables that we will be dealing with
    double_size = 8; 
    complex_size = double_size * 2;
    device = gpuDevice();
    
    %% Pre-allocate memory for <P, P*> and <V, P*>    
    % Preallocate them in gpu if there's enough memory
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
    fprintf( "Calculating cross correlation values...\nCurrent Progress: 0.00%%\f" );
    tic;
    
    % Perform the cross-correlation
    for idx_omega = 1:count_omega

        curr_pp = zeros( count_sensor, count_sensor, 'gpuArray' );
        curr_vp = zeros( count_sensor, count_sensor, 'gpuArray' );
        
        curr_p_mat = pressure( :, :, idx_omega);
        curr_v_mat = velocity( :, :, idx_omega);
        
        for idx_dist = 1:dist_col
            
            % extract info needed in this loop
            curr_dist = distances( :, dist_col );
            
            % sort the rows/cols
            p_mat = sortrows( [curr_dist'; curr_p_mat], 1);
            v_mat = sortrows( [curr_dist'; curr_v_mat], 1);
            p_mat = p_mat( 2:count_snapshot+1, :);
            v_mat = v_mat( 2:count_snapshot+1, :);

            curr_pp = curr_pp + p_mat.' * p_mat;
            curr_vp = curr_vp + v_mat.' * p_mat;
        end

        pp(:, :, idx_omega) = curr_pp;
        vp(:, :, idx_omega) = curr_vp;
        
        if mod( idx_omega, 10 ) == 0
            if ( double(idx_omega)/double(count_omega)*100 > 10 ) 
                fprintf( "\b" );
            end
            fprintf ("\b\b\b\b\b\b%.2f%%\f", double(idx_omega)/double(count_omega)*100);
        end
    end
    
    % Average out the pp and vp over snapshot
    pp = pp ./ count_snapshot ./ dist_col;
    vp = vp ./ count_snapshot ./ dist_col;
    
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