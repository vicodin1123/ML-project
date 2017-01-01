% Gaussian Process for Classification
% clear; close all;

TrainSize = 2000;
TestSize = 720;
Dimension = 8;

%% Read data
Data = csvread('../Data/hiv_data.csv', 1, 0);

TrainSet = Data(1:TrainSize, :);
TestSet = Data(TrainSize+1:TrainSize+TestSize, :);

TrainTarget = TrainSet(:, Dimension+1);
TrainSet = TrainSet(:, 1:Dimension);

TestTarget = TestSet(:, Dimension+1);
TestSet = TestSet(:, 1:Dimension);

%% Build Cov
Alpha = 0.01;
Theta = [1; 0.5];
Eta = ones(Dimension, 1);

Cov = zeros(TrainSize);
for i = 1 : TrainSize
    for r = i : TrainSize
        Cov(i, r) = GPRegressionKernel( ...
            TrainSet(i, :), TrainSet(r, :), Theta, Eta);
        Cov(r, i) = Cov(i, r);
    end
end
Cov = Cov + Alpha*eye(size(Cov));

%% Learning
I = eye(TrainSize, TrainSize);
A = unifrnd(-1, 1, [TrainSize 1]);

% Find A
for i = 1 : 5
    Sigma = sigmoid(A);
    W = diag(Sigma.*(1-Sigma));
    A = Cov*inv(I + W*Cov)*(TrainTarget - Sigma + W*A);
    g = mean(TrainTarget-Sigma-inv(Cov)*A);
    disp(g);
end
Sigma = sigmoid(A);

%% Prediction
TestPred = zeros(size(TestTarget));
TestError = zeros(size(TestTarget));
k = zeros(size(TrainTarget));
c = 0;

Back = TrainTarget - Sigma;

for i = 1 : TestSize
    for r = 1 : TrainSize
        k(r) = GPRegressionKernel( ...
            TestSet(i, :), TrainSet(r, :), Theta, Eta);
    end        
    mu = k' * Back;
    TestPred(i) = sigmoid(mu);
end

TestPred(TestPred>=0.5) = 1;
TestPred(TestPred<0.5) = 0;
Error = numel(find(TestPred ~= TestTarget));
disp(1-Error/TestSize);
%% Show result
%% Prediction 2
ts = TrainSize;
TrainPred = zeros(ts, 1);
k = zeros(size(TrainTarget));
c = 0;

Back = TrainTarget - Sigma;

for i = 1 : ts
    for r = 1 : TrainSize
        k(r) = GPRegressionKernel( ...
            TrainSet(i, :), TrainSet(r, :), Theta, Eta);
    end        
    mu = k' * Back;
    TrainPred(i) = sigmoid(mu);
end
TrainPred(TrainPred>=0.5) = 1;
TrainPred(TrainPred<0.5) = 0;
Error = numel(find(TrainPred ~= TrainTarget(1:ts)));
disp(1-Error/TrainSize);