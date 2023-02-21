% an example of how to conduct open loop tests on
% the "virtual plant" provided as a Simulink model.
% Prabir Barooah, for Spring 2022, EML 5311
%
% 1. Put all these files in a folder, and then 'cd'
% to that folder from the matlab command prompt before 
% you try anything. 

% 2. The simulink model uses a Level-2 S function, 
% which contains a mathematical model of the plant
% that is used for simulation. The S-function details are hidden
% in the file 'virtualPlant.p'
% Simulink sometimes gives strange errors unless you are working
% in the same folder in which the S function (the .p file
% and all the Simulink models) reside. Hence point 1

% 3. I have designed the Simulink model so that the sampling period
% can be changed by you (Ts), and the 'from workspace' and 'to workspace'
% variables are saved at that sampling period. When you start making
% changes to the files, especially in testing closed loop controller,
% you may add additional 'to/from workspace' blocks, but make sure
% they follow the same philosophy. Always verify from the data
% that the sampling period has not been messed up.

% 4. Related to 3: I have found that it is best to
% use "structure with time" for the 'to/from workspace' blocks
% to ensure every signal gets sampled at the specified rate.
% That is what I have used here, and I strongly suggest you do the same
% when you test your closed loop design.


clear
close all
clc


modelName = 'openLoopTestBed_R2019b';

Ts=0.01; %sampling period, in seconds (rather, time units)
tfinal = 100;
timeInput = [0:Ts:tfinal]';


%%---
% construct the input structure
uValues = 20*sin(3*timeInput);

u = [];
u.time = timeInput;
u.signals.values = uValues;
u.signals.dimensions = 1;

%%- run simulation
Out = sim(modelName,'StopTime',num2str(tfinal));
%%--


%% plot the results

timeOut = Out.y.time;
yValues = Out.y.signals.values;

figure
plot(timeInput,uValues,'b*--',timeOut,yValues,'r*-');
xlabel('time');ylabel('y and u-command');
title('Beware: u is the u commanded, it might be getting saturated');
legend('u','y');












