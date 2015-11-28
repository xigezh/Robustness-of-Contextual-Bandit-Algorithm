max_time = 200;
spec = 1;
param_gs=[100,500,1e-3,1e-3];
param_fmin=[1e-3,10];
n_ms = 20;
p_explore=0.2;
p_s=0.9;
optim_gap=1;
seed = 123456;
n = 10000;
%n = 10;
% change n_simu to 100 and change tau
n_simu=100;

mu_star=[10 -1 0 0 -0.25 -0.25 -0.4 0];

tau_vec = [0,0.2,0.4,0.6,0.8];

for i = 1:5
    tau = tau_vec(i);
    % calculate the optimal vaules 
    [ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150729( mu_star,tau, p_explore,p_s, param_fmin, n_ms, n, seed)
    online_exp_burden20151009(p_explore, p_s, max_time, tau, spec, param_gs, param_fmin, n_simu, n_ms, optim_gap)

end



%draw boxplot

csv_name1=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.csv');
csv_name2=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.2.csv');
csv_name3=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.4.csv');
csv_name4=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.6.csv');
rr1 = csvread(csv_name1);
rr2 = csvread(csv_name2);
rr3 = csvread(csv_name3);
rr4 = csvread(csv_name4);
rr = [rr1,rr2,rr3,rr4];
csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9.csv');
csv_name_optim_2=strcat('optimal_burden_0.2_0.2_0.9.csv');
csv_name_optim_3=strcat('optimal_burden_0.4_0.2_0.9.csv');
csv_name_optim_4=strcat('optimal_burden_0.6_0.2_0.9.csv');

optim_reward_1 = csvread(csv_name_optim_1);
optim_reward_2 = csvread(csv_name_optim_2);
optim_reward_3 = csvread(csv_name_optim_3);
optim_reward_4 = csvread(csv_name_optim_4);

optim_reward = [optim_reward_1(2),optim_reward_2(2),optim_reward_3(2),optim_reward_4(2)];

tau = [repmat(0,1,length(rr(:,1))),repmat(0.2,1,length(rr(:,2))),repmat(0.4,1,length(rr(:,2))),repmat(0.6,1,length(rr(:,2)))];
boxplot(rr,tau);
hold on
plot(optim_reward,'r:');
legend('optimal');

title('Average Cost verse tau');
xlabel('tau');
ylabel('Average Cost');

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
