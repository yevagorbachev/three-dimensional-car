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
graphic = rigidbody.box3d(1, 3, 0.5);
wheel = rigidbody.box3d(0.25, 0.25, 0.25);
xlabel("x");
ylabel("y");
zlabel("z");
daspect([1 1 1]);
view([-26 17])

rb1 = rigidbody(graphic, position = position, orientation = rotation);
rb2 = rigidbody(wheel, ...
    orientation = timetable(theta', VariableNames = "theta", RowTimes = seconds(time)), ...
    origin = rb1, offset = [1 3 0.5]/2);
plr = player([rb1 rb2]);
plr.play([min(time) max(time)], 1);

xlim([0 10]);
ylim([0 10]);
zlim([-2 2]);
