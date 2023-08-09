
local mod = SomethingWicked
local sfx = SFXManager()

local function VoidMachineCanUse(player, slot)
    if not player:HasInvincibility() then
        --Playing the machine
        local hearts
        if player:GetHearts() > 1 then
            hearts = player:GetHearts()
            if player:GetSoulHearts() == 0 then
                hearts = hearts - 1
            end
            player:TakeDamage(hearts, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
        else
            hearts = 1
            player:TakeDamage(hearts, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
        end
        sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
        
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
        poof.Color = Color(0.1, 0.1, 0.1)

        hearts = math.abs(hearts) * 1.2
        if hearts % 1 < 0.5 then
            hearts = math.floor(hearts)
        else
            hearts = math.ceil(hearts)
        end

        return hearts
    end
end

local function VoidMachineOnUse(player, payout, slot)
    local v_rng = slot:GetDropRNG()
    mod:SpawnPickupShmorgabord(payout, PickupVariant.PICKUP_COIN, v_rng, slot.Position + Vector(0, slot.Size), slot, function (pickup)
        pickup.Velocity = mod:GetPayoutVector(v_rng)
    end)

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, slot.Position + Vector(0, slot.Size), Vector.Zero, slot)
    
    local randInt = v_rng:RandomInt(2)
    if randInt == 1 then
        return true
    else
        sfx:Play(SoundEffect.SOUND_HEARTOUT, 1, 0)
    end
end

mod:InitSlotData({
    slotVariant = mod.MachineVariant.MACHINE_VOIDBLOOD,
    functionCanPlay = function (player, slot)
        return VoidMachineCanUse(player, slot)
    end,
    functionOnPlay =  function (player, payout, slot) 
        return VoidMachineOnUse(player, payout, slot) 
    end,

    animFramesPlaying = 17,
    animFramesDeath = 5
})