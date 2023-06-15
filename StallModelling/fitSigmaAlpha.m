function [fitresult, gof] = fitSigmaAlpha(alpha, CL)
%CREATEFIT(ALPHA,CL)
%  Create a fit.
%
%  Data for 'sigmaAlpha' fit:
%      X Input : alpha
%      Y Output: CL
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 22-Aug-2021 17:45:31

%% Housekeeping
if max(alpha) > (2*pi)  % If alpha exceeds 2pi, it's clearly not in radians
    alpha = deg2rad(alpha); % Therefore convert it to radians before this mess gets any worse
end

%% Fit: 'sigmaAlpha'.
[xData, yData] = prepareCurveData( alpha, CL );

% Set up fittype and options.
ft = fittype( 'CL_alpha(alpha,M,alpha0,CL0,CLa);', 'independent', 'alpha', 'dependent', 'CL' );
% ft = fittype( 'CL_alpha(alpha,M,alpha0,0.0422,5.2128);', 'independent', 'alpha', 'dependent', 'CL' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.MaxFunEvals = 20000;
opts.MaxIter = 5000;
opts.Robust = 'Bisquare';
opts.StartPoint = [0.0731 5 50 0.5];
% opts.StartPoint = [50 0.5];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'sigmaAlpha' );
h = plot( fitresult, xData, yData );
legend( h, 'CL vs. alpha', 'sigmaAlpha', 'Location', 'NorthEast' );
% Label axes
xlabel alpha
ylabel CL
grid on

end

%% Nested functions
function CL = CL_alpha(alpha,M,alpha0,CL0,CLa)
% Calculate CL, including sigma
sigmaAlpha  = @(alpha,M,alpha0)...
    (1+exp(-M.*(alpha-alpha0))+(exp(M.*(alpha+alpha0))))...
    ./...
    ((1+exp(-M.*(alpha-alpha0))).*(1+exp(M.*(alpha+alpha0))));

CL = (1-sigmaAlpha(alpha,M,alpha0))...
    .*...
    (CL0+CLa.*alpha)...
    + sigmaAlpha(alpha,M,alpha0)...
    .*...
    (2.*sign(alpha).*(sin(alpha).^2).*cos(alpha));

end