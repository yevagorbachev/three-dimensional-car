params;

t_f = 5;
mdl = "vehicle";

vehicle_pos_0 = [0; 0; 1];
vehicle_vel_0 = [0; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(10);
roll = deg2rad(10);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

figure; 

hold on;
view(-50,30);
daspect([1 1 1]);
xlim([-10 10]);
ylim([-10 10]);
zlim([0 10]);
xlabel("x");
ylabel("y");
grid on;

bx = box3d([cg_to_front cg_to_rear], base_width, [cg_to_road vehicle_height - cg_to_road]);

ornt = array2timetable(logsout.("vehicle.ornt"), RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);
pos = array2timetable(logsout.("vehicle.pos"), RowTimes = logsout.Time, ...
    VariableNames = ["x", "y", "z"]);

ani = animator(bx, position = pos, orientation = ornt);
