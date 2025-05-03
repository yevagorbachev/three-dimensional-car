classdef mobilecamera < playable
    properties (Access = protected)
        position (1,1) griddedInterpolant;
        % orientation (1,1) griddedInterpolant;
        base_lims (3,2) double;
    end
    
    methods
        function mc = mobilecamera(ax, motion)
            arguments
                ax matlab.graphics.axis.Axes;
                motion.position timetable = timetable;
                % motion.orientation timetable = timetable;
            end

            mc.base_lims = [ax.XLim; ax.YLim; ax.ZLim];
            mc.graphic = ax;
            mc.set_position_data(motion.position);
        end

        function render(mc, time)
            new_lims = mc.base_lims + mc.position(time)';

            mc.graphic.XLim = new_lims(1,:);
            mc.graphic.YLim = new_lims(2,:);
            mc.graphic.ZLim = new_lims(3,:);
        end
    end

    methods (Access = protected)
        function set_position_data(mc, tab)
            arguments
                mc (1,1) mobilecamera;
                tab timetable;
            end

            if isempty(tab)
                tab = timetable(RowTimes = seconds([0 1e-10]));
            end

            cols = tab.Properties.VariableNames;
            required_cols = ["x", "y", "z"];
            not_present = setdiff(required_cols, cols);
            tab{:, not_present} = zeros(height(tab), length(not_present));

            mc.position = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["x", "y", "z"]}, "spline", "nearest");
        end
    end
end

