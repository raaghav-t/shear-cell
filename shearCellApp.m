function shearCellApp

% Define Variables
sampleRate = 1;

fig = uifigure('WindowState','fullscreen', ...
    'Name','ShearCell App by Raaghav');
g = uigridlayout(fig,[6 6], 'BackgroundColor',[234 249 217]/255);
g.RowHeight = {'1x','2x','2x','2x','2x','1x'};
g.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

% Plots to visualize data as its collected
% Voltage versus steps
axisForceTime = uiaxes(g);
axisForceTime.Layout.Row = [2 5];
axisForceTime.Layout.Column = [1 3];
axisForceTime.Title.String = 'Force Versus Time';
axisForceTime.XLabel.String = 'Time (s)';
axisForceTime.YLabel.String = 'Force (N)';

% Voltage versus steps
axisTorqueTime = uiaxes(g);
axisTorqueTime.Layout.Row = [2 5];
axisTorqueTime.Layout.Column = [4 6];
axisTorqueTime.Title.String = 'Force Versus Time';
axisTorqueTime.XLabel.String = 'Time (s)';
axisTorqueTime.YLabel.String = 'Torque (N*m)';

% Interactable elements
% Button to begin recording and plotting data
recordButton = uibutton(g, ...
    "Text","Begin Recording", ...
    "ButtonPushedFcn", @(src,event) recordButtonPushed(), ...
    "BackgroundColor", [249 57 67]/255);
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 1;


% Button to reset app
resetButton = uibutton(g, ...
    "Text","Reset", ...
    "ButtonPushedFcn", @(src,event) resetButtonPushed(), ...
    "BackgroundColor", [192 76 253]/255);
resetButton.Layout.Row = 1;
resetButton.Layout.Column = 6;


% Button that saves data to a csv
saveButton = uibutton(g, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[126 178 221]/255);
saveButton.Layout.Row = 6;
saveButton.Layout.Column = 5;

% Button that ends live feed
endButton = uibutton(g, ...
    "Text","End Recording", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[95 15 64]/255);
endButton.Layout.Row = 6;
endButton.Layout.Column = 6;

% Panel to display latest value
valuePanel = uipanel(g, ...
    "Title","Latest Value", ...
    "BackgroundColor",[252 176 179]/255);
valuePanel.Layout.Row = 1;
valuePanel.Layout.Column = [1 2];
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];

% Field that allows you to change filename (first half)
materialType = uieditfield(g, "Value", 'set material', ...
    'BackgroundColor',[229/255 202/255 250/255]);
materialType.Layout.Row = 6;
materialType.Layout.Column = 3;

% Field that allows you to change filename (second half)
normalLoad = uieditfield(g, "Value", 'set load (N)', ...
    'BackgroundColor',[229/255 202/255 250/255]);
normalLoad.Layout.Row = 6;
normalLoad.Layout.Column = 4;

% Arduino serial read
serial = serialport("/dev/cu.usbmodem2101", 57600);
configureTerminator(serial,"CR/LF");
flush(serial);
serial.UserData = struct("Data",[],"Time",[]);

stateA = 0;

    function recordButtonPushed()
        flush(serial);
        serial.UserData = struct("Force",[],"Torque",[],"Time",[]);
        stateA = 1;
        time = 0;
        while stateA == 1
            time = time + 0.1; %/sampleRate;
            % Read the ASCII data from the serialport object.
            weight = readline(serial);
            force  = str2double(weight)/9.80665;
            torque = force * 1;
            % Convert the string data to numeric type and save it
            % in the UserData property of the serialport object.
            serial.UserData.Force(end+1) = force;

            serial.UserData.Force(end+1) = torque;
            % Update the Count value of the serialport object.
            serial.UserData.Time(end+1) = time;

            % Data is ploted
            configureCallback(serial, "off");
            plot(axisForceTime, ...
                serial.UserData.Time(2:end), ...
                serial.UserData.Force(2:end));
            plot(axisForceTime, ...
                serial.UserData.Time(2:end), ...
                serial.UserData.Torque(2:end));
        end
    end

    function saveButtonPushed()
        data = [serial.UserData.Time(2:end), serial.UserData.Data(2:end)];
        valuePanelValue.Text = data;
        fileName1  = materialType.Value;
        fileName2  = normalLoad.Value;
        formatSpec = '%s%s.csv';

        locationName = sprintf(formatSpec,fileName1,fileName2);

        writematrix(data, locationName)
        saveButton.Text = 'Saved';
        saveButton.BackgroundColor = [252 242 149]/255;
    end

    function endButtonPushed()
        stateA = 0;
        endButton.Text = 'Recording Ended';
        endButton.BackgroundColor = [252 207 149]/255;
    end

    function resetButtonPushed()
        plot(axisForceTime,0,0)
        endButton.Text = 'End Recording';
        endButton.BackgroundColor = [95 15 64]/255;
        saveButton.Text = 'Save';
        saveButton.BackgroundColor = [126 178 221]/255;
    end
end