
snapshot = 3;
freq = 1;
sensor = 5;

%X = randn( snapshot, sensor, freq, 'double' ) + randn( snapshot, sensor, freq, 'double' ) * 1i;
%Y = randn( snapshot, sensor, freq, 'double' ) + randn( snapshot, sensor, freq, 'double' ) * 1i;
X = reshape( 1:15, [snapshot, sensor, freq ] );
Y = reshape( 1:15, [snapshot, sensor, freq ] );

fake_pp =  zeros( sensor, sensor, freq ) ;
fake_vp =  zeros( sensor, sensor, freq ) ; 

% Perform the cross-correlation
for idx_omega = 1:freq

    for idx_snapshot = 1:snapshot

        % make it count_sensorx1 * 1xcount_sensor to generate the desired matrix
        % NOTE: this part is taking about 25% of the time
        p_i = X( idx_snapshot, :, idx_omega );
        v_i = Y( idx_snapshot, :, idx_omega );

        % pp = <p_i, p_j*>, ps = <p_i, v_j*> for each omega
        % NOTE: this part is taking about 70% of the time
        fake_pp( :, :, idx_omega) = fake_pp( :, :, idx_omega) + p_i' * p_i;
        fake_vp( :, :, idx_omega) = fake_vp( :, :, idx_omega) + v_i' * p_i;
    end

end


test_pp = zeros( sensor, sensor, freq ) ;
test_vp = zeros( sensor, sensor, freq ) ; 

for idx_omega = 1 : freq
    
    p_mat = X( :, :, idx_omega );   % 100 x 200
    v_mat = Y( :, :, idx_omega );   % 100 x 200
    
    test_pp(:, :, idx_omega) = p_mat' * p_mat;
    test_vp(:, :, idx_omega) = v_mat' * p_mat;
    
end

percent_error = mean(mean(mean( abs( test_pp - fake_pp ) ) ) ) / mean(mean(mean( abs( test_pp ))));
fprintf ("Percent error: %d\n",( percent_error));