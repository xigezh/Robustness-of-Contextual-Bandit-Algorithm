

function [ value ] = policy_value_burden20150729( theta, mu, lambda, n, seed)

%policy value when burden effect presents

rng(seed);

psi=normrnd(0,1,n,3);
mean_mat=[0,0,0];
cov_mat=[1,0.3,-0.3;0.3,1,-0.3;-0.3,-0.3,1];

x_initial=mvnrnd(mean_mat,cov_mat,1);

p=unifrnd(0,1,n,1);


r_dim=8;
p_dim=4;
k=p_dim-1;

m=n*0.9;
%simulate stationary distribution under policy pi_theta


emi_data=zeros(n,3);
emi_data(1,:)=x_initial;


for i=2:n
    a=(logistic(theta*[1,emi_data(i-1,:)]')<p(i));
    emi_data(i,1)=emi_data(i-1,1)*0.4+psi(i,1);
    emi_data(i,2)=emi_data(i-1,2)*0.25+ 0.8*a + psi(i,2);
    emi_data(i,3)=emi_data(i-1,3)*0.5+0.05*emi_data(i-1,3)*a+0.5*a+psi(i,3);
end

%delete the first 1/10
emi_data_use=emi_data((n*0.1+1):n,:);


r_feature_mat1=[ones(m,1),emi_data_use,ones(m,1),emi_data_use];

r_feature_mat0=[ones(m,1),emi_data_use,zeros(m,k+1)];

%policy features
%this version include all context in the policy feature
p_feature_mat=[ones(m,1),emi_data_use];
prob_lin=theta*p_feature_mat';
%expected reward given a=1
er1=mu*r_feature_mat1';
%expected reward given a=0
er0=mu*r_feature_mat0';
%value function
value=mean(er1.*logistic(prob_lin)+er0.*logistic(-prob_lin))+lambda*theta*(p_feature_mat'*p_feature_mat/m)*theta';
%derivative
% deriv=(er1.*logistic_deriv(prob_lin)*p_feature_mat+er0.*(-logistic_deriv(prob_lin))*p_feature_mat)/m+...
%     2*lambda*theta*(p_feature_mat'*p_feature_mat/m);
%hess=((repmat(er1.*logistic_hess(prob_lin),p_dim,1).*p_feature_mat')*p_feature_mat+(repmat(er0.*(logistic_hess(-prob_lin)),p_dim,1).*p_feature_mat')*p_feature_mat)/m+...
%   2*lambda*(p_feature_mat'*p_feature_mat/m);

end