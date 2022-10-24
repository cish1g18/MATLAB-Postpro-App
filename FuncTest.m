bslSel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\BSL\Cp\05-04-2022_HC-Cp-Z';
optSel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\Option\Cp\23-A00-CSH-001-Cp-Z';


optIm = imread(fullfile(optSel, 'frame00050.png'));
bslIm = imread(fullfile(bslSel, 'frame00050.png'));
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
    CpScale = [[255,0,51];[255,99,60];[255,151,69];[253,205,78];...
        [252,248,87];[220,242,77];[175,229,61];[113,211,39];[30,199,61];...
        [69,193,137];[92,187,184];[99,177,205];[87,162,202];...
        [73,146,199];[54,129,195];[36,111,194];[32,97,195];[27,81,197];...
        [20,60,199];[9,27,201];[68,0,192];[103,0,179];[130,0,165];...
        [150,0,150];[141,0,141];[131,0,131];[122,0,122];[108,0,108];...
        [94,0,94];[76,0,76];[54,0,54];[0,0,0]];
    CpScale = uint8(CpScale);
    CpLookup = [linspace(CpMax-CpStep,CpMin,nSteps)];
    CpPal = [[234,0,255];[137,59,255];[33,102,243];[0,161,250];...
        [0,229,216];[134,255,118];[255,255,255];[246,255,0];[255,231,0];...
        [255,165,0];[255,61,0];[137,0,0];[40,0,0]];
    CpPal = uint8(CpPal);
    CpDelta = [-0.75;-0.625;-0.5;-0.375;-0.25;-0.125;0;0.125;0.25;0.375;...
        0.5;0.625;0.75]
    
    geom = uint8([32,32,30]);
    
    delta = zeros(size(bslIm));
    tic
    for i = 1:size(delta,1)
        for j = 1:size(delta,2)
            bsl = bslIm(i,j,[1,2,3]);
            opt = optIm(i,j,[1,2,3]);

            if abs(bsl-geom)<uint8([3,3,3]) | abs(opt-geom)<uint8([3,3,3])
                delta(i,j,[1,2,3]) = [0,0,0];
            elseif bsl == opt
                delta(i,j,[1,2,3]) = CpPal(7);
            else
                bslInd = find(abs(CpScale-bsl) < [1,1,1], 1);
                optInd = find(abs(CpScale-opt) < [1,1,1], 1);
                
                bslVal = CpLookup(bslInd);
                optVal = CpLookup(optInd);
                
                del = optVal-bslVal;
                if del<=-0.75
                    delta(i,j,[1,2,3]) = CpPal(1, [1,2,3]);
                elseif del>=0.75
                    delta(i,j,[1,2,3]) = CpPal(13, [1,2,3]);
                else
                    k=find(CpDelta==del,1);
                    delta(i,j,[1,2,3])=CpPal(k,[1,2,3]);
                end
            end
        end
    end
    
    %for i =1:13
    %    delta = changem(delta, [(0.125*i)-0.875,0,0], CpDelta(i,[1,2,3]));
    %end
    
    %delta = changem(delta, [-0.75,0,0], CpDelta(1,[1,2,3]));
    %delta = changem(delta, [-0.625,0,0], CpDelta(2,[1,2,3]));
    %delta = changem(delta, [-0.5,0,0], CpDelta(3,[1,2,3]));
    %delta = changem(delta, [-0.325,0,0], CpDelta(4,[1,2,3]));
    %delta = changem(delta, [-0.25,0,0], CpDelta(5,[1,2,3]));
    %delta = changem(delta, [-0.125,0,0], CpDelta(6,[1,2,3]));
    %delta = changem(delta, [0,0,0], CpDelta(7,[1,2,3]));
    %delta = changem(delta, [0.125,0,0], CpDelta(8,[1,2,3]));
    %delta = changem(delta, [0.25,0,0], CpDelta(9,[1,2,3]));
    %delta = changem(delta, [0.325,0,0], CpDelta(10,[1,2,3]));
    %delta = changem(delta, [0.5,0,0], CpDelta(11,[1,2,3]));
    %delta = changem(delta, [0.625,0,0], CpDelta(12,[1,2,3]));
    %delta = changem(delta, [0.75,0,0], CpDelta(13,[1,2,3]));
    
    toc
    
    imshow(delta)
    impixelinfo()
    % Lookup table to convert from RGB value to numerical value
    
    %CpTLookup = [linspace(CpTMax-CpTStep,CpTMin,nSteps), CpTScale];
    %VorLookup = [linspace(VorMax-VorStep,VorMin,nSteps), VorScale];
    %VelLookup = [linspace(VelMax-VelStep,VelMin,nSteps), VelScale];
    
    
    
    
    
    
    