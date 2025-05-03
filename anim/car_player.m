function [rb, cam] = car_setup(box, logs, opts)
    arguments
        box;
        logs timetable;
        opts.xlims = [-5 5];
        opts.ylims = [-5 5];
        opts.zlims = [-1 2.5];
    end

    ax = box.Parent;
    hold(ax, "on");
    grid(ax, "on");
    view(ax, 3);
    daspect(ax, [1 1 1]);
    xlim(ax, opts.xlims); ylim(ax, opts.ylims); zlim(ax, opts.zlims);
    xlabel(ax, "x [m]"); ylabel(ax, "y [m]"); zlabel(ax, "z [m]");

    vecornt = quatinv(logs.("vehicle.ornt"));
    ornt = array2timetable(vecornt, RowTimes = logs.Time, ...
        VariableNames = ["s", "i", "j", "k"]);
    pos = array2timetable(logs.("vehicle.pos"), RowTimes = logs.Time, ...
        VariableNames = ["x", "y", "z"]);
    
    rb = rigidbody(box, position = pos, orientation = ornt);
    cam = mobilecamera(ax, position = pos);
end

