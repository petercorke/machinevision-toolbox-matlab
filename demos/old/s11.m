camera = Movie('traffic_sequence.mpg');
about camera
camera
im = camera.grab();
idisp(im)
im = camera.grab();
idisp(im)
im = camera.grab();
idisp(im)
im = camera.grab();
idisp(im)
clear camera

camera = AxisWebCamera('http://wc2.dartmouth.edu');
im = camera.grab();
idisp(im)
clear camera

camera = VideoCamera();
im = camera.grab();
idisp(im)
clear camera
