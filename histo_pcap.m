% Obtain the histogram of the input image
function output = histo_pcap(input_image)
     
    [rows,col] = size(input_image);
    count = zeros(rows,1);
%     prr = zeros(rows,1);
    for i = 1:rows
        for j = 1:col
            count(input_image(i,j)+1) = count(input_image(i,j)+1)+1;    %+1 is added to counter MATLAB indexing
%           prr(input_image(i,j)+1) = count(input_image(i,j)+1)./(rows*col);
        end
    end
    
    output = count;

end
