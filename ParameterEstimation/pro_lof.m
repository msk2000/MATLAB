%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pro_lof: Short period and phugoid response, processes data from POSTFLT.
%           Removes time delay, converts to m/s, rad, rad/s.
%           Removes steady offsets.
%           filters and differentiates signals.
%
% INPUTS : Time, EAS, AlphaTru, AlphaTrue, IRSPtcRt, IRSPitch, Elevator,
% Sample No.
%
% SYNTAX: [t,udot,wdot,qdot,thdot,u,w,q,theta,eta] =
%           pro_lof(Time,EAS,AlphaTru,IRSPtcRt,IRSPitch,Elevator,SamNu)
% AUTHOR: G.J. Mullen for the NFLC, Cranfield.
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

% function [to,udoto,wdoto,qdoto,thdoto,uo,wo,qo,thetao,etao] = pro_lof(Time,EAS,AlphaTru,IRSPtcRt,IRSPitch,Elevator,SamNu)
function [outStruct] = pro_lof(dataTable,SamNu)

% % Filter measurements (Filter charact. are not unique. Modify to meet needs)

% [b,a] = butter(2,0.127);
% Elevator = filtfilt(b,a,Elevator);
% 
% [b,a] = butter(2,0.127);
% IRSPtcRt = filtfilt(b,a,IRSPtcRt);
% 
% [b,a] = butter(2,0.127);
% AlphaTru = filtfilt(b,a,AlphaTru);
% 
% [b,a] = butter(2,0.127);
% EAS = filtfilt(b,a,EAS);

%% Convert all variables to SI units and construct Uo

AlphaTru = degtorad(dataTable.alpha_deg);
IRSPtcRt = degtorad(dataTable.Q_deg);
IRSPitch = degtorad(dataTable.Pitch_deg);
Elevator = degtorad(dataTable.Elevator_deg);

EAS = 0.51444*dataTable.IAS0_knots;
Uo = mean(EAS(1:SamNu)); % Trim airspeed

%% Subtract Initial offsets.

Elevator = Elevator - mean(Elevator(1:SamNu));
AlphaTru = AlphaTru - mean(AlphaTru(1:SamNu));
IRSPtcRt = IRSPtcRt - mean(IRSPtcRt(1:SamNu));
IRSPitch = IRSPitch - mean(IRSPitch(1:SamNu));
EAS = EAS - mean(EAS(1:SamNu));

%% Construct w

w = Uo*tan(AlphaTru);

% % Remove time delays. Valid for 50hz only. Must be changed
% 
% % l = length(Time);
% IRSPitch = IRSPitch(6:(1-1));
% IRSPtcRt = IRSPtcRt(7:1);
% Elevator = Elevator(1:(1-6));
% Time = Time(1:(1-6));
% w = w(1:(1-6));
% EAS = EAS(1:(1-6));

%% Calculate rate of change and filter if necessary.

udot = diff(EAS)./diff(dataTable.Time_sec);
udot = [0; udot];
[b,a] = butter(2,0.016);
udot = filtfilt(b,a,udot);
udot = udot - mean(udot(1:SamNu));

wdot = diff(w)./diff(dataTable.Time_sec);
wdot = [0; wdot];
wdot = wdot - mean(wdot(1:SamNu));

qdot = diff(IRSPtcRt)./diff(dataTable.Time_sec);
qdot = [0 ; qdot];
qdot = qdot - mean(qdot(1:SamNu));

thdot = IRSPtcRt; % Small perturbation model

% Sub sample for every 5th element of the variables

%IRSPitch = reduce1(IRSPitch);
%IRSPtcRt = reduce1(IRSPtcRt);
%Elevator = reduce1(Elevator);
%w = reduce1(w);
%EAS = reduce1(EAS);

%udot = reduce1(udot);
%wdot = reduce1(wdot);
%qdot = reduce1(qdot);
%thdot = reduce1(thdot);

%Time = reduce1(Time);

%% Prepare output
outStruct.t = dataTable.Time_sec;
outStruct.udot = udot;
outStruct.wdot = wdot;
outStruct.qdot = qdot;
outStruct.thdot = thdot;
outStruct.u = EAS;
outStruct.w = w;
outStruct.q = IRSPtcRt;
outStruct.theta = IRSPitch;
outStruct.eta = Elevator;

end