%% REFERENCE PARAMETERS FOR CLASS 3 PASSENGER CARS
clear;
u = symunit;

grav = 9.81;
vehicle_mass = 7.607 * uconv(u.lbf * u.s^2 / u.in, u.kg);
vehicle_weight = vehicle_mass * grav;
principal_moments = [3085, 20001, 23989] * uconv(u.lbf * u.s^2 * u.in, u.kg * u.m^2);
vehicle_inertia = diag(principal_moments);

wheel_radius = 0.3;
wheel_inertia = 0.8;

cg_to_front = 39.7 * uconv(u.in, u.m);
cg_to_rear = 65.41 * uconv(u.in, u.m);
cg_to_road = 22.05 * uconv(u.in, u.m);
base_width = 58.7 * uconv(u.in, u.m);
% base_width = 30 * uconv(u.in, u.m);
% vehicle_height = 57.9 * uconv(u.in, u.m);
vehicle_height = 1;

front_stiffness = 110 * uconv(u.lbf / u.in, u.N / u.m);
front_damping = 8.69 * uconv(u.lbf/(u.in / u.s), u.N / (u.m / u.s));
rear_stiffness = 114 * uconv(u.lbf / u.in, u.N / u.m);
rear_damping = 6.93 * uconv(u.lbf/(u.in / u.s), u.N / (u.m / u.s));

soln = [2 2; -cg_to_front cg_to_rear] \ [vehicle_weight; 0];
eql_front_force = soln(1);
eql_front_defl = eql_front_force / front_stiffness;
eql_rear_force = soln(2);
eql_rear_defl = eql_rear_force / rear_stiffness;

patch_leftfront = [cg_to_front, base_width/2, -cg_to_road - eql_front_defl];
patch_rightfront = [cg_to_front, -base_width/2, -cg_to_road - eql_front_defl];
patch_leftrear = [-cg_to_rear, base_width/2, -cg_to_road - eql_rear_defl];
patch_rightrear = [-cg_to_rear, -base_width/2, -cg_to_road - eql_rear_defl];

min_velocity = 1e-8;

function ufactor = uconv(nat, tar)
    ufactor = double(unitConversionFactor(nat, tar));
end
