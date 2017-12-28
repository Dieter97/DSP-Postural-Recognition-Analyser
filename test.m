clear; clc;
figure(1);
t = 0:1/50:10-1/50;                     
x = sin(2*pi*12*t) + sin(2*pi*5*t);
n = length(x); 
%x = x .* transpose(blackman(n));
plot(t,x);
title('Base signal');
grid on;

figure(2);
y = fft(x);     
f = (0:length(y)-1)*50/length(y);                 
fshift = (-n/2:n/2-1)*(50/n);
yshift = fftshift(y);
plot(fshift,abs(yshift)/(n/2));
title('Magnitude');
grid on;

figure(3);
xnoise = x + 2.5*gallery('normaldata',size(t),4);
%xnoise = xnoise .* transpose(blackman(n));
ynoise = fft(xnoise);
ynoiseshift = fftshift(ynoise);    
power = abs(ynoiseshift).^2/n; 
plot(fshift,power);
title('Power');
grid on;