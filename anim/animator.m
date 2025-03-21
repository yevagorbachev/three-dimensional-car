classdef animator < handle
    properties
        % origin;
        % offset (3,1) double = [NaN; NaN; NaN];
        graphic;
        pointdata (:, :, 3) double;
        pos_terp (1,1) griddedInterpolant;
        rot_terp (1,1) griddedInterpolant;
    end

    methods
        function ani = animator(graphic, motion)
            arguments
                graphic handle;
                motion.position timetable = timetable;
                motion.rotation timetable = timetable;
            end

            ani.pointdata = animator.get_vertices(graphic);
            ani.graphic = graphic;
            opts = {"spline", "nearest"};

            if isempty(motion.position)
                ani.pos_terp = griddedInterpolant([0 1e-10]', zeros(2,3), opts{:});
            else
                ani.pos_terp = griddedInterpolant(seconds(motion.position.Time), ...
                    motion.position{:, ["x", "y", "z"]}, opts{:});
            end

            if isempty(motion.rotation)
                ani.rot_terp = griddedInterpolant([0 1e-10]', [1 0 0 0; 1 0 0 0], opts{:});
            else
                ani.rot_terp = griddedInterpolant(seconds(motion.rotation.Time), ...
                    motion.rotation{:, ["s", "i", "j", "k"]}, opts{:});
            end
        end

        function vertices = compute_vertices(ani, vertices, time)
            arguments
                ani animator;
                vertices (:, :, 3) double;
                time (1,1) double
            end

            quat = ani.rot_terp(time);
            direction = animator.quat_to_direction(quat);
            vertices = tensorprod(direction, vertices, 2, 3);
            % tensor-product outputs 3xMxN for MxNx3 <vertices> input, 
            % but setting (1xMxN) that should be last
            vertices = permute(vertices, [2 3 1]);
            % position is (Tx3) when queried -- move 3 to the page dimension
            position = ani.pos_terp(time);
            vertices = vertices + permute(position, [1 3 2]);
        end

        function animate(ani)
            arguments
                ani animator;
            end

            t_end = max(ani.pos_terp.GridVectors{1}(end), ani.rot_terp.GridVectors{1}(end));
            start = tic;
            while (isvalid(ani.graphic))
                time = toc(start);
                if time > t_end
                    break;
                end
                vertices = ani.compute_vertices(ani.pointdata, time);
                animator.set_vertices(ani.graphic, vertices);
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
