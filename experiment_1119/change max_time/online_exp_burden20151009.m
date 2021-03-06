function []=online_exp_burden20151009(p_explore, p_s, max_time, tau, spec, param_gs, param_fmin, n_simu, n_ms, optim_gap)


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

x_coeff = [0,0.6,1];
length_coeff = 3;
for j = 1: length_coeff
x_co = x_coeff(j);

%%%%%%%%%%%***revise***%%%%%%%%%%%%%
%mu_name=strcat('home/ehlei/ac_simulation/',mu_star_file,'.csv');
mu_star=[10 -1 0 tau -0.25 -0.25 -0.4 0];
ci_alpha=0.05;


p_dim=4;
r_dim=8;

%once the population quantities are calculated (on a different task)
%read the results
csv_name=strcat('optimal_burden_', num2str(tau),'_',num2str(p_explore),'_',num2str(p_s),'x_coeff',num2str(x_coeff(j)),'.csv');

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_time_mat = [200,400,600,800,max_time];
%check_time_mat=[2,4,6,8,max_time];
n_time=5;
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

value_record = zeros(n_simu,n_time);

value_record1=zeros(n_simu,1);
value_record2=zeros(n_simu,1);
value_record3=zeros(n_simu,1);
value_record4=zeros(n_simu,1);
value_record5=zeros(n_simu,1);


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


    [track_theta, track_mu, track_action, track_reward, r_feature_mat, p_feature_mat, context_mat, spec_hat ] = policy_online20150729( ...
    max_time, optim_time, lambda, mu_star, spec, param_gs, param_fmin, n_ms,x_co);



    check_time1 = check_time_mat(1);
    check_time2 = check_time_mat(2);
    check_time3 = check_time_mat(3);
    check_time4 = check_time_mat(4);
    check_time5 = check_time_mat(5);


    %track estimated theta and mu
    theta1=track_theta(:,check_time1)';
    theta2=track_theta(:,check_time2)';
    theta3=track_theta(:,check_time3)';
    theta4=track_theta(:,check_time4)';
    theta5=track_theta(:,check_time5)';

    %mu=track_mu(:,check_time1)';
    
    %theta_record(1,:,i)=theta;

    %mu_record(1,:,i)=mu;
    
    %flag_record(:,i)=track_flag(check_time1);
    

    
    %calculate bias and mse for theta
    %theta_mse(1,:,i)=(theta-repmat(theta_star,n_time,1)).^2;
    %theta_bias(1,:,i)=theta-repmat(theta_star,n_time,1);
    
    %estimated noise
    %spec_record(time,i)=spec_hat(check_time)';
    
    
    value_record1(i)=policy_value_burden20150729( x_co,theta1, mu_star, lambda, 50000, 999);
    value_record2(i)=policy_value_burden20150729( x_co,theta2, mu_star, lambda, 50000, 999);
    value_record3(i)=policy_value_burden20150729( x_co,theta3, mu_star, lambda, 50000, 999);
    value_record4(i)=policy_value_burden20150729( x_co,theta4, mu_star, lambda, 50000, 999);
    value_record5(i)=policy_value_burden20150729( x_co,theta5, mu_star, lambda, 50000, 999);

end

delete(myPool);


value_record = [value_record1, value_record2, value_record3, value_record4, value_record5];

%write output to file
%theta
%t_record=permute(theta_record,[3,2,1]);
%theta_file_name=strcat('online_exp_btsrp_burden_theta_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
 %   '_',num2str(tau),'_x_coeff',num2str(x_coeff(j)),'.csv');
%csvwrite(theta_file_name,t_record);


%mu
%m_record=permute(mu_record,[3,2,1]);
%mu_file_name=strcat('online_exp_btsrp_burden_mu_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
 %   '_',num2str(tau),'_x_coeff',num2str(x_coeff(j)),'.csv');
%csvwrite(mu_file_name,m_record);

%value
%value_file_name=strcat('online_exp_btsrp_burden_value_',num2str(max_time), '_', num2str(p_explore),'_',num2str(p_s),...
 %   '_',num2str(tau),'_x_coeff',num2str(x_coeff(j)),'.csv');
%csvwrite(value_file_name,value_record);

filename = strcat('value_x_coeff_is',num2str(x_coeff(j)),'.csv');
csvwrite(filename,value_record);


end


end




