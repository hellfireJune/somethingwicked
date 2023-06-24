local this = {}
local heartValues = {
    [HeartSubType.HEART_HALF] = 1,
    [HeartSubType.HEART_FULL] = 2,
    [HeartSubType.HEART_SCARED] = 2,
    [HeartSubType.HEART_BLENDED] = 2,
    [HeartSubType.HEART_DOUBLEPACK] = 4,
}

local function blockSlotDMG(player) 
    local color = Color(1, 1, 1, 1, 0.5)
    player:SetColor(color, 8, 3, true, false)
    return false
end

local isBlocking = false
function this:OnBloodDMG(player, amount, flags, source, dmgCooldown)

    player = player:ToPlayer()
    if not player then
        return
    end

    local p_data = player:GetData()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_TEMPERANCE)then
        if isBlocking == true then
            return
        end
        if player:GetHearts() - amount <= 0 then
            isBlocking = true
            player:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, dmgCooldown)
            isBlocking = false

            this:BreakTemperance(player)
            player:RemoveCollectible(CollectibleType.SOMETHINGWICKED_TEMPERANCE)
            return false
        else
            local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_TEMPERANCE)
            if rng:RandomFloat() < 0.175 * amount then
                local numberToDrop = math.min(amount, p_data.SomethingWickedPData.temperance_hearts)
                SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(numberToDrop, PickupVariant.PICKUP_HEART, rng, player.Position, player, function (pickup)
                    pickup.Velocity = SomethingWicked.SlotHelpers:GetPayoutVector(rng)
                end)
                p_data.SomethingWickedPData.temperance_hearts = p_data.SomethingWickedPData.temperance_hearts - numberToDrop
            end
        end
    else
        local sourceEnt = source.Entity
        if not sourceEnt then
            return
        end
        if sourceEnt.Type == EntityType.ENTITY_SLOT
        and (sourceEnt.Variant == SomethingWicked.MachineVariant.MACHINE_BLOOD
        or sourceEnt.Variant == SomethingWicked.MachineVariant.MACHINE_DEVIL_BEGGAR) then
            if player:HasTrinket(TrinketType.SOMETHINGWICKED_SURGICAL_MASK) then
                local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_SURGICAL_MASK)
                if t_rng:RandomFloat() < 0.33 then
                    return blockSlotDMG(player)
                end
            end
            if player:HasCollectible(CollectibleType.SOMETHINGWICKED_TEMPERANCE) then
                if p_data.SomethingWickedPData.temperance_hearts >= amount then
                    p_data.SomethingWickedPData.temperance_hearts = p_data.SomethingWickedPData.temperance_hearts - amount
                    return blockSlotDMG(player)
                end
            end
        end
    end
end

local maxhearts = 12
function this:PlayerRender(player, offset)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_TEMPERANCE) then
        return
    end
    local p_data = player:GetData()
    p_data.SomethingWickedPData.temperance_hearts = p_data.SomethingWickedPData.temperance_hearts or maxhearts

    local pos = Isaac.WorldToScreen(player.Position)

    Isaac.RenderText((p_data.SomethingWickedPData.temperance_hearts/2).."/"..(maxhearts/2), pos.X, pos.Y, 1, 0, 0, 1)
end

function this:BreakTemperance(player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.temperance_hearts = p_data.SomethingWickedPData.temperance_hearts or 0
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_TEMPERANCE)
    SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(p_data.SomethingWickedPData.temperance_hearts, PickupVariant.PICKUP_HEART, rng, player.Position, player, function (pickup)
        pickup.Velocity = SomethingWicked.SlotHelpers:GetPayoutVector(rng)
    end)
    p_data.SomethingWickedPData.temperance_hearts = nil
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnBloodDMG, EntityType.ENTITY_PLAYER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, this.PlayerRender)

function this:HeartCollision(entity, player)
    if heartValues[entity.SubType] == nil then
        return
    end

    player = player:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_TEMPERANCE) then
        return
    end

    local p_data = player:GetData()
    if p_data.SomethingWickedPData.temperance_hearts < maxhearts
    and not player:CanPickRedHearts() and SomethingWicked.ItemHelpers:CanPickupPickupGeneric(entity, player) then
        local value = heartValues[entity.SubType]
        entity:Remove()
        --add the stuff here
    end
end

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_SURGICAL_MASK] = {
        isTrinket = true,
        desc = "33% chance to not take damage when using a blood donation machine",
        Hide = true,
    }
}
return this