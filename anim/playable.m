classdef playable < handle
    properties (GetAccess = public, SetAccess = protected)
        graphic
    end
    methods (Abstract, Access = public)
        render(obj, time);
    end
end
