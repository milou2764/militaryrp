MRP.SetWL = function(ply,fac,reg,val)
    local wl = MRP.GetWL(ply)
    wl[fac][reg] = val
    local success = MRP.UpdateWL(ply,wl)
    MRP.SendWL(ply)
    return success
end
local getCommand = "mrp_getwl"
local getCommandHelp = getCommand .. " <target name>"
local setCommand = "mrp_setwl"
local commandHelp = setCommand .. " <target name> <faction> <regiment> <0,1>"
local function getCommandFn(ply, _, args)
    local target = MRP.FindPlayer(args[1])
    if target == nil then
        ply:ChatPrint("could not find target")
        ply:ChatPrint(getCommandHelp)
        return false
    else
        ply:ChatPrint("target is " .. target:MRPName())
    end
    local tbl = MRP.GetWL(target)
    ply:ChatPrint(table.ToString(tbl, "wl", true))
end

local function setCommandFn(ply, _, args)
    local target = MRP.FindPlayer(args[1])
    if target == nil then
        ply:ChatPrint("could not find target")
        ply:ChatPrint(commandHelp)
        return false
    else
        ply:ChatPrint("target is " .. target:MRPName())
    end
    local fac = tonumber(args[2])
    if fac==nil then
        ply:ChatPrint("faction should be a digit")
        ply:ChatPrint(commandHelp)
        return false
    end
    local reg = tonumber(args[3])
    if reg==nil then
        ply:ChatPrint("regiment should be a digit")
        ply:ChatPrint(commandHelp)
        return false
    end
    local val = tonumber(args[4])
    if val==nil then
        ply:ChatPrint("end value is either 0 or 1")
        ply:ChatPrint(commandHelp)
    end
    local success = MRP.SetWL(target,fac,reg,val)
    if success then
        ply:ChatPrint("whitelist successfully set")
    else
        ply:ChatPrint("command failed")
    end
end

concommand.Add(getCommand, getCommandFn)
concommand.Add(setCommand, setCommandFn)

hook.Add(
    "PlayerCanSeePlayersChat",
    "MRPWLCommand",
    function(text, _, _, ply)
        Log.d("MRPWL", "hellooooo")
        if string.sub(text, 1, #setCommand+1) == "/"..setCommand then
            local args = string.Split(text, " ")
            table.remove(args, 1)
            return false
        elseif string.sub(text, 1, #getCommand+1) == "/"..getCommand then
            local args = string.Split(text, " ")
            table.remove(args, 1)
            getCommandFn(ply, nil, args)
            return false
        end
    end
)
