Log = Log or {}

local white = Color(255, 255, 255)
local red = Color(255, 0, 0)

-- @tparam Color color
-- @tparam string tag
-- @tparam string m
local function log(color, tag, m)
    local t = os.date('%X')
    MsgC(color, t, '\t', tag, '\t',  m, '\n')
end

Log.d = function(tag, m)
    log(white, tag, m)
end

Log.e = function(tag, m)
    log(red, tag, m)
end


