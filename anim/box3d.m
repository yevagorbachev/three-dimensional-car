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

    pa = patch(xverts(idx), yverts(idx), zverts(idx), "r", FaceAlpha = 0.1);
end

