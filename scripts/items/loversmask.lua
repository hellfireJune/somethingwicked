local this = {}
CollectibleType.SOMETHINGWICKED_LOVERS_MASK = Isaac.GetItemIdByName("Lover's Mask")

local shouldntBlock = false
local procChance = 0.6
function this:BlockDMG(ent, amount, flags, source, dmgCooldown)
    ent = ent:ToPlayer()
    
    if flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_CURSED_DOOR | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_RED_HEARTS) ~= 0
    or shouldntBlock
    or ent == nil or not ent:HasCollectible(CollectibleType.SOMETHINGWICKED_LOVERS_MASK) then
        return 
    end

    local c_rng = ent:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_LOVERS_MASK)
    if c_rng:RandomFloat() > procChance then
        ---tnx hybrid andromeda
		if ent:HasTrinket(TrinketType.TRINKET_PERFECTION) then
			SomethingWicked.sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
			ent:TryRemoveTrinket(TrinketType.TRINKET_PERFECTION)
			ent:TryRemoveTrinket(TrinketType.TRINKET_PERFECTION + TrinketType.TRINKET_GOLDEN_FLAG)
		end
		ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NO_PENALTIES, source, 0)
    end
    return false
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.BlockDMG, EntityType.ENTITY_PLAYER)
this.EIDEntries = {}
return this