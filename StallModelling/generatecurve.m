% First load the csv as column vectors
% Second set the AR to correct valuie

alpha = deg2rad(alpha1);
AR = 7.4;
CL = CL.*AR/(AR+2);
[fitOut, gof] = fitSigmaAlpha(alpha,CL)