params;

t_f = 5;
mdl = "vehicle";

vehicle_pos_0 = [0; 0; 1.5];
vehicle_vel_0 = [0; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(10);
roll = deg2rad(30);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

steer_time = 0;
torque_time = 0;
front_steer = [0 0];
front_torque = [0 0];

rear_steer = [0 0];
rear_torque = [0 0];

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

figure; 

tiledlayout(1,2);

nexttile;
hold on;
grid on;
view(-50,30);
daspect([1 1 1]);
xlim([-5 5]); ylim([-5 5]); zlim([-0.1 7.5]);
xlabel("x"); ylabel("y"); zlabel("z");

vecornt = quatinv(logsout.("vehicle.ornt"));
ornt = array2timetable(vecornt, RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);
pos = array2timetable(logsout.("vehicle.pos"), RowTimes = logsout.Time, ...
    VariableNames = ["x", "y", "z"]);

bx = rigidbody.box3d([cg_to_front cg_to_rear], base_width, ...
    [cg_to_road vehicle_height - cg_to_road]);
rb = rigidbody(bx, position = pos, orientation = ornt);

nexttile; hold on; grid on;
yline(vehicle_mass * grav/4, "--k", Label = "W/4", HandleVisibility = "off");
sp_lf = signalplayer(plot(logsout.Time, logsout.("leftfront.load"), DisplayName = "LF")); 
sp_rf = signalplayer(plot(logsout.Time, logsout.("rightfront.load"), DisplayName = "RF"));
sp_lr = signalplayer(plot(logsout.Time, logsout.("leftrear.load"), DisplayName = "LR"));
sp_rr = signalplayer(plot(logsout.Time, logsout.("rightrear.load"), DisplayName = "RR"));
legend;

plr = player([rb sp_lf sp_rf sp_lr sp_rr]);
plr.play([0 t_f], 1);
