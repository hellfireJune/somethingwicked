local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local cobIFrames = 24
local function procChance(player)
    return 0.13 + (player.Luck*0.04)
end
local shouldMakeDMGCrazy = false
local function OnTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    if shouldMakeDMGCrazy then
        return
    end
    ent = ent:ToNPC()
    if not ent
    or not ent:IsEnemy() then
        return
    end

    local e_data = ent:GetData()
    if e_data.sw_crownOfBloodIFrames and e_data.sw_crownOfBloodIFrames > 0 then
        return false
    end
    if e_data.sw_hellfirePrimedFrames and e_data.sw_hellfirePrimedFrames <= 0 then
        return
    elseif not e_data.sw_hellfirePrimedFrames and ent.HitPoints < 0.1 then
        return
    end
    local player = PlayerManager.FirstCollectibleOwner(mod.ITEMS.HELLFIRE)
    if player then
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.HELLFIRE)
        if e_data.sw_isHellfireMarked == nil then
            e_data.sw_isHellfireMarked = c_rng:RandomFloat() < procChance(player)
        end
    end
    if PlayerManager.AnyoneHasCollectible(mod.ITEMS.CROWN_OF_BLOOD) and e_data.sw_crownOfBloodMarked == nil then
        e_data.sw_crownOfBloodMarked = true
    end
    if e_data.sw_isHellfireMarked or e_data.sw_crownOfBloodMarked then
        shouldMakeDMGCrazy = true
        ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, dmgCooldown)
        shouldMakeDMGCrazy = false
        return false
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeDMG)

function mod:HellfireCOBUpdate(ent)
    local e_data = ent:GetData()
    
    if e_data.sw_crownOfBloodMarked then
        if ent.HitPoints < 0.1 then
            e_data.sw_crownOfBloodMarked = false
            e_data.sw_crownOfBloodIFrames = cobIFrames
            
            ent:AddHealth(ent.MaxHitPoints / 2)
            --ent:BloodExplode()

            local color = Color(2, 0, 0, 1, 2)
            color:SetColorize(4, 0, 0, 1)
            ent:SetColor(color, cobIFrames + 1, 10, true, false)
            
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, ent.Position, Vector.Zero, ent)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, ent.Position, Vector.Zero, ent)
            ent:Update()
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1)
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

            sfx:Play(SoundEffect.SOUND_BEEP, 1, 0)
        elseif e_data.sw_hellfirePrimedFrames == 0 then
            ent:BloodExplode()
            ent:TakeDamage(10, 0, EntityRef(ent), 0)
            Game():BombTearflagEffects(ent.Position, 1, TearFlags.TEAR_BRIMSTONE_BOMB, Isaac.GetPlayer(0), 1)
            sfx:Stop(SoundEffect.SOUND_BEEP)
        end
    elseif ent.HitPoints < 0.1 then
        e_data.sw_hellfirePrimedFrames = 30
    end
end

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, mod.HellfireCOBUpdate)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    if not PlayerManager.AnyoneHasCollectible(mod.ITEMS.CROWN_OF_BLOOD) then
        return
    end

    local luck = 0
    for _, value in ipairs(mod:UtilGetAllPlayers()) do
        luck = luck + value.Luck
    end
    luck = mod:Clamp(luck, 10, 0)
    local rng = mod:GlobalGetCollectibleRNG(mod.ITEMS.CROWN_OF_BLOOD)

    --https://bindingofisaacrebirth.fandom.com/wiki/Room_Clear_Awards?so=search
    local thing = (rng:RandomFloat() * luck * 0.1) + rng:RandomFloat()
    local type = PickupVariant.PICKUP_COIN
    if thing < 0.22 then
        return
    end
    if thing < 0.3 then
        --card, pill, or trinket
        goto spawn
    end
    if thing < 0.45 then
        type = PickupVariant.PICKUP_COIN
        goto spawn
    end
    if thing < 0.6 then
        type = PickupVariant.PICKUP_HEART
        goto spawn
    end
    if thing < 0.8 then
        type = PickupVariant.PICKUP_KEY
        goto spawn
    end
    if thing < 0.95 then
        type = PickupVariant.PICKUP_BOMB
        goto spawn
    end
    --chest

    ::spawn::
    mod:UtilScheduleForUpdate(function ()
        local room = game:GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
        
        Isaac.Spawn(EntityType.ENTITY_PICKUP, type, 0, pos, Vector.Zero, nil)
    end, 1)
end)