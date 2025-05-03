params;

t_0 = 0;
t_f = 1;
dt = 0.001;

initial_slip = -1;
final_slip = 1;
initial_side = 0;
final_side = 0;
load = vehicle_mass * grav;

so = sim("traction_circle");
lon_hi = extractTimetable(so.logsout);

initial_slip = -1;
final_slip = 1;
initial_side = 0;
final_side = 0;
load = 0.5 * vehicle_mass * grav;
so = sim("traction_circle");
lon_lo = extractTimetable(so.logsout);

initial_slip = 0;
final_slip = 0;
initial_side = -pi/2;
final_side = pi/2;
load = vehicle_mass * grav;
so = sim("traction_circle");
side_hi = extractTimetable(so.logsout);

initial_slip = 0;
final_slip = 0;
initial_side = -pi/2;
final_side = pi/2;
load = 0.5 * vehicle_mass * grav;
so = sim("traction_circle");
side_lo = extractTimetable(so.logsout);


figure(name = "Forces");
layout = tiledlayout(1,2);
sgtitle("Vehicle-terrain models");

nexttile; hold on; grid on;
plot(100 * lon_hi.slip, lon_hi.fwd_force, DisplayName = "mg");
plot(100 * lon_lo.slip, lon_lo.fwd_force, DisplayName = "mg/2");
yline(vehicle_mass*grav * [-1 1], "--k", Label = "$\pm mg$", Interpreter = "latex", ...
    HandleVisibility = "off");
xlabel("Slip [%]");
ylabel("Forward force [N]");

nexttile; hold on; grid on;
plot(rad2deg(side_hi.sideslip), side_hi.side_force, DisplayName = "mg");
plot(rad2deg(side_lo.sideslip), side_lo.side_force, DisplayName = "mg/2");
yline(vehicle_mass*grav * [-1 1], "--k", Label = "$\pm mg$", Interpreter = "latex", ...
    HandleVisibility = "off");
xlabel("Sideslip [deg]");
ylabel("Side force [N]");
lgn = legend(Orientation = "horizontal");
lgn.Layout.Tile = "north";

