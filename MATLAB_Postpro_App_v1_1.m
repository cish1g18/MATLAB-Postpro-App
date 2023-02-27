%% MATLAB_Postpro_App_v1_1
% App to display pairs of CFD postpro images and generate deltas
%
% Author: Caleb St. Hill (cish1g18@soton.ac.uk)
% Date: 11/02/2023

%% Setup
%% UI elements

App.UIFigure = uifigure('Name', 'Matlab Postpro App v1');

App.UIFigure.UserData.sel.frame = [51,2,1]; %counter: keeps track of current frame for x,y,z slices
App.UIFigure.UserData.sel.frameXYZ = 1;
App.UIFigure.UserData.sel.var = 'Cp'; 
App.UIFigure.UserData.sel.slice = 'X';
App.UIFigure.UserData.sel.fileExt = '\*.png'; %default file extension 

set(App.UIFigure,'KeyPressFcn',@(src,event)keyCallback(src,event, ...
    App.UIFigure.UserData.sel,App.UIFigure.UserData.bsl, ...
    App.UIFigure.UserData.opt));

App.UIFigure.UserData.File = uimenu(App.UIFigure, "Text", 'File');

App.UIFigure.UserData.bsl.Dropdown = uimenu(App.UIFigure.UserData.File, ...
    "Text", "BSL Selection", "MenuSelectedFcn",@(src,event) ...
    BSLDropdownFcn(src,event,App.UIFigure.UserData.sel));
App.UIFigure.UserData.opt.Dropdown = uimenu(App.UIFigure.UserData.File, ...
    "Text","Option Selection","MenuSelectedFcn", @(src,event) ...
    OptDropdownFcn(src,event,App.UIFigure.UserData.sel));

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
    'Position', [116, 10, 50,50], 'Text', 'Delta');

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
%% Select BSL and Option Folders

waitfor(msgbox('Select BSL directory'));
App.UIFigure.UserData.bsl.sel = uigetdir('BSL Directory');
waitfor(msgbox('Select Option directory'));
App.UIFigure.UserData.opt.sel = uigetdir(App.UIFigure.UserData.bsl.sel, 'Option Directory');

%bslsel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\Option';
%optSel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\BSL';

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
    UIFigure.UserData.sel.frameXYZ)};

App.UIFigure.UserData.opt.im = uiimage(App.UIFigure.UserData.Grid);
App.UIFigure.UserData.opt.im.Layout.Row = 2;
App.UIFigure.UserData.opt.im.Layout.Column = 3;
App.UIFigure.UserData.opt.im.ImageSource = App.UIFigure.UserData.opt.ims{App.UIFigure.UserData.sel.frame(App. ...
    UIFigure.UserData.sel.frameXYZ)};


%% Callback Functions

function leftBtnCallback(src,event,sel, bsl, opt)

    App = ancestor(src,"figure","toplevel");

    sel.frame(sel.frameXYZ) = mod(sel.frame(sel.frameXYZ)-2,100)+1;
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
end

function rightBtnCallback(src,event,sel,bsl,opt)

    App = ancestor(src,"figure","toplevel");

    sel.frame(sel.frameXYZ) = mod(sel.frame(sel.frameXYZ),100)+1;
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;

end

function keyCallback(src,event,sel,bsl,opt)

    App = ancestor(src,"figure","toplevel");

    if strcmp(event.Key,'leftarrow')
        sel.frame(sel.frameXYZ) = mod(sel.frame(sel.frameXYZ)-2,100)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};
    elseif strcmp(event.Key,'rightarrow')
        sel.frame(sel.frameXYZ) = mod(sel.frame(sel.frameXYZ),100)+1;
        bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
        opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};
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
    
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
    
end

function sliceBtnCallback(src,event,sel,bsl,opt)
    % Callback function called by Slice button group

    App = ancestor(src,"figure","toplevel");

    if event.NewValue.Tag == 'X'
        sel.slice = 'X';
        sel.frameXYZ = 1;
    elseif event.NewValue.Tag == 'Y'
        sel.slice = 'Y';
        sel.frameXYZ = 2;
    elseif event.NewValue.Tag == 'Z'
        sel.slice = 'Z';
        sel.frameXYZ = 3;
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
    
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};

    App.UserData.bsl = bsl;
    App.UserData.opt = opt;
    App.UserData.sel = sel;
end

function BSLDropdownFcn(src, event,sel)

    bsl.sel = uigetdir(bsl.sel, 'BSL Directory');
    bsl.DS = imageDatastore(append(bsl.dir,sel.fileExt));
    bsl.ims = readall(bsl.DS);
    bsl.im.ImageSource = bsl.ims{sel.frame(sel.frameXYZ)};

end

function OptDropdownFcn(src, event,sel)

    opt.sel = uigetdir(opt.sel, 'BSL Directory');
    opt.DS = imageDatastore(append(opt.dir,sel.fileExt));
    opt.ims = readall(opt.DS);
    opt.im.ImageSource = opt.ims{sel.frame(sel.frameXYZ)};

end

%function delBtnCallback(src, event)
%
%end
%% Functions

function delOut = delta(optIm, bslIm, var)
    % Function that uses lookup tables for Cp, CpT, Vorticity, and Vel XYZ
    % to convert image file into matrix of numerical values, based on the
    % RGB values for each pixel.
    
    
    
end
