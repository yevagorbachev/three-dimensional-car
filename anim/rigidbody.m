classdef rigidbody < playable
    properties
        pointdata (:, :, 3) double;
        position (1,1) griddedInterpolant;
        orientation (1,1) griddedInterpolant;
        scale (1,1) griddedInterpolant

        origin (1,:) rigidbody;
        offset (1,1,3) double;
    end

    methods
        function body = rigidbody(graphic, motion)
            arguments
                graphic handle;
                motion.position timetable = timetable;
                motion.orientation timetable = timetable;
                motion.scale timetable = timetable;
                motion.origin = rigidbody.empty(1,0);
                motion.offset (3,1) double = [0; 0; 0]
            end

            body.graphic = graphic;
            body.pointdata = body.vertices_from_graphic();
            body.set_position_data(motion.position);
            body.set_orientation_data(motion.orientation);
            body.set_scale_data(motion.scale);
            body.origin = motion.origin;
            body.offset = motion.offset;
        end

        function set_position_data(body, tab)
            arguments
                body (1,1) rigidbody;
                tab timetable;
            end

            if isempty(tab)
                tab = timetable(RowTimes = seconds([0 1e-10]));
            end

            cols = tab.Properties.VariableNames;
            required_cols = ["x", "y", "z"];
            not_present = setdiff(required_cols, cols);
            tab{:, not_present} = zeros(height(tab), length(not_present));

            body.position = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["x", "y", "z"]}, "spline", "nearest");
        end

        function set_orientation_data(body, tab)
            arguments
                body (1,1) rigidbody;
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

            body.orientation = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["s", "i", "j", "k"]}, "spline", "nearest");
        end

        function set_scale_data(body, tab)
            arguments
                body (1,1) rigidbody;
                tab timetable;
            end

            if isempty(tab)
                tab = timetable(RowTimes = seconds([0 1e-10]));
            end

            cols = tab.Properties.VariableNames;
            required_cols = ["x", "y", "z"];
            not_present = setdiff(required_cols, cols);
            tab{:, not_present} = ones(height(tab), length(not_present));
            
            body.scale = griddedInterpolant(seconds(tab.Time), ...
                tab{:, ["x", "y", "z"]}, "spline", "nearest");
        end

        function vertices = compute_vertices(body, vertices, time)
            arguments
                body rigidbody;
                vertices (:, :, 3) double;
                time (1,1) double
            end

            quat = body.orientation(time);
            direction = rigidbody.quat_to_direction(quat);
            vertices = tensorprod(direction, vertices, 2, 3);
            % tensor-product outputs 3xMxN for MxNx3 <vertices> input, 
            % but setting (1xMxN) that should be last
            vertices = permute(vertices, [2 3 1]);
            % position is (Tx3) when queried -- move 3 to the page dimension
            position = body.position(time);
            vertices = vertices + permute(position, [1 3 2]);

            if ~isempty(body.origin)
                vertices = vertices + body.origin.compute_vertices(body.offset, time);
            end
        end

        function render(body, time)
            arguments (Input)
                body (1,1) rigidbody;
                time (1,1) double;
            end

            vt = body.compute_vertices(body.pointdata, time);
            body.vertices_to_graphic(vt);
        end
    end

    methods (Access = protected)
        function vertices = vertices_from_graphic(body)
            arguments (Input)
                body (1,1) rigidbody;
            end
            arguments (Output)
                vertices (:, :, 3) double;
            end
            if isempty(body.graphic.ZData)
                body.graphic.ZData = zeros(size(body.graphic.YData));
            end
            
            vertices = cat(3, body.graphic.XData, body.graphic.YData, body.graphic.ZData);
        end

        function vertices_to_graphic(body, vertices)
            arguments (Input)
                body (1,1) rigidbody;
                vertices (:, :, 3) double;
            end

            body.graphic.XData = vertices(:, :, 1);
            body.graphic.YData = vertices(:, :, 2);
            body.graphic.ZData = vertices(:, :, 3);
        end
    end

    methods (Static)
        function direction = quat_to_direction(quat)
            arguments (Input)
                quat (1,4) double;
            end 
            arguments (Output)
                direction (3,3) double;
            end

            quat = quat / vecnorm(quat, 2, 2);
            qr = quat(1);
            qi = quat(2);
            qj = quat(3);
            qk = quat(4);

            direction = [1-2*(qj.^2+qk.^2), 2.*(qi.*qj - qk.*qr), 2.*(qi.*qk + qj.*qr);
                        2.*(qi.*qj+qk.*qr), 1-2.*(qi.^2 + qk.^2), 2.*(qj.*qk - qi.*qr);
                        2.*(qi.*qk - qj.*qr), 2.*(qj.*qk + qi.*qr), 1 - 2.*(qi.^2 + qj.^2)];
        end

        function pa = box3d(len, wid, hgt)
            arguments
                len (1,:) double;
                wid (1,:) double;
                hgt (1,:) double;
            end
            % from MATLAB answers 
            % https://www.mathworks.com/matlabcentral/answers/1578550-how-to-plot-a-3d-cube-based-if-i-have-the-coordinates-of-the-8-surrounding-nodes

            if isscalar(len) 
                len = [len/2 len/2];
            end
            if isscalar(wid)
                wid = [wid/2 wid/2];
            end
            if isscalar(hgt)
                hgt = [hgt/2 hgt/2];
            end
            
            coord = [-len(2) -wid(2) -hgt(1);
                len(1) -wid(2) -hgt(1);
                len(1) wid(1) -hgt(1);
                -len(2) wid(1) -hgt(1);
                -len(2) -wid(2) hgt(2);
                len(1) -wid(2) hgt(2);
                len(1) wid(1) hgt(2);
                -len(2) wid(1) hgt(2)];
            idx = [4 8 5 1 4; 
                1 5 6 2 1; 
                2 6 7 3 2; 
                3 7 8 4 3; 
                5 8 7 6 5; 
                1 4 3 2 1]';

            xverts = coord(:, 1);
            yverts = coord(:, 2);
            zverts = coord(:, 3);

            cols = colororder;
            pa = patch(xverts(idx), yverts(idx), zverts(idx), "r", FaceAlpha = 0.1);
        end
    end
end
