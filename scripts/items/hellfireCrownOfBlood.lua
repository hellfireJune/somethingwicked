local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_HELLFIRE = Isaac.GetItemIdByName("Hellfire")
CollectibleType.SOMETHINGWICKED_CROWN_OF_BLOOD = Isaac.GetItemIdByName("Crown of Blood")

local cobIFrames = 20
local function procChance(player)
    return 0.13 + (player.Luck*0.04)
end
local shouldMakeDMGCrazy = false
function this:OnTakeDMG(ent, amount, flags, source, dmgCooldown)
    if shouldMakeDMGCrazy then
        return
    end
    ent = ent:ToNPC()
    if not ent
    or not ent:IsEnemy() then
        return
    end

    local e_data = ent:GetData()
    if e_data.sw_crownOfBloodIFrames and e_data.sw_crownOfBloodIFrames > cobIFrames then
        return false
    end
    if e_data.sw_hellfirePrimedFrames and e_data.sw_hellfirePrimedFrames <= 0 then
        return
    elseif not e_data.sw_hellfirePrimedFrames and ent.HitPoints < 0.1 then
        return
    end
    local flag, player = mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_HELLFIRE)
    if flag and player then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_HELLFIRE)
        if e_data.sw_isHellfireMarked == nil then
            e_data.sw_isHellfireMarked = c_rng:RandomFloat() < procChance(player)
        end
    end
    if mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_CROWN_OF_BLOOD) and e_data.sw_crownOfBloodMarked == nil then
        e_data.sw_crownOfBloodMarked = true
    end
    if e_data.sw_isHellfireMarked or e_data.sw_crownOfBloodMarked then
        shouldMakeDMGCrazy = true
        ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, dmgCooldown)
        shouldMakeDMGCrazy = false
        return false
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnTakeDMG)

function this:NPCUpdate(ent)
    local e_data = ent:GetData()
    
    if e_data.sw_crownOfBloodMarked then
        if ent.HitPoints < 0.1 then
            e_data.sw_crownOfBloodMarked = false
            e_data.sw_crownOfBloodIFrames = cobIFrames + 1
            
            ent:AddHealth(ent.MaxHitPoints / 3)
            ent:BloodExplode()
            ent:SetColor(Color(1, 1, 1, 1, 1), cobIFrames + 1, 10, true, false)
            ent:Update()
        end
        return
    end
    if e_data.sw_crownOfBloodIFrames then
        e_data.sw_crownOfBloodIFrames = e_data.sw_crownOfBloodIFrames - 1

        if e_data.sw_crownOfBloodIFrames < 0 then
            e_data.sw_crownOfBloodIFrames = nil
        end
    end

    if not e_data.sw_isHellfireMarked then
        return
    end
    if e_data.sw_hellfirePrimedFrames ~= nil then
        if e_data.sw_hellfirePrimedFrames < 0 then
            return
        end

        e_data.sw_hellfirePrimedFrames = e_data.sw_hellfirePrimedFrames - 1
        local shouldFlash = e_data.sw_hellfirePrimedFrames % 5 == 4
        if shouldFlash then
            local color = Color(1, 1, 1, 1, 1)
            ent:SetColor(color, 8, 3, true, false)

            mod.sfx:Play(SoundEffect.SOUND_BEEP, 1, 0)
        elseif e_data.sw_hellfirePrimedFrames == 0 then
            ent:BloodExplode()
            Game():BombTearflagEffects(ent.Position, 1, TearFlags.TEAR_BRIMSTONE_BOMB, Isaac.GetPlayer(0), 1)
            mod.sfx:Stop(SoundEffect.SOUND_BEEP)
        end
    elseif ent.HitPoints < 0.1 then
        e_data.sw_hellfirePrimedFrames = 30
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_HELLFIRE] = {
        desc = "{{Collectible118}} On death, enemies have a chance to stay alive for slightly longer, then explode and fire 4 brimstone lasers in the cardinal directions#Scales with luck",
        encycloDesc = mod:UtilGenerateWikiDesc({"On death, enemies have a chance to stay alive for slightly longer, then explode and fire 4 brimstone lasers in the cardinal directions", "Scales with luck"}),
        pools = { mod.encyclopediaLootPools.POOL_CURSE, mod.encyclopediaLootPools.POOL_DEVIL, mod.encyclopediaLootPools.POOL_ULTRA_SECRET,
            mod.encyclopediaLootPools.POOL_GREED_DEVIL}
    },
    [CollectibleType.SOMETHINGWICKED_CROWN_OF_BLOOD] = {
        desc = "these foes run rampant",
        Hide = true,
    }
}
return this