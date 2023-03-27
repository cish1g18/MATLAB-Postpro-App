function MATLAB_Postpro_App_v1_1()
%% MATLAB_Postpro_App_v1_1
% App to display pairs of CFD postpro images and generate deltas
%
% Author: Caleb St. Hill (cish1g18@soton.ac.uk)
% Date: 11/02/2023

%% Setup
% UI elements

App.UIFigure = uifigure('Name', 'Matlab Postpro App v1');

App.UIFigure.UserData.sel.frame = [51,2,1,1]; %counter: keeps track of current frame for x,y,z,s slices
App.UIFigure.UserData.sel.frameXYZS = 1;
App.UIFigure.UserData.sel.var = 'Cp'; 
App.UIFigure.UserData.sel.slice = 'X';
App.UIFigure.UserData.sel.fileExt = '\*.png'; %default file extension 

set(App.UIFigure,'KeyPressFcn',@(src,event)keyCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));

App.UIFigure.UserData.File = uimenu(App.UIFigure, "Text", 'File');

App.UIFigure.UserData.bsl.Dropdown = uimenu(App.UIFigure.UserData.File, ...
    "Text", "BSL Selection", "MenuSelectedFcn",@(src,event) ...
    BSLDropdownFcn(src,event,App.UIFigure.UserData.sel, ...
    App.UIFigure.UserData.bsl,App.UIFigure.UserData.opt));
App.UIFigure.UserData.opt.Dropdown = uimenu(App.UIFigure.UserData.File, ...
    "Text","Option Selection","MenuSelectedFcn", @(src,event) ...
    OptDropdownFcn(src,event,App.UIFigure.UserData.sel, ...
    App.UIFigure.UserData.bsl,App.UIFigure.UserData.opt));

App.UIFigure.UserData.Grid = uigridlayout(App.UIFigure,[3,3]);
App.UIFigure.UserData.Grid.RowHeight = {30,'1x',90};
App.UIFigure.UserData.Grid.ColumnWidth = {'1x','1x','1x'};

App.UIFigure.UserData.Col1Title = uilabel(App.UIFigure.UserData.Grid,'Text','BSL');
App.UIFigure.UserData.Col1Title.Layout.Row = 1;
App.UIFigure.UserData.Col1Title.Layout.Column = 1;
App.UIFigure.UserData.Col1Title.HorizontalAlignment = 'center';
App.UIFigure.UserData.Col1Title.VerticalAlignment = 'center';
App.UIFigure.UserData.Col1Title.FontSize = 24;

App.UIFigure.UserData.Col2Title = uilabel(App.UIFigure.UserData.Grid,'Text','Delta');
App.UIFigure.UserData.Col2Title.Layout.Row = 1;
App.UIFigure.UserData.Col2Title.Layout.Column = 2;
App.UIFigure.UserData.Col2Title.HorizontalAlignment = 'center';
App.UIFigure.UserData.Col2Title.VerticalAlignment = 'center';
App.UIFigure.UserData.Col2Title.FontSize = 24;

App.UIFigure.UserData.Col3Title = uilabel(App.UIFigure.UserData.Grid,'Text','Option');
App.UIFigure.UserData.Col3Title.Layout.Row = 1;
App.UIFigure.UserData.Col3Title.Layout.Column = 3;
App.UIFigure.UserData.Col3Title.HorizontalAlignment = 'center';
App.UIFigure.UserData.Col3Title.VerticalAlignment = 'center';
App.UIFigure.UserData.Col3Title.FontSize = 24;

App.UIFigure.UserData.UI = uibuttongroup(App.UIFigure.UserData.Grid);
App.UIFigure.UserData.UI.Title = 'Frame';
App.UIFigure.UserData.UI.Layout.Row = 3;
App.UIFigure.UserData.UI.Layout.Column = 1;

App.UIFigure.UserData.Var = uibuttongroup(App.UIFigure.UserData.Grid, 'SelectionChangedFcn', ...
    @(src,event)varBtnCallback(src,event,App.UIFigure.UserData.sel, ...
    App.UIFigure.UserData.bsl,App.UIFigure.UserData.opt));
App.UIFigure.UserData.Var.Title = 'Variable';
App.UIFigure.UserData.Var.Layout.Row = 3;
App.UIFigure.UserData.Var.Layout.Column = 2;

App.UIFigure.UserData.Slice = uibuttongroup(App.UIFigure.UserData.Grid, ...
    'SelectionChangedFcn', @(src,event)sliceBtnCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));
