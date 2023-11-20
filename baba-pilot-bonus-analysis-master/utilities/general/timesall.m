function result = timesall(varargin)
    if( nargin > 0 )
        result = varargin{1};
        for k=2:nargin
            result = result(:) * reshape(varargin{k},1,[]);
        end
        result = reshape(result,1,[]);
    else
        result = [];
    end
end