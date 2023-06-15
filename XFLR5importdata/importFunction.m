function outData = importFunction(fname)
% Import comma separated (csv) XFLR5 data and format correctly for further
% processing.
%
% Present capability:
%   - Cp/X, multigraph files, including metadata [Tested using XFLR5 v6.47]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Import CSV file

    fid = fopen(fname,'r');                         % File ID

    header_line = fgetl(fid);                       % Read header

    inCsv = textscan(fid,'%f', 'Delimiter', ',');   % Read csv data

    fid = fclose(fid);                              % Close file and note error code

    if fid; warning('CSV file did not close properly'); end         % Just in case something went wrong

    %% Parse header
    X_pos = regexp(header_line,'X,');   % Index locations of X variable identifier in header. Mainly needed as a means of counting them
    numPlots = numel(X_pos);            % Count the indices. There's a plot for each of them

    header_cell = cell(numPlots,1);     % Pre-allocate array for headers
    % Separate each header into its own cell
    for i = 1:numPlots
        switch i
            case numPlots
                header_cell{i} = header_line(X_pos(i):end);
            otherwise
                header_cell{i} = header_line(X_pos(i):X_pos(i+1)-1);
        end
    end

    %% Reshape and parse CSV data
    inConv = inCsv{1};      % Pull vector out of cell array. Bloody textscan!!!

    inConv = reshape(inConv,[3.*numPlots, numel(inConv)./(3.*numPlots)])';    % Convert to horizontally stacked grid of plots for each curve
    % Data at this stage look like [X Cp NaN; ...]. This will be addressed
    % later.

    skipPlot = false(size(X_pos));       % Preallocate skip indices, in case of missing plots

    % Identify missing plots
    for i = 1:numPlots      % For each plot
        if isnan(inConv(1,3.*i-2))    % Check if X is NaN
            skipPlot(i) = true;         % Note skip if it is
        end
    end

    usablePlots = numPlots - sum(skipPlot);     % Number of plots which didn't fail

    %% Separate into output cell
    outData = cell([usablePlots, 1]);     % Pre-allocate output cell array

    outIndex = 1;   % Separate index is needed in case of failed XFLR5 computations

    for i = 1:numPlots
        if skipPlot(i)
            continue
        end

        outData{outIndex}.X             = inConv(:,i*3-2);  % Chord coordinates
        outData{outIndex}.Cp            = inConv(:,i*3-1);  % Cp values
        outData{outIndex}.numPanels     = size(inConv,1);   % Number of panels

        % NACA number
        ni1 = regexp(header_cell{i},'NACA');    % Start of NACA string
        ni2 = regexp(header_cell{i},'-');       % Start of next string

        outData{outIndex}.NACA_num = header_cell{i}(ni1:ni2-1); % From start of NACA to start of next, but -1 to exclude actual start

        % Reynolds number
        [~, ri] = regexpi(header_cell{i},'Re='); % Find the last index (=). Using regexpi instead of regexp to ignore case
        outData{outIndex}.Re = sscanf(header_cell{i}(ri+1:end),'%f');   % Pull a float out of what follows. Again, +1 to exclude the (=)

        % Angle of attack
        [~, ai] = regexpi(header_cell{i},'Alpha=');
        outData{outIndex}.Alpha = sscanf(header_cell{i}(ai+1:end),'%f');

        % NCrit
        [~, nci] = regexpi(header_cell{i},'NCrit=');
        outData{outIndex}.NCrit = sscanf(header_cell{i}(nci+1:end),'%f');

        % XTrTop
        [~, xtti] = regexpi(header_cell{i},'XTrTop=');
        outData{outIndex}.XTrTop = sscanf(header_cell{i}(xtti+1:end),'%f');

        % XTrBot
        [~, xtbi] = regexpi(header_cell{i},'XtrBot=');
        outData{outIndex}.XTrBot = sscanf(header_cell{i}(xtbi+1:end),'%f');

        outIndex = outIndex + 1;
    end

end