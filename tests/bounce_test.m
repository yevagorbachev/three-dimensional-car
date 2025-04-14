clear;

    t_f = 5;
mdl = "bounce";

vehicle_pos_0 = [0; 0; 1];
vehicle_vel_0 = [0; 2; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(10);
roll = deg2rad(10);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

mass = 1e3; % [kg]
ride_rate = 100e3; % [N/m]
grav = 10; % [N/kg]

length = 2; % [m]
width = 1; % [m]
height = 2; % [m];
rest_length = height/2; % [m]

inertia = mass/12 * diag([width^2 + height^2, length^2 + height^2, length^2 + width^2]);

X_LF = [length/2; width/2; -rest_length];
X_LR = [-length/2; width/2; -rest_length];
X_RF = [length/2; -width/2; -rest_length];
X_RR = [-length/2; -width/2; -rest_length];

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

bx = box3d(length, width, height);

ornt = array2timetable(logsout.vehicle_ornt, RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);
pos = array2timetable(logsout.vehicle_position, RowTimes = logsout.Time, ...
    VariableNames = ["x", "y", "z"]);

ani = animator(bx, position = pos, orientation = ornt);
