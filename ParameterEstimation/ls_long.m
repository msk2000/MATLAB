%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ls_long : Estimates the A and B matrices of the longitudinal state space
%            model  
%
%       | udot | = |xu xw xq xth||u | + |xeta| 
%       | wdot | = |zu zw zq zth||w | + |zeta| eta
%       | qdot | = |mu mw mq mth||q | + |meta|
%       | thdot| = |0  0  1  0  ||th| + |0   |
%       using a simple least squares algorith.
%       Assumes all data processed by "pro_lof".
%
%  INPUTS : Airspeed and rate of change (u,udot), 
%           heave velocity and rate of change (w, wdot),
%           pitch rate and rate of change (q,qdot),
%           pitch attitude (th), elevator (eta), time (t).
%
%  OUTPUTS : Stability and control derivatives and error estimates.
% 
%  SYNTAX : [A,B,C,D,seA,seB] = ls_long(udot,wdot,qdot,thdot,u,w,q,th,eta,t)
% 
%  AUTHOR: G.J. Mullen for the NFLC, Cranfield
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Modified by M Safat Khan to accept pre-processed X-Plane data saved
% using the UDP interface and resampled using a uniform rate.
%
% Surrounding code makes extensive use of matlab's table data type, so this
% function has been modified to work with it. As long as the necessary data
% are present, there should be no issue.
%
% Output has been modified to struct data type to simplify user
% interaction.
%
% Filtering, delay adjustment and sub-sampling disabled as X-Plane data are
% fairly clean, not subject to output delays and already resampled as
% necessary.


% function [Ao,Bo,Co,Do,seA,seB] = ls_long(udot,wdot,qdot,thdot,u,w,q,th,eta,t)
function [outStruct] = ls_long(inStruct,generatePlots)

%% Form the Z and H matrices.

if exist('Z', 'var')
    clear Z
end
if exist('H', 'var')
    clear H
end

n = 4.*length(inStruct.u)-3;
N = length(inStruct.t);

for i = 1:4:n
    Z(i) = inStruct.udot(.25.*(i+3));
    Z(i+1) = inStruct.wdot(.25.*(i+3));
    Z(i+2) = inStruct.qdot(.25.*(i+3));
    Z(i+3) = inStruct.thdot(.25.*(i+3));
    
    H(i,1:20) = [inStruct.u(.25.*(i+3)) inStruct.w(.25.*(i+3))...
        inStruct.q(.25.*(i+3)) inStruct.theta(.25.*(i+3))...
        inStruct.eta(.25.*(i+3)) zeros(1,15)];
    
    H(i+1,1:20) = [zeros(1,5) inStruct.u(.25.*(i+3))...
        inStruct.w(.25.*(i+3)) inStruct.q(.25.*(i+3))...
        inStruct.theta(.25.*(i+3)) inStruct.eta(.25.*(i+3)) zeros(1,10)];
    
    H(i+2,1:20) = [zeros(1,10) inStruct.u(.25.*(i+3))...
        inStruct.w(.25.*(i+3)) inStruct.q(.25.*(i+3))...
        inStruct.theta(.25.*(i+3)) inStruct.eta(.25.*(i+3)) zeros(1,5)];
    
    H(i+3,1:20) = [zeros(1,15) inStruct.u(.25.*(i+3))...
        inStruct.w(.25.*(i+3)) inStruct.q(.25.*(i+3))...
        inStruct.theta(.25.*(i+3)) inStruct.eta(.25.*(i+3))];
end

% Make Z a column vector

Z = Z';
cond(H);

%% Calculate the parameter estimates and form the A and B matrices

