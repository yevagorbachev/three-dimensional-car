clear;
t_f = 5;
mdl = "dzhan";
inertia = diag([20; 10; 5]);
vehicle_spin_0 = [0; 50; 0.01];
vehicle_ornt_0 = [1; 0; 0; 0];

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

ornt = array2timetable(logsout.vehicle_ornt, RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);


figure; hold on;

tiledlayout(1,3);

nexttile; hold on;

view(25,30);
daspect([1 1 1]);
xlim([-10 10]);
ylim([-10 10]);
zlim([-10 10]);
bx = rigidbody.box3d(1, 2, 5);

nexttile([1 2]); hold on;
plot(logsout.Time, logsout.vehicle_spin);

rb = rigidbody(bx, orientation = ornt);
plr = player(rb);
plr.play([0 t_f], 0.25);
