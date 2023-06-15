%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pro_sp1 : Short period response, processes data from POSTFLT. 
%           Removes time delays, converts to m/s, rad, rad/s. 
%           Removes steady offsets.
%           filters and differentiates signals
%
% INPUTS : Time, AlphaTru, IRSPtcRt, Elevator, EAS, Sample No.
%
%
% OUTPUTS : wdot, qdot, w, q, eta.
%
% SYNTAX : [t, wdot,qdot,w,q,eta] =
% pro_sp1(Time,AlphaTru,IRSPtcRt,Elevator,EAS,SamNu)
%
% AUTHOR : G.J. Mullen for the NFLC, Cranfield.
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

% function [to,wdoto,qdoto,wo,qo,etao] = pro_sp1(Time,AlphaTru,IRSPtcRt,Elevator,EAS,SamNu)
function [outStruct] = pro_sp1(dataTable,SamNu)

% % Filer variables.
% 
% [b,a] = butter(3,0.0464); % NOTE: Filter characteristics
% AlphaTru = filtfilt(b,a,AlphaTru); % are not unique. Modify to suit
%                                     % specific requirements.
%                                     
% [b,a] = butter(2,0.095);
% Elevator = filtfilt(b,a,Elevator);
% 
% [b,a] = butter(3,0.127);
% IRSPtcRt = filtfilt(b,a,IRSPtcRt);

%% Convert all variables to SI units and construct Uo

AlphaTru = degtorad(dataTable.alpha_deg);
IRSPtcRt = degtorad(dataTable.Q_deg);
Elevator = degtorad(dataTable.Elevator_deg);

EAS = 0.51444*dataTable.IAS0_knots;
Uo = mean(EAS(1:SamNu)); % Trim airspeed

%% Subtract Initial offsets.

Elevator = Elevator - mean(Elevator(1:SamNu));
AlphaTru = AlphaTru - mean(AlphaTru(1:SamNu));
IRSPtcRt = IRSPtcRt - mean(IRSPtcRt(1:SamNu));

% Construct w
w = Uo.*tan(AlphaTru);

% % Remove time delays. (Valid for 50 Hz sample rate only. Modify!)
% 
% l = length(Time);
% IRSPtcRt = IRSPtcRt(7:1);
% Elevator = Elevator (1:(1-6));
% Time = Time(1:(1-6));
% w = w(1:(1-6));

%% Calculate rate of change of signals, and remove any initial offsets.

wdot = diff(w)./diff(dataTable.Time_sec);
wdot = [0; wdot];
wdot = wdot - mean(wdot(1:SamNu));

qdot = diff(IRSPtcRt)./diff(dataTable.Time_sec);
qdot = [0; qdot];
qdot = qdot - mean(qdot(1:SamNu));

%Divide each value by maximum

%wdot = wdot./max(abs(wdot));
%qdot = qdot./max(abs(qdot));
%w = w./max(abs(w));
%q - q./max(abs(q));
%Elevator = Elevator./max(abs(elevator));

%% Prepare output
outStruct.t = dataTable.Time_sec;
outStruct.wdot = wdot;
outStruct.qdot = qdot;
outStruct.w = w;
outStruct.q = IRSPtcRt;
outStruct.eta = Elevator;
