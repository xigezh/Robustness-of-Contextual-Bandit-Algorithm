n = 100;
x_coeff = [0,0.2,0.4,0.6,0.8,1];
length_coeff = 6;
p=unifrnd(0,1,n,1);

psi=normrnd(0,1,n,3);
mean_mat=[0,0,0];
cov_mat=[1,0.3,-0.3;0.3,1,-0.3;-0.3,-0.3,1];
x_initial=mvnrnd(mean_mat,cov_mat,1);
x_co = 1;

csv_name_optim=strcat('optimal_burden_0_0.2_0.9x_coeff',num2str(x_co),'.csv'); 
optim_theta = csvread(csv_name_optim);
population_theta = optim_theta(:,3:6);

csv_name_exp=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff',num2str(x_co),'.csv');
exp_theta = csvread(csv_name_exp);
experiment_theta = exp_theta(100,:);

context_mat=zeros(n,3);
context_mat(1,:)=x_initial;



for i=2:n
    a=(logistic(population_theta*[1,context_mat(i-1,:)]')<p(i));
    context_mat(i,1)=context_mat(i-1,1)*0.4+psi(i,1);
    context_mat(i,2)=context_mat(i-1,2)*0.25+ 0.8*a*x_co + psi(i,2);
    context_mat(i,3)=context_mat(i-1,3)*0.5+0.05*context_mat(i-1,3)*a*x_co+0.5*a*x_co+psi(i,3);
end

context_popu = [repmat(1,n,1),context_mat];

for i=2:n
    a=(logistic(experiment_theta*[1,context_mat(i-1,:)]')<p(i));
    context_mat(i,1)=context_mat(i-1,1)*0.4+psi(i,1);
    context_mat(i,2)=context_mat(i-1,2)*0.25+ 0.8*a*x_co + psi(i,2);
    context_mat(i,3)=context_mat(i-1,3)*0.5+0.05*context_mat(i-1,3)*a*x_co+0.5*a*x_co+psi(i,3);
end
context_exp = [repmat(1,n,1),context_mat];

population_policy = logistic(context_popu*population_theta');
experiment_policy = logistic(context_exp*experiment_theta');

histogram(population_policy,25)
hold on
histogram(experiment_policy,25)
legend('population','experiement')
title('x_coefficient is 1')

