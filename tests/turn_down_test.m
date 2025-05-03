params;

t_f = 15;
mdl = "vehicle";

vehicle_pos_0 = [-10; -10; cg_to_road + 0.2];
vehicle_vel_0 = [5; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(0);
roll = deg2rad(0);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

torque_time = 0;
steer_time = 2;
% front_steer = deg2rad([20 20]);
front_steer = deg2rad([10 10]);
% front_torque = [100 100];
front_torque = [-100 -100];
rear_steer = [0 0];
rear_torque = [0 0];
friction = true;

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

figure; 

sz = 20;
hold on;
view(-50,30);
daspect([1 1 1]);
xlim([-sz sz]);
ylim([-sz sz]);
zlim([0 10]);
xlabel("x");
ylabel("y");
grid on;

bx = box3d([cg_to_front cg_to_rear], base_width, [cg_to_road vehicle_height - cg_to_road]);

vecornt = quatinv(logsout.("vehicle.ornt"));
ornt = array2timetable(vecornt, RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);
pos = array2timetable(logsout.("vehicle.pos"), RowTimes = logsout.Time, ...
    VariableNames = ["x", "y", "z"]);

ani = animator(bx, position = pos, orientation = ornt);
