t_0 = 0;
t_f = 10;

C_i = 210e3;
g = 9.807;
m = 25e3/g;
R = 0.1;
m_w = 20;
J = (2/5)*m_w*R^2;
T = 50;
t_step = 4;
min_velocity = 1e-4;

friction = false;

model = "single_wheel_translation";
sim(model);