App.UIFigure.UserData.Slice.Title = 'Slice';
App.UIFigure.UserData.Slice.Layout.Row = 3;
App.UIFigure.UserData.Slice.Layout.Column = 3;

% Navigation & Delta Buttons
App.UIFigure.UserData.leftBtn = uibutton(App.UIFigure.UserData.UI, ...
    'Icon', 'left.png', 'Text', '', 'Position', [10, 10, 50, 50], ...
    'ButtonPushedFcn', @(src,event)leftBtnCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));
App.UIFigure.UserData.rightBtn = uibutton(App.UIFigure.UserData.UI, ...
    'Icon', 'right.png', 'Text', '', 'Position', [63, 10, 50, 50], ...
    'ButtonPushedFcn', @(src,event)rightBtnCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));
App.UIFigure.UserData.delBtn = uibutton(App.UIFigure.UserData.UI, ...
    'Position', [116, 10, 50,50], 'Text', 'Delta',  ...
    'ButtonPushedFcn', @(src,event)delBtnCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));

% Variable selection buttons 
App.UIFigure.UserData.cpBtn = uitogglebutton(App.UIFigure.UserData.Var, ...
    'Text', 'Cp', 'Position', [10, 40, 30, 22], 'Tag', 'Cp');
App.UIFigure.UserData.cptBtn = uitogglebutton( ...
    App.UIFigure.UserData.Var, 'Text', 'CpT', 'Position',...
    [44, 40, 35, 22], 'Tag', 'CpT');
App.UIFigure.UserData.vorBtn = uitogglebutton( ...
    App.UIFigure.UserData.Var, 'Text', 'Vorticity', 'Position',...
    [83, 40, 60, 22], 'Tag', 'Vor'); 
App.UIFigure.UserData.velXBtn = uitogglebutton( ...
    App.UIFigure.UserData.Var, 'Text', 'NdVelX', 'Position',...
    [10, 10, 50, 22], 'Tag', 'UX');
App.UIFigure.UserData.velYBtn = uitogglebutton( ...
    App.UIFigure.UserData.Var, 'Text', 'NdVelY', 'Position',...
    [64, 10, 50, 22], 'Tag', 'UY');
App.UIFigure.UserData.velZBtn = uitogglebutton( ...
    App.UIFigure.UserData.Var, 'Text', 'NdVelZ', 'Position',...
    [118, 10, 50, 22], 'Tag', 'UZ');


% Slice selection buttons
App.UIFigure.UserData.xBtn = uitogglebutton( ...
    App.UIFigure.UserData.Slice, 'Text', 'X', 'Position', ...
    [10, 10, 22, 22], 'Tag', 'X');
App.UIFigure.UserData.yBtn = uitogglebutton( ...
    App.UIFigure.UserData.Slice, 'Text', 'Y', 'Position', ...
    [36, 10, 22, 22], 'Tag', 'Y');
App.UIFigure.UserData.zBtn = uitogglebutton( ...
    App.UIFigure.UserData.Slice, 'Text', 'Z','Position', ...
    [62, 10, 22, 22], 'Tag', 'Z');
App.UIFigure.UserData.sBtn = uitogglebutton( ...
    App.UIFigure.UserData.Slice, 'Text', 'S','Position', ...
    [88, 10, 22, 22], 'Tag', 'S');
%% Select BSL and Option Folders

uiwait(msgbox('Select BSL directory', 'modal'));
App.UIFigure.UserData.bsl.sel = uigetdir('BSL Directory');
uiwait(msgbox('Select Option directory','modal'));
App.UIFigure.UserData.opt.sel = uigetdir(fullfile( ...
    App.UIFigure.UserData.bsl.sel,'..'), 'Option Directory');

App.UIFigure.UserData.bsl.vars = [];
App.UIFigure.UserData.opt.vars = [];

App.UIFigure.UserData.bsl.varStruct = dir(App.UIFigure.UserData.bsl.sel);
App.UIFigure.UserData.bsl.nVars = size(App.UIFigure.UserData.bsl.varStruct);
App.UIFigure.UserData.bsl.nVars = App.UIFigure.UserData.bsl.nVars(1);

App.UIFigure.UserData.opt.varStruct = dir(App.UIFigure.UserData.opt.sel);
App.UIFigure.UserData.opt.nVars = size(App.UIFigure.UserData.opt.varStruct);
App.UIFigure.UserData.opt.nVars = App.UIFigure.UserData.opt.nVars(1);

