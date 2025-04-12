classdef animator < handle
    properties
        origin (1,:) animator;
        offset (1,1,3) double;
        graphic;
        pointdata (:, :, 3) double;
        position (1,1) griddedInterpolant;
        orientation (1,1) griddedInterpolant;
        end_time (1,1) double = 0;
    end

    methods
        function ani = animator(graphic, motion)
            arguments
                graphic handle;
                motion.position timetable = timetable;
                motion.orientation timetable = timetable;
                motion.origin = animator.empty(1,0);
                motion.offset (3,1) double = [0; 0; 0]
            end

            ani.graphic = graphic;
            ani.pointdata = animator.get_vertices(ani.graphic);
            ani.set_position(motion.position);
            ani.set_orientation(motion.orientation);
            ani.origin = motion.origin;
            ani.offset = motion.offset;
        end

        function set_position(ani, tab)
            arguments
                ani (1,1) animator;
                tab timetable;
            end

            if isempty(tab)
                tab = timetable(RowTimes = seconds([0 1e-10]));
            end

            cols = tab.Properties.VariableNames;
            required_cols = ["x", "y", "z"];
            not_present = setdiff(required_cols, cols);
            tab{:, not_present} = zeros(height(tab), length(not_present));

            ani.position = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["x", "y", "z"]}, "spline", "nearest");
            ani.end_time = max(ani.end_time, seconds(tab.Time(end)));
        end

        function set_orientation(ani, tab)
            arguments
                ani (1,1) animator;
                tab timetable;
            end

            cols = tab.Properties.VariableNames;
            required_cols = ["s", "i", "j", "k"];
            if isempty(cols)
                tab = array2timetable([1 0 0 0; 1 0 0 0], ...
                    VariableNames = required_cols, ...
                    RowTimes = seconds([0 1e-10]));
            elseif isscalar(cols) && (cols == "theta")
                s = cos(tab.theta/2);
                k = sin(tab.theta/2);
                ij = zeros(height(tab), 2);
                tab{:, required_cols} = [s, ij, k];
            elseif (length(cols) == 4) && all(ismember(required_cols, cols))
                % all good
            else
                error("Invalid table input");
            end

            ani.orientation = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["s", "i", "j", "k"]}, "spline", "nearest");
            ani.end_time = max(ani.end_time, seconds(tab.Time(end)));
        end

        function vertices = compute_vertices(ani, vertices, time)
            arguments
                ani animator;
                vertices (:, :, 3) double;
                time (1,1) double
            end

            quat = ani.orientation(time);
            direction = animator.quat_to_direction(quat);
            vertices = tensorprod(direction, vertices, 2, 3);
            % tensor-product outputs 3xMxN for MxNx3 <vertices> input, 
            % but setting (1xMxN) that should be last
            vertices = permute(vertices, [2 3 1]);
            % position is (Tx3) when queried -- move 3 to the page dimension
            position = ani.position(time);
            vertices = vertices + permute(position, [1 3 2]);

            if ~isempty(ani.origin)
                vertices = vertices + ani.origin.compute_vertices(ani.offset, time);
            end
        end

        function animate(anis, rate)
            arguments
                anis (1,:) animator;
                rate (1,1) double = 1;
            end

            t_end = max([anis.end_time]);
            start = tic;
            while true
                time = toc(start)*rate;
                if time > t_end
                    break;
                end
                for i = 1:length(anis)
                    ani = anis(i);
                    vertices = ani.compute_vertices(ani.pointdata, time);
                    animator.set_vertices(ani.graphic, vertices);
                end
                drawnow;
            end
        end
    end

    methods (Static)
        function vertices = get_vertices(graphic)
            arguments (Input)
                graphic handle;
            end
            arguments (Output)
                vertices (:, :, 3) double;
            end
            if isempty(graphic.ZData)
                graphic.ZData = zeros(size(graphic.YData));
            end
            
            vertices = cat(3, graphic.XData, graphic.YData, graphic.ZData);
        end

        function set_vertices(graphic, vertices)
            arguments
                graphic handle;
                vertices (:, :, 3) double;
            end

            graphic.XData = vertices(:, :, 1);
            graphic.YData = vertices(:, :, 2);
            graphic.ZData = vertices(:, :, 3);
        end

        function direction = quat_to_direction(quat)
            arguments (Input)
                quat (1,4) double;
            end 
            arguments (Output)
                direction (3,3) double;
            end

            s = vecnorm(quat, 2, 2)^(-2);
            qr = quat(1);
            qi = quat(2);
            qj = quat(3);
            qk = quat(4);

            direction = [1-2*s.*(qj.^2+qk.^2), 2*s.*(qi.*qj - qk.*qr), 2*s.*(qi.*qk + qj.*qr);
                        2*s.*(qi.*qj+qk.*qr), 1-2*s.*(qi.^2 + qk.^2), 2*s.*(qj.*qk - qi.*qr);
                        2*s.*(qi.*qk - qj.*qr), 2*s.*(qj.*qk + qi.*qr), 1 - 2*s.*(qi.^2 + qj.^2)];
        end
    end
end
