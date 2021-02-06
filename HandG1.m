close all
%% Import Java Robot
import java.awt.Robot;
import java.awt.event.*
mouse = Robot;
numFrame = 300;

%% Create video input object.
cam = imaqhwinfo; % Get Camera information
cameraName = char(cam.InstalledAdaptors(end));
cameraInfo = imaqhwinfo(cameraName);
cameraId = cameraInfo.DeviceInfo.DeviceID(end);
cameraFormat = char(cameraInfo.DeviceInfo.SupportedFormats(end));
vidDevice = imaq.VideoDevice(cameraName, cameraId, cameraFormat, ... % Input Video from current adapter
                    'ReturnedColorSpace', 'RGB');

vidInfo = imaqhwinfo(vidDevice);  % Acquire video information

screenSize = get(0,'ScreenSize'); % Acquire system screensize
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Setup blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true, ...
                                'MinimumBlobArea', 3000, ...
                                'MaximumCount', 5);
palmblob = vision.BlobAnalysis('AreaOutputPort', false, ...
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true, ...
                                'MinimumBlobArea', 3000, ...
                                'MaximumCount', 1);                          
hshape = vision.ShapeInserter('BorderColor','Custom', ... % Setup colored box handling
                                    'CustomBorderColor', [1 0 0],...
                                    'Fill', true, ...
                                    'FillColor','Custom', 'CustomFillColor',[1 0 0], ...
                                    'Opacity', 0.4);
palmshape = vision.ShapeInserter('BorderColor','Custom', ... % Setup colored box handling
                                    'CustomBorderColor', [1 1 0],...
                                    'Fill', true, ...
                                    'FillColor','Custom', 'CustomFillColor',[1 1 0], ...
                                    'Opacity', 0.4);                                
hVideoIn = vision.VideoPlayer('Name', 'Gesture Recognition', ... % Setup output video stream handling
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
%initializing variables
nFrame = 0;
lCount = 0; rCount = 0; dCount = 0;
sureEvent = 5;
iPos = vidInfo.MaxWidth/2;

while (nFrame < numFrame)
    img1 = step(vidDevice);
    %img1 = flip(img1,2);
    img2 = rgb2gray(img1);                                                        
    lvl = graythresh(img2);                                                      
    img3 = imbinarize(img2, lvl);     
    img4 = bwareaopen(img3, 500);
    img5 = medfilt2(img4, [5 5]);
    img6 = imfill(img5,'holes');
    img7 = imtophat(img6,strel('disk',35));
    img8 = imopen(img7, strel('disk',35));
    [cc_1,bb_1] = step(palmblob,img8); %palm
    [cc_2,bb_2] = step(hblob,img7);    %fingers
    [B,L] = bwboundaries(img7, 'noholes');
    nof = num2str(size(bb_2,1));
    nof1 = size(bb_2,1);
    
        if(~isempty(bb_2))
        img1 = step(hshape,img1,bb_2);
        img1 = insertText(img1,[215,205],strcat('count:',nof),...
                                        'FontSize', 20, 'BoxColor', [0 0 1], 'TextColor', 'white');
        end

        if (~isempty(bb_1))
            img1 = step(palmshape,img1,bb_1);
        end
imshow(img1)
        
%% Begin Mouse Movements
        if nof1==1 %move                                          
%             [cc_2, bb_2] = step(hblob, hshape); % Get the centroids and bounding boxes of the red blobs
            mouse.mouseMove(1.5*(cc_2(:,1))*screenSize(3)/vidInfo.MaxWidth, 1.5*(cc_2(:,2))*screenSize(4)/vidInfo.MaxHeight);
%             mouse.mouseMove(1600-(a(1).Centroid(1,1)*(5/2)),(a(1).Centroid(1,2)*(5/2)-180));
  
        elseif nof1==2 %leftclick
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             pause(0.2);
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);

         elseif nof1==3 %rightclick brings up menu
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             pause(0.2)
             mouse.mousePress(4);
             pause(0.1);
             mouse.mouseRelease(4);

         elseif nof1==4 %doubleclick
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             pause(0.9);
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             pause(0.09);
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             
 lCount = 0; rCount = 0; dCount = 0;
 
         elseif nof1==5 %scroll
             mouse.mousePress(16);
             pause(0.1);
             mouse.mouseRelease(16);
             mouse.mouseWheel(10);
             mouse.mouseWheel(-10);
         end

nFrame = nFrame + 1;
end
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clc; 