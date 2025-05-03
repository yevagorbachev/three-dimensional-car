classdef signalplayer < playable
    properties
        base (1,1) matlab.graphics.chart.primitive.Line;
        time (1,:) duration;
    end

    methods
        function sp = signalplayer(lineobj, timeinfo)
            if isduration(lineobj.XData)
                timeinfo = lineobj.XData;
            end

            if length(timeinfo) ~= length(lineobj.XData)
                error("Time and data are different sizes");
            end

            sp.time = timeinfo;
            sp.base = lineobj;
            sp.graphic = copyobj(sp.base, sp.base.Parent);
            sp.base.HandleVisibility = "off";
            sp.base.Color(4) = 0.2;

            sp.render(-Inf);
        end

        function render(sp, time)
            valid_indices = sp.time <= seconds(time);
            sp.graphic.XData = sp.base.XData(valid_indices);
            sp.graphic.YData = sp.base.YData(valid_indices);
        end
    end
end
