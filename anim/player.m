classdef player < handle
    properties
        targets (1,:);
        ticker (1,1) timer;
        start_tic (1,1) uint64;
        rate (1,1) double = 1;
        start_time (1,1) double = NaN;
        end_time (1,1) double;
    end

    properties (Dependent)
        fig (1,1) matlab.ui.Figure;
        time (1,1) double;
    end

    methods
        function plr = player(targets)
            arguments
                targets (1,:) playable;
            end
            plr.targets = targets;
            plr.ticker = timer;
            plr.ticker.ExecutionMode = "fixedRate";
            plr.ticker.StartFcn = @timer_start_fcn;
            plr.ticker.StopFcn = @timer_stop_fcn;
            plr.ticker.TimerFcn = @timer_run_fcn;
            plr.ticker.Period = 1/100;
            
            function timer_start_fcn(timer, event)
                plr.start_tic = tic;
                fprintf("Starting animation over %2g-%2g sec at %2gx\n", ...
                    plr.start_time, plr.end_time, plr.rate)
                figure(plr.fig);
            end

            function timer_run_fcn(timer, event)
                tm = plr.time;
                if tm > plr.end_time
                    plr.ticker.stop;
                end
                for tar = plr.targets
                    tar.render(tm);
                end
            end

            function timer_stop_fcn(timer, event)
                fprintf("Finished animation\n");
                plr.start_time = plr.time;
            end
        end

        function play(plr, rng, rate)
            arguments
                plr (1,1) player;
                rng (1,2) double;
                rate (1,1) double = 1;
            end
            plr.rate = rate;
            plr.start_time = rng(1);
            plr.end_time = rng(2);
            plr.ticker.start;
        end

        function resume(plr)
            if ~isfinite(plr.start_time)
                error("Player not started");
            end
            plr.ticker.start;
        end

        function stop(plr)
            plr.ticker.stop;
        end

        function tm = get.time(plr)
            tm = plr.rate * toc(plr.start_tic) + plr.start_time;
        end

        function fig = get.fig(plr)
            gh1 = plr.targets(1).graphic;
            fig = ancestor(gh1, "matlab.ui.Figure");
        end
    end
end
