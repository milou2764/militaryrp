AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Caisse de ravitaillement"
ENT.Category = "4 - Caisses de ravitaillement"
ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/wood_crate001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:GetPhysicsObject():EnableMotion(false)
    end

    function ENT:drop(slotName, target, activator)
        target:SetNWInt(slotName, 1)
        local ent = ents.Create(self.ClassName)
        ent:Spawn()
        ent:SetPos(activator:EyePos() - Vector(0, 0, 10))

        return ent
    end

    function ENT:PhysicsCollide(data, collider)
        if not IsFirstTimePredicted() then return end
        local item = data.HitEntity

        if item.MRPID then
            for k = 1, 20 do
                if self:GetNWInt("Inventory" .. k) < 2 then
                    item:fitIn("Inventory" .. k, self)
                    break
                end
            end
        end
    end
else
    function ENT:Initialize()
        self:Draw()
    end

    function ENT:Draw()
        self:DrawModel()
    end

    hook.Add("StartCommand", "MRPOpenCrate", function(ply, CUserCmd)
        if not IsFirstTimePredicted() then return end

        if CUserCmd:KeyDown(32) and ply == LocalPlayer() then
            local ent = ply:GetEyeTrace().Entity
            if not ent or not IsValid(ent) then return end

            if ent:GetClass() == "mrp_crate" and (not MRP.chestPanel or not IsValid(MRP.chestPanel)) and ply:GetPos():Distance(ent:GetPos()) < 100 then
                if not MRP.plyInvPanel or not IsValid(MRP.plyInvPanel) then
                    MRP.createDropZone()
                    MRP.OpenPlyInvPanel(ply)
                    MRP.OpenChest(ent)
                else
                    MRP.OpenChest(ent)
                end
            end
        end
    end)
end