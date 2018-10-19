% Obtain the CDF of input image
% The input variables are the input image as well as the PDF of the image. 
function output = cdf_crr(input_image,pcap_info)
    [rows col] = size(input_image);
    cdf = zeros(rows,1);
    sum=0;
    for p = 1 : 256
        sum = sum + pcap_info(p);
        cdf(p) = cdf(p) + sum;
    end
    output = cdf;
end