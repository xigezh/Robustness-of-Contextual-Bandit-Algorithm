%%%%%%%%%%%%%
max_time = 1000;
%max_time = 10;
spec = 1;
param_gs=[100,500,1e-3,1e-3];
param_fmin=[1e-3,10];
n_ms = 20;
p_explore=0.2;
p_s=0.9;
optim_gap=1;
%%%%%%%%%%%%%%
n =10000;
%n = 100;

%%%%%%%%%%%%%%%
n_simu=100;
%n_simu=10;
tau_mat=[0.2,0.4,0.6];

tau_length = length(tau_mat);




%[ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150729( mu_star,tau, p_explore,p_s, param_fmin, n_ms, n, seed)

for i = 1:tau_length
    
    tau = tau_mat(i);
    mu_star=[10 -1 0 tau -0.25 -0.25 -0.4 0];

online_exp_burden20151009(p_explore, p_s, max_time, tau, spec, param_gs, param_fmin, n_simu, n_ms, optim_gap);

end
% tau = 0, 0.2, 0.4, 0.6
% then change max_time = 500, tau = 0, 0.2, 0.4, 0.6

% draw a boxplot, extract data from the last file created: average reward
% verse value of tau.
% the optimal value line is the 2nd column in optimal_burden_tau_ ... cvs
% files. Add it to the boxplot
% need functions:
% online_exp_burden20151009
% policy_oline20150729
% policy_value_burden20150729
% optimal_burden_0_0.2_0.9.cvs files
% logistic files
