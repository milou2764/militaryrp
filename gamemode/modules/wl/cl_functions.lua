local meta = FindMetaTable('Player')
MRP.WL = MRP.WL or {}

local function wlUpdate()
    local nFac = net.ReadUInt(3)
    for i=1,nFac do
        local nReg = net.ReadUInt(4)
        MRP.WL[i] = {}
        for j=1,nReg do
            MRP.WL[i][j] = net.ReadUInt(2)==1
        end
    end
end

net.Receive("mrp_wl_update", wlUpdate)

function meta:MRPIsRegWL(fac, reg)
    return MRP.WL[fac][reg]
end
