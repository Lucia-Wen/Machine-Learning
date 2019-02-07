function [ xyLimits ] = TransformImage2Ground( uvLimits,cameraInfo )
%TransformImage2Ground Summary of this function goes here
%   Detailed explanation goes here
[row , col ] = size(uvLimits);
inPoints4 = zeros(row+2,col);
inPoints4(1:2,:) = uvLimits;
inPoints4(3,:) = 1;
inPoints3 = inPoints4(1:3,:);

%%
tyawp = [
    cos(cameraInfo.yaw*pi/180), -sin(cameraInfo.yaw*pi/180), 0;
    sin(cameraInfo.yaw*pi/180), cos(cameraInfo.yaw*pi/180), 0;
    0, 0, 1];

tpitchp = [1, 0, 0;
    0, -sin(cameraInfo.pitch*pi/180), -cos(cameraInfo.pitch*pi/180);
    0, cos(cameraInfo.pitch*pi/180), -sin(cameraInfo.pitch*pi/180)];

transform = tyawp*tpitchp;

t1p = [
    cameraInfo.focalLengthX, 0, cameraInfo.opticalCenterX;
    0, cameraInfo.focalLengthY, cameraInfo.opticalCenterY;
    0, 0, 1];

T = t1p * transform;

inPoints3_T = inv(T)*inPoints3;

xyLimits =  -cameraInfo.cameraHeight *inPoints3_T(1:2,:)  ./  (ones(2,1)*inPoints3_T(3,:)) ;

end

