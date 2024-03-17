local lastent = nil
hook.Add("simfphysPhysicsCollide", "MRPsimfphysPhysicsCollide", function(ent, data, _)
    local item = data.HitEntity
    if item.MRPID and item ~= lastent then
        for k = 1, 20 do
            if ent:GetNWInt("Inventory" .. k) < 2 then
                lastent = item
                item:fitIn("Inventory" .. k, ent)
                break
            end
        end
    end
end)
