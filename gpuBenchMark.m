    
% Author: Yiming Cai
% filename: checkGPU.m
% date created: 4/6/2018
% description: check the capacity of the GPU, and the power it has when
%   it is put to do some FFT operations


% Note that, the more data that is loaded onto GPU, the faster it can work
%   compared to the CPU (since all the data is calculated in parallel).
%   To test this out, change the value of 'n' down below and experiment
% 
% Also note that, the more operations that are done on the GPU without
%   gathering or clearing it out, the less the latency. To test this out,
%   change the value of 'limit' down below and experiment


% the gpu takes approximately 2 minutes to start up for the first time
% but afterwards it become much faster

function [CPU_time,GPU_time] = gpuBenchMark(height, width, limit)

%     dev = gpuDevice();
%     fprintf(...
%     'GPU detected (%s, %d multiprocessors, Compute Capability %s)\n\n',...
%     dev.Name, dev.MultiprocessorCount, dev.ComputeCapability);

    seed = 1248127;
    rng(seed);
    X = rand(height, width);

    % on GPU -----------------
%     disp( "GPU available memory before running: " + (dev.AvailableMemory / 1024 / 1024) + "MB" );

    %Note that it takes some time to convert X to a GPU array
    tic;
    G = gpuArray(X);
    timeConvert = toc;

    tic;
    for i = 1:limit
        G_dft = fft(G);
    end
    timeFFT = toc;

    %Note that it takes an awful amount of time to gather G_dft
    tic;
    dft = gather(G_dft);
    timeGather = toc;

    %Note that it takes as much time to clear as it is to gather
%     disp( "GPU available memory before clearing: " + (dev.AvailableMemory / 1024 / 1024) + "MB" );
    tic;
    clear G;
    clear G_dft;
    timeClear = toc;
    timeGPU = timeConvert + timeFFT + timeGather + timeClear;
%     disp( "GPU available memory after: " + (dev.AvailableMemory / 1024 / 1024) + "MB" );
    % -------------------------

    % on CPU ------------------

    tic;

    for i = 1:limit
        X_dft = fft(X);
    end

    timeCPU = toc;
    % ------------------------
    
    CPU_time = timeCPU;
    GPU_time = timeGPU;
    return;

%     disp(" ");
%     [h,w] = size(X);
%     disp(limit + " FFTs on " + h +"x"+ w + " on GPU: " + timeGPU + " sec" );
%     disp(limit + " FFTs on " + h +"x"+ w + " on CPU: " + timeCPU + " sec" );
%     disp(" ");
%     disp("Converting to gpuArray took: " + (timeConvert / timeGPU * 100) + "% of gpu time");
%     disp(limit + " FFT took: " + (timeFFT / timeGPU * 100) + "% of gpu time");
%     disp("Gathering took: " + (timeGather / timeGPU * 100) + "% of gpu time");
%     disp("Clearing took: " + (timeClear / timeGPU * 100) + "% of gpu time");
end

