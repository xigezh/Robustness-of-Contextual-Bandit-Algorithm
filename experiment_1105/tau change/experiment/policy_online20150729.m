function [track_theta, track_mu, track_action, track_reward, r_feature_mat, p_feature_mat, context_mat, spec_hat ] = policy_online20150729( ...
    max_time, optim_time, lambda, mu_star, spec, param_gs, param_fmin, n_ms)

%online actor critic algorithm, finding optimal policy in reducing smoking
%rate

%start with ms and then use fmincon


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%empirical distribution of contexts are generated from data_id
%no more truncation of noise
%able to generate different reward distribution: r_dist, spec
%the dimension of theta remain fixed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read data from scrach
%emi_data=csvread('/scratch/stats_flux/ehlei/emi_data_emmy.csv');

%simulate evening indicator according to a deterministic sequence
%
% data_name=strcat('/scratch/stats_flux/ehlei/',data_id,'.csv');
% emi_data=csvread(data_name);
% %
% 
% [n,k]=size(emi_data);
% 
% %take only the first 1/3 of the data, only need to simulate fixmind and
% %smking mood
% n=n/3;

%new generative model where [s1,s2] ~N(0,[1,tau,tau,1])
%s3 ~N(0,1)

%ar(1) model 
%with burden


%includes
%id

    function [ a,prob ] = simu_action( theta, p_feature )
        %simulate action a
        %calculate the probability of action a=1 and a=0
        x=sum(theta.*p_feature);
        prob=[1-logistic(x),logistic(x)];
        a=rand<prob(2);
        
    end

    function [ r] = simu_reward(r_feature, mu_star, spec)
        
        r_mean=sum(r_feature.*mu_star);
        
        %simulate from normal distribution
        r=r_mean+normrnd(0,spec);
        
    end

