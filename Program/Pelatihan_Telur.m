clc; clear; close all;

image_folder = 'Data Latih';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);

fitur_area = zeros(1,total_images);
fitur_perimeter = zeros(1,total_images);
fitur_metric = zeros(1,total_images);
fitur_eccentricity = zeros(1,total_images);
fitur_contrast = zeros(1,total_images);
fitur_correlation = zeros(1,total_images);
fitur_energy = zeros(1,total_images);
fitur_homogeneity = zeros(1,total_images);
% fitur_red = zeros(1,total_images);
% fitur_green = zeros(1,total_images);
% fitur_blue = zeros(1,total_images);

for n = 1:total_images
    full_name= fullfile(image_folder, filenames(n).name);
    I = imread(full_name);
    red = I(:,:,1);
    green = I(:,:,2);
    blue = I(:,:,3);

%Melakukan tresholding terhadap Citra
cform = makecform('srgb2lab');
lab = applycform(I,cform);
     
ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
     
nColors = 2;
[cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                    'Replicates',3);
     
pixel_labels = reshape(cluster_idx,nrows,ncols);
     
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
     
    for k = 1:nColors
        color = I;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;
    end
     
area_cluster1 = sum(find(pixel_labels==1));
area_cluster2 = sum(find(pixel_labels==2));
     
[~,cluster_min] = min([area_cluster1,area_cluster2]);
     
segmentasi = (pixel_labels==cluster_min);

%mengkonversi hasil segmentasi k-means ke biner
% segmentasi = im2bw(Img_bw,0.5);

%mengkonversi hasil segmentasi ke dalam tipe double
seg_doub=double(segmentasi);

% %membangun strel dengan bentuk disk ukuran 5 piksel
% str1 = strel('disk',5);
% str2 = strel('disk',20);
% 
% dilasi=imdilate(segmentasi,str2);
% erosi=imerode(dilasi,str2);
% 
% %melakukan operasi closing menggunakan strel yang telah dibangun
% closing = imclose(dilasi,str1);

filling = imfill(segmentasi,'holes');

bersih = bwareaopen(filling,5000);

gray = rgb2gray(I);
gray(~bersih) = 0;
imshow(gray);

%fitur bentuk
stats = regionprops(bersih,'Area','Perimeter','Eccentricity');
fitur_area(n) = stats.Area;
fitur_perimeter(n) = stats.Perimeter;
fitur_metric(n) = 4*pi*fitur_area(n)/(fitur_perimeter(n)^2);
fitur_eccentricity(n) = stats.Eccentricity;

%fitur tekstur
pixel_dist = 1;
GLCM = graycomatrix(gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
fitur_contrast(n) = mean(stats.Contrast);
fitur_correlation(n) = mean(stats.Correlation);
fitur_energy(n) = mean(stats.Energy);
fitur_homogeneity(n) = mean(stats.Homogeneity);

end

input = [fitur_area;fitur_perimeter;fitur_metric;fitur_eccentricity;fitur_contrast;fitur_correlation;fitur_energy;fitur_homogeneity];
target = zeros(1,120);
target(:,1:40) = 1;
target(:,41:120) = 2;

net = newff(input,target,[10 5],{'logsig','logsig'},'trainlm');
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-6;
net = train(net,input,target);
output = round(sim(net,input));
save net.mat net

% scatter3(fitur_area,fitur_perimeter,30,target);
% title('Penyebaran Piksel dalam Ruang Ukuran Pixel')
% xlabel('Area')
% ylabel('Perimeter')
% xlabel('-')

[m,n] = find(output==target);
akurasi = sum(m)/total_images*100;