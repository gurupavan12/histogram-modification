% Perform power-law transformation c*r^(gamma)
% Input image and gamma are the input variables
function output = gammatransform(input_image,gamma)
    input_image= double(input_image);
    [rows col] = size(input_image);
    
    gamma_image = double(zeros(rows,col));
    
    gamma_image = 255.*((input_image./255).^gamma);
    output = uint8(gamma_image);
    
end
