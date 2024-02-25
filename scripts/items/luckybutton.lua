local this = {}
local mod = SomethingWicked

local function spawnPickup(variant, position, rng, subType)
    subType = subType or 0
    Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, 0, position, mod.SlotHelpers:GetPayoutVector(rng), nil)
end

--chances taken from https://bindingofisaacrebirth.fandom.com/wiki/Machines
mod.LuckyButtonValidSlots = {
    [SomethingWicked.MachineVariant.MACHINE_SLOT] = function (position, rng, foot, hardMode, mult)
        local chance = 0.54
        if foot then
            chance = chance / 1.4
        end
        if hardMode then
            chance = chance * 1.4
        end
        if rng:RandomFloat() < chance then
            local variant = 0
            local dec = rng:RandomFloat()*0.389
            local doTwice = false

            if dec < 0.047 then -- bomb chance
                variant = PickupVariant.PICKUP_BOMB
            elseif dec < 0.047 + 0.031 then -- bomb chance plus key chance
                variant = PickupVariant.PICKUP_KEY
            elseif dec < 0.047 + 0.031 + 0.093 then-- bomb chance plus key chance plus heart chance
                variant = PickupVariant.PICKUP_HEART
            elseif dec < 0.047 + 0.031 + 0.093 + 0.047 then -- bomb chance plus key chance plus pill chance
                variant = PickupVariant.PICKUP_PILL
            elseif dec < 0.047 + 0.031 + 0.093 + 0.047 + 0.114 + 0.57 then -- bomb chance plus key chance plus both coin chances
                if dec < 0.047 + 0.031 + 0.093 + 0.047 + 0.114 then
                    doTwice = false
                else
                    doTwice = true
                end
                variant = PickupVariant.PICKUP_COIN
            end

            for i = 1, mult * (doTwice and 2 or 1), 1 do
                spawnPickup(variant, position, rng)
            end
        end
    end,
    [SomethingWicked.MachineVariant.MACHINE_FORTUNE] = function (position, rng, foot, _, mult)
        if rng:RandomFloat() > (foot and 0.46 or 0.65) then
            local variant = PickupVariant.PICKUP_TRINKET
            local subtype = 0
            
            local weighter = rng:RandomInt(3)
            if weighter == 1 then
                variant = PickupVariant.PICKUP_HEART
                subtype = HeartSubType.HEART_SOUL
            end
            if weighter == 2 then
                variant = PickupVariant.PICKUP_TAROTCARD
            end
            
            for i = 1, mult, 1 do
                spawnPickup(variant, position, rng, subtype)
            end
        end
    end,
}

function this:PostUpdate()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(mod.TRINKETS.LUCKY_BUTTON) then
        local machines = Isaac.FindByType(EntityType.ENTITY_SLOT)
        for key, slot in pairs(machines) do
            if this.ValidSlots[slot.Variant] then
                local e_data = slot:GetData()
                local sprite = slot:GetSprite()
                if sprite:IsPlaying("Prize") and sprite:GetFrame() == 4 then
                    if not e_data.somethingWicked_luckyButtonCheck then
                        local func = this.ValidSlots[slot.Variant]
                        local foot = mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
                        local hardMode = mod.game.Difficulty == Difficulty.DIFFICULTY_HARD

                        func(slot.Position, slot:GetDropRNG(), foot, hardMode, mod.ItemHelpers:GlobalGetTrinketNum(mod.TRINKETS.LUCKY_BUTTON))

                        e_data.somethingWicked_luckyButtonCheck = true
                        break
                    end
                else
                    e_data.somethingWicked_luckyButtonCheck = false
                end
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.PostUpdate)

this.EIDEntries = {
    [mod.TRINKETS.LUCKY_BUTTON] = {
        desc = "Slot machines and fortune machines will try to pay out twice",
        Hide = true,
    }
}
return this