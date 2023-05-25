local this = {}
CollectibleType.SOMETHINGWICKED_LOVERS_MASK = Isaac.GetItemIdByName("Lover's Mask")

local shouldntBlock = false
local procChance = 0.33
function this:BlockDMG(ent, amount, flags, source, dmgCooldown)
    ent = ent:ToPlayer()
    --print("troller")
    
    if flags & DamageFlag.DAMAGE_FAKE ~= 0
    or shouldntBlock
    or ent == nil or not ent:HasCollectible(CollectibleType.SOMETHINGWICKED_LOVERS_MASK) then
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

    local c_rng = ent:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_LOVERS_MASK)
    if c_rng:RandomFloat() < procChance then
        flags = flags | DamageFlag.DAMAGE_FAKE
    end
    if ent:HasTrinket(TrinketType.TRINKET_PERFECTION) then
        SomethingWicked.sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        ent:TryRemoveTrinket(TrinketType.TRINKET_PERFECTION)
        ent:TryRemoveTrinket(TrinketType.TRINKET_PERFECTION + TrinketType.TRINKET_GOLDEN_FLAG)
    end
    shouldntBlock = true
    ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NO_PENALTIES, source, 0)
    shouldntBlock = false
    return false
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.BlockDMG, EntityType.ENTITY_PLAYER)
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LOVERS_MASK] = {
        desc = "{{Heart}} 30% chance to block any red heart damage#↑ Prevents the damage penalty devil deal chance"
    }
}
return this