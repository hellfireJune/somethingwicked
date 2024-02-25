local mod = SomethingWicked
local game = Game()

local procChance = 0.30
local function BlockDMG(_, ent, amount, flags, source, dmgCooldown)
    ent = ent:ToPlayer()
    --print("troller")
    
    if flags & DamageFlag.DAMAGE_FAKE ~= 0
    or ent == nil or not ent:HasCollectible(mod.ITEMS.LOVERS_MASK) then
        return 
    end
    local isRedHearts = false
    local rHearts = ent:GetHearts()
    if rHearts > 0 then
        if ent:HasTrinket(TrinketType.TRINKET_CROW_HEART)
        or flags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 then
            isRedHearts = true
        elseif ent:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
            local bHearts = ent:GetBoneHearts()
            if (rHearts / 2) - bHearts > 0 then
                isRedHearts = true
            end
        else
            local sHearts = ent:GetSoulHearts()
            local mHearts = ent:GetMaxHearts()
            if mHearts >= rHearts
            and sHearts == 0 then
                isRedHearts = true
            end
        end
    end
    if not isRedHearts then
        return
    end

    local level = game:GetLevel()
    if level:GetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED) == false then
        mod:UtilScheduleForUpdate(function ()
            level:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
        end, 0, ModCallbacks.MC_INPUT_ACTION)
    end

    local c_rng = ent:GetCollectibleRNG(mod.ITEMS.LOVERS_MASK)
    if c_rng:RandomFloat() < procChance then
        local color = Color(1, 1, 1, 1, 0.5)
        ent:SetColor(color, 8, 3, true, false)
        ent:SetMinDamageCooldown(40)
        return false
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlockDMG, EntityType.ENTITY_PLAYER)