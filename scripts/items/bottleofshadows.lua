local this = {}
CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHADOWS = Isaac.GetItemIdByName("Bottle of Shadows")

function this:ShadowStatusEffect(npc)
    local e_data = npc:GetData()
    if e_data.somethingWicked_shadeTick and e_data.somethingWicked_shadeTick > 0 then 
        e_data.somethingWicked_shadeTick = e_data.somethingWicked_shadeTick - 1
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.ShadowStatusEffect)

function this:OnShadeDMGd(ent)
    local e_data = ent:GetData()
    if e_data.somethingWicked_shadeTick and e_data.somethingWicked_shadeTick > 0 then
        
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnShadeDMGd)