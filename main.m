%%%%%%%%%%%%% main.m file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose:  
%      Perform contrast enhancement
% The following input variables are used:
%       f = input image
%       
% Code flow:
%       1   Read the input image
%       2   Obtain the pixel count by passing it through histo_pcap.m
%       3   Divide by total number of pixels to get PDF
%       4   Pass it through cdf_crr.m to obtain the CDF
%       5   Perform power-law transformation and thereby obtain its
%           histogram and CDF
%       6   Obtain the range at which the new conditioned pixels are
%           present
%       7   Perform contrast stretching and thereby obtain its histogram
%           and CDF
%       8   Perform histogram equalisation and obtain its histogram and CDF
%
%  The following functions are called:
%          histo_pcap.m     To obtain the histogram of an image
%          gammatransform.m To perform power-law transformation
%          cdf_crr.m        To obtain the CDF of image
% 
% 
% 
%  Author:      Pavan Gurudath
%  Date:        11/01/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;            % Clear the command window
clear all;      % Clear the variables in the workspace 
close all;      % Close all figure/plot windows

warning off
%% Input image and its details

f = imread('truck.gif');    %input image
[rows,col] = size(f);

%% PART-1: Compute and plot the image's histogram bpr(r) and cdf cr(r).

histo_image = zeros(rows,1);

pcap_input_image = histo_pcap(f);                    %Obtain the histogram of image
pdf_input_image = pcap_input_image/(rows*col);
cdf_input_image = cdf_crr(f,pdf_input_image);       %Obtain the CDF of image

y=1:1:256;
%Histogram Plot
h= figure;
plot(y,pcap_input_image);
xlabel('r'); ylabel('p^r(r)');
title('Histogram of input image');
saveas(h,'histogram_input.jpg');

%PDF Plot
h = figure;
plot(y,pdf_input_image);
title('PDF of input image'); 
xlabel('r'); ylabel('Pr(r)');
saveas(h,'pdf_input.jpg');

%CDF Plot
h = figure;
plot(y,cdf_input_image);
title('CDF of input image'); 
xlabel('r'); ylabel('Cr(r)');
saveas(h,'cdf_input.jpg');

%% PART-2: Gamma transformation

gamma1 = gammatransform(f,5);                   %Gamma = 5;
h = figure;
imshow(uint8(gamma1));
title('Gamma Correction factor = 5');
saveas(h,'gamma5.jpg');

pcap_gamma_image = histo_pcap(gamma1);                    %Obtain the histogram of image
pdf_gamma_image = pcap_gamma_image/(rows*col);
cdf_gamma_image = cdf_crr(gamma1,pdf_gamma_image);       %Obtain the CDF of image

%Histogram Plot
h= figure;
plot(y,pcap_gamma_image);
xlabel('r'); ylabel('p^r(r)');
title('Histogram of gamma=5 image');
saveas(h,'histogram_gamma.jpg');

%CDF Plot
h = figure;
plot(y,cdf_gamma_image);
title('CDF of gamma=5 image'); 
xlabel('r'); ylabel('Cr(r)');
saveas(h,'cdf_gamma.jpg');


gamma2 = gammatransform(f,0.2);                 %Gamma = 0.2;
h = figure;
imshow(uint8(gamma2));
title('Gamma Correction factor = 0.2');
saveas(h,'gamma2.jpg');

pcap_gamma2_image = histo_pcap(gamma2);                    %Obtain the histogram of image
pdf_gamma2_image = pcap_gamma2_image/(rows*col);
cdf_gamma2_image = cdf_crr(gamma2,pdf_gamma2_image);       %Obtain the CDF of image

%Histogram Plot
h= figure;
plot(y,pcap_gamma2_image);
xlabel('r'); ylabel('p^r(r)');
title('Histogram of gamma=0.2 image');
saveas(h,'histogram_gamma2.jpg');

%CDF Plot
h = figure;
plot(y,cdf_gamma2_image);
title('CDF of gamma=0.2 image'); 
xlabel('r'); ylabel('Cr(r)');
saveas(h,'cdf_gamma2.jpg');

% h = figure;
% imshowpair(gamma1, gamma2, 'Montage');

%% PART-3: Contrast Stretching

cdf_new_image = double(zeros(256,1));
c_mid_low = double(ones(256,1));
c_mid_high = double(zeros(256,1));

for p = 1:256
    if cdf_input_image(p)<0.1
        cdf_new_image(p) = 0;
    elseif cdf_input_image(p)<=0.9
        cdf_new_image(p) = cdf_input_image(p);
        c_mid_low(p) = cdf_input_image(p);
        c_mid_high(p) = cdf_input_image(p);
    else
        cdf_new_image(p) = 1;
    end
end

h = figure; 
plot(y,cdf_new_image);
title('CDF of new contrast stretched image BEFORE stretching');
saveas(h,'cdf_before_stretching.jpg');

[a L1] = min(c_mid_low);            %Find starting point of contrast stretching
[b L2] = max(c_mid_high);           %Find ending point of contrast stretching
L2 = L2+1;

slope = 255/(L2 - L1);              %Slope of contrast stretching
b= -slope*(L1);                     %y-intercept of contrast stretching line

f_stretch_contrast = double(zeros(rows,col));

for i=1:rows
    for j=1:col
        if f(i,j) <= L1
            f_stretch_contrast(i,j) = 0;
        elseif f(i,j) >= L2
            f_stretch_contrast(i,j) = 255;
        else
            f_stretch_contrast(i,j) = slope*double(f(i,j))+b;
        end
    end
end


f_stretch_contrast = uint8(f_stretch_contrast);

figure;
imshow(f_stretch_contrast);
imwrite(f_stretch_contrast,'ContrastStretching.jpg');

pcap_new_image = histo_pcap(f_stretch_contrast);
pdf_new_image = pcap_new_image/(rows*col);
cdf_new_image = cdf_crr(f_stretch_contrast,pdf_new_image);

y=1:1:256;
%Histogram Plot
h = figure;
plot(y,pcap_new_image);
title('Histogram of image after contrast stretching');
saveas(h,'histogram_after_stretching.jpg');

%PDF Plot
h = figure;
plot(y,pdf_new_image);
title('PDF of image after contrast stretching'); 
saveas(h,'pdf_after_stretching.jpg');

%CDF Plot
h = figure;
bar(y,cdf_new_image);
title('CDF of new contrast stretched image AFTER stretching'); 
saveas(h,'cdf_after_stretching.jpg');

%% PART-4: Otpimal Contrast Stretching

pcap_ocs_image = histo_pcap(f);
pdf_ocs_image = pcap_ocs_image/(rows*col);
cdf_ocs_image = cdf_crr(f,pdf_ocs_image);

% Lmax = max(max(f));
Lmax = 255;

for r=1:256
    s= nearest(cdf_ocs_image(r).*Lmax);
    for i=1:rows
        for j=1:col
            if (f(i,j) == r)
                out_eq_image(i,j) = s;
            end
        end
    end
end

h = figure;
imshow(uint8(out_eq_image));
title('Equalised Output Image');
imwrite(uint8(out_eq_image),'EqualisedOutputImage.jpg');

out_eq_image = uint8(out_eq_image);
pcap_newocs_image = histo_pcap(out_eq_image);
pdf_newocs_image = pcap_newocs_image/(rows*col);
cdf_newocs_image = cdf_crr(out_eq_image,pdf_newocs_image);

y=1:1:256;
%Histogram Plot
h = figure;
plot(y,pcap_newocs_image);
title('Histogram equalisation');
saveas(h,'histogram_after_equalisation.jpg');

%PDF Plot
h = figure;
plot(y,pdf_newocs_image);
title('PDF of image after Histogram equalisation'); 
saveas(h,'pdf_after_equalisation.jpg');

%CDF Plot
h = figure;
bar(y,cdf_newocs_image);
title('CDF of image after Histogram equalisation'); 
saveas(h,'cdf_after_equalisation.jpg');
