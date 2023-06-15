%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ls_sp : Estimates a reduced order state space short period model of the
%           form:
%
%       | wdot | = |zw    zq||w| + |zeta| eta
%       | qdot | = |mw    mq||q| + |zeta| 
%
%       using a simple least squares algorith.
%       Assumes all data processed by "pro_sp1".
%
%  INPUTS : Heave velocity and rate of change (w,wdot), pitch rate and rate
%  of change (q, qdot), elevator (eta) and time (t).
%
%  OUTPUTS : Stability and control derivatives and error estimatews.
% 
%  SYNTAX : [A,B,C,D,seA,seB] = ls_sp(wdot,qdot,w,q,eta,t)
% 
%  AUTHOR: G.J. Mullen for the NFLC, Cranfield
%
% COMMENTS: For background theory see J.M. Mendel, "Discrete Techniques of
%           Parameter Estimation", Marcel Dekker, Inc 1973.
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

% function [Ao,Bo,Co,Do,seAo,seBo] = ls_sp(wdot,qdot,w,q,eta,t)
function [outStruct] = ls_sp(inStruct,generatePlots)

%% Form the Z and H matrices.

n = 2.*length(inStruct.wdot)-1;
N = length(inStruct.wdot);

for i = 1:2:n
    Z(i) = inStruct.wdot(.5.*(i+1));
    Z(i+1) = inStruct.qdot(.5.*(i+1));
    
    H(i,1:6) = [inStruct.w(.5.*(i+1)) inStruct.q(.5.*(i+1)) inStruct.eta(.5.*(i+1)) 0 0 0];
    H(i+1,1:6) = [0 0 0 inStruct.w(.5.*(i+1)) inStruct.q(.5.*(i+1)) inStruct.eta(.5.*(i+1))];
end

%% Make Z a column vector.

Z = Z';

%% Calculate the parameter estimates.

% theta = inv(H'*H)*H'*Z;
theta = (H'*H)\H'*Z;

f = inv(H'*H); % Used later in standard error estimates. 

zw = theta(1);
zq = theta(2);
mw = theta(4);
mq = theta(5);
zeta = theta(3);
meta = theta(6);

A = [zw, zq; mw, mq];
B = [zeta; meta];
C = eye(2);
D = zeros(2,1);

% Output frequency and damping

% damp(A)

%% Estimate the standard error for each derivative.

[y,~] = lsim(A,B,C,D,inStruct.eta,inStruct.t); % predict the outputs from estimated model.
if generatePlots
    figure(1),plot(inStruct.t,inStruct.w,inStruct.t,y(:,1),'--g'); % compare estimated and actual w.
    xlabel('seconds'),ylabel('m/s'),title('Measured(-) and PRedicted(--) w');
    figure(2),plot(inStruct.t,inStruct.q,inStruct.t,y(:,2),'--g'); % compare estimated and actual q.
    xlabel('seconds'),ylabel('rad/s'),title('Measured(-) and Predicted(--) q');
end

sqe_w = [y(:,1) - inStruct.w].*[y(:,1) - inStruct.w]; %square of errors for w.
% sqe_w = (y(:,1) -inStruct.w).^2; %square of errors for w.
ssqe_w = sum(sqe_w); % sum of square of errors for w.
sigma_w =sqrt((ssqe_w)/(N-3)); % standard deviation of w equation.

sqe_q = [y(:,2) - inStruct.q].*[y(:,2) - inStruct.q];
% sqe_q = (y(:,2)-inStruct.q).^2;
size(sqe_q);
ssqe_q = sum(sqe_q);
sigma_q = sqrt((ssqe_q)/(N-3));

for j = 1:6
    g(j,j) = sqrt(f(j,j));
end

g = diag(g);

sew = sigma_w*g(1:3);
seq = sigma_q*g(1:3);

%% Put error components in the same form as the A, B matrices.

seA = [sew(1) sew(2); seq(1) seq(2)];
seB = [sew(3); seq(3)];

%% Assign output
outStruct.A = A;
outStruct.B = B;
outStruct.C = C;
outStruct.D = D;
outStruct.seA = seA;
outStruct.seB = seB;

outStruct.raw.zw = theta(1);
outStruct.raw.zq = theta(2);
outStruct.raw.mw = theta(4);
outStruct.raw.mq = theta(5);
outStruct.raw.zeta = theta(3);
outStruct.raw.meta = theta(6);