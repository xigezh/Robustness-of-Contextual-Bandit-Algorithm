function [ theta_star, value_star, lambda_star, f_star ] = policy_population_lambda20150729( mu_star,tau, p_explore,p_s, param_fmin, n_ms, n, seed)
%find the best populational best policy: varying lambda

%AR 1 model where

%with burden

%change the burden effect
mu_star(4)=tau;

p_dim=4;
r_dim=8;

param_gs=[100,500,1e-3,1e-3];
param_fmin=[1e-3,10];


%find lambda
[ ~,lambda ] = tune_param20150726( mu_star, tau, p_explore, p_s, param_gs, param_fmin);
l_bound = fzero(@(x) logistic(x)-p_explore,0);

q_bound=l_bound^2*p_s;


rng(seed);

psi=normrnd(0,1,n,3);
mean_mat=[0,0,0];
cov_mat=[1,0.3,-0.3;0.3,1,-0.3;-0.3,-0.3,1];

x_initial=mvnrnd(mean_mat,cov_mat,1);

p=unifrnd(0,1,n,1);


p_dim=4;
k=p_dim-1;

m=n*0.9;

    function [ value ] = policy_value( theta, mu,lambda)
        
        %simulate stationary distribution under policy pi_theta
        
        
        emi_data=zeros(n,3);
        emi_data(1,:)=x_initial;
        
        
        for i=2:n
            a=(logistic(theta*[1,emi_data(i-1,:)]')<p(i));
            emi_data(i,1)=psi(i,1);
            emi_data(i,2)=psi(i,2);
            emi_data(i,3)=psi(i,3);
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
        %deriv=(er1.*logistic_deriv(prob_lin)*p_feature_mat+er0.*(-logistic_deriv(prob_lin))*p_feature_mat)/m+...
        %    2*lambda*theta*(p_feature_mat'*p_feature_mat/m);
        %hess=((repmat(er1.*logistic_hess(prob_lin),p_dim,1).*p_feature_mat')*p_feature_mat+(repmat(er0.*(logistic_hess(-prob_lin)),p_dim,1).*p_feature_mat')*p_feature_mat)/m+...
         %   2*lambda*(p_feature_mat'*p_feature_mat/m);
        
    end

    %test whether the solution satisfies the quadratic constraint
    function [  sat  ] = ineq_test(theta)
        
       
        emi_data=zeros(n,3);
        emi_data(1,:)=x_initial;
        
        
        for i=2:n
            a=(logistic(theta*[1,emi_data(i-1,:)]')<p(i));
            emi_data(i,1)=psi(i,1);
            emi_data(i,2)=psi(i,2);
            emi_data(i,3)=psi(i,3);
        end
        
        %delete the first 1/10
        emi_data_use=emi_data((n*0.1+1):n,:);
        p_feature_mat=[ones(m,1),emi_data_use];
        
        sat=theta*(p_feature_mat'*p_feature_mat/m)*theta' <= q_bound + tol;
    end

%make a function wrapper for the unconstraint optimization problem, for
%fixed lambda
    function [sat, theta] = solve_theta(lambda)
        f=@(theta) policy_value( theta, mu_star, lambda);
        %opts = optimoptions(@fmincon,'Algorithm','interior-point');
        problem = createOptimProblem('fmincon','objective',f,'x0',zeros(1,p_dim),...
        'lb',-ones(1,p_dim)*param_fmin(2),'ub',ones(1,p_dim)*param_fmin(2),'options',opts);
        %gs = GlobalSearch;
        %solve the unconstraint problem
        ms = MultiStart;
        [theta,~] = run(ms,problem,n_ms);
        
        %test whether the constraint is satisfied
        sat= ineq_test(theta);
    end

    function [ x, lambda ] = find_lambda (intv)
        fprintf('start with search interval for lambda [ %f, %f] \n',intv);
        
        %test the lower intv
        while solve_theta(intv(1))==1 && intv(1)>0
            %lower the entire interval
            width=intv(2)-intv(1);
            intv(2)=intv(1);
            intv(1)=max(0,intv(2)-width);
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
        end
        
        %test the upper intv
        while solve_theta(intv(2))==0
            %higher the entire interval
            width=intv(2)-intv(1);
            intv(1)=intv(2);
            intv(2)=intv(1)+width;
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
        end
        
        %start binary search
        width=intv(2)-intv(1);
        [sat,x]=solve_theta((intv(2)+intv(1))/2);
        
        while width>= eps
            if sat==1
                %the lower half interval
                intv(2)=intv(1)+width/2;
            else
                intv(1)=intv(2)-width/2;
            end
            width=intv(2)-intv(1);
            fprintf('search interval for lambda updated to be [ %f, %f] \n',intv);
            [sat,x]=solve_theta((intv(2)+intv(1))/2);
        end
        
        lambda=(intv(2)+intv(1))/2;
        
    end
%tolerance in search for lambda
eps=1e-2;
tol=1e-3;

%theta0=zeros(1,4);

opts = optimoptions(@fmincon,'Algorithm','interior-point','TolFun',param_fmin(1),'Display','off');
%gs = GlobalSearch('NumStageOnePoints',param_gs(1),'NumTrialPoints',param_gs(2),'TolFun',param_gs(3),'TolX',param_gs(4));

[ theta_star, lambda_star ] = find_lambda ([0.1,0.5]);

fprintf('At lambda %f ,true optimal theta is [%f %f %f %f] \n', lambda_star,theta_star);

f_star=@(theta) policy_value( theta, mu_star, lambda_star);
value_star=f_star(theta_star);

%write to file
%repeat string
p_str=repmat(' %f ',1,p_dim);
%r_str=repmat(' %f ',1,r_dim);

%calculate the coverage and write to file
txt_name=strcat('optimal_burden_', num2str(tau),'_',num2str(p_explore),'_',num2str(p_s),'.txt');
id=fopen(txt_name,'w');
fprintf(id,'lambda is %f \n',lambda_star);
fprintf(id,'optimal policy value is %f \n',value_star);
fprintf(id,'optimal policy is %f %f %f %f \n',theta_star);

fclose(id);


csv_name=strcat('optimal_burden_', num2str(tau),'_',num2str(p_explore),'_',num2str(p_s),'.csv');
csvwrite(csv_name,[lambda_star,value_star,theta_star]);



end

