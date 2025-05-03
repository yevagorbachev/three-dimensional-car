function [sps, axs] = wheeldata_players(layout, logs, parts, opts)
    arguments (Input)
        layout
        logs timetable
        parts (1,:) string {mustBeNonempty};
        opts.wheels (1,:) string {mustBeMember(opts.wheels, ...
            ["leftfront" "rightfront" "leftrear" "rightrear"])} = ...
            ["leftfront" "rightfront" "leftrear" "rightrear"];
        opts.labels (1,:) string = parts; 
    end

    arguments (Output)
        sps (1,:) signalplayer;
        axs (1,:) matlab.graphics.axis.Axes;
    end

    names.leftfront = "LF";
    names.rightfront = "RF";
    names.leftrear = "LR";
    names.rightrear = "RR";

    if length(opts.labels) < length(parts)
        error("Labels must be same length as data, if specified");
    end

    sps = signalplayer.empty();
    
    for i_part = 1:length(parts)
        axs(i_part) = nexttile(layout);
        hold on; 
        grid on;
        for i_wheel = 1:length(opts.wheels)
            item = opts.wheels(i_wheel) + "." + parts(i_part);
            lh = plot(logs.Time, logs.(item), ...
                DisplayName = names.(opts.wheels(i_wheel)));
            sps(end+1) = signalplayer(lh);
        end
        if i_part == 1
            legend(Location = "northoutside", Orientation = "horizontal");
        end
        first_item = opts.wheels(1) + "." + parts(i_part);
        un = logs.Properties.VariableUnits{first_item};
        if un == ""
            ylabel(opts.labels(i_part));
        else
            ylabel(sprintf("%s [%s]", opts.labels(i_part), un));
        end
    end
end
