params;

t_f = 20;
mdl = "vehicle";

vehicle_pos_0 = [0; 10; cg_to_road];
vehicle_vel_0 = [0; 10; 0];
vehicle_spin_0 = [0; 0; 0];
yaw = deg2rad(-90);
pitch = deg2rad(0);
roll = deg2rad(0);
vehicle_ornt_0 = quatinv(angle2quat(yaw, pitch, roll))';

steer_time = 0;
torque_time = 2;
front_steer = deg2rad([-10 -10]);
% front_steer = [0 0];
% front_torque = [100 100];
% front_torque = [-100 -100];

front_torque = [0 0];
rear_steer = [0 0];
rear_torque = [0 0];
friction = true;

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

sigs = ["load", "sideslip", "sideforce"];

sz_anim = ceil(length(sigs)/2);
sz_traj = floor(length(sigs)/2);

figure; 
layout = tiledlayout(length(sigs), 2);
layout.TileIndexing = "columnmajor";

nexttile([sz_anim 1]);
bx = rigidbody.box3d([cg_to_front cg_to_rear], base_width, ...
    [cg_to_road vehicle_height - cg_to_road]);
[rb, cam] = car_player(bx, logsout, zlim = [-cg_to_road 2.5]);

nexttile([sz_traj 1]);

traj = plot(logsout.("vehicle.pos")(:,1), logsout.("vehicle.pos")(:,2));
traj_sp = signalplayer(traj, logsout.Time);
daspect([1 1 1]);

[splayers, axes] = wheeldata_players(layout, logsout, sigs, ...
    labels = ["Load", "Sideslip", "Side force"]);

yline(axes(1), vehicle_mass * grav/4, "--k", Label = "W/4", HandleVisibility = "off");

plr = player([rb, cam, traj_sp, splayers]);
plr.play([0 t_f], 1);

