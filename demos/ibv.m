cam = CentralCamera('default');
P = mkgrid(2, 0.5, 'T', transl(0,0,3));
pStar = bsxfun(@plus, 200*[-1 -1 1 1; -1 1 1 -1], cam.pp')

Tc0 = transl(1,1,-3)*trotz(0.6);
ibvs= IBVS(cam, 'T0', Tc0, 'pstar', pStar)
ibvs.run()
ibvs.plot_p()
ibvs.plot_vel()
ibvs.plot_camera()
ibvs.plot_jcond()
clf

ibvs = IBVS_l(cam, 'example');
ibvs.run()
