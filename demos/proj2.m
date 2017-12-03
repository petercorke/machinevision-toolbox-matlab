clear cam
fishcam = FishEyeCamera('projection', 'equiangular', 'pixel', 10e-6, 'resolution', [1280 1024])
fishcam.mesh(X, Y, Z);
clear fishcam

catcam = CatadioptricCamera('projection', 'equiangular', 'maxangle', pi/4, 'pixel', 20e-6, 'resolution', [1280 1024])
catcam.mesh(X,Y,Z, 'Tcam', transl(0.5, 0, 0.5))
clear catcam