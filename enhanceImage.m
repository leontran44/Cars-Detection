function img = enhanceImage(img)

    % Convert color image to grayscale
    grayImg = im2gray(img);
    
    % Remove noise from the grayscale image (you can use any denoising method of your choice)
    denoisedImg = medfilt2(grayImg,[3 3]);
    
    
    % Output the enhanced image
    img = denoisedImg;


end
