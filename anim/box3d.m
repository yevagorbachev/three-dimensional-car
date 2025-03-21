function pa = box3d(length, width, height)
    arguments
        length (1,1) double;
        width (1,1) double;
        height (1,1) double;
    end
    % from MATLAB answers 
    % https://www.mathworks.com/matlabcentral/answers/1578550-how-to-plot-a-3d-cube-based-if-i-have-the-coordinates-of-the-8-surrounding-nodes
    coord = 0.5*[-1 -1 -1;
        1 -1 -1;
        1 1 -1;
        -1 1 -1;
        -1 -1 1;
        1 -1 1;
        1 1 1;
        -1 1 1];
    idx = [4 8 5 1 4; 
        1 5 6 2 1; 
        2 6 7 3 2; 
        3 7 8 4 3; 
        5 8 7 6 5; 
        1 4 3 2 1]';

    coord = coord .* [length, width, height];
    xverts = coord(:, 1);
    yverts = coord(:, 2);
    zverts = coord(:, 3);

    pa = patch(xverts(idx), yverts(idx), zverts(idx), "r", FaceAlpha = 0.1);
end

