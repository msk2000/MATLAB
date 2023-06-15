function importedDataSet = udpDumpImport(fname)
% Read UDP dump file and return data table

%% Read data, skipping line 1 which is the header
inArray = csvread(fname,1,0);       % Import data using csvread, see doc csvread for more

%% Read header
fid = fopen(fname,'r');     % Open file read-only
inHdr = fgetl(fid);         % Get the first line
fid = fclose(fid);          % Close file and note error code

if fid; warning('File did not close correctly!'); end       % If there is an error code closing the file, this will spit out a warning. You need to do fclose all to free up fids

%% Process header
headerShell = textscan(inHdr,'%s','Delimiter',',');         % Pull individual strings from header, delimiter is comma
header = cell(numel(headerShell{:}),1);                     % Pre-allocate final form of header cell array
for i = 1:numel(headerShell{:})
    header{i} = headerShell{:}{i};                          % Un-nest cell array
end

%% Process data
% dataArray = cell(1,size(inArray,2));
% 
% for i = 1:numel(header)
%     dataArray{1,i} = inArray(:,i);
% end

%% Build table
importedDataSet = table;                                    % Create table object
for i = 1:numel(header)                                         % For each table entry
    importedDataSet.(header{i}) = inArray(:,i);                 % Assign data column to label
end

end