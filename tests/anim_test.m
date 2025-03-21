time = 0:0.1:10;

omega = 10;
theta = omega*time;
uvec = [0; 1; 0];
quat = [sin(theta/2); cos(theta/2).*uvec];
rotation = array2timetable(quat', VariableNames = ["s", "i", "j", "k"], RowTimes = seconds(time));

v = 1;
x = [v*time; v*time; zeros(1, length(time))];
position = array2timetable(x', VariableNames = ["x", "y", "z"], RowTimes = seconds(time));

figure;
graphic = box3d(1, 3, 0.5);
xlabel("x");
ylabel("y");
zlabel("z");
daspect([1 1 1]);
view([-26 17])
ani = animator(graphic, position = position, rotation = rotation);

xlim([0 10]);
ylim([0 10]);
zlim([-2 2]);
