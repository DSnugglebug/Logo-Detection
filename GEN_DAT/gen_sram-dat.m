%% Generate data to save to sram
clc;
clear;
close all;
logo = imread('carLogo.jpg');
logo = rgb2gray(logo);

%% sram data for logo and honda mark
tmpl = imread('lena.jpg');
tmpl = rgb2gray(tmpl);

fid = fopen('lena.dat','w');

[logo_height, logo_width] = size(logo);
[tmpl_height, tmpl_width] = size(tmpl);

latch = 0;
for row = 1:logo_height
    for col = 1:logo_width   
        tmp = logo(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

for row = 1:tmpl_height
    for col = 1:tmpl_width   
        tmp = tmpl(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

fclose(fid);
fprintf('finished\n');

%% sram data for logo and lexus mark
tmpl = imread('Lexuss.jpg');
tmpl = rgb2gray(tmpl);

fid = fopen('logo_lexus.dat','w');

[logo_height, logo_width] = size(logo);
[tmpl_height, tmpl_width] = size(tmpl);

latch = 0;
for row = 1:logo_height
    for col = 1:logo_width   
        tmp = logo(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

for row = 1:tmpl_height
    for col = 1:tmpl_width   
        tmp = tmpl(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

fclose(fid);
fprintf('finished\n');

%% sram data for logo and toyota mark
tmpl = imread('toyota.jpg');
tmpl = rgb2gray(tmpl);

fid = fopen('logo_toyota.dat','w');

[logo_height, logo_width] = size(logo);
[tmpl_height, tmpl_width] = size(tmpl);

latch = 0;
for row = 1:logo_height
    for col = 1:logo_width   
        tmp = logo(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

for row = 1:tmpl_height
    for col = 1:tmpl_width   
        tmp = tmpl(row, col);
        tmp = uint8(tmp);
        tmp = dec2bin(tmp);
        if (latch == 0)
            fprintf(fid,'\"%08s', tmp);   
        else
            fprintf(fid,'%08s\", ', tmp);
        end
        latch = mod(latch + 1, 2);
    end
end

fclose(fid);
fprintf('finished\n');

