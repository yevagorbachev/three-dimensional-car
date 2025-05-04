params;

t_f = 30;
mdl = "vehicle";

vehicle_pos_0 = [0; -10; cg_to_road];
vehicle_vel_0 = [5; 0; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(0);
pitch = deg2rad(0);
roll = deg2rad(0);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

steer_time = 0;
torque_time = 0;
front_steer = deg2rad([-5 -5]);
% front_steer = [0 0];
front_torque = [0 0];
% front_torque = [-100 -100];

% front_torque = [0 0];
rear_steer = [0 0];
rear_torque = [20 20];

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

wheel_sigs = ["load", "sideslip", "sideforce", "fwdvel", "sidevel"];
body_sigs = ["speed", "yaw_rate"];

n_plots = length(wheel_sigs) + length(body_sigs);
logsout = convert(logsout, "rad", "deg", @rad2deg);
logsout.speed = vecnorm(logsout.("vehicle.vel"), 2, 2);
logsout.yaw_rate = logsout.("vehicle.spin")(:, 3);

sz_anim = ceil(n_plots/2);
sz_traj = floor(n_plots/2);

figure; 
layout = tiledlayout(n_plots, 2);
layout.TileIndexing = "columnmajor";

nexttile([sz_anim 1]);
bx = rigidbody.box3d([cg_to_front cg_to_rear], base_width, ...
    [cg_to_road vehicle_height - cg_to_road]);
[rb, cam] = car_player(bx, logsout, zlim = [-cg_to_road 2.5]);

nexttile([sz_traj 1]);

traj = plot(logsout.("vehicle.pos")(:,1), logsout.("vehicle.pos")(:,2));
traj_sp = signalplayer(traj, logsout.Time);
daspect([1 1 1]);

[splayers, axes] = wheeldata_players(layout, logsout, wheel_sigs, ...
    labels = ["Load", "Sideslip", "Side force", "V_x", "V_y"]);

yline(axes(1), vehicle_mass * grav/4, "--k", Label = "W/4", HandleVisibility = "off");
ylim(axes(2), [-10 10]);

vc_splayers = signalplayer.empty()
for i_vc = 1:length(body_sigs);
    nexttile; hold on; grid on;
    lh = plot(logsout.Time, logsout.(body_sigs(i_vc)));
    vc_splayers(end+1) = signalplayer(lh);
end

plr = player([rb, cam, traj_sp, splayers, vc_splayers]);
plr.play([0 t_f], 1);

