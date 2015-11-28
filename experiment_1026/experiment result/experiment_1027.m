csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9x_coeff0.csv');
csv_name_optim_2=strcat('optimal_burden_0_0.2_0.9x_coeff0.2.csv');
csv_name_optim_3=strcat('optimal_burden_0_0.2_0.9x_coeff0.4.csv');
csv_name_optim_4=strcat('optimal_burden_0_0.2_0.9x_coeff0.6.csv');
csv_name_optim_5=strcat('optimal_burden_0_0.2_0.9x_coeff0.8.csv');
csv_name_optim_6=strcat('optimal_burden_0_0.2_0.9x_coeff1.csv');

optim_theta_1 = csvread(csv_name_optim_1);
optim_theta_2 = csvread(csv_name_optim_2);
optim_theta_3 = csvread(csv_name_optim_3);
optim_theta_4 = csvread(csv_name_optim_4);
optim_theta_5 = csvread(csv_name_optim_5);
optim_theta_6 = csvread(csv_name_optim_6);

optim_theta = [optim_theta_1(:,3:6);optim_theta_1(:,3:6);optim_theta_1(:,3:6);optim_theta_1(:,3:6);optim_theta_1(:,3:6);optim_theta_1(:,3:6)];

csv_name1=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff0.csv');
csv_name2=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff0.2.csv');
csv_name3=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff0.4.csv');
csv_name4=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff0.6.csv');
csv_name5=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff0.8.csv');
csv_name6=strcat('online_exp_btsrp_burden_theta_200_0.2_0.9_0_x_coeff1.csv');

theta_exp_1 = csvread(csv_name1);
theta_exp_2 = csvread(csv_name2);
theta_exp_3 = csvread(csv_name3);
theta_exp_4 = csvread(csv_name4);
theta_exp_5 = csvread(csv_name5);
theta_exp_6 = csvread(csv_name6);

exp_mean_theta = [mean(theta_exp_1);mean(theta_exp_2);mean(theta_exp_3);mean(theta_exp_4);mean(theta_exp_5);mean(theta_exp_6)];
bias = exp_mean_theta - optim_theta;


theta_11 = theta_exp_1(:,1);
p11 = length(theta_11(theta_11>0))/length(theta_11);
theta_12 = theta_exp_1(:,2);
p12 = length(theta_12(theta_12>0))/length(theta_12);
theta_13 = theta_exp_1(:,3);
p13 = length(theta_13(theta_13>0))/length(theta_13);
theta_14 = theta_exp_1(:,4);
p14 = length(theta_14(theta_14>0))/length(theta_14);

right_result_perc1 = [p11,p12,p13,p14];

theta_21 = theta_exp_2(:,1);
p21 = length(theta_21(theta_21>0))/length(theta_21);
theta_22 = theta_exp_2(:,2);
p22 = length(theta_22(theta_22>0))/length(theta_22);
theta_23 = theta_exp_2(:,3);
p23 = length(theta_23(theta_23>0))/length(theta_23);
theta_24 = theta_exp_2(:,4);
p24 = length(theta_24(theta_24>0))/length(theta_24);

right_result_perc2 = [p21,p22,p23,p24];

theta_31 = theta_exp_3(:,1);
p31 = length(theta_31(theta_31>0))/length(theta_31);
theta_32 = theta_exp_3(:,2);
p32 = length(theta_32(theta_32>0))/length(theta_32);
theta_33 = theta_exp_3(:,3);
p33 = length(theta_33(theta_33>0))/length(theta_33);
theta_34 = theta_exp_3(:,4);
p34 = length(theta_34(theta_34>0))/length(theta_34);

right_result_perc3 = [p31,p32,p33,p34];

theta_41 = theta_exp_4(:,1);
p41 = length(theta_41(theta_41>0))/length(theta_41);
theta_42 = theta_exp_4(:,2);
p42 = length(theta_42(theta_42>0))/length(theta_42);
theta_43 = theta_exp_4(:,3);
p43 = length(theta_43(theta_43>0))/length(theta_43);
theta_44 = theta_exp_4(:,4);
p44 = length(theta_44(theta_44>0))/length(theta_44);

right_result_perc4 = [p41,p42,p43,p44];

theta_51 = theta_exp_5(:,1);
p51 = length(theta_51(theta_51>0))/length(theta_51);
theta_52 = theta_exp_5(:,2);
p52 = length(theta_52(theta_52>0))/length(theta_52);
theta_53 = theta_exp_5(:,3);
p53 = length(theta_53(theta_53>0))/length(theta_53);
theta_54 = theta_exp_5(:,4);
p54 = length(theta_54(theta_54>0))/length(theta_54);

right_result_perc5 = [p51,p52,p53,p54];

theta_61 = theta_exp_6(:,1);
p61 = length(theta_61(theta_61>0))/length(theta_61);
theta_62 = theta_exp_6(:,2);
p62 = length(theta_62(theta_62>0))/length(theta_62);
theta_63 = theta_exp_6(:,3);
p63 = length(theta_63(theta_63>0))/length(theta_63);
theta_64 = theta_exp_6(:,4);
p64 = length(theta_64(theta_64>0))/length(theta_64);

right_result_perc6 = [p61,p62,p63,p64];

percentage =[right_result_perc1;right_result_perc2;right_result_perc3;right_result_perc4;right_result_perc5;right_result_perc6];

exp_mean_theta
percentage
bias