params;
adhesion = 1;
weight = vehicle_mass * grav;
resist = 0.008;
leng = cg_to_front + cg_to_rear;
F_max_rwd = (adhesion * weight * (cg_to_front - resist * cg_to_road)/leng)/(1 - adhesion * cg_to_road/leng);
F_max_fwd = (adhesion * weight * (cg_to_rear + resist * cg_to_road)/leng)/(1 + adhesion * cg_to_road/leng);


t_f = 3;
mdl = "vehicle";

vehicle_pos_0 = [0; -10; cg_to_road];
vehicle_vel_0 = [10; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(0);
roll = deg2rad(0);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';
steer_time = 0;
torque_time = 0;
front_steer = [0 0];
rear_steer = [0 0];

%% FWD
inputs = [struct(front_torque = wheel_radius * F_max_fwd/4 * [1 1], rear_torque = [0 0]);
    struct(front_torque = wheel_radius * F_max_fwd/2 * [1 1], rear_torque = [0 0]);
    struct(front_torque = wheel_radius * F_max_fwd * [1 1], rear_torque = [0 0])];

simins = structs2inputs(mdl, inputs);
simouts = sim(simins, ShowProgress = "on");%, TransferBaseWorkspaceVariables = "on");

logs_min = extractTimetable(simouts(1).logsout);
logs_mid = extractTimetable(simouts(2).logsout);
logs_max = extractTimetable(simouts(3).logsout);

figure(name = "FWD traction");
layout = tiledlayout(2,1);
layout.TileSpacing = "tight";

nexttile; hold on; grid on;
plot(logs_min.Time, logs_min.("leftfront.load") + logs_min.("rightfront.load"), ...
    DisplayName = "F/2 Front");
plot(logs_min.Time, logs_min.("leftrear.load") + logs_min.("rightrear.load"), ...
    "--", DisplayName = "F/2 Rear", SeriesIndex = 1);
plot(logs_mid.Time, logs_mid.("leftfront.load") + logs_mid.("rightfront.load"), ...
    DisplayName = "F Front");
plot(logs_mid.Time, logs_mid.("leftrear.load") + logs_mid.("rightrear.load"), ...
    "--", DisplayName = "F Rear", SeriesIndex = 2);
plot(logs_max.Time, logs_max.("leftfront.load") + logs_max.("rightfront.load"), ...
    DisplayName = "2F Front");
plot(logs_max.Time, logs_max.("leftrear.load") + logs_max.("rightrear.load"), ...
    "--", DisplayName = "2F Rear", SeriesIndex = 3);

legend(Location = "northoutside", Orientation = "horizontal");
ylabel("Load");
yline(weight/2, "--k", Label = "W/2", HandleVisibility = "off");
ysecondarylabel("N");

nexttile; hold on; grid on;
plot(logs_min.Time, logs_min.("leftfront.traction") + logs_min.("rightfront.traction"), ...
    DisplayName = "F/2");
plot(logs_mid.Time, logs_mid.("leftfront.traction") + logs_mid.("rightfront.traction"), ...
    DisplayName = "F");
plot(logs_max.Time, logs_max.("leftfront.traction") + logs_max.("rightfront.traction"), ...
    DisplayName = "2F");
yline(F_max_fwd, "--k", Label = "F", LabelVerticalAlignment = "bottom", HandleVisibility = "off");
ylabel("Tractive effort");
ysecondarylabel("N");
ylim([0 F_max_fwd * 1.1]);

xlabel(layout, "Time");

%% RWD
inputs = [struct(rear_torque = wheel_radius * F_max_rwd/4 * [1 1], front_torque = [0 0]);
    struct(rear_torque = wheel_radius * F_max_rwd/2 * [1 1], front_torque = [0 0]);
    struct(rear_torque = wheel_radius * F_max_rwd * [1 1], front_torque = [0 0])];

simins = structs2inputs(mdl, inputs);
simouts = sim(simins, ShowProgress = "on");%, TransferBaseWorkspaceVariables = "on");

logs_min = extractTimetable(simouts(1).logsout);
logs_mid = extractTimetable(simouts(2).logsout);
logs_max = extractTimetable(simouts(3).logsout);

figure(name = "RWD traction");
layout = tiledlayout(2,1);
layout.TileSpacing = "tight";

nexttile; hold on; grid on;
plot(logs_min.Time, logs_min.("leftfront.load") + logs_min.("rightfront.load"), ...
    DisplayName = "F/2 Front");
plot(logs_min.Time, logs_min.("leftrear.load") + logs_min.("rightrear.load"), ...
    "--", DisplayName = "F/2 Rear", SeriesIndex = 1);
plot(logs_mid.Time, logs_mid.("leftfront.load") + logs_mid.("rightfront.load"), ...
    DisplayName = "F Front");
plot(logs_mid.Time, logs_mid.("leftrear.load") + logs_mid.("rightrear.load"), ...
    "--", DisplayName = "F Rear", SeriesIndex = 2);
plot(logs_max.Time, logs_max.("leftfront.load") + logs_max.("rightfront.load"), ...
    DisplayName = "2F Front");
plot(logs_max.Time, logs_max.("leftrear.load") + logs_max.("rightrear.load"), ...
    "--", DisplayName = "2F Rear", SeriesIndex = 3);

legend(Location = "northoutside", Orientation = "horizontal");
ylabel("Load");
yline(weight/2, "--k", Label = "W/2", HandleVisibility = "off");
ysecondarylabel("N");

nexttile; hold on; grid on;
plot(logs_min.Time, logs_min.("leftrear.traction") + logs_min.("rightrear.traction"), ...
    DisplayName = "F/2");
plot(logs_mid.Time, logs_mid.("leftrear.traction") + logs_mid.("rightrear.traction"), ...
    DisplayName = "F");
plot(logs_max.Time, logs_max.("leftrear.traction") + logs_max.("rightrear.traction"), ...
    DisplayName = "2F");
yline(F_max_rwd, "--k", Label = "F", LabelVerticalAlignment = "bottom", HandleVisibility = "off");
ylabel("Tractive effort");
ysecondarylabel("N");
ylim([0 F_max_fwd * 1.1]);

xlabel(layout, "Time");
