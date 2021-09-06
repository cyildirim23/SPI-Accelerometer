close all;
clear all; 

serialportlist
numbytes = 115200;

FPGA = serialport("COM4", 115200);
data = read (FPGA, numbytes, "uint8");

x_data = zeros(1, numbytes/4);
y_data = zeros(1, numbytes/4);
z_data = zeros(1, numbytes/4);

x_bin_LSB = strings(1, (numbytes/8) - 1);
y_bin_LSB = strings(1, (numbytes/8) - 1);
z_bin_LSB = strings(1, (numbytes/8) - 1);

x_bin_MSB = strings(1, (numbytes/8) - 1);
y_bin_MSB = strings(1, (numbytes/8) - 1);
z_bin_MSB = strings(1, (numbytes/8) - 1);

xbinstr = strings(1, (numbytes/16) - 1);
ybinstr = strings(1, (numbytes/16) - 1);
zbinstr = strings(1, (numbytes/16) - 1);

x_data_final = zeros(1, (numbytes/16) - 1);
y_data_final = zeros(1, (numbytes/16) - 1);
z_data_final = zeros(1, (numbytes/16) - 1);

counter = 2;

delete(FPGA)

start = find(data == 255, 1)
for x = start:8:((numbytes/4) - 8)
    
    x_data(counter + 1) = data(x + 2);
    x_data(counter + 2) = data(x + 3);
    x_bin_LSB(counter/2) = dec2bin(x_data(counter + 1), 8);
    x_bin_MSB(counter/2)= dec2bin(x_data(counter + 2), 8);
    
    y_data(counter + 1) = data(x + 4);
    y_data(counter + 2) = data(x + 5);
    y_bin_LSB(counter/2) = dec2bin(y_data(counter + 1), 8);
    y_bin_MSB(counter/2) = dec2bin(y_data(counter + 2), 8);
    
    z_data(counter + 1) = data(x + 6);
    z_data(counter + 2) = data(x + 7);
    z_bin_LSB(counter/2) = dec2bin(z_data(counter + 1), 8);
    z_bin_MSB(counter/2) = dec2bin(z_data(counter + 2), 8);
    
    counter = counter + 2;
end

for i = 1:1:((numbytes/8) - 1)
    
    xbinstr(i) = strcat(x_bin_MSB(i), x_bin_LSB(i));
    ybinstr(i) = strcat(y_bin_MSB(i), y_bin_LSB(i));
    zbinstr(i) = strcat(z_bin_MSB(i), z_bin_LSB(i));
    
     if(bin2dec(xbinstr(i)) >= 512)
        x_data_final(i) = 4 * (-1024 + (bin2dec(xbinstr(i))));
    end
    if (bin2dec(xbinstr(i)) < 512)
        x_data_final(i) = 4 * bin2dec(xbinstr(i));
    end
    
    if(bin2dec(ybinstr(i)) >= 512)
        y_data_final(i) = 4 * (-1024 + (bin2dec(ybinstr(i))));
    end
    if(bin2dec(ybinstr(i)) < 512)
        y_data_final(i) = 4 * bin2dec(ybinstr(i));
    end
        
    if(bin2dec(zbinstr(i)) >= 512)
        z_data_final(i) = 4 * (-1024 + (bin2dec(zbinstr(i))));  
    end
    if (bin2dec(zbinstr(i)) < 512)
        z_data_final(i) = 4 * bin2dec(zbinstr(i));
    end
    
end

x_data_final(7200) = 0;
y_data_final(7200) = 0;
z_data_final(7200) = 0;

x_avg_ind = 0;
y_avg_ind = 0;
z_avg_ind = 0;

for r = 1:1:((numbytes/16) - 2)
    if (r <= 7150)
        for avg = 1:1:50
            
            x_avg_ind =  x_avg_ind + (x_data_final(r + avg));
            y_avg_ind =  y_avg_ind + (y_data_final(r + avg));
            z_avg_ind =  z_avg_ind + (z_data_final(r + avg));
            
        end
    end
    
    x_avg(r) = x_avg_ind / 50;
    y_avg(r) = y_avg_ind / 50;
    z_avg(r) = z_avg_ind / 50;
    
    x_avg_ind = 0;
    y_avg_ind = 0;
    z_avg_ind = 0;
  
end

x = x_data_final;
y = y_data_final;
z = z_data_final;

j = 1:numel(x_avg);
k = 1:numel(y_avg);
L = 1:numel(z_avg);

subplot(1, 3, 1)
plot(j(1:1:(end/2)), x_avg(1:1:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'X-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'

subplot(1, 3, 2)
plot(k(1:1:(end/2)), y_avg(1:1:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'Y-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'

subplot(1, 3, 3)
plot(L(1:1:(end/2)), z_avg(1:1:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'Z-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'

subplot(2, 3, 1)
plot(j(1:50:(end/2)), x(1:50:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'X-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'

subplot(2, 3, 2)
plot(k(1:50:(end/2)), y(1:50:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'Y-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'

subplot(2, 3, 3)
plot(L(1:50:(end/2)), z(1:50:(end/2)))
axis([1 ((numbytes/32) - 1) -2100 2100])
title 'Z-Axis Acceleration'
xlabel 'Sample Number'
ylabel 'Acceleration (mG)'


delete data;
delete start;

