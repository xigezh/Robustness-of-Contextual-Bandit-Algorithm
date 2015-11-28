
csv_name1=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff0.csv');
csv_name2=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff0.2.csv');
csv_name3=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff0.4.csv');
csv_name4=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff0.6.csv');
csv_name5=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff0.8.csv');
csv_name6=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0_x_coeff1.csv');

rr1 = csvread(csv_name1);
rr2 = csvread(csv_name2);
rr3 = csvread(csv_name3);
rr4 = csvread(csv_name4);
rr5 = csvread(csv_name5);
rr6 = csvread(csv_name6);

rr = [rr1,rr2,rr3,rr4,rr5,rr6];

csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9x_coeff0.csv');
csv_name_optim_2=strcat('optimal_burden_0_0.2_0.9x_coeff0.2.csv');
csv_name_optim_3=strcat('optimal_burden_0_0.2_0.9x_coeff0.4.csv');
csv_name_optim_4=strcat('optimal_burden_0_0.2_0.9x_coeff0.6.csv');
csv_name_optim_5=strcat('optimal_burden_0_0.2_0.9x_coeff0.8.csv');
csv_name_optim_6=strcat('optimal_burden_0_0.2_0.9x_coeff1.csv');

optim_reward_1 = csvread(csv_name_optim_1);
optim_reward_2 = csvread(csv_name_optim_2);
optim_reward_3 = csvread(csv_name_optim_3);
optim_reward_4 = csvread(csv_name_optim_4);
optim_reward_5 = csvread(csv_name_optim_5);
optim_reward_6 = csvread(csv_name_optim_6);


optim_reward = [optim_reward_1(2),optim_reward_2(2),optim_reward_3(2),optim_reward_4(2),optim_reward_5(2),optim_reward_6(2)];

x_coeff = [repmat(0,1,length(rr(:,1))),repmat(0.2,1,length(rr(:,2))),repmat(0.4,1,length(rr(:,3))),repmat(0.6,1,length(rr(:,4))),repmat(0.8,1,length(rr(:,5))),repmat(1,1,length(rr(:,6)))];

boxplot(rr,x_coeff);
hold on
plot(optim_reward,'r:');
legend('optimal');

title('Average reward verse x_coefficient');
xlabel('x_coefficient');
ylabel('Average reward');

