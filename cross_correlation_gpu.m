% s_a and s_b are the unprocessed signals from the acoustic array
% Each is a 3D matrix with the following dimension definition:
% 1st dim: snapshot
% 2nd dim: sensor/node
% 3rd dim: sample/t
% delta_t should be the time between each sample input
function [pp, vp] = cross_correlation_gpu( s_a, s_b, delta_t )
    %% DEFINE SOME CONSTANTS HERE
    % define some constant variables, which might need to be changed
    
    dist_surface = 0.005; % distance between the surface and sensor in meter (?)  
    dist_sensor = 2 * dist_surface; % distance between the sensors
    density = 1.25; % density of the medium, which is air
    speed_sound = 343; % speed of sound in air
    z_ref = density * speed_sound; % impedance value reference
    
    %% CHECK THE MATRIX SIZES
    % check if the two matrices have the same size
    [count_snapshot, count_sensor, count_sample] = size(s_a);
    [count_snapshot_b, count_sensor_b, count_sample_b] = size(s_b);
    if count_snapshot ~= count_snapshot_b ...
            || count_sensor ~= count_sensor_b ...
            || count_sample ~= count_sample_b 
        
        fprintf("The size of input matrices do not match\n");
        pp = 0; vp = 0;
        return;
    end
    
    %% Byte size of matlab variables that we will be dealing with
    double_size = 8; 
    complex_size = 16;
      
    %% Find the omega values
    % find the frequency values of the results of fft
    % the omega should be in the range of 0 to 1/delta_t or 1/delta_t/2
    f_delta = 1 / (delta_t * count_sample);
    fs = 1 / delta_t;
    raw_count_omega = count_sample ;
    raw_omega_vec = 2 * pi * linspace(0, fs - f_delta, raw_count_omega );

    % truncate the vectors
    count_omega = uint32( raw_count_omega/2 );
    omega_vec = raw_omega_vec( 1 : count_omega );
    
    tic;
    %% Selects a single GPU (multiple GPU is possible but more complicated)
    device = gpuDevice();
        
    %% Perform the FFT. If there's enough memory, everything should be on GPU now
    % If the gpu has enough memory to hold one of them
    if (count_sample * count_snapshot * count_sensor * complex_size * 2 < device.AvailableMemory )
        p_a = gpuArray( s_a ); 
        clear s_a;
        p_a = fft( p_a, count_sample, 3);
        p_a = p_a(:, :, 1:count_omega);
        
        p_b = gpuArray( s_b); 
        clear s_b;
        p_b = fft( p_b, count_sample, 3);
        p_b = p_b(:, :, 1:count_omega);
        
    % else do both on CPU
    else
        p_a = fft( s_a, count_sample, 3); 
        clear s_a;
        p_a = p_a(:, :, 1:count_omega);
        
        p_b = fft( s_b, count_sample, 3); 
        clear s_b;
        p_b = p_b(:, :, 1:count_omega);
    end
    
    %% Find pressure on the surface
    p_s = (p_a + p_b) / 2;
    
    %% Find the velocity on the surface
    % Find the omega value of each corresponding matrix cell
    omega_mat = repmat( omega_vec, count_snapshot, 1 ,count_sensor );
    omega_mat = permute( omega_mat, [1, 3, 2] );
    
    v_s = ( (p_b - p_a) ./ ( density * dist_sensor ) ) ./ (1i .* omega_mat);
    clear omega_mat; clear p_b; clear p_a;
     
    %% Check the time used
    time_fft = toc;
    fprintf("time to find surface pressure and velocity: " + time_fft + "sec\n");
    
    %% Pre-allocate memory for <P, P*> and <V, P*>    
    % Preallocate them in gpu if there's enough memory
    if ( count_sensor * count_sensor * count_omega * complex_size * 2 < device.AvailableMemory)
        pp =  zeros( count_sensor, count_sensor, count_omega, 'gpuArray' ) ;
        vp =  zeros( count_sensor, count_sensor, count_omega, 'gpuArray' ) ; 
    else
        pp =  zeros( count_sensor, count_sensor, count_omega ) ;
        vp =  zeros( count_sensor, count_sensor, count_omega ) ; 
        if ( isa( p_s, 'gpuArray' ) )
            p_s = gather(p_s);
            v_s = gather(v_s);
        end
    end
    
    %% Find the cross correlation in the form of <p, p*> and <p, v*>
    fprintf( "Calculating cross correlation values...\nCurrent Progress: 0.00%%\f" );
    tic;
    
    % Perform the cross-correlation
    for idx_omega = 1:count_omega
        
        p_mat = p_s( :, :, idx_omega);
        v_mat = v_s( :, :, idx_omega);
        
        pp(:, :, idx_omega) = p_mat.' * p_mat;
        vp(:, :, idx_omega) = v_mat.' * p_mat;
        
        if mod( idx_omega, 10 ) == 0
            if ( double(idx_omega)/double(count_omega)*100 > 10 ) 
                fprintf( "\b" );
            end
            fprintf ("\b\b\b\b\b\b%.2f%%\f", double(idx_omega)/double(count_omega)*100);
        end
        
    end
    
    % Average out the pp and vp over snapshot
    pp = pp ./ count_snapshot;
    vp = vp ./ count_snapshot;
    
    % Gather the information back to CPU
    if (isa(pp, 'gpuArray'))
        pp = gather(pp);
        vp = gather(vp);
    end
    
    %% Report the time used to find the cross correlations
    time_cross = toc;
    fprintf("\ntime to find <p,p*> and <p,v*>: " + time_cross + "sec\n");
    
    return;
end