%% Use precomputed kernels from Amazon reviews
load 'kernels.mat'
kernels = {unigram_kernel, bigram_kernel, trigram_kernel};
n = size(unigram_kernel, 1);

%% Generate random kernels
n = 10;
A = rand(n, n);
B = 2*rand(n, n);
C = 3*rand(n, n);
kernels = {A'*A, B'*B, C'*C};

%% Use precomputed kernels from scikit-learn newsgroup dataset

%% Solve the primal problem
p = 10;
rho = 100;

[K, D] = eigs(kernels{1}, p);
for i = 1:size(K, 2)
    K(:,i) = K(:,i) * sqrt(D(i,i));
end
for i = 2:size(kernels, 2)
    [V, D] = eigs(kernels{i}, p);
    for i = 1:size(V,2)
        V(:,i) = V(:,i) * sqrt(D(i,i));
    end
    K = [K, V];
end

m = size(K, 2);

cvx_begin
    variable lambda(m+1, 1)
    
    minimize ( trace_inv(combined_kernel(lambda, K, rho)) )
    
    sum(lambda) == 1;
    lambda >= 0;
    
cvx_end

bar(lambda)