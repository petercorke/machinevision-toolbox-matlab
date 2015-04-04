function VisualServoTest(testCase)
      tests = functiontests(localfunctions);
end
    
function camera_test(testCase)
    cam = CentralCamera('default');
    s = cam.char();
    cam

    P = mkgrid(3, 1.0, transl(0,0,2));

    uv = cam.project(P)
    cam.plot(P);
    uv = cam.plot(P);


    fov = cam.fov();
    K = cam.K();
    C = cam.C();

    about P
    ray = cam.ray(uv);

    cam.hold()
    cam.plot(P);
    cam.ishold();
    cam.clf();
    cam.plot([200 300 1]');
    cam.homline([200 200 1]');
    cam.plot_camera();
    %cam.plot_epiline();

    J = cam.visjac_p(P, 1);
    J = cam.visjac_p_polar(P, 1);
    %J = cam.visjac_l(P);
    %J = cam.visjac_e(P);
    cam.flowfield([1 0 0 0 0 0]');
end

function epipolar_test(testCase)
    return
    F = fmatrix(uv1, uv2)
    %[F,r] = fmatrix(uv1, uv2)

    epidist(F, uv1, uv2)

    [F,r] = fmatrix([uv1; uv2])

    clearfigs
    cam1 = camera('camera 1');

    P = mkgrid(3, 1.0, transl(0,0,2));
    P

    T = transl(0.5,-0.2,0)*trotx(-0.2)*trotz(0.3);
    T = transl(-0.3, 0.4, -0.8)*trotz(0.5)*troty(.3)*trotx(.3);
    cam2 = camera(T, 'camera 2');

    uv1 = cam1.plot(P, 'o')
    uv2 = cam2.plot(P, 'o')

    H = homography(uv1, uv2)

    homtrans(H, uv1)-uv2

    cam2.hold
    plot2(homtrans(H, uv1)', '+')
    cam2.hold(0)
    cam2.clf

    homtrans(H, uv1)
    homtrans(inv(H), uv2)


    P2 = pinv(cam1.C) * [
        312 512 712
        912 912 912
          1   1   1];

    P2
    cam1.project(P2(1:3,:))
    pause
    % columns at (X,Y,Z) and any multiple will project to the same point
    % set range of points to be 1, 3, 4
    P2 = P2(1:3,:) * diag([1 3 4])
    cam1.project(P2(1:3,:))
    P = [P P2]
    cam1.plot(P, 'o')
    cam2.plot(P, 'o')


    uv1 = cam1.project(P)
    uv2 = cam2.project(P)

    homtrans(H, uv1)-uv2

    H = ransac(@homography, [uv1 uv2], .01)
end
%function sphcamera_test(testCase)
%function panocamera_test(testCase)
