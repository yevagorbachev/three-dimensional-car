t_f = 5;
mdl = "dzhan";
inertia = diag([20; 10; 5]);
vehicle_spin_0 = [0; 10; 0.01];
vehicle_ornt_0 = [1; 0; 0; 0];

simout = sim(mdl);
logsout = extractTimetable(simout.logsout);

ornt = array2timetable(logsout.vehicle_ornt, RowTimes = logsout.Time, ...
    VariableNames = ["s", "i", "j", "k"]);

figure; hold on;

view(25,30);
daspect([1 1 1]);
xlim([-10 10]);
ylim([-10 10]);
zlim([-10 10]);

bx = box3d(1, 2, 5);
ani = animator(bx, orientation = ornt);
ani.animate;