%the value function

    function [ value ] = policy_value( theta, mu, i, lambda)
        
        prob_lin=theta*p_feature_mat(1:i,:)';
        %expected reward given a=1
        er1=mu*[ones(i,1),context_mat(1:i,:),ones(i,1),context_mat(1:i,:)]';
        %expected reward given a=0
        er0=mu*[ones(i,1),context_mat(1:i,:),zeros(i,p_dim)]';
        %value function
        value=mean(er1.*logistic(prob_lin)+er0.*logistic(-prob_lin))+lambda*theta*(p_feature_mat'*p_feature_mat/i)*theta';
        %derivative
        %deriv=(er1.*logistic_deriv(prob_lin)*p_feature_mat(1:i,:)+er0.*(-logistic_deriv(prob_lin))*p_feature_mat(1:i,:))/i+...
        %    2*lambda*theta*(p_feature_mat(1:i,:)'*p_feature_mat(1:i,:)/i);
        
    end


%include all the context in policy feature
p_dim=4;
r_dim=p_dim*2;

                             
                             
                            
A=zeros(r_dim,1);
B=eye(r_dim)*0.001;
%predictors and moderators
context_mat=zeros(max_time,p_dim-1);
%r_feature_mat=zeros(max_time,r_dim);

%dimension of policy feature
%[1,fixmind, smkmood, eve]
p_feature_mat=zeros(max_time,p_dim);
r_feature_mat=zeros(max_time,r_dim);

%track
track_mu=zeros(r_dim,max_time);
track_theta=zeros(p_dim,max_time);
track_action=zeros(1,max_time);


track_reward=zeros(1,max_time);
theta=zeros(1,p_dim);

%a matrix
%gs, multistart, fmincon
track_value=zeros(3,max_time);

% track_time=zeros(1,max_time);
%
% %track the gradient and hession of the solution found by fmincon
% track_grad=zeros(p_dim,max_time);
% %whether the hessian is positive definite
% track_hess=zeros(1,max_time);
% track_flag=zeros(1,max_time);
spec_hat=zeros(1,max_time);



%fmincon opts
opts = optimoptions(@fmincon,'Algorithm','interior-point','TolFun',param_fmin(1),'Display','off');
%global search opts
gs = GlobalSearch('NumStageOnePoints',param_gs(1),'NumTrialPoints',param_gs(2),'TolFun',param_gs(3),'TolX',param_gs(4));
ms = MultiStart;

%fmincon opts
lb=-ones(1,p_dim)*param_fmin(2);
ub=ones(1,p_dim)*param_fmin(2);


psi=normrnd(0,1,max_time,3);
mean_mat=[0,0,0];
cov_mat=[1,0.3,-0.3;0.3,1,-0.3;-0.3,-0.3,1];

x_initial=mvnrnd(mean_mat,cov_mat,1);
%x3=normrnd(0,1,max_time,1);

%p=unifrnd(0,1,max_time,1);

context = zeros(6,3);
for i=1:max_time
    %simulate context
    %mean zero, variance 1
        if i==1
            context=x_initial;
        else
            context=[context_mat(i-1,1)*0.4+psi(i,1),...
                context_mat(i-1,2)*0.25+0.8*a+ psi(i,2),...
                context_mat(i-1,3)*0.5+0.05*context_mat(i-1,3)*a+0.5*a+psi(i,3)];

        end
    
    %policy feature and simulate an action
    %p_feature=[1,fixmind,smkmood,eve];
    p_feature=[1,context];
    [a,~]=simu_action(theta,p_feature);
    %fprintf('simulated action at time %i is %i \n',i,a);
    track_action(i)=a;
    
    %reward feature and simulate a reward
    r_feature=[1, context, a, a*context];
    r=simu_reward(r_feature, mu_star,  spec);
    track_reward(i)=r;
    
    %fprintf('simulated reward at time %i is %f \n',i,r);
    %record predictors and moderators
    context_mat(i,:)=context;
    p_feature_mat(i,:)=p_feature;
    r_feature_mat(i,:)=r_feature;
    
    %update estimate of mu
    B=B+r_feature'*r_feature;
    A=A+r_feature'*r;
    mu=B\A;
    track_mu(:,i)=mu;
    %fprintf('estimated mu is \n');
    %disp(mu');
    
    %update the objective function
    f=@(theta) policy_value( theta, mu', i, lambda);
    
    
    %initial value
    if i==1
        theta0=zeros(1,p_dim);
    else
        theta0=track_theta(:,i-1)';
    end
    
    %global search only takes constraint optimizatio problem
    %provide a generous bound
    problem = createOptimProblem('fmincon','objective',f,'x0',theta0,...
        'lb',-ones(1,p_dim)*param_fmin(2),'ub',ones(1,p_dim)*param_fmin(2),'options',opts);
    
    
    
    %     %gs
    %     [theta,y1] = run(gs,problem);
    %     track_theta(:,i)=theta;
    %     track_value(1,i)=y1;
    
    
    %for the first 10 decision points, use random policy
    if i<=20
        [theta,y2]=run(ms,problem,n_ms);
        track_value(2,i)=y2;
        track_theta(:,i)=theta;
    elseif ismember(i,optim_time)
        [theta,y3]=fmincon(f,theta0,[],[],[],[],lb,ub,[],opts);
        track_value(3,i)=y3;
        track_theta(:,i)=theta;
    end
    
    
    
    
    
    %estimate spec
    if i>=10
        %estimate the standard deviation
        spec_hat(i)=sqrt((track_reward(1:i)-mu'*r_feature_mat(1:i,:)')*(track_reward(1:i)-mu'*r_feature_mat(1:i,:)')'/(i-r_dim));
    end
    
 %for j = 1: p_dim
 %  theta_plot(j,i) = theta(j);
 %end
end

%i=1:max_time;
%figure(1);
%plot(i,theta_plot(1,i));

%figure(2);
%plot(i,theta_plot(2,i));

%figure(3);
%plot(i,theta_plot(3,i));

%figure(4);
%plot(i,theta_plot(4,i));

end

