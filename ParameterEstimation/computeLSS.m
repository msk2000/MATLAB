function stabilityDerivatives = computeLSS(rawDataTable, cutoffSample,generatePlots)
% Compute longitudinal static stability derivatives using Cranfield method
% (see paper). This is the driving function which should make everything
% else work with the raw data captured from X-Plane via UDP and reprocessed
% accordingly.
%
% rawDataTable is the data table generated by the UDP import function and
% held within the dataSet structs. This should be de-nested for the purpose
% of this function.
%
% cutoffSample is the last sample just before the actual test starts. It's
% used by the Cranfield algorithms to establish baseline values and remove
% zero offsets such that the following code can compute accurate estimates.
%
% The Cranfield code has been modified to work with current matlab (2017b)
% as well as to present neater code, but functionally it should remain
% identical.

pro_sp1_output = pro_sp1(rawDataTable,cutoffSample);
ls_sp_output = ls_sp(pro_sp1_output,generatePlots);

pro_lof_output = pro_lof(rawDataTable,cutoffSample);
ls_long_output = ls_long(pro_lof_output,generatePlots);

stabilityDerivatives.sp=ls_sp_output;
stabilityDerivatives.long=ls_long_output;

fprintf(1,'Stability output SP1\n');
damp(ls_sp_output.A);
fprintf(1,'Stability output long\n');
damp(ls_long_output.A);

end