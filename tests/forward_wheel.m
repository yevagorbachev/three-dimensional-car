params;

t_0 = 0;
t_f = 1;
step_time = 0.5;
initial_torque = -10;
final_torque = 50;
% final_torque = 4e3;
initial_spin = 0;
si = Simulink.SimulationInput("single_wheel_translation");

% dt = 0.001;
solver = "ode15s";
si = si.setModelParameter(SolverType = "Variable-step", SolverName = solver);

tim = tic;
so = sim(si);
fprintf("Solver <%s> Finished in %.2f sec\n", solver, toc(tim));
logs_15s = extractTimetable(so.logsout);
fprintf("%d time steps taken\n", height(logs_15s));

calc_accel = logs_15s.torque / (vehicle_mass * wheel_radius^2 + wheel_inertia);
calc_baccel = (logs_15s.torque / wheel_radius) / (vehicle_mass + wheel_inertia / wheel_radius^2);
logs_15s.calc_spin = cumtrapz(seconds(logs_15s.Time), calc_accel);
logs_15s.calc_vel = cumtrapz(seconds(logs_15s.Time), calc_baccel);

solver = "ode45";
si = si.setModelParameter(SolverType = "Variable-step", SolverName = solver);
tim = tic;
so = sim(si);
fprintf("Solver <%s> Finished in %.2f sec\n", solver, toc(tim));
logs_45 = extractTimetable(so.logsout);
fprintf("%d time steps taken\n", height(logs_45));


figure(name = "Cut view");
layout = tiledlayout(2,2);
layout.TileSpacing = "tight";
sgtitle("Longitudinal Force Verification")
xlabel(layout, "Time");

    spin = nexttile; hold on; grid on;
plot(logs_15s.Time, logs_15s.spin, DisplayName = "ode15s");
plot(logs_45.Time, logs_45.spin, DisplayName = "ode45");
plot(logs_15s.Time, logs_15s.calc_spin, DisplayName = "Caculated from torque");
lg = legend(Orientation = "horizontal");
lg.Layout.Tile = "north";
ylabel("Wheel spin [rad/s]");

vel = nexttile; hold on; grid on;
plot(logs_15s.Time, logs_15s.vel, DisplayName = "ode15s");
plot(logs_45.Time, logs_45.vel, DisplayName = "ode45");
plot(logs_15s.Time, logs_15s.calc_vel, DisplayName = "Caculated from torque");
ylabel("Body velocity [m/s]");

slip = nexttile; hold on; grid on;
plot(logs_15s.Time, 100 * logs_15s.slip, DisplayName = "ode15s");
plot(logs_45.Time, 100 * logs_45.slip, DisplayName = "ode45");
ylabel("Slip ratio [%]");

force = nexttile; hold on; grid on;
plot(logs_15s.Time, logs_15s.force, DisplayName = "ode15s");
plot(logs_45.Time, logs_45.force, DisplayName = "ode45");
plot(logs_15s.Time, logs_15s.torque / wheel_radius, DisplayName = "Caculated from torque");
if (final_torque / wheel_radius) > (0.9 * vehicle_mass)
    yline(vehicle_mass * grav, "--k", Label = "$mg$", Interpreter = "latex", HandleVisibility = "off")
end
ylabel("Tractive force [N]");

linkaxes([spin vel slip force], "x");

cut_fig = figure(name = "Full view");
new_layout = copyobj(layout, cut_fig);
new_lgn = findobj(new_layout, Type = "Legend");
new_lgn.Layout.Tile = "north";

xlim(force, seconds(0.6 + 1e-6 * [0 20]));
