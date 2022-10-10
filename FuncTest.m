    image = imread('frame00000.png');
    Var = 'Cp'
    
    
    % Number of steps on colour scale. If this changes, change this value.
    % If colour scale density only changes for one variable, add bespoke 
    % value and replace nSteps in the relevant formulae
    nSteps = 32;
    
    % Max and min value for each variable. If colour scale range changes,
    % change these values. Could take in Max/Min obj to function and define
    % these in body of code.
    CpMax = 1;
    CpMin = -3;
    CpTMax = 1;
    CpTMin = -0.5;
    VorMax = 500;
    VorMin = -500;
    VelMax = 1.5;
    VelMin = -1.5;
    
    % Calculation of numerical range of colour scale.
    % Move outside function for performance gains.
    CpRange = CpMax-CpMin;
    CpStep = CpRange/nSteps;
    CpTRange = CpTMax-CpTMin;
    CpTStep = CpTRange/nSteps;
    VorRange = VorMax-VorMin;
    VorStep = VorRange/nSteps;
    VelRange = VelMax-VelMin;
    VelStep = VelRange/nSteps;
    
    % RGB values for each colour scale
    CpScale = [[255,0,51],[255,99,60],[255,151,69],[253,205,78],...
        [252,248,87],[220,242,77],[175,229,61],[115,215,40],[31,202,62],...
        [70,196,139],[94,190,187],[101,180,209],[89,165,205],...
        [74,149,202],[55,131,198],[37,113,197],[33,99,198],[27,82,200],...
        [20,61,202],[9,27,204],[69,0,195],[105,0,182],[132,0,168],...
        [153,0,153],[143,0,143],[132,0,132],[121,0,121],[108,0,108],...
        [94,0,94],[76,0,76],[54,0,54],[0,0,0]];
    CpScale = uint8(CpScale);
    
    % Lookup table to convert from RGB value to numerical value
    CpLookup = [linspace(CpMax-CpStep,CpMin,nSteps), CpScale];
    %CpTLookup = [linspace(CpTMax-CpTStep,CpTMin,nSteps), CpTScale];
    %VorLookup = [linspace(VorMax-VorStep,VorMin,nSteps), VorScale];
    %VelLookup = [linspace(VelMax-VelStep,VelMin,nSteps), VelScale];
    
    
    