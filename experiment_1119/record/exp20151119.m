max_time = 200;
spec = 1;
param_gs=[100,500,1e-3,1e-3];
param_fmin=[1e-3,10];
n_ms = 20;
p_explore=0.2;
p_s=0.9;
optim_gap=1;

% change n_simu to 100 and change tau
n_simu=100;
tau=0;

mu_star=[10 -1 0 0 -0.25 -0.25 -0.4 0];


%[ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150729( mu_star,tau, p_explore,p_s, param_fmin, n_ms, n, seed)


online_exp_burden20151009(p_explore, p_s, max_time, tau, spec, param_gs, param_fmin, n_simu, n_ms, optim_gap)

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
