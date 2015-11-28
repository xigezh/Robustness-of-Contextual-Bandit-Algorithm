function [ theta_star, lambda_star ] = tune_param20150726( mu_star, tau, p_explore, p_s, param_gs, param_fmin)
%calculate the tuning parameter lambda based:

%if the clinician wants an exploration probability p_explore for p_s*100
%percent of the context

%we should penalize the average reward with tuning parameter lambda

%this is for |A|=2

%bound for theta^Tg(s)
l_bound = fzero(@(x) logistic(x)-p_explore,0);

q_bound=l_bound^2*p_s;

% mu_star=[-10.565073960023
% 0.671933556258146
% 2.05378503773588
% 4.51288058798492
% 0.322730739385093
% 1.16445700663611
% -1.97068117933803
% -2.05999016945819
% -1.47900123458138
% -2.87075342314939
% 1.42153294068036
% 1.50601703044647
% 1.25758920868981]';



%[ theta_star, value_star, lambda, f_star ] = policy_population_lambda20150726( mu_star, q_bound, tau);

[ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150726( mu_star, q_bound, tau, param_gs, param_fmin);


end

