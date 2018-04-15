% Author: Yiming Cai
% filename: checkGPU.m
% date created: 4/6/2018
% plot the GPU speed against CPU's given some FFT functions to solve

% to fool the PC into initializing the GPU before testing
clear;
disp( gpuDevice );
dummy = zeros(1, 10);
g_dummy = gpuArray( dummy );
clear g_dummy;

progress = 0.0;
run_count_per_config = 60;
ind_n = uint32( linspace(10, 400000, 50) );
ind_limit = uint32( linspace(1, 3000, 50) );

time_GPU_n = zeros(numel(ind_n), run_count_per_config);
time_CPU_n = zeros(numel(ind_n), run_count_per_config);
time_GPU_limit = zeros(numel(ind_limit), run_count_per_config);
time_CPU_limit = zeros(numel(ind_limit), run_count_per_config);

step = 50.0/double(numel(ind_n));
for idx = 1:numel(ind_n)
    
    for r = 1:run_count_per_config
        [t_c, t_g] = gpuBenchMark(1, ind_n(idx), 10);
        time_CPU_n(idx, r) = t_c;
        time_GPU_n(idx, r) = t_g;
    end
    progress = progress + step;
    fprintf("Current progress: %d%%\n", progress);
    
end

disp("Finished first half of testing");

step = 50.0/double(numel(ind_limit));
for idx = 1:numel(ind_limit)
    
    for r = 1:run_count_per_config
        [t_c, t_g] = gpuBenchMark(1, 512, ind_limit(idx));
        time_CPU_limit(idx, r) = t_c;
        time_GPU_limit(idx, r) = t_g;
    end
    progress = progress + step;
    fprintf("Current progress: %d%%\n", progress);
    
end

mean_time_GPU_n = zeros(1, numel(ind_n));
mean_time_CPU_n = zeros(1, numel(ind_n));
mean_time_GPU_limit = zeros(1, numel(ind_n));
mean_time_CPU_limit = zeros(1, numel(ind_n));

sd_time_GPU_n = zeros(1, numel(ind_limit));
sd_time_CPU_n = zeros(1, numel(ind_limit));
sd_time_GPU_limit = zeros(1, numel(ind_limit));
sd_time_CPU_limit = zeros(1, numel(ind_limit));

for idx = 1:numel(ind_n)
    mean_time_GPU_n(idx) = mean( time_GPU_n(idx,:) );
    mean_time_CPU_n(idx) = mean( time_CPU_n(idx,:) );
    sd_time_GPU_n(idx) = std( time_GPU_n(idx,:) );
    sd_time_CPU_n(idx) = std( time_CPU_n(idx,:) );
end

for idx = 1:numel(ind_n)
    mean_time_GPU_limit(idx) = mean( time_GPU_limit(idx,:) );
    mean_time_CPU_limit(idx) = mean( time_CPU_limit(idx,:) );
    sd_time_GPU_limit(idx) = std( time_GPU_limit(idx,:) );
    sd_time_CPU_limit(idx) = std( time_CPU_limit(idx,:) );
end

s1 = "GPU time";
s2 = "CPU time";

figure; 
subplot(2,1,1);
p1 = errorbar(ind_n, mean_time_GPU_n, sd_time_GPU_n); 
%p1 = errorbar(ind_n(2:numel(ind_n)), mean_time_GPU_n(2:numel(ind_n)), sd_time_GPU_n(2:numel(ind_n))); 
title('GPU time against number of elements');
xlabel('number of elements');
ylabel('time spent');
legend(p1, s1);

subplot(2,1,2);
p2 = errorbar(ind_n, mean_time_CPU_n, sd_time_CPU_n);
title('CPU time against number of elements');
xlabel('number of elements');
ylabel('time spent');
legend(p2, s2);

figure;
subplot(2,1,1);
p1 = errorbar(ind_limit, mean_time_GPU_limit, sd_time_GPU_limit); 
title('GPU time against number of FFTs');
xlabel('number of FFTs');
ylabel('time spent');
legend(p1, s1);

subplot(2,1,2);
p2 = errorbar(ind_limit, mean_time_CPU_limit, sd_time_CPU_limit);
title('CPU time against number of FFTs');
xlabel('number of FFTs');
ylabel('time spent');
legend(p2, s2);

save('checkGPU_results');
