function pitch_out = estimate_pitch(cameraInfo,vp)

% pitch = sym('pitch','real');
% theta = sym('theta','real');

syms pitch;
theta = 0;

pi = 3.1415926;
vpp = [ sin(theta*pi/180)/cos(pitch*pi/180);
        cos(theta*pi/180)/cos(pitch*pi/180);
        0];

 tyawp = [
	  cos(cameraInfo.yaw*pi/180), -sin(cameraInfo.yaw*pi/180), 0;         
	  sin(cameraInfo.yaw*pi/180), cos(cameraInfo.yaw*pi/180), 0;
      0, 0, 1];
 tpitchp = [1, 0, 0;
            0, -sin(pitch*pi/180), -cos(pitch*pi/180);
            0, cos(pitch*pi/180), -sin(pitch*pi/180)];
 transform = tyawp*tpitchp;
 t1p = [
    cameraInfo.focalLengthX, 0, cameraInfo.opticalCenterX;
    0, cameraInfo.focalLengthY, cameraInfo.opticalCenterY;
    0, 0, 1];
transform = t1p*transform;

vp_symbol = transform*vpp;

vp_symbol = vp_symbol / vp_symbol(3)  - [vp(2),vp(1),0]';

out = solve(vp_symbol(2),pitch);
pitch_out = eval(out);
pitch_out = real(pitch_out(find(pitch_out>0)));


end



