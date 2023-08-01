function shearCellApp

% Define Variables
voltage  = 0;
time     = 0;
fig = uifigure('WindowState','fullscreen', ...
    'Name','Plot App by Raaghav');
g = uigridlayout(fig,[6 6], 'BackgroundColor',[222/255 255/255 241/255]);
g.RowHeight = {'1x','2x','2x','2x','2x','1x'};
g.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

% Plots to visualize data as its collected
% Voltage versus steps
axisVoltStep = uiaxes(g);
axisVoltStep.Layout.Row = [2 5];
axisVoltStep.Layout.Column = [1 6];
axisVoltStep.Title.String = 'Voltage Versus Steps';
axisVoltStep.XLabel.String = 'Voltage (V)';
axisVoltStep.YLabel.String = 'Steps (crank)';

% Interactable elements
% Button to aquire the next datapoint and plot it

recordButton = uibutton(g, ...
    "Text","Begin Recording", ...
    "ButtonPushedFcn", @(src,event) recordButtonPushed(), ...
    "BackgroundColor", [0.5 1 0.5]);
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 1;

% Test
recordButton = uibutton(g, ...
    "Text","Begin Recording", ...
    "ButtonPushedFcn", @(src,event) testButtonPushed(), ...
    "BackgroundColor", [0.5 1 0.5]);
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 2;

% Button that saves data to a csv
saveButton = uibutton(g, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[149, 252, 158]/255);
saveButton.Layout.Row = 6;
saveButton.Layout.Column = 5;

% Button that ends live feed
endButton = uibutton(g, ...
    "Text","End Live", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[242/255 19/255 83/255]);
endButton.Layout.Row = 6;
endButton.Layout.Column = 6;

% Panel to display latest value
valuePanel = uipanel(g, ...
    "Title","Latest Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
valuePanel.Layout.Row = 1;
valuePanel.Layout.Column = [1 2];
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];

% Panel to display live value
livePanel = uipanel(g, ...
    "Title","Live Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
livePanel.Layout.Row = 1;
livePanel.Layout.Column = [3 4];
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];

% Dropdown menu that chooses steps taken with crank
stepSelector = uidropdown(g, ...
    'BackgroundColor',[222/255 255/255 241/255]);
stepSelector.Layout.Row = 1;
stepSelector.Layout.Column = 6;
stepSelector.Items = {'2', '1', '0.5'};
stepSelector.Value = '2';

% Field that allows you to change filename (first half)
discType = uieditfield(g, "Value", 'set material', ...
    'BackgroundColor',[229/255 202/255 250/255]);
discType.Layout.Row = 6;
discType.Layout.Column = 3;

% Field that allows you to change filename (second half)
stationType = uieditfield(g, "Value", 'set load (N)', ...
    'BackgroundColor',[229/255 202/255 250/255]);
stationType.Layout.Row = 6;
stationType.Layout.Column = 4;


% Initialize voltage - step plot data
voltX     = [];
stepY     = [];

% Arduino Attach
serial = serialport("/dev/cu.usbmodem2101",57600);
configureTerminator(serial,"CR/LF");
flush(serial);
serial.UserData = struct("Data",[],"Count",1);

    function testButtonPushed(src, ~)

        % Read the ASCII data from the serialport object.
        data = readline(src);

        % Convert the string data to numeric type and save it in the UserData
        % property of the serialport object.
        src.UserData.Data(end+1) = str2double(data);

        % Update the Count value of the serialport object.
        src.UserData.Count = src.UserData.Count + 1;

        % If 1001 data points have been collected from the Arduino, switch off the
        % callbacks and plot the data.
        if src.UserData.Count > 1001
            configureCallback(src, "off");
            plot(axisVoltStep,src.UserData.Data(2:end));
        end
    end
% 
% % Configure Pins
% configurePin(a,'A0','AnalogInput');
% configurePin(a,'D3','DigitalOutput');
% 
% % Generate 'random' data to read
% writePWMVoltage(a,'D3',3);

% stateA = 1;
% while stateA == 1
%     voltage   = readVoltage(a,'A0');
%     livePanelValue.Text = sprintf('%5.3f',voltage);
%     pause(0.5);
% end
    function recordButtonPushed()
        while stateA == 1
        % Define voltage and step
        voltage   = readVoltage(a,'A0');
        time      = time + 0.1;
        % Append the voltstep data to the cumulative data
        voltX     = [voltX, voltage];
        stepY     = [stepY, step];

        % Define voltage and step
        shearForce   = voltage;

        % Append the voltstep data to the cumulative data
        voltX     = [voltX, shearForce];
        stepY     = [stepY, step];

        % Update latest value
        valuePanelValue.Text = sprintf('%5.3f',voltage);
        
        % Plot the cumulative data
        plot(axisVoltStep, voltX, stepY);
        pause(0.1)
        end
    end

    function saveButtonPushed()
        data = [voltX(:), stepY(:)];

        fileName1  = discType.Value;
        fileName2  = stationType.Value;
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
end