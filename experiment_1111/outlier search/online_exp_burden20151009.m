function []=online_exp_burden20151009(p_explore, p_s, max_time, tau, spec, param_gs, param_fmin, n_simu, n_ms, optim_gap)

% Put these in the output box
%theta_traj, mu_traj, value_traj





%use matlab 2015a version



%bootstrap performance in the online setting:

%bootstrap the context
%bootstrap the residuals
%bootstrap the actions using theta_hat

%no cheating optimization

%using data generative model from Katie
%hopefully this code can deal with different kinds of generative model
%where the dimension of contexts may vary, or the "linearity" of reward may
%be false. 


%uodate to 20150714b: using the short confidence interval in percentile t
%and efron
%embedded function

%update to 20140716b: run ac to get bootstrap sample 

%update to 20150717: only one check_time

%update to 20150722: eve simulated according to mod(i,3)==0, use 

%update to 20150725: bootstrap the context

%update to 20150726: continous context %new generative model where [s1,s2] ~N(0,[1,tau,tau,1])
%s3 evening indicator

%ar(1)
%with burden

%update to 20150729: ignore ci, only focus on the policy value


%%%%%%%%%%%***revise***%%%%%%%%%%%%%
%mu_name=strcat('home/ehlei/ac_simulation/',mu_star_file,'.csv');
mu_star=[10 -1 0 tau -0.25 -0.25 -0.4 0];
ci_alpha=0.05;


p_dim=4;
r_dim=8;
% x_coeff = [0,0.2,0.4,0.6,0.8,1];
% length_coeff = 6;
% for j = 1: length_coeff
%     x_co = x_coeff(j);
x_co = 1;

%once the population quantities are calculated (on a different task)
%read the results
csv_name=strcat('optimal_burden_', num2str(tau),'_',num2str(p_explore),'_',num2str(p_s),'x_coeff',num2str(x_co),'.csv');

rr=csvread(csv_name);
lambda=rr(1);
% population level average reward
value_star=rr(2);
theta_star=rr(3:6);


%max_time=200;
%n_simu=500;

%track coverage for theoretical CIs
%theo_mu=zeros(1,n_simu);
%theo_theta=zeros(1,n_simu);
alpha=0.05;
%track_seed=zeros(1,n_simu);



check_time=max_time;
n_time=1;
% mean square error
mu_mse=zeros(n_time,r_dim,n_simu);
% real_mu - experiment_mu
mu_bias=zeros(n_time,r_dim,n_simu);
mu_record=zeros(n_time,r_dim,n_simu);

theta_mse=zeros(n_time,p_dim,n_simu);
theta_bias=zeros(n_time,p_dim,n_simu);
theta_record=zeros(n_time,p_dim,n_simu);

%
spec_record=zeros(n_time,n_simu);

value_record=zeros(n_simu,n_time);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theta_traj = zeros(max_time,p_dim,n_simu);
mu_traj = zeros(max_time,r_dim,n_simu);
value_traj = zeros(n_simu,max_time);
r_feature_traj = zeros(max_time,r_dim,n_simu);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%var_theta_theo=var_theory20141215(mu_star, theta_star, lambda, noise);


%start parallel
 %sched = findResource('scheduler', 'type', 'mpiexec')
 %set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
 %set(sched, 'EnvironmentSetMethod', 'setenv')
 %use the 'sched' object when calling matlabpool
 %the size of the pool (16) should equal ppn in PBS
 %matlabpool (sched, n_core)

 n_core = str2double(getenv('PBS_NP'));
 myPool = parpool('current', n_core);

%if isempty(getenv('PBS_NP'))
%     n_core = 4;
%else
%     n_core = str2double(getenv('PBS_NP'));
%end


optim_time=optim_gap:optim_gap:max_time;


parfor i=1:n_simu
    
    fprintf('simulation number %i \n\n',i);
    %seed=34323*i;
    seed=100*i;
    rng(seed);


    %[track_theta, track_mu, track_action, track_reward, r_feature_mat, ~, context_mat, spec_hat ] = policy_online20150725( ...
    %max_time, optim_time, lambda, mu_star, r_dist, spec,data_id, seed ,param_gs, param_fmin, n_ms);
    [track_theta, track_mu, track_action, track_reward, r_feature_mat, p_feature_mat, context_mat, spec_hat ] = policy_online20150729( ...
    max_time, optim_time, lambda, mu_star, spec, param_gs, param_fmin, n_ms,x_co,seed);

    theta_traj(:,:,i) = track_theta';
    mu_traj(:,:,i) = track_mu';
    value_traj(i,:) = track_reward;
    r_feature_traj(:,:,i) = r_feature_mat;



    %track estimated theta and mu
    theta=track_theta(:,check_time)';
    mu=track_mu(:,check_time)';
    
    theta_record(:,:,i)=theta;
    mu_record(:,:,i)=mu;
    
    %flag_record(:,i)=track_flag(check_time);
    
    %calculate bias and mse for mu
    mu_mse(:,:,i)=(mu-repmat(mu_star,n_time,1)).^2;
    mu_bias(:,:,i)=mu-repmat(mu_star,n_time,1);
    
    %calculate bias and mse for theta
    theta_mse(:,:,i)=(theta-repmat(theta_star,n_time,1)).^2;
    theta_bias(:,:,i)=theta-repmat(theta_star,n_time,1);
    
    %estimated noise
    spec_record(:,i)=spec_hat(check_time)';
    
    
    value_record(i)=policy_value_burden20150729( x_co,theta, mu_star, lambda, 50000, 999);


