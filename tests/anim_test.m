time = 0:0.1:10;

omega = 10;
theta = omega*time;
uvec = [0; 1; 0];
quat = [sin(theta/2); cos(theta/2).*uvec];
rotation = array2timetable(quat', VariableNames = ["s", "i", "j", "k"], RowTimes = seconds(time));

v = 1;
x = [v*time; v*time];
position = array2timetable(x', VariableNames = ["x", "y"], RowTimes = seconds(time));

figure;
graphic = box3d(1, 3, 0.5);
wheel = box3d(0.25, 0.25, 0.25);
xlabel("x");
ylabel("y");
zlabel("z");
daspect([1 1 1]);
view([-26 17])

ani = animator(graphic, position = position, orientation = rotation);
ani2 = animator(wheel, ...
    orientation = timetable(theta', VariableNames = "theta", RowTimes = seconds(time)), ...
    origin = ani, offset = [1 3 0.5]/2);
anis = [ani ani2];

xlim([0 10]);
ylim([0 10]);
zlim([-2 2]);
