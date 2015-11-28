function [ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150726( mu_star, q_bound, tau, param_gs, param_fmin)
%find the best populational best policy: varying lambda

n=5000;
mean_mat=[0,0];
cov_mat=[1,tau;tau,1];
emi_data=zeros(n,3);

emi_data(:,1:2)=mvnrnd(mean_mat,cov_mat,n);
%eve=binornd(1,1/3,[n,1]);

emi_data(:,3)=normrnd(0,1,n,1);

    

[n,k]=size(emi_data);

r_feature_mat1=[ones(n,1),emi_data,ones(n,1),emi_data];
r_feature_mat0=[ones(n,1),emi_data,zeros(n,k+1)];

p_feature_mat=[ones(n,1),emi_data];



    function [ value, deriv ] = policy_value( theta, lambda)
        
        prob_lin=theta*p_feature_mat';
        %expected reward given a=1
        er1=mu_star*r_feature_mat1';
        %expected reward given a=0
        er0=mu_star*r_feature_mat0';
        %value function
        value=mean(er1.*logistic(prob_lin)+er0.*logistic(-prob_lin))+lambda*theta*(p_feature_mat'*p_feature_mat/n)*theta';
        %derivative
        deriv=(er1.*logistic_deriv(prob_lin)*p_feature_mat+er0.*(-logistic_deriv(prob_lin))*p_feature_mat)/n+...
            2*lambda*theta*(p_feature_mat'*p_feature_mat/n);
        
    end

%make a function wrapper for the unconstraint optimization problem, for
%fixed lambda
    function [sat, theta] = solve_theta(lambda, q_bound)
        f=@(theta) policy_value( theta,lambda);
        %opts = optimoptions(@fmincon,'Algorithm','interior-point');
        problem = createOptimProblem('fmincon','objective',f,'x0',theta0,...
        'lb',-ones(1,4)*param_fmin(2),'ub',ones(1,4)*param_fmin(2),'options',opts);
        %gs = GlobalSearch;
        %solve the unconstraint problem
        [theta,y] = run(gs,problem);
        
        %test whether the constraint is satisfied
        sat= theta*(p_feature_mat'*p_feature_mat/n)*theta' <= q_bound + tol;
    end

    function [ x, lambda ] = find_lambda (intv)
        fprintf('start with search interval for lambda [ %f, %f] \n',intv);
        
        %test the lower intv
        while solve_theta(intv(1), q_bound)==1 && intv(1)>0
            %lower the entire interval
            width=intv(2)-intv(1);
            intv(2)=intv(1);
            intv(1)=max(0,intv(2)-width);
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
        end
        
        %test the upper intv
        while solve_theta(intv(2), q_bound)==0
            %higher the entire interval
            width=intv(2)-intv(1);
            intv(1)=intv(2);
            intv(2)=intv(1)+width;
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
        end
        
        %start binary search
        width=intv(2)-intv(1);
        [sat,x]=solve_theta((intv(2)+intv(1))/2, q_bound);
        
        while width>= eps
            if sat==1
                %the lower half interval
                intv(2)=intv(1)+width/2;
            else
                intv(1)=intv(2)-width/2;
            end
            width=intv(2)-intv(1);
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
            [sat,x]=solve_theta((intv(2)+intv(1))/2, q_bound);
        end
        
        lambda=(intv(2)+intv(1))/2;
        
    end
%tolerance in search for lambda
eps=1e-2;
tol=1e-3;

theta0=zeros(1,4);

opts = optimoptions(@fmincon,'Algorithm','interior-point','TolFun',param_fmin(1),'Display','off');
gs = GlobalSearch('NumStageOnePoints',param_gs(1),'NumTrialPoints',param_gs(2),'TolFun',param_gs(3),'TolX',param_gs(4));

[ theta_star, lambda_star ] = find_lambda ([0.1,0.5]);

fprintf('At lambda %f ,true optimal theta is [%f %f %f %f] \n', lambda_star,theta_star);

f_star=@(theta) policy_value( theta,lambda_star);
value_star=f_star(theta_star);

end

