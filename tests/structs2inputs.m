%% Assign structure variables to simulation input
% simin = struct2input(simin, params)
% Inputs
%   simin   Simulink.SimulationInput object or simulation name
%   params  Structure with parameters
% Outputs
%   simin   Simulink.SimulationInput object with assigned variables
%
% % Example
% rocket.A_ref = 23.1e-2;
% rocket.h_0 = 2300;
% rocket.v_0 = 300;
% simin = struct2input("sim_2dof", rocket);
% simout = sim(simin);

function simins = structs2inputs(simin, params)
    arguments
        simin
        params struct
    end
    if isstring(simin)
        simin = Simulink.SimulationInput(simin);
    end

    simins(1:numel(params)) = simin;

    fields = string(fieldnames(params));
    for i_sim = 1:numel(simins)
        for fn = 1:length(fields)
            name = fields(fn);
            simins(i_sim) = simins(i_sim).setVariable(name, params(i_sim).(name));
        end
    end
end
