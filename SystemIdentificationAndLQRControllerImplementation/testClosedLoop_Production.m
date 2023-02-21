clc;close all; 
load sineSweepData;
ref_type = 'step_zero21_at5_back20_at15';% -  0 at all times except between 5 and 15

t = [0:0.01:50]';
r = F_ref_at_t(t,ref_type);
ref.signals.values = r;
ref.time = t;
ref.signals.dimensions = [1];

figure(1)
plot(t,r,'b.-')
xlabel('time');ylabel('reference');

[A,B,C,D]=ssdata(sys);

n = size(A,1);
m = size(B,2);
x0 = zeros(n,1);
Q = C' * C;
R = 0.11;
wts = zeros(n,m);

[K,S,CLP] = lqr(A,B,Q,R,wts);
OBSPLS = 02*CLP;

ustar = -inv(C*inv(A)*B-D)*r;
uss.signals.values = ustar;
uss.time = t;
uss.signals.dimensions = [1];

Ltemp = place(A',C',OBSPLS);
L = Ltemp';


Aobs = [A-L*C];
Bobs = [L, B-L*D];
Cobs = eye(size(Aobs));%Cobs = C-(D*K);
Dobs = zeros(size(Bobs));
% xobs = zeros(length(Aobs),1);
model = 'closedLoop_ProductionTest';

Out = sim(model,'StopTime',num2str(t_final));
Y_values = Out.yout.signals.values;
U_values = Out.uout.signals.values;
tout    = Out.yout.time;
figure(1)
hold on
plot(tout,Y_values);

figure(2)
% Saturation
plot(tout,U_values);

