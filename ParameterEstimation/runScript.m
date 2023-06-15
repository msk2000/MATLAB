%% Controls
checkPlot       = false;
runCalc         = true;
cutoffSample    = 502;

generatePlots   = false; % Enable plots in ls_long and ls_sp

testToRun       = 'pitchStabHoomanHigh';
varToPlot       = 'Roll_deg';

%% Load data
dataSet = loadUdpData;

%% Tidy up data
dataSetReprocessed = reprocessDataSet(dataSet);

%% Plot check data
if checkPlot
    testFig = figure;
    testAx = axes;
    hold(testAx,'on');
    plot(testAx,dataSet.(testToRun).Time_sec-dataSet.(testToRun).Time_sec(1),...
        dataSet.(testToRun).(varToPlot),'-k');
    plot(testAx,dataSetReprocessed.(testToRun).Time_sec,...
        dataSetReprocessed.(testToRun).(varToPlot),'--r');
end

%% Compute longitudinal static stability and phugoid
if runCalc
    testResult = computeLSS(dataSetReprocessed.(testToRun),cutoffSample,generatePlots);

    %% Transfer function 
    [nQDeltaE1,dQDeltaE1]=ss2tf(testResult.sp.A,testResult.sp.B,testResult.sp.C(2,:),testResult.sp.D(2,:),1)

    %% TF
    z=[dataSetReprocessed.(testToRun).Q_deg,dataSetReprocessed.(testToRun).Elevator_deg];
    nn=[3 2 0];
    th=oe(z,nn,100,0.01,1.6,4096,1);
    th=sett(th,0.02);
    present(th)
    [dnum,dden] = th2tf(th);
    [qnum2,qden2] = d2cm(dnum,dden,0.02,'tustin');
    qnum2 = qnum2(2:3);     % Get rid of that 2nd order term, it's inconvenient
    qnum2
    qden2
    
end