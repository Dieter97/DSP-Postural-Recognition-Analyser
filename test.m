clear; clc;
figure(1);
f=25; %Hz
fs=f*10; 

% Read data from excel sheet
x = transpose(xlsread('standing still eyes closed.xlsx', 'b12:b1400'));
x = repmat(x,1,40);
% Create time axis
t = 0:1/fs:((1/fs)*(length(x)-1));

%t = -1:1/fs:1;

n = length(t);

% function
%x = rectangularPulse(-0.5, 0.5, t);
%x = zeros(size(t)); x(1:fs/f:end)=1;                    
%x = sin(2*pi*12*t) + sin(2*pi*5*t);
%x = (t.^2 .* pi) + ((t-5).*t.^3);
%x = t;

plot(t,x);
title('Base signal');
grid on;

% Window function
x = x .* transpose(blackman(n));
%x = x .* transpose(hann(n));
%x = x .* transpose(hamming(n));
%x = x .* transpose(rectwin(n));

figure(2);
y = fft(x);     
%f = (0:length(y)-1)*fs/length(y);                 
fshift = (-n/2:n/2-1)*(fs/n);
yshift = fftshift(y);
plot(fshift,abs(yshift)/(n/2));
title('Magnitude');
grid on;

figure(3);
xnoise = x + 2.5*gallery('normaldata',size(t),6);
%xnoise = xnoise .* transpose(blackman(n));
ynoise = fft(xnoise);
ynoiseshift = fftshift(ynoise);    
power = abs(ynoiseshift).^2/n; 
plot(fshift,power);
title('Power');
grid on;