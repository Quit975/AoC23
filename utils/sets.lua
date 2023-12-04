Set = {}

function Set.New (t)
    local set = {}
    local size = 0
    for _, l in ipairs(t) do set[l] = true; size = size + 1 end
    return set, size
end

function Set.Union (a,b)
    local res = Set.New{}
    local size = 0
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    for _ in pairs(res) do size = size + 1 end
    return res, size
end

function Set.Intersection (a,b)
    local res = Set.New{}
    local size = 0
    for k in pairs(a) do
        res[k] = b[k]
        if res[k] then
            size = size + 1
        end
    end
    return res, size
end