end

delete(myPool);

[num] = max(value_record(:));
[outlier_i] = ind2sub(size(value_record),find(value_record==num));

median = median(value_record(:));
[median_is] = ind2sub(size(value_record),find(value_record==median));
median_i = median_is(1);

% theta_traj(:,:,i) = track_theta';
% mu_traj(:,:,i) = track_mu';
% value_traj(i,:) = track_reward;
% r_feature_traj(:,:,i) = r_feature_mat;

%outlier inference
outlier_reward_traj = value_traj(outlier_i,:);
outlier_mu_traj = mu_traj(:,:,outlier_i);%% max_time,r_dim
outlier_theta_traj = theta_traj(:,:,outlier_i); %% 200,4
outlier_r_feature_traj = r_feature_traj(:,:,outlier_i); % max_time, r_dim

theta_1 = outlier_theta_traj(:,1);
theta_2 = outlier_theta_traj(:,2);
theta_3 = outlier_theta_traj(:,3);
theta_4 = outlier_theta_traj(:,4);




%normal set inference
norm_reward_traj = value_traj(median_i,:);
norm_mu_traj = mu_traj(:,:,median_i);%% max_time,r_dim
norm_theta_traj = theta_traj(:,:,median_i); %% 200,4
norm_r_feature_traj = r_feature_traj(:,:,median_i); % max_time, r_dim

norm_theta_1 = norm_theta_traj(:,1);
norm_theta_2 = norm_theta_traj(:,2);
norm_theta_3 = norm_theta_traj(:,3);
norm_theta_4 = norm_theta_traj(:,4);



%track the trajectory of noise of reward (outlier & normal)
outlier_reward_traj_noise = abs(outlier_reward_traj - value_star);
norm_reward_traj_noise = abs(norm_reward_traj - value_star);

%track the final values with the ith run

mu_final = outlier_mu_traj(check_time,:);
track_final = [outlier_reward_traj(check_time), mu_final, theta_1(check_time), theta_2(check_time), theta_3(check_time), theta_4(check_time)];
csvwrite('check outlier convergence',track_final);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%draw trajectory of reward, mu and theta.
figure(1);
fig1 = plot(outlier_reward_traj);
legend;
xlabel('time');
ylabel('cost');
title('outlier cost trajectory');
saveas(fig1,'outlier_cost_traj.jpg');

figure(2);
color1 = ['-b','-r','-g','-m'];
plot(theta_1,color1(1));
hold on;
plot(theta_2,color1(2));
hold on;
plot(theta_3,color1(3));
hold on;
plot(theta_4,color1(4));
hold on;
legend;
xlabel('time');
ylabel('theta');
title('outlier theta trajectory');
fig2 = figure(2);
saveas(fig2,'outlier_theta_traj.jpg');

figure(3);
color2 = ['-b','-r','-g','-m','-c','-y','-k','-b'];
for i = 1:r_dim
fig3 = plot(outlier_mu_traj(:,i),color2(i));
    hold on;
end
legend;
xlabel('time');
ylabel('mu');
title('outlier mu trajectory');
saveas(fig3,'outlier_mu_traj.jpg');

figure(4);
color4 = ['-b','-r']
plot(outlier_reward_traj_noise, color4(1));
hold on;
plot(norm_reward_traj_noise, color4(2));
legend('outlier','median');
xlabel('time');
ylabel('noise (reward)');
title('outlier reward noise trajectory');
fig4 = figure(4);
saveas(fig4,'outlier_vs_norm_reward_cost.jpg');

figure(5);
color5 = ['-b','-r','-g','-m','-c','-y','-k','-b'];
for i = 1:r_dim
fig5 = plot(norm_mu_traj(:,i),color5(i));
hold on;
end
legend;
xlabel('time');
ylabel('mu');
title('normal data mu trajectory');
saveas(fig5,'normal_mu_traj.jpg');




% correlation of [1 s a sa]
cor_r_feature = corrcoef(outlier_r_feature_traj);
csvwrite('correlation_r_feature.csv',cor_r_feature);

% condition number of r_feature_mat
condi_num = cond(outlier_r_feature_traj);
sqrt_condi_num = sqrt(condi_num);
csvwrite('sqrt condition num of r_feature',sqrt_condi_num);






%write output to file
%theta
t_record=permute(theta_record,[3,2,1]);
theta_file_name=strcat('online_exp_btsrp_burden_theta_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
    '_',num2str(tau),'x_coeff',num2str(x_co),'.csv');
csvwrite(theta_file_name,t_record);


%mu
m_record=permute(mu_record,[3,2,1]);
mu_file_name=strcat('online_exp_btsrp_burden_mu_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
    '_',num2str(tau),'x_coeff',num2str(x_co),'.csv');
csvwrite(mu_file_name,m_record);

%value
value_file_name=strcat('online_exp_btsrp_burden_value_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
    '_',num2str(tau),'x_coeff',num2str(x_co),'.csv');
csvwrite(value_file_name,value_record);


end

%end




