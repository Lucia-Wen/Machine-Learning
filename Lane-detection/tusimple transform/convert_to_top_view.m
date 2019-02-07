function [outImage, row_axis, col_axis] = convert_to_top_view(I, cameraInfo, outWidth, vp_ratio, grid_show, invalid_v)
CH_n = 1 + 2*(length(size(I))==3);
[Rheight, Rwidth] =  size(I(:,:,1));
ipmInfo.ipmWidth = outWidth;
ipmInfo.ipmLeft = 100;
ipmInfo.ipmRight = Rwidth-100;
ipmInfo.ipmTop = 10;
ipmInfo.ipmBottom = Rheight-5;

%% get effective area in UV space
vpp = GetVanishingPoint(cameraInfo);
vp.x = vpp(1);
vp.y = vpp(2);
max_vison_end = vp.y*vp_ratio;
uvLimitsp = [ vp.x,         ipmInfo.ipmRight, ipmInfo.ipmLeft,  vp.x;
    ipmInfo.ipmTop, ipmInfo.ipmTop, ipmInfo.ipmTop,   ipmInfo.ipmBottom];
uvLimitsp(2,:) = max(uvLimitsp(2,:),max_vison_end); % must larger than vp.y

%% sample in XYZ space
xyLimits = TransformImage2Ground(uvLimitsp,cameraInfo);
row1 = xyLimits(1,:);
row2 = xyLimits(2,:);
xfMin = min(row1); xfMax = max(row1);
yfMin = min(row2); yfMax = max(row2);
ipmInfo.ipmHeigh = round(round(outWidth / (xfMax - xfMin) * (yfMax - yfMin)));

outImage = zeros(ipmInfo.ipmHeigh,ipmInfo.ipmWidth,CH_n);
[outRow outCol,~] = size(outImage);
col_axis = linspace(xfMin, xfMax, outCol);
row_axis = linspace(yfMax, yfMin, outRow);
[xrow, ycol] = meshgrid(col_axis,row_axis);
xrow = xrow';ycol = ycol';
xyGrid = [xrow(:)';ycol(:)'];

%% TransformGround2Image
uvGrid = TransformGround2Image(xyGrid,cameraInfo);
urow = reshape(uvGrid(1,:),size(xrow))';
vcol = reshape(uvGrid(2,:),size(xrow))';

[oheight,owidth,~] = size(outImage);
interval = 5;
grid_x = abs(col_axis(interval) - col_axis(1))/1000;
grid_y = abs(row_axis(interval) - row_axis(1))/1000;
grid_area = grid_x * grid_y;
if grid_show
    %
    temp = floor(max_vison_end):1:size(I,1);
    uv = zeros(size(temp,2),2);
    uv(:,2) = temp;
    uv(:,1) = (size(I,2)+1)/2;
    xy = TransformImage2Ground(uv',cameraInfo);
    dis = xy(2,:)/100;
    row_n = size(xy,2):-1:1;
    figure(6),
    [hAx,H1,H2] = plotyy(row_n,dis,row_n(1:end-1),abs(dis(2:end)-dis(1:end-1)));
    grid on;
    xlabel('Row number (bottom=1)')
    ylabel(hAx(1),'vertical Ground distance')
    ylabel(hAx(2),'Ground distance per row')
    
    %
    figure(5),imagesc(uint8(I));
    n_w = 1:interval:owidth;
    for n_h = 1:interval:oheight
        hold on,plot(urow(n_h,n_w),vcol(n_h,n_w),'b-')
    end
    n_h = 1:interval:oheight;
    for n_w = 1:interval:owidth
        hold on,plot(urow(n_h,n_w),vcol(n_h,n_w),'b-')
    end
    hold on, plot([1,size(I,2)], [vp.y,vp.y],'-r');
    title(sprintf('x:%.2f,y:%.2f,A:%.2f',grid_x,grid_y,grid_area));
end

%% image render
for ch=1:CH_n
    R = I(:,:,ch);
    if nargin < 6
        means = mean(R(:))/255;
    else
        means = invalid_v;
    end
    RR = double(R)/255;
    for i=1:outRow
        for j = 1:outCol
            ui = uvGrid(1,(i-1)*outCol+j);
            vi = uvGrid(2,(i-1)*outCol+j);
            if (ui<ipmInfo.ipmLeft || ui>ipmInfo.ipmRight || vi<ipmInfo.ipmTop || vi>ipmInfo.ipmBottom)
                outImage(i,j,ch) = means;
            else
                x1 = int32(ui); x2 = int32(ui+1);
                y1 = int32(vi); y2 = int32(vi+1);
                x = ui-double(x1) ;  y = vi-double(y1);
                val = double(RR(y1,x1))*(1-x)*(1-y)+double(RR(y1,x2))*x*(1-y)+double(RR(y2,x1))*(1-x)*y+double(RR(y2,x2))*x*y;
                outImage(i,j,ch) = val;
            end
        end
    end
end