
function [pp,pv] = acous_arr_impedance_ineff( s_a, s_b, delta_t )

    [count_theta, count_sensor, count_sample] = size(s_a);
    [count_theta_b, count_sensor_b, count_sample_b] = size(s_b);
    if count_theta ~= count_theta_b ...
            || count_sensor ~= count_sensor_b ...
            || count_sample ~= count_sample_b 
        
        fprintf("The size of input matrices do not match\n");
        pp = 0; pv = 0;
        return;
    else
        fprintf("The size of input matrices match\n");
    end
    
    T_max = delta_t * count_sample;
    p_a = zeros( count_theta, count_sensor, count_sample );
    p_b = zeros( count_theta, count_sensor, count_sample );
    
    for theta = 1:count_theta
        for sensor = 1:count_sensor
            p_a( theta, sensor, : ) = fft( s_a( theta, sensor ) );
            p_b( theta, sensor, : ) = fft( s_b( theta, sensor ) );
        end
    end
    
    pp = p_a;
    pv = p_b;
    return;
end

