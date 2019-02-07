%% transform from image view to BEV
file_root = '../data/train_set/';

% camera parameter
load('cameraParams.mat');
cameraInfo.focalLengthX = cameraParams.FocalLength(1);
cameraInfo.focalLengthY = cameraParams.FocalLength(2);
cameraInfo.opticalCenterX = 640;
cameraInfo.opticalCenterY = 360;%
cameraInfo.cameraHeight = 1200;
cameraInfo.pitch = 3;
cameraInfo.yaw = 0;
road_interval = 2;
ratio_eff = 1.1; % adjust output range

% load vp
txt = fopen('train_vp.txt','r');
vp_name = {};
vp_value = [];
num = 0;
while ~feof(txt)
    num = num + 1;
    content = fgetl(txt);
    content = split(content,',');
    vp_name{num} = content{1};
    vp_value(num,:) = [str2double(content{2})  str2double(content{3})];
end
% !!!!!!! you can also use mean vp position !!!!!!!!

% transform and save
for i=1:length(vp_name)
    filename = vp_name{i};
    im = imread([file_root filename]);
    cameraInfo.pitch= estimate_pitch(cameraInfo,vp_value(i,:).*[size(im,1) size(im,2)]);
    [bev_im, row_axis, col_axis] = convert_to_top_view(im, cameraInfo, 600, ratio_eff, 0, 0); %main code for tranformation
    figure(1),subplot(211),imagesc(im)
    subplot(212),imagesc(bev_im)
end
