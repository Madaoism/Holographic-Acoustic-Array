X = rand( 100, 200, 300, 'double' );
Y = rand( 100, 200, 300, 'double' );

fake_pp =  zeros( 200, 200, 300 ) ;
fake_vp =  zeros( 200, 200, 300 ) ; 

% Perform the cross-correlation
for idx_omega = 1:300

    for idx_snapshot = 1:100

        % make it count_sensorx1 * 1xcount_sensor to generate the desired matrix
        % NOTE: this part is taking about 25% of the time
        p_i = X( idx_snapshot, :, idx_omega );
        v_i = Y( idx_snapshot, :, idx_omega );

        % pp = <p_i, p_j*>, ps = <p_i, v_j*> for each omega
        % NOTE: this part is taking about 70% of the time
        fake_pp( :, :, idx_omega) = fake_pp( :, :, idx_omega) + p_i.' * p_i;
        fake_vp( :, :, idx_omega) = fake_vp( :, :, idx_omega) + v_i.' * p_i;
    end

end


test_pp = zeros( 200, 200, 300 ) ;
test_vp = zeros( 200, 200, 300 ) ; 

for idx_omega = 1 : 300
    
    p_mat = X( :, :, idx_omega );   % 100 x 200
    v_mat = Y( :, :, idx_omega );   % 100 x 200
    
    test_pp(:, :, idx_omega) = p_mat.' * p_mat;
    test_vp(:, :, idx_omega) = v_mat.' * p_mat;
    
end

average_diff = sum( sum( sum( abs( fake_pp - test_pp ) ) ) ) / (100*200*300);