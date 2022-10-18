local this = {}
Card.SOMETHINGWICKEDTHOTH_THE_AEON = Isaac.GetCardIdByName("TheAeon")
SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD = Isaac.GetEntityVariantByName("Abyssal Machine")

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player) 
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
    poof.Color = Color(0.1, 0.1, 0.1)
    poof.SpriteScale = Vector(1.5, 1.5)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)
end


SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_THE_AEON)

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD,
    functionCanPlay = function (player, slot)
        return this:VoidMachineCanUse(player, slot)
    end,
    functionOnPlay =  function (player, payout, slot) 
        return this:VoidMachineOnUse(player, payout, slot) 
    end,

    animFramesPlaying = 17,
    animFramesDeath = 5
})

function this:VoidMachineCanUse(player, slot)
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
        SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
        
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

function this:VoidMachineOnUse(player, payout, slot)
    local v_rng = slot:GetDropRNG()
    SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(payout, PickupVariant.PICKUP_COIN, v_rng, slot.Position + Vector(0, slot.Size), slot, function (pickup)
        pickup.Velocity = SomethingWicked.SlotHelpers:GetPayoutVector(v_rng)
    end)
    --[[while payout > 0 do
        local coinType
        for index, realIDx in ipairs(this.CoinOrders) do
            local value = this.Coins[realIDx]
            index = realIDx

            local flag = v_rng:RandomFloat() > (1 / (0.25 * index))
            if index <= payout
            and not flag then
                coinType = value
                payout = payout - index 
                break
            end
        end

        local angle = v_rng:RandomInt(120)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, coinType, slot.Position + Vector(0, slot.Size), Vector.FromAngle(angle + 30) * 5, slot) 
    end ]]

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, slot.Position + Vector(0, slot.Size), Vector.Zero, slot)
    
    local randInt = v_rng:RandomInt(2)
    if randInt == 1 then
        return true
    else
        SomethingWicked.sfx:Play(SoundEffect.SOUND_HEARTOUT, 1, 0)
    end
end
--[[function this:VoidMachineUpdate(player)
    --Like, 90% of this code I nabbed from andromeda's Wisp Wizard
    --Which itself was nabbed from the Harlot Beggar's mod, heh

    --I also took some stuff from AgentCucco's Job mod, for the destruction bit

    local voidMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, this.VoidMachineVariant)

    for i, voidMachine in ipairs(voidMachines) do
        local v_sprite = voidMachine:GetSprite()
        local v_data = voidMachine:GetData()
        local v_rng = voidMachine:GetDropRNG()

        if voidMachine.SubType == 0 then
            if v_sprite:IsPlaying("Wiggle") and v_sprite:GetFrame() == 17 then v_sprite:Play("Prize") end
            if v_sprite:IsFinished("Prize") then v_sprite:Play("Idle") end

            if v_sprite:IsEventTriggered("Prize") and v_data.somethingWicked_payoutAmount ~= nil then
                --paying out
                while v_data.somethingWicked_payoutAmount > 0 do
                    local coinType
                    for index, realIDx in ipairs(this.CoinOrders) do
                        local value = this.Coins[realIDx]
                        index = realIDx

                        local flag = v_rng:RandomFloat() > (1 / (0.25 * index))
                        if index <= v_data.somethingWicked_payoutAmount
                        and not flag then
                            coinType = value
                            v_data.somethingWicked_payoutAmount = v_data.somethingWicked_payoutAmount - index 
                            break
                        end
                    end

                    local angle = v_rng:RandomInt(120)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, coinType, voidMachine.Position + Vector(0, voidMachine.Size), Vector.FromAngle(angle + 30) * 5, voidMachine) 
                end 

                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, voidMachine.Position + Vector(0, voidMachine.Size), Vector.Zero, voidMachine)
                v_data.somethingWicked_payoutAmount = nil

                local randInt = v_rng:RandomInt(2)
                if randInt == 1 then
                    --Dead Machine 
                    local newMachine = Isaac.Spawn(EntityType.ENTITY_SLOT, this.VoidMachineVariant, 1, voidMachine.Position, Vector.Zero, voidMachine) 
                    newMachine:GetSprite():Play("Death")
                    voidMachine:Remove()
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, newMachine.Position, Vector.Zero, newMachine)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)
                else SomethingWicked.sfx:Play(SoundEffect.SOUND_HEARTOUT, 1, 0) end
            end

		    if voidMachine.Position:Distance(player.Position) <= player.Size + voidMachine.Size
            and v_sprite:IsPlaying("Idle")
            and not player:HasInvincibility() then
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
                SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
                
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
                poof.Color = Color(0.1, 0.1, 0.1)

                hearts = math.abs(hearts) * 1.2
                if hearts % 1 < 0.5 then
                    hearts = math.floor(hearts)
                else
                    hearts = math.ceil(hearts)
                end

                v_data.somethingWicked_payoutAmount = hearts
                v_sprite:Play("Wiggle")
            end
        end
        

        --On Bombed
        if voidMachine.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        and not voidMachine.SubType ~= 2 then
            if (not v_sprite:IsPlaying("Death"))
            and (not (v_sprite:GetAnimation() == "Broken")) then
                v_sprite:Play("Death")
            end
            voidMachine.SubType = 2

            for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
                this:removingStuff(pickup, voidMachine)
            end
            for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
                this:removingStuff(pickup, voidMachine)
            end
        end

        if v_sprite:IsPlaying("Death") and v_sprite:GetFrame() == 5  then
            v_sprite:Play("Broken")

            voidMachine.Size = 0
        end
    end
end

function this:removingStuff(pickup, voidMachine)
    if pickup.FrameCount <= 3
    and voidMachine.Position:Distance(pickup.Position) <= voidMachine.Size + pickup.Size + voidMachine.Velocity:Length() + pickup.Velocity:Length()
    then
        pickup:Remove()
    end
end

function this:VoidMachineNewRoom()
    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, this.VoidMachineVariant)) do
        if value.SubType > 0 then
            value:Remove()
        end
    end
end]]--

this.Coins = {
    [10] = CoinSubType.COIN_DIME,
    [5] = CoinSubType.COIN_NICKEL,
    [1] = CoinSubType.COIN_PENNY
}
this.CoinOrders = {
    [1] = 10,
    [2] = 5,
    [3] = 1,
} --lua is quirky

this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_THE_AEON] = {
        desc = "Spawns a void blood machine"
    }
}
return this