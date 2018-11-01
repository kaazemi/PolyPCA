function x = init(default,fieldName,optsin)
    if nargin < 3 || ~isfield(optsin,fieldName)
        x = default;
    else
        x = optsin.(fieldName);
    end
end
