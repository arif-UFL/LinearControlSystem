clear all; close all; clc
A_u = 9.9; %Amplitude of input sinusoid
omega_array = logspace(-1,2,30);    % "radians/time unit"
decay_time = [20]; %in "time units"
num_cycles2average_nom = [5]; %needs to be a positive integer
Fs = [50]; %sampling period in "samples/time unit"
Ts = 1/Fs;
g_hat_array = nan*ones(length(omega_array),1);
theta_hat_array = nan*ones(length(omega_array),1);
for omega_index = 1:length(omega_array)
    omega = omega_array(omega_index);
    num_cycles2average = num_cycles2average_nom+5*ceil(omega);
    t_final = decay_time+(2*pi/omega)*num_cycles2average;
    time = [0:Ts:t_final]';
    uValues = A_u*sin(omega*time);
    u = []; % Input vector to 
    u.time = time;
    u.signals.values = uValues;  %% Input values
    u.signals.dimensions = 1;
    % experimentation
    tstart = tic;
    model = 'openLoopTestBed_R2019b';
    Out = sim(model,'stoptime',num2str(t_final));
    timeTaken = toc(tstart)
    timeOut = Out.y.time;
    y_at_omega= Out.y.signals.values;
    inds2average = [ceil(decay_time/Ts):1:length(time)]';
    N = length(inds2average);
    cosine_vector = cos(omega*time);
    sine_vector = sin(omega*time);
    ZcN = y_at_omega(inds2average)'*cosine_vector(inds2average);
    ZsN = y_at_omega(inds2average)'*sine_vector(inds2average);
    g_hat_omega = 2/A_u/N*sqrt(ZcN^2+ZsN^2); %gain estimate
    theta_hat_omega = atan2(ZcN,ZsN);
    %save estimates
    g_hat_array(omega_index) = g_hat_omega;
    theta_hat_array(omega_index) = theta_hat_omega;
    disp(['done with freq = ',num2str(omega),' rad/sec']);
end
%%
close all
h = g_hat_array.*exp(1j*unwrap(theta_hat_array));% converting to complex form
n = 4;% no of zeros
d = n+1;% # no of poles
% system Identification
[b,a] = invfreqs(h,omega_array,n,d);
sys = tf(b,a);
[A,B,C,D] = tf2ss(b,a);
% frequency response
w = logspace(-1,2.1,2000);
[Gjw] = freqresp(sys,w);
Gjw = Gjw(:);
% Bode Plots
figure(1)
subplot(2,1,1)
semilogx(omega_array,20*log10(g_hat_array),'ro');
hold on
semilogx(w,20*log10(abs(Gjw)),'b');
ylabel('gain, dB');
subplot(2,1,2)
semilogx(omega_array,rad2deg(unwrap(theta_hat_array)),'ro');
hold on
semilogx(w,unwrap(angle(Gjw))*180/pi,'b');
xlabel('\omega (rad/sec)');
ylabel('\phi(degree)');
[z,p,k] = zpkdata(sys,'v');
save sineSweepData;