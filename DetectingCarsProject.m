% Read the input video
v = VideoReader('RoadTraffic.mp4');

% Create a VideoWriter object for the output video
vOut = VideoWriter('CleanRoadTraffic.mp4', 'MPEG-4');
vOut.FrameRate = v.FrameRate;
open(vOut);

% Loop through each frame of the input video
while hasFrame(v)
    % Read a frame from the input video
    frame = readFrame(v);
    
    % Enhance the frame using the enhanceImage() function
    enhancedFrame = enhanceImage(frame);
    
    % Write the enhanced frame to the output video
    writeVideo(vOut, enhancedFrame);
end
% Close the VideoWriter object
close(vOut);

v= VideoReader("CleanRoadTraffic.mp4");
frameSum = im2double(read(v,1));
for idx = 2:v.NumFrames
    frameSum = frameSum + im2double(read(v,idx));
end
aveFrame = frameSum/ v.NumFrames;
% Test Frame Segmentation Algorithm
frame =read(v,153);
frame = im2double(frame);
background = aveFrame;
frameDiff = abs(frame - background);
[CarsBW,CarsMasked] = segmentedCars2(frameDiff);
montage({frameDiff,CarsBW})

CarsProps = regionprops("table",CarsBW,"all");
CarsProps

totalTruePixels = sum(CarsBW(:));

% Initialize the video reader object.
v= VideoReader("CleanRoadTraffic.mp4");
frameSum = im2double(read(v,1));
for idx = 2:v.NumFrames
    frameSum = frameSum + im2double(read(v,idx));
end
aveFrame = frameSum/ v.NumFrames;
imshow(aveFrame)

% Get the total number of frames in the video
numFrames = v.NumFrames;

% Create a table to store the region information
regionTable = table();

% Initialize variables for average region size calculation
totalRegionSize = 0;
numFramesWithCar = 0;

% Process each frame
for frameNumber = 1:numFrames
    % Read the current frame
    frame = read(v, frameNumber);
    
    % Convert the frame to double precision
    frame = im2double(frame);
    
    % Calculate frame difference
    frameDiff = abs(frame - aveFrame);
  
    % Segment the cars using the segmentedCars2() function
    [CarsBW, ~] = segmentedCars2(frameDiff);
    
    % Calculate region properties
    CarsProps = regionprops(CarsBW, 'Area');
    
    % Check if at least one car is detected in the frame
    if ~isempty(CarsProps)
        % Update region size and frame count
        totalRegionSize = totalRegionSize + sum([CarsProps.Area]);
        numFramesWithCar = numFramesWithCar + 1;
    end
    
    % Create a row for the current frame in the region table
    frameRow = table(frameNumber, size(CarsProps, 1), mean([CarsProps.Area]), sum([CarsProps.Area]));
    
    % Append the frame row to the region table
    regionTable = [regionTable; frameRow];
end

% Calculate the average region size in terms of pixels
averageRegionSize = totalRegionSize / numFramesWithCar;

% Display the region table
disp(regionTable);

% Display the average region size
disp("Average region size (pixels): " + averageRegionSize);

%% Moving Car Detection Project
% Task is to finding moving cars, and insert a bounding box around it

v = VideoReader("NewRoadTraffic.mp4");
v.FrameRate;
firstFrame = read(v,1);
firstFrame = im2double(firstFrame);

v2 = VideoWriter("car_bound2.mp4", "MPEG-4");
v2.FrameRate = v.FrameRate;
open(v2)

for idx = 1:v.NumFrames
    frame = read(v,idx);
    frame = im2double(frame);

    frameDiffer = abs (firstFrame - frame);

    bw = segmentedCars2(frameDiffer);

    props = regionprops("table",bw,"BoundingBox");

    carboxed = insertShape(frame,"rectangle",props.BoundingBox,...
        "LineWidth",3,"Color","red");
    writeVideo(v2,carboxed)
end
close(v2);


% Create VideoReader objects for both videos
video1Reader = VideoReader("RoadTraffic.mp4");
video2Reader = VideoReader("car_bound2.mp4");

% Get video properties
frameRate = video1Reader.FrameRate;
frameWidth = video1Reader.Width;
frameHeight = video1Reader.Height;

% Create a new VideoWriter object for the output montage video
outputVideo = VideoWriter("ComparisonRoadTraffic.mp4", 'MPEG-4');
outputVideo.FrameRate = frameRate;
open(outputVideo);

% Read and process each frame from both videos
while hasFrame(video1Reader) && hasFrame(video2Reader)
    % Read frames from both videos
    frame1 = readFrame(video1Reader);
    frame2 = readFrame(video2Reader);

    % Resize frame 2 to match frame 1's height 
    frame2 = imresize(frame2, [frameHeight, NaN]);

    % Create a new frame with both videos side by side
    montageFrame = [frame1, frame2];

    % Write the frame into the output video
    writeVideo(outputVideo, montageFrame);
end

% Close the output video file
close(outputVideo);

function [BW,maskedImage] = segmentedCars2(X)
%segmentImage Segment image using auto-generated code from Image Segmenter app
%  [BW,MASKEDIMAGE] = segmentImage(X) segments image X using auto-generated
%  code from the Image Segmenter app. The final segmentation is returned in
%  BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 18-Jul-2023
%----------------------------------------------------

% Threshold image with manual threshold
BW = im2gray(X) > 2.000000e-01;

% Open mask with disk
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);

% Close mask with disk
radius = 20;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;

end