for i=1:App.UIFigure.UserData.bsl.nVars
    App.UIFigure.UserData.bsl.vars = [App.UIFigure.UserData.bsl.vars, append('\', string(App.UIFigure.UserData.bsl.varStruct(i).name))];
end

for i=1:App.UIFigure.UserData.opt.nVars
    App.UIFigure.UserData.opt.vars = [App.UIFigure.UserData.opt.vars, append('\', string(App.UIFigure.UserData.opt.varStruct(i).name))];
end

App.UIFigure.UserData.opt.varInd = find(endsWith(App.UIFigure.UserData.opt.vars, App.UIFigure.UserData.sel.var));
App.UIFigure.UserData.bsl.varInd = find(endsWith(App.UIFigure.UserData.bsl.vars, App.UIFigure.UserData.sel.var));

App.UIFigure.UserData.opt.varDir = append(App.UIFigure.UserData.opt.sel, App.UIFigure.UserData.opt.vars(App.UIFigure.UserData.opt.varInd));
App.UIFigure.UserData.bsl.varDir = append(App.UIFigure.UserData.bsl.sel, App.UIFigure.UserData.bsl.vars(App.UIFigure.UserData.bsl.varInd));

App.UIFigure.UserData.bsl.slices = [];
App.UIFigure.UserData.opt.slices = [];

App.UIFigure.UserData.bsl.sliceStruct = dir(App.UIFigure.UserData.bsl.varDir);
App.UIFigure.UserData.bsl.nSlices = size(App.UIFigure.UserData.bsl.sliceStruct);
App.UIFigure.UserData.bsl.nSlices=App.UIFigure.UserData.bsl.nSlices(1);

App.UIFigure.UserData.opt.sliceStruct = dir(App.UIFigure.UserData.opt.varDir);
App.UIFigure.UserData.opt.nSlices = size(App.UIFigure.UserData.opt.sliceStruct);
App.UIFigure.UserData.opt.nSlices = App.UIFigure.UserData.opt.nSlices(1);

for i=1:App.UIFigure.UserData.bsl.nSlices
    App.UIFigure.UserData.bsl.slices = [App.UIFigure.UserData.bsl.slices, append('\', string(App.UIFigure.UserData.bsl.sliceStruct(i).name))];
end

for i=1:App.UIFigure.UserData.opt.nSlices
    App.UIFigure.UserData.opt.slices = [App.UIFigure.UserData.opt.slices, append('\', string(App.UIFigure.UserData.opt.sliceStruct(i).name))];
end

App.UIFigure.UserData.opt.sliceInd = find(endsWith(App.UIFigure.UserData.opt.slices, App.UIFigure.UserData.sel.slice));
App.UIFigure.UserData.bsl.sliceInd = find(endsWith(App.UIFigure.UserData.bsl.slices, App.UIFigure.UserData.sel.slice));

App.UIFigure.UserData.opt.dir = append(App.UIFigure.UserData.opt.varDir, App.UIFigure.UserData.opt.slices(App.UIFigure.UserData.opt.sliceInd));
App.UIFigure.UserData.bsl.dir = append(App.UIFigure.UserData.bsl.varDir, App.UIFigure.UserData.bsl.slices(App.UIFigure.UserData.bsl.sliceInd));
%% Load all images in BSL and Option folders

App.UIFigure.UserData.bsl.DS = imageDatastore(append(App.UIFigure.UserData.bsl.dir,App.UIFigure.UserData.sel.fileExt));
App.UIFigure.UserData.bsl.ims = readall(App.UIFigure.UserData.bsl.DS);
App.UIFigure.UserData.opt.DS = imageDatastore(append(App.UIFigure.UserData.opt.dir,App.UIFigure.UserData.sel.fileExt));
App.UIFigure.UserData.opt.ims = readall(App.UIFigure.UserData.opt.DS);

%% Display image pairs in app

App.UIFigure.UserData.bsl.im = uiimage(App.UIFigure.UserData.Grid);
App.UIFigure.UserData.bsl.im.Layout.Row = 2;
App.UIFigure.UserData.bsl.im.Layout.Column = 1;
App.UIFigure.UserData.bsl.im.ImageSource = App.UIFigure.UserData.bsl.ims{App.UIFigure.UserData.sel.frame(App. ...
    UIFigure.UserData.sel.frameXYZS)};

App.UIFigure.UserData.opt.im = uiimage(App.UIFigure.UserData.Grid);
App.UIFigure.UserData.opt.im.Layout.Row = 2;
App.UIFigure.UserData.opt.im.Layout.Column = 3;
App.UIFigure.UserData.opt.im.ImageSource = App.UIFigure.UserData.opt.ims{App.UIFigure.UserData.sel.frame(App. ...
    UIFigure.UserData.sel.frameXYZS)};

App.UIFigure.UserData.del.im = uiimage(App.UIFigure.UserData.Grid);
App.UIFigure.UserData.del.im.Layout.Row = 2;
App.UIFigure.UserData.del.im.Layout.Column = 2;

%% Callback Functions

function leftBtnCallback(src,event,sel, bsl, opt)

    App = ancestor(src,"figure","toplevel");

    sel.frame(sel.frameXYZS) = mod(sel.frame(sel.frameXYZS)-2,100)+1;
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
end

function rightBtnCallback(src,event,sel,bsl,opt)

    App = ancestor(src,"figure","toplevel");
    if sel.frameXYZS ~= 4
        sel.frame(sel.frameXYZS) = mod(sel.frame(sel.frameXYZS),100)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};
    else
        sel.frame(sel.frameXYZS) = mod(sel.frame(sel.frameXYZS),14)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};
    end

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;

end

function keyCallback(src,event,sel,bsl,opt)

    App = ancestor(src,"figure","toplevel");

    if strcmp(event.Key,'leftarrow')
        sel.frame(sel.frameXYZS) = mod(sel.frame(sel.frameXYZS)-2,100)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};
    elseif strcmp(event.Key,'rightarrow')
        sel.frame(sel.frameXYZS) = mod(sel.frame(sel.frameXYZS),100)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};
    end  
    
    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;

end


function varBtnCallback(src,event,sel,bsl,opt)
    % Callback function called by Var button group
    
    App = ancestor(src,"figure","toplevel");

    if strcmp(event.NewValue.Tag, 'Cp')
        sel.var = 'Cp';   
    elseif strcmp(event.NewValue.Tag, 'CpT')
        sel.var = 'CpT';
    elseif strcmp(event.NewValue.Tag, 'Vor')
        sel.var = 'Vorticity';  
    elseif strcmp(event.NewValue.Tag, 'UX')
        sel.var = 'X';
    elseif strcmp(event.NewValue.Tag, 'UY')
        sel.var = 'Y';
    elseif strcmp(event.NewValue.Tag, 'UZ')
        sel.var = 'Z';  
    end

    opt.varInd = find(endsWith(opt.vars, sel.var));
    bsl.varInd = find(endsWith(bsl.vars, sel.var));

    opt.varDir = append(opt.sel, opt.vars(opt.varInd));
    bsl.varDir = append(bsl.sel, bsl.vars(bsl.varInd));

    bsl.slices = [];
    opt.slices = [];

    bslSliceStruct = dir(bsl.varDir);
    nBslSlices = size(bslSliceStruct);
    nBslSlices = nBslSlices(1);

    optSliceStruct = dir(opt.varDir);
    nOptSlices = size(optSliceStruct);
    nOptSlices = nOptSlices(1);
    
    for i=1:nBslSlices
        bsl.slices = [bsl.slices, append('\', string(bslSliceStruct(i).name))];
    end

    for i=1:nOptSlices
        opt.slices = [opt.slices, append('\', string(optSliceStruct(i).name))];
    end

    opt.sliceInd = endsWith(opt.slices, sel.slice);
    bsl.sliceInd = endsWith(bsl.slices, sel.slice);
    
    opt.dir = append(opt.varDir, opt.slices(opt.sliceInd));
    bsl.dir = append(bsl.varDir, bsl.slices(bsl.sliceInd));
    
    bsl.DS = imageDatastore(append(bsl.dir,sel.fileExt));
    bsl.ims = readall(bsl.DS);
    opt.DS = imageDatastore(append(opt.dir,sel.fileExt));
    opt.ims = readall(opt.DS);
    
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
    
end

function sliceBtnCallback(src,event,sel,bsl,opt)
    % Callback function called by Slice button group

    App = ancestor(src,"figure","toplevel");

    if event.NewValue.Tag == 'X'
        sel.slice = 'X';
        sel.frameXYZS = 1;
    elseif event.NewValue.Tag == 'Y'
        sel.slice = 'Y';
        sel.frameXYZS = 2;
    elseif event.NewValue.Tag == 'Z'
        sel.slice = 'Z';
        sel.frameXYZS = 3;
    elseif event.NewValueTag == 'S'
        sel.slice = 'S';
        sel.frameXYZS = 3;
    end
    
    opt.sliceInd = find(endsWith(opt.slices, sel.slice));
    bsl.sliceInd = find(endsWith(bsl.slices, sel.slice));
        
    opt.dir = append(opt.varDir, opt.slices(opt.sliceInd));
    bsl.dir = append(bsl.varDir, bsl.slices(bsl.sliceInd));
        
    % use updated image path to display image pair
    bsl.DS = imageDatastore(append(bsl.dir,sel.fileExt));
    bsl.ims = readall(bsl.DS);
    opt.DS = imageDatastore(append(opt.dir,sel.fileExt));
    opt.ims = readall(opt.DS);
    
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
end

function BSLDropdownFcn(src, event,sel,bsl,opt)

    bsl.sel = uigetdir(fullfile(bsl.sel,'..'), 'BSL Directory');
    bsl.vars = [];

    bsl.varStruct = dir(bsl.sel);
    bsl.nVars = size(bsl.varStruct);
    bsl.nVars = bsl.nVars(1);

    for i=1:bsl.nVars
        bsl.vars = [bsl.vars, append('\', string(bsl.varStruct(i).name))];
    end

    bsl.varInd = find(endsWith(bsl.vars, sel.var));

    bsl.varDir = append(bsl.sel, bsl.vars(bsl.varInd));

    bsl.slices = [];

    bsl.sliceStruct = dir(bsl.varDir);
    bsl.nSlices = size(bsl.sliceStruct);
    bsl.nSlices=bsl.nSlices(1);

    for i=1:bsl.nSlices
        bsl.slices = [bsl.slices, append('\', string(bsl.sliceStruct(i).name))];
    end

    bsl.sliceInd = find(endsWith(bsl.slices, sel.slice));

    bsl.dir = append(bsl.varDir, bsl.slices(bsl.sliceInd));
    
    % Load all images in BSL folder

    bsl.DS = imageDatastore(append(bsl.dir,sel.fileExt));
    bsl.ims = readall(bsl.DS);

    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZS)};

    App.UserData.bsl = bsl;
    App.UserData.sel = sel;
end

function OptDropdownFcn(src, event,sel,bsl,opt)

    opt.sel = uigetdir(fullfile(opt.sel,'..'), 'Option Directory');
    opt.vars = [];

    opt.varStruct = dir(opt.sel);
    opt.nVars = size(opt.varStruct);
    opt.nVars = opt.nVars(1);

    for i=1:opt.nVars
        opt.vars = [opt.vars, append('\', string(opt.varStruct(i).name))];
    end

    opt.varInd = find(endsWith(opt.vars, sel.var));

    opt.varDir = append(opt.sel, opt.vars(opt.varInd));

    opt.slices = [];

    opt.sliceStruct = dir(opt.varDir);
    opt.nSlices = size(opt.sliceStruct);
    opt.nSlices=opt.nSlices(1);

    for i=1:opt.nSlices
        opt.slices = [opt.slices, append('\', string(opt.sliceStruct(i).name))];
    end

    opt.sliceInd = find(endsWith(opt.slices, sel.slice));

    opt.dir = append(opt.varDir, opt.slices(opt.sliceInd));
    
    % Load all images in BSL folder

    opt.DS = imageDatastore(append(opt.dir,sel.fileExt));
    opt.ims = readall(opt.DS);

    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZS)};

    App.UserData.opt = opt;
    App.UserData.sel = sel;
end

function delBtnCallback(src,event,sel,bsl,opt)

    App = ancestor(src,"figure","toplevel");
    opt.delIm = 255*im2single(imread(fullfile(opt.dir, strcat('frame', ...
        pad(num2str(sel.frame(sel.frameXYZS)-1),5,'left','0'),'.png'))));
    bsl.delIm = 255*im2single(imread(fullfile(bsl.dir, strcat('frame', ...
        pad(num2str(sel.frame(sel.frameXYZS)-1),5,'left','0'),'.png'))));
    
    % Number of steps on colour scale.
    nSteps = 32;
    
    % Max and min value for each variable. If colour scale range changes,
    % change these values.
    CpMax = 1;
    CpMin = -3;
    CpTMax = 1;
    CpTMin = -0.5;
    VorMax = 500;
    VorMin = -500;
    VelMax = 1.5;
    VelMin = -1.5;
    
    % Calculation of numerical range of colour scale.
    % Move to GUI setup
    CpRange = CpMax-CpMin;
    CpStep = CpRange/nSteps;
    CpTRange = CpTMax-CpTMin;
    CpTStep = CpTRange/nSteps;
    VorRange = VorMax-VorMin;
    VorStep = VorRange/nSteps;
    VelRange = VelMax-VelMin;
    VelStep = VelRange/nSteps;
    
    % Delta Palette
    DelPal = [[234,0,255];[137,59,255];[33,102,243];[0,161,250];...
        [0,229,216];[134,255,118];[255,255,255];[246,255,0];[255,231,0];...
        [255,165,0];[255,61,0];[137,0,0];[40,0,0]];
    
    % RGB values for each colour scale
    %Cp
    CpScale = [[255,0,51];[255,99,60];[255,151,69];[253,205,78];...
        [252,248,87];[220,242,77];[175,229,61];[115,215,40];[30,199,61];...
        [70,196,139];[94,190,187];[101,180,209];[89,165,205];...
        [74,149,202];[55,131,198];[37,113,197];[33,99,198];[27,82,200];...
        [20,61,202];[9,27,204];[69,0,195];[105,0,182];[132,0,168];...
        [153,0,153];[143,0,143];[132,0,132];[121,0,121];[108,0,108];...
        [94,0,94];[76,0,76];[54,0,54];[0,0,0]];
    CpDelta = [-0.75;-0.625;-0.5;-0.375;-0.25;-0.125;0;0.125;0.25;0.375;...
        0.5;0.625;0.75];
    CpLookup = [linspace(CpMax-CpStep,CpMin,nSteps)];
    
    %CpT
    CpTScale = [[255,0,51];[255,52,54];[255,74,56];[255,91,58];...
        [255,105,61];[255,117,63];[255,129,65];[255,156,69];...
        [254,178,73];[254,198,77];[253,217,80];[253,233,84];...
        [252,249,87];[241,249,84];[225,244,78];[207,238,72];...
        [188,233,66];[167,227,58];[142,221,50];[113,215,39];...
        [71,208,25];[21,207,42];[42,215,85];[56,223,112];[66,231,134];...
        [77,236,154];[96,206,191];[106,172,213];[106,133,222];...
        [102,83,226];[72,59,215];[0,0,204]];
    CpTDelta = [-0.75;-0.625;-0.5;-0.375;-0.25;-0.125;0;0.125;0.25;...
    0.375;0.5;0.625;0.75];
    CpTLookup = [linspace(CpMax-CpStep,CpMin,nSteps)];
    
    if strcmp(sel.var,'Cp')
        Scale = CpScale;
        Delta = CpDelta;
        Lookup = CpLookup;
    elseif strcmp(sel.var,'CpT')
        Scale = CpTScale;
        Delta = CpTDelta;
        Lookup = CpTLookup;
    %elseif strcmp(Var,'Vor')
    %    Scale = VorScale;
    %    Delta = VorDelta;
    %    Lookup = VorLookup;
    end
    
    geom = [0,0,0];
    
    delta = uint8(zeros(size(bsl.delIm)));
    tic
    zero = DelPal(7, [1,2,3]);

    for i = 1:size(delta,1)
        for j = 1:size(delta,2)
            bsl.pixel = [bsl.delIm(i,j,1),bsl.delIm(i,j,2),bsl.delIm(i,j,3)];
            opt.pixel = [opt.delIm(i,j,1),opt.delIm(i,j,2),opt.delIm(i,j,3)];

            if bsl.pixel == [0,0,0] | opt.pixel == [0,0,0]
                delta(i,j,:) = [0,0,0];
            elseif bsl.pixel == opt.pixel
                delta(i,j,:) = zero;
            else
                bslDel = abs(Scale-bsl.pixel);
                optDel = abs(Scale-opt.pixel);
                bslInd = find(bslDel(:,1)<10 & bslDel(:,2)<10 & ...
                    bslDel(:,3)<10, 1);
                optInd = find(optDel(:,1)<10 & optDel(:,2)<10 & ...
                    optDel(:,3)<5, 1);
                
                if isempty(bslInd) | isempty(optInd)
                    del = 0;
                else
                    bslVal = Lookup(bslInd);
                    optVal = Lookup(optInd);
                    del = optVal-bslVal;
                    if del<=-0.75
                        delta(i,j,:) = DelPal(1, [1,2,3]);
                    elseif del>=0.75
                        delta(i,j,:) = DelPal(13, [1,2,3]);
                    else
                        k=find(Delta==del,1);
                        delta(i,j,:)=DelPal(k,[1,2,3]);
                    end
                end
            end
        end
    end

    App.UserData.del.im.ImageSource = delta;

end
end