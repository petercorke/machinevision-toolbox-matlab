cam = CentralCamera('default')
about cam
cam.C
cam.K
P = mkgrid(3 ,0.2, 'T', transl(0, 0, 1.0));
cam.plot(P)
cam.plot(P, 'Tcam', transl(-1,0,0.5)*troty(0.9));
figure(2)
plot_sphere(P, 0.01, 'b');
cam.plot_camera(P)

cam.clf
[X,Y,Z] = mkcube(0.2, 'T', transl(0, 0, 0.6), 'edge');
cam.mesh(X, Y, Z);
cam.mesh(X, Y, Z, 'Tcam', transl(-1,0,0.5)*troty(0.9));
