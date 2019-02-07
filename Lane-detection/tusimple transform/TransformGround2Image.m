function [ uvGrid ] = TransformGround2Image( xyGrid, cameraInfo )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if size(xyGrid,1)==2
    inPoints3 = [xyGrid(1:2,:);zeros(1,size(xyGrid,2))];
    inPoints3(3,:) = inPoints3(3,:) - cameraInfo.cameraHeight;
else
    inPoints3 = xyGrid(1:3,:);
end

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

inPoints3_T = T*inPoints3;

uvGrid = inPoints3_T(1:2,:)  ./  (ones(2,1)*inPoints3_T(3,:));

end