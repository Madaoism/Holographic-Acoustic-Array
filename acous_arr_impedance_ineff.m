function [pp,pv] = acous_arr_impedance_ineff( s_a, s_b, delta_t )

    % define some constant variables, which might need to be changed
    density = 1.225; % density of the medium, which is air
    dist_sensor = 0.06; % distance between the sensors in meter (?)  

    % check if the two matrices have the same size
    [count_theta, count_sensor, count_sample] = size(s_a);
    [count_theta_b, count_sensor_b, count_sample_b] = size(s_b);
    if count_theta ~= count_theta_b ...
            || count_sensor ~= count_sensor_b ...
            || count_sample ~= count_sample_b 
        
        fprintf("The size of input matrices do not match\n");
        pp = 0; pv = 0;
        return;
    end
    
    % find the omega values of corresponding fft 
    omega_vec = linspace(0, 1/delta_t, count_sample);
    count_omega = numel(omega_vec);
    
    % perform the fft on the third dimension, which is the time domain
    % right now the dimension is defined as:
    % 1st dim: theta
    % 2nd dim: sensor
    % 3rd dim: omega
    p_a = fft(s_a, count_sample, 3);
    p_b = fft(s_b, count_sample, 3);
    
    % for now, let p_s = average of p_a and p_b
    p_s = (p_a + p_b) / 2;
    
    % v_s = 1/(+-i*omega) * (p_b - p_a)/ ( density * dist )
    v_s = (p_b - p_a) / ( density * dist_sensor );
    for idx_omega = 1:count_omega
        v_s( :, :, idx_omega ) = v_s( :, :, idx_omega) / (1i * omega_vec(idx_omega));
    end
    
    % initialize new arrays for the output
    pp = zeros( count_sensor, count_sensor, count_omega );
    ps = zeros( count_sensor, count_sensor, count_omega );
    
    for idx_omega = 1:count_omega
        
        for idx_theta = 1:count_theta
            
            % make it 4x1 * 1x4 to generate the desired matrix
            p_i = transpose( p_s( idx_theta, :, idx_omega ) );
            p_j = p_i';
            v_j = transpose( v_s( idx_theta, :, idx_omega ) )';
            
            % pp = <p_i, p_j*>, ps = <p_i, s_j*> for each omega
            pp( :, :, idx_omega) = pp( :, :, idx_omega) + p_i * p_j;
            ps( :, :, idx_omega) = ps( :, :, idx_omega) + p_i * v_j;
        end
        
        % find the average across the different theta angles
        pp( :, :, idx_omega) = pp( :, :, idx_omega) / count_theta; 
        ps( :, :, idx_omega) = ps( :, :, idx_omega) / count_theta; 
        
    end
   
    return;
end

