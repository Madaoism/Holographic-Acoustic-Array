%% 
function [pressure] = p_sphere(d,freq,c)

    omega = 2 * pi * freq;
    k = omega / c;
    
    pressure = exp( -1i .* k .* d )./(4.*pi.*d);
end

