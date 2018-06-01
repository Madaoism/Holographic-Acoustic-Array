
% sensor ---------r--------- sound source
freq = 1100;
c = 343;
density = 1.225;
dist = [0, 0.005, 0.01];
r = [5, 5, 5];   % range from sensor

p = p_sphere( r, freq, c );
v = ( p(1) - p(3) ) / (1i * 2 * pi * freq * (dist(3) - dist(1)) * density );

z_ref = c * density;
z_cal = p(2) / v;