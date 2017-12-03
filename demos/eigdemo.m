A = [1 2; 3 4]/2;
s = max(abs(eig(A)));

clf
axis([-s s -s s]);
grid
title('Eigenvector demonstration')
xlabel('x');
ylabel('y');
axis equal
hold on

%anim = Animate('eigs');

axis(axis)
l1 = arrow([0 0]', [0 0]', 'FaceColor', 'r', 'EdgeColor', 'r', 'Width', 1.5);  % input vector
l2 = arrow([0 0]', [0 0]', 'FaceColor', 'b', 'EdgeColor', 'b', 'Width', 1.5);  % transformed vector

legend({'v', 'A*v'}, 'Location', 'southeast', 'FontSize', 16)

for k=1:500
    theta = -k/500*2*pi;
    
    x = cos(theta); y = sin(theta);
    v = [x y]';
    vp = A*v;
    
    arrow(l1, 'Stop', v);
    arrow(l2, 'Stop', vp);
    
    %anim.add();
    pause(0.05);
end
    
    