local this = {}
CollectibleType.SOMETHINGWICKED_ICE_WAND = Isaac.GetItemIdByName("Ice Wand")

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, _, player, flags)
    SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_ICE_WAND)
end, CollectibleType.SOMETHINGWICKED_ICE_WAND)

function this:IceWandUpdate(player)
    if SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_ICE_WAND) then
        local tear = player:FireTear(player.Position, (SomethingWicked.HoldItemHelpers:GetUseDirection(player)), false, true, false)
        tear.Velocity = tear.Velocity:Resized(15)
        local t_data = tear:GetData()
        t_data.somethingWicked_isIceWandTear = true
    end
end

function this:RemoveTear(tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_isIceWandTear then
        for _, ent in ipairs(Isaac.FindInRadius(tear.Position, 100, 8)) do
            if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                ent:AddFreeze(EntityRef(tear.SpawnerEntity), 30)
                ent:AddEntityFlags(EntityFlag.FLAG_ICE)
                ent:TakeDamage(40, 0, EntityRef(tear.SpawnerEntity), 1)
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.IceWandUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.RemoveTear, EntityType.ENTITY_TEAR)

this.EIDEntries = {}
return this