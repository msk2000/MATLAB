function newDataSet = reprocessDataSet(oldDataSet)
% This function receives an entire set (made up of multiple CSV files) as
% returned by loadUdpData and reprocesses it so it is compatible with other
% existing code.
%
% Features:
%   - Remove duplicate entries
%   - Flag up multiple data sets in the same file [MAYBE]
%   - Reset simulation timer to t0 = 0
%   - Resample data to a constant sample rate
%   - Cut off the beginning and end to remove noise added by the resampling
%   algorithm.

%% Control variables
resamplingFrequency = 200;  % Hz
badSamplesToRemoveFromEnds = round(resamplingFrequency./2);    % How many samples to trim off the end
                                    % to avoid the starting and finishing
                                    % noise added by the resampling function
dataNames = fieldnames(oldDataSet);
resampleMethod = 'linear';   % 'linear' (default) | 'pchip' | 'spline'

%% Remove duplicates
for i = 1:numel(dataNames)
    newDataSet.(dataNames{i}) = unique(oldDataSet.(dataNames{i}),'rows');
end

%% Look for multiple data sets?

%% Reset time to t0 = 0
for i = 1:numel(dataNames)
    newDataSet.(dataNames{i}).Time_sec = newDataSet.(dataNames{i}).Time_sec - newDataSet.(dataNames{i}).Time_sec(1);
end

%% Resample data
for i = 1:numel(dataNames)
    tableFieldNames = newDataSet.(dataNames{i}).Properties.VariableNames;
    resampledTime = cell(size(tableFieldNames));
    resampledData = cell(size(tableFieldNames));
    for j = 1:numel(tableFieldNames)
        % Skip resampling time
        if strcmpi(tableFieldNames{j},'Time_sec')
            skipInd = j;
            continue
        end
        % Resample and assign to cell. Keep note of resampled time for
        % later
        [resampledData{j}, resampledTime{j}]...
            = resample(newDataSet.(dataNames{i}).(tableFieldNames{j}),...
            newDataSet.(dataNames{i}).Time_sec, resamplingFrequency,...
            resampleMethod);
    end
    
    % Verify resampled time
    for k = 1:numel(resampledTime)-1
        if k == skipInd; continue; end
        if k == skipInd-1; continue; end
        if ~isequal(resampledTime{k},resampledTime{k+1})
            error('Resampling function done a dumb!');
        end
    end
    
    % Tidy up field names
    for m = 1:length(tableFieldNames)
        if strcmpi(tableFieldNames{m},'Time_sec')
            tableFieldNames{m} = [];
            break
        end
    end
    
    % Assign output
    newDataTable = table;
    newDataTable.Time_sec = resampledTime{2};
    
    for l = 2:numel(resampledData)
        newDataTable.(tableFieldNames{l}) = resampledData{l};
    end
    
    % Snippy-snip
    newDataSet.(dataNames{i}) = newDataTable(badSamplesToRemoveFromEnds:end-badSamplesToRemoveFromEnds,:);  % DEGM
%     newDataSet.(dataNames{i}) = newDataTable;  % DEGM
    
end

%% Clear bad samples
% newDataSet = newDataSet(badSamplesToRemoveFromEnds:end-badSamplesToRemoveFromEnds,:);

end