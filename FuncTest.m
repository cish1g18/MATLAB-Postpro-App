bslSel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\BSL\Cp\05-04-2022_HC-Cp-X';
optSel = 'C:\Users\caleb\Documents\FS 2022-23\Postpro\MATLAB Postpro App\Example Images\Option\Cp\23-A00-CSH-001-Cp-X';


optIm = im2double(imread(fullfile(optSel, 'frame00055.png')));
bslIm = im2double(imread(fullfile(bslSel, 'frame00055.png')));

%optIm = imread(fullfile(optSel, 'frame00050.png'));
%bslIm = imread(fullfile(bslSel, 'frame00050.png'));

Var = 'Cp';
    
    
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
        [252,248,87];[220,242,77];[175,229,61];[115,215,40];[30,199,61];...
        [70,196,139];[94,190,187];[101,180,209];[89,165,205];...
        [74,149,202];[55,131,198];[37,113,197];[33,99,198];[27,82,200];...
        [20,61,202];[9,27,204];[69,0,195];[105,0,182];[132,0,168];...
        [153,0,153];[143,0,143];[132,0,132];[121,0,121];[108,0,108];...
        [94,0,94];[76,0,76];[54,0,54];[0,0,0]];
    CpLookup = [linspace(CpMax-CpStep,CpMin,nSteps)];
    CpPal = [[234,0,255];[137,59,255];[33,102,243];[0,161,250];...
        [0,229,216];[134,255,118];[255,255,255];[246,255,0];[255,231,0];...
        [255,165,0];[255,61,0];[137,0,0];[40,0,0]];
    CpDelta = [-0.75;-0.625;-0.5;-0.375;-0.25;-0.125;0;0.125;0.25;0.375;...
        0.5;0.625;0.75];
    
    geom = [0,0,0];
    
    delta = uint8(zeros(size(bslIm)));
    
    
    %figure()
    %imshow(bslIm)
    %impixelinfo()
    %figure()
    %imshow(optIm)
    
    tic
    for i = 1:size(delta,1)
        for j = 1:size(delta,2)
            bsl = 255*[bslIm(i,j,1), bslIm(i,j,2), bslIm(i,j,3)];
            opt = 255*[optIm(i,j,1), optIm(i,j,2), optIm(i,j,3)];

            if abs(bsl-geom)<[3,3,3] | abs(opt-geom)<[3,3,3]
                delta(i,j,[1,2,3]) = [0,0,0];
            elseif bsl == opt
                delta(i,j,[1,2,3]) = CpPal(7, [1,2,3]);
            else
                bslDel = abs(CpScale-bsl);
                optDel = abs(CpScale-opt);
                bslInd = find(bslDel(:,1)<10 & bslDel(:,2)<10 & bslDel(:,3)<10, 1);
                optInd = find(optDel(:,1)<10 & optDel(:,2)<10 & optDel(:,3)<10, 1);
                
                if isempty(bslInd) | isempty(optInd)
                    del = 0;
                else
                    bslVal = CpLookup(bslInd);
                    optVal = CpLookup(optInd);
                    del = optVal-bslVal;
                end
                
                
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
    
    figure()
    imshow(delta)
    impixelinfo()
