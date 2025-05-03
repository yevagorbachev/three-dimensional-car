classdef playable < handle & matlab.mixin.Heterogeneous
    properties (GetAccess = public, SetAccess = protected)
        graphic
    end
    methods (Abstract, Access = public)
        render(obj, time);
    end
end
