%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik
img = imread('48hColony1_DAPI.tif');
img = img>800;
imshow(img);
% The image itself has already been separated for the nuclear channel.

%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities


%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 

% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei

seg = h5read('Simple Segmentation.h5', '/exported_data');
seg = squeeze(seg == 2)';
imshow(seg);

%% step 3.1: show segmentation as overlay on raw data

ima = imadjust(mat2gray(im));
rgb = cat(3, ima, ima+0.4*seg, ima);
imshow(rgb);

%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects
L = bwlabel(seg);
Lrgb = label2rgb(L,'jet','w','shuttle');
imshow(Lrgb,[]);

%% step 5: use h5read to read your Ilastik probabilities and visualize

% it will have a channel for each segmentation class you defined

prob = h5read('Probabilities.h5', '/exported_data');
nucprob = squeeze(prob(2,:,:))';
imshow(nucprob);

%% step 6: threshold probabilities to separate nuclei better

thresh = 0.95;
newseg = nucprob>thresh;
newLrgb = label2rgb(bwlabel(newseg), 'jet', 'w', 'shuttle');
imshow(newLrgb);

%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)
outside = ~imdilate(seg,strel('disk',1);
basin = imcomplement(bwdist(ouside));
basin = imimposemin(basin, newseg | ouside);
L = watershed(basin);
L(~seg) = 0;
finalLrgb = label2rgb(L, 'jet','w','shuttle');
imshow(finalLrgb);

%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

Ilastik= h5read('Ilastik.h5', '/exported_data');
Ilastik = squeeze(Ilastik)';
imshow(Ilastik);

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc

img_close = imclose(Ilastik, strel('disk', 5));
imshow(img_close);

