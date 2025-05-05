params;

radius = 500; % [m]
speed = 20; % [m/s]
steer = (cg_to_front + cg_to_rear) / radius;
calc_sideslip = speed^2 / (grav * radius);
ss_torque = vehicle_mass * grav * sin(sin(steer)) * wheel_radius;

t_f = 200;
mdl = "vehicle";

vehicle_pos_0 = [0; -radius; cg_to_road];
vehicle_vel_0 = [speed; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(0);
roll = deg2rad(0);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';
wheel_spin_0 = speed / wheel_radius;

steer_time = 0;
torque_time = 0;
front_steer = [steer steer];
% front_steer = [0 0];
% front_torque = [30 30];
% front_torque = [-100 -100];

front_torque = [0 0];
rear_steer = [0 0];
% rear_torque = [1.1 1.1];

rear_torque = ss_torque * [0.5 0.5];

simout = sim(mdl);
logs = extractTimetable(simout.logsout);

wheel_sigs = ["load", "sideslip", "sideforce", "fwdvel"];

n_plots = length(wheel_sigs)
logs = convert(logs, "rad", "deg", @rad2deg);
logs.speed = vecnorm(logs.("vehicle.vel"), 2, 2);
logs.yaw_rate = logs.("vehicle.spin")(:, 3);

sz_anim = ceil(n_plots/2);
sz_traj = floor(n_plots/2);

figure(name = "Vehicle trajectory");
hold on; grid on;
plot(logs.("vehicle.pos")(:,1), logs.("vehicle.pos")(:,2));
daspect([1 1 1]);
xlabel("x"); ylabel("y");
xsecondarylabel("m"); ysecondarylabel("m");

figure(name = "Load transfer and sideslip");
layout = tiledlayout(2,1);
layout.TileSpacing = "tight";

nexttile; hold on; grid on;
plot(logs.Time, logs.("leftfront.sideslip"), DisplayName = "LF");
plot(logs.Time, logs.("rightfront.sideslip"), DisplayName = "RF");
plot(logs.Time, logs.("leftrear.sideslip"), DisplayName = "LR");
plot(logs.Time, logs.("rightrear.sideslip"), DisplayName = "RR");
yline(-rad2deg(calc_sideslip), "--k", Label = "\alpha", DisplayName = "Calculated");
legend(Location = "northoutside", Orientation = "horizontal");
ylabel("Sideslip angle");
ysecondarylabel("deg");

nexttile; hold on; grid on;
plot(logs.Time, logs.("leftfront.load"), DisplayName = "LF");
plot(logs.Time, logs.("rightfront.load"), DisplayName = "RF");
plot(logs.Time, logs.("leftrear.load"), DisplayName = "LR");
plot(logs.Time, logs.("rightrear.load"), DisplayName = "RR");
ylabel("Load");
ysecondarylabel("N");

xlabel(layout, "Time");


figure(name = "Animations"); 
layout = tiledlayout(n_plots, 2);
layout.TileIndexing = "columnmajor";

nexttile([sz_anim 1]);
bx = rigidbody.box3d([cg_to_front cg_to_rear], base_width, ...
    [cg_to_road vehicle_height - cg_to_road]);
[rb, cam] = car_player(bx, logs, zlim = [-cg_to_road 2.5]);

nexttile([sz_traj 1]);
grid on; hold on;
traj = plot(logs.("vehicle.pos")(:,1), logs.("vehicle.pos")(:,2));
traj_sp = signalplayer(traj, logs.Time);
daspect([1 1 1]);
xlabel("x"); ylabel("y");

[splayers, axes] = wheeldata_players(layout, logs, wheel_sigs, ...
    labels = ["Load", "Sideslip", "Side force", "Forward speed"]);

yline(axes(1), vehicle_mass * grav/4, "--k", Label = "W/4", HandleVisibility = "off");
yline(axes(2), -rad2deg(calc_sideslip), "--k", Label = "\alpha", HandleVisibility = "off")

plr = player([rb, cam, traj_sp, splayers]);
% plr.play([0 t_f], 10);

