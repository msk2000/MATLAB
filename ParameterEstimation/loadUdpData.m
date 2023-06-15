function dataSet = loadUdpData(lddir)
% Scan current or requested directory and load all csv files from it

if nargin<1
    lddir = pwd;
end

filesInDir = dir(lddir);
f_ind = [];
for i = 1:numel(filesInDir)
    if min(ismember('.csv',filesInDir(i).name))
        f_ind = [f_ind;i];
    end
end

if isempty(f_ind)
    error('No csv files present');
end

fnames = cell(numel(f_ind),1);
varNames = fnames;
for i = 1:numel(f_ind)
    fnames{i} = filesInDir(f_ind(i)).name;
    [~, varNames{i}, ~] = fileparts(fnames{i});
end

for i = 1:numel(fnames)
    dataSet.(varNames{i}) = udpDumpImport(fnames{i});
end

end