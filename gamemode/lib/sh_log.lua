Log = Log or {}

local white = Color(255, 255, 255)
local red = Color(255, 0, 0)

-- @tparam Color color
-- @tparam string tag
-- @tparam string m
local function log(color, tag, m)
    local t = os.date('%X')
    MsgAll(t, '\t', tag, '\t',  m, '\n')
    MsgC(red, "[MRP] ", white, t, '\t', tag, '\t',  m, '\n')
end

Log.d = function(tag, m)
    if not MRP.Debug then return end
    log(white, tag, m)
end

Log.e = function(tag, m)
    if not MRP.Debug then return end
    log(red, tag, m)
    error(m)
end


