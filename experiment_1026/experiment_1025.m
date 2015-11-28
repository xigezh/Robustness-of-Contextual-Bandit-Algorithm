max_time = 200;
optim_time = 10:10:max_time;
%lambda = 0.159375;
mu_star = [10,-1,0,0.4,-0.25,-0.25,-0.4,0];
tau = 0;
spec = 1;
param_gs=[100,500,1e-3,1e-3];
param_fmin=[1e-3,10];
n_ms = 20;
n = 10000;



p_explore=0.2;
p_s=0.9;
%calculate the population optimal policy
l_bound = fzero(@(x) logistic(x)-p_explore,0);

q_bound=l_bound^2*p_s;

% First run the population policy and get lambda = 0.159375 and the
% population theta [-0.000452 0.613548 -0.492724 0.001116]. Plug the lambda
% into the experiment with various rng seed

% comment out the population run
[ theta_star, value_star, lambda, f_star ] = policy_population_lambda20151021( mu_star, q_bound, tau, param_gs, param_fmin);


% experiment1 to 3 
% rng(999);
% rng(34234);
% rng(92343214);

%run online actor critc
%[track_theta, track_mu, track_action, track_reward, r_feature_mat, p_feature_mat, context_mat, spec_hat ] = policy_online20150726( ...
%    max_time, optim_time, lambda, mu_star, tau, spec ,param_gs, param_fmin, n_ms);

% Under seed 999, theta = [0.05,0.65,-0.55,0.00]
% change seed and run actor critic again

% Under 34234, theta = [0.01,0.65,-0.55,0.01]
% Under 92343214, theta = [0.00,0.55,-0.50,0.01]
