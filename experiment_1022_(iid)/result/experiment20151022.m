clear;
csv_name=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.csv');
value = csvread(csv_name);
optimal = csvread('optimal_burden_0_0.2_0.9.csv');
optimal_value = optimal(2);

boxplot(value);
hold on;
plot(1,optimal_value,'-bx','Markersize',12);