% thetak = inv(H'*H)*H'*Z;
thetak = (H'*H)\H'*Z;

f=inv(H'*H); % Used later in standard error estimates.

% size(f)

%% Calculate the standard error in the parameter estimates.

xu = thetak(1);
xw = thetak(2);
xq = thetak(3);
xth = thetak(4);
xeta = thetak(5);
zu = thetak(6);
zw = thetak(7);
zq = thetak(8);
zth = thetak(9);
zeta = thetak(10);
mu = thetak(11);
mw = thetak(12);
mq = thetak(13);
mth = thetak(14);
meta = thetak(15);

A = [xu xw xq xth; zu zw zq zth; mu mw mq mth; thetak(16) thetak(17) thetak(18) thetak(19)];
B = [xeta; zeta; meta; thetak(20)];
C = eye(4);
D = zeros(4,1);

%% Estimate the standard error for each derivative.

[y,~] = lsim(A,B,C,D,inStruct.eta,inStruct.t); % predict the outputs from the estimated model.

if generatePlots
    figure(1),plot(inStruct.t,inStruct.u,inStruct.t,y(:,1),'--g'); % comapre estimated and actual u.
    xlabel('seconds'),ylabel('m/s'),title('Measured(-) and Predicted(--) u');

    figure(2),plot(inStruct.t,inStruct.w,inStruct.t,y(:,2),'--g'); % compare estimated and actual w.
    xlabel('seconds'),ylabel('m/s'),title('Measured(-) and Predicted(--) w');

    figure(3), plot(inStruct.t,inStruct.q,inStruct.t,y(:,3),'--g'); % compare estimated and actual q.
    xlabel('seconds'),ylabel('rad/s'),title('Measured(-) and Predicted(--) q');

    figure(4), plot(inStruct.t,inStruct.theta,inStruct.t,y(:,4),'--g'); % compare estimated and actual theta.
    xlabel('seconds'),ylabel('rad'),title('Measured(-) and Predicted(--) theta');
end

sqe_u = [y(:,1) - inStruct.u].*[y(:,1) - inStruct.u]; % square of errors for u.
ssqe_u = sum(sqe_u);  % sum of square of errors for u
sigma_u = sqrt((ssqe_u)/(N-5)); % standard deviation of u equation

sqe_w = [y(:,2) - inStruct.w].*[y(:,2) - inStruct.w]; % square of errors for w.
ssqe_w = sum(sqe_w);  % sum of square of errors for w
sigma_w = sqrt((ssqe_w)/(N-5)); % standard deviation of w equation

sqe_q = [y(:,3) - inStruct.q].*[y(:,3) - inStruct.q]; % square of errors for q.
ssqe_q = sum(sqe_q);  % sum of square of errors for q
sigma_q = sqrt((ssqe_q)/(N-5)); % standard deviation of q equation

sqe_th = [y(:,4) - inStruct.theta].*[y(:,4) - inStruct.theta]; % square of errors for th.
ssqe_th = sum(sqe_th);  % sum of square of errors for th
sigma_th = sqrt((ssqe_th)/(N-5)); % standard deviation of th equation

for j = 1:20
    g(j,j) = sqrt(f(j,j));
end
g = diag(g);

seu = sigma_u*g(1:5);
sew = sigma_w*g(1:5);
seq = sigma_q*g(1:5);
seth = sigma_th*g(1:5);

%% Put error estimates in the same form as the A, B matrices.

seA= [seu(1) seu(2) seu(3) seu(4); sew(1) sew(2) sew(3) sew(4); seq(1) seq(2) seq(3) seq(4); seth(1) seth(2) seth(3) seth(4)];
seB = [seu(5); sew(5); seq(5); seth(5)];

%% Assign output
outStruct.A = A;
outStruct.B = B;
outStruct.C = C;
outStruct.D = D;
outStruct.seA = seA;
outStruct.seB = seB;

outStruct.raw.xu = thetak(1);
outStruct.raw.xw = thetak(2);
outStruct.raw.xq = thetak(3);
outStruct.raw.xth = thetak(4);
outStruct.raw.xeta = thetak(5);
outStruct.raw.zu = thetak(6);
outStruct.raw.zw = thetak(7);
outStruct.raw.zq = thetak(8);
outStruct.raw.zth = thetak(9);
outStruct.raw.zeta = thetak(10);
outStruct.raw.mu = thetak(11);
outStruct.raw.mw = thetak(12);
outStruct.raw.mq = thetak(13);
outStruct.raw.mth = thetak(14);
outStruct.raw.meta = thetak(15);


end








