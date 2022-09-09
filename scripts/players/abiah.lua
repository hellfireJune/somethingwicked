local this = {}
this.costume = Isaac.GetCostumeIdByPath("gfx/characters/character_001_abiahhead.anm2")
PlayerType.SOMETHINGWICKED_ABIAH = Isaac.GetPlayerTypeByName("Abiah")
CollectibleType.SOMETHINGWICKED_JOEL = Isaac.GetItemIdByName("Joel!")

this.obolCoinRate = 7
this.obolShardRate = 4
this.obolHPRate = 2
this.shardCoinRate = 1.5

function this:PlayerInit(player)
    local p_data = player:GetData()
    if player:GetPlayerType() == PlayerType.SOMETHINGWICKED_ABIAH then
        player:AddNullCostume(this.costume)

        if (#Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 
        and SomethingWicked.game:GetFrameCount() ~= 0) ~= true then
            player:AddCollectible(CollectibleType.SOMETHINGWICKED_D_STOCK, 8)
            player:SetPocketActiveItem(CollectibleType.SOMETHINGWICKED_JOEL, 2, false)
            
            player:AddTrinket(TrinketType.TRINKET_RIB_OF_GREED)
            p_data.SomethingWickedPData.abiah_obols = 8
            --player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER)
        end
    end
end

function this:UseItem(_, rngObj, player, flags)
    local p_data = player:GetData()
    local room = SomethingWicked.game:GetRoom()
    local level = SomethingWicked.game:GetLevel()
    if p_data.SomethingWickedPData.joelWarpRoom ~= nil
    and room:GetType() == RoomType.ROOM_SHOP  then
        SomethingWicked.game:StartRoomTransition(p_data.SomethingWickedPData.joelWarpRoom, -1)
        p_data.SomethingWickedPData.joelWarpRoom = nil
    else
        p_data.SomethingWickedPData.joelWarpRoom = level:GetCurrentRoomIndex()
        local shopIDx = level:QueryRoomTypeIndex(RoomType.ROOM_SHOP, true, rngObj)
        SomethingWicked.game:StartRoomTransition(shopIDx, -1)
    end
end

function this:PlayerUpdate(player)
    
    if player:GetPlayerType() ~= PlayerType.SOMETHINGWICKED_ABIAH then
        return
    end
    local p_data = player:GetData()
    p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols or 0
    p_data.SomethingWickedPData.abiah_obolShards = p_data.SomethingWickedPData.abiah_obolShards or 0
    p_data.SomethingWickedPData.abiah_usingObols = p_data.SomethingWickedPData.abiah_usingObols or false

    local mxHearts = player:GetMaxHearts()
    if mxHearts > 0 then
        player:AddMaxHearts(-mxHearts)
        player:AddBlackHearts(math.floor(mxHearts * 0.5))

        p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols + math.floor(mxHearts * (this.obolHPRate / 2))
    end

    if p_data.SomethingWickedPData.abiah_obolShards >= this.obolShardRate then
        p_data.SomethingWickedPData.abiah_obolShards = p_data.SomethingWickedPData.abiah_obolShards - this.obolShardRate
        p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols + 1
    end

    if Input.IsActionTriggered(11, player.ControllerIndex) then
        p_data.SomethingWickedPData.abiah_usingObols = not p_data.SomethingWickedPData.abiah_usingObols
    end
end

function this:PlayerRender(player, offset)
    if player:GetPlayerType() ~= PlayerType.SOMETHINGWICKED_ABIAH then
        return
    end
    local p_data = player:GetData()
    p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols or 0

    local pos = Isaac.WorldToScreen(player.Position)

    Isaac.RenderText(p_data.SomethingWickedPData.abiah_obols..", "..p_data.SomethingWickedPData.abiah_obolShards..", "..tostring(p_data.SomethingWickedPData.abiah_usingObols), pos.X, pos.Y, 1, 1, 1, 1)
end

function this:PickupCollision(pickup, collider)
    collider = collider:ToPlayer()
    if collider == nil
    or collider:GetPlayerType() ~= PlayerType.SOMETHINGWICKED_ABIAH
    or collider:IsExtraAnimationPlaying() then
       return 
    end

    local cost, costShards = this:CalculateCosts(pickup)
    if cost == 0 and costShards == 0 then
        costShards = 1
    end
    local p_data = collider:GetData()
    if cost ~= nil
    and p_data.SomethingWickedPData.abiah_usingObols then
        p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols or 0
        if cost <= p_data.SomethingWickedPData.abiah_obols
        and (costShards <= p_data.SomethingWickedPData.abiah_obolShards or cost < p_data.SomethingWickedPData.abiah_obols) then

            p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols - cost
            p_data.SomethingWickedPData.abiah_obolShards = p_data.SomethingWickedPData.abiah_obolShards - costShards
            if (p_data.SomethingWickedPData.abiah_obolShards < 0) then
                p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols - 1
                p_data.SomethingWickedPData.abiah_obolShards = p_data.SomethingWickedPData.abiah_obolShards + this.obolShardRate
            end
            pickup.Price = PickupPrice.PRICE_FREE
        else
            return nil
        end
    end
end

function this:PickupRender(pickup)
    local rtrn = true
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:GetPlayerType() == PlayerType.SOMETHINGWICKED_ABIAH then
            rtrn = false
        end
    end
    if rtrn then
        return
    end
    local cost, costShards = this:CalculateCosts(pickup)
    if cost == nil then
        return
    end
    local pos = Isaac.WorldToScreen(pickup.Position)

    Isaac.RenderText(cost..", "..costShards, pos.X, pos.Y, 1, 0, 1, 1)
end

function this:CalculateCosts(pickup)
    local cost = pickup.Price 
    local roomType = SomethingWicked.game:GetRoom():GetType()

    if cost > 0 then
        return math.floor(pickup.Price / this.obolCoinRate), math.floor((pickup.Price % this.obolCoinRate) / this.shardCoinRate)
    end
    if cost == PickupPrice.PRICE_THREE_SOULHEARTS then
        local hearts = Isaac.GetItemConfig():GetCollectible(pickup.SubType).DevilPrice

        return math.floor(hearts * this.obolHPRate), 0
    end

    return nil
end

function this:NewFloorObols()
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:GetPlayerType() == PlayerType.SOMETHINGWICKED_ABIAH  then
            local p_data = value:GetData()
            p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols or 0

            if p_data.SomethingWickedPData.abiah_obols > 0 then
                p_data.SomethingWickedPData.abiah_obols = p_data.SomethingWickedPData.abiah_obols - 1
                value:AddBlackHearts(1)
            end
        end
    end
end

this.HeartValues = {
    [HeartSubType.HEART_FULL] = 2,
    [HeartSubType.HEART_SCARED] = 2,
    [HeartSubType.HEART_HALF] = 1,
    [HeartSubType.HEART_DOUBLEPACK] = 4,
}
function this:HeartCollision(entity, player)
    player = player:ToPlayer()
    if (entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED
    and entity.SubType ~= HeartSubType.HEART_DOUBLEPACK)
    or player == nil
    or player:GetPlayerType() ~= PlayerType.SOMETHINGWICKED_ABIAH then
        return
    end
    local p_data = player:GetData()
        p_data.SomethingWickedPData.abiah_obolShards = p_data.SomethingWickedPData.abiah_obolShards + this.HeartValues[entity.SubType]
        entity:Remove()
            
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, entity)
        poof.Color = Color(0.6, 0.1, 0.1)
        SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)

        return true
    end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, this.PlayerInit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, this.PlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, this.PlayerRender)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.HeartCollision, PickupVariant.PICKUP_HEART)

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, this.PickupRender)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_JOEL)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewFloorObols)

--the following code has been obliterated off the face of the planet, and into The Aeon card file

--[[function this:VoidMachineUpdate(player)
    --Like, 90% of this code I nabbed from andromeda's Wisp Wizard
    --Which itself was nabbed from the Harlot Beggar's mod, heh

    --I also took some stuff from AgentCucco's Job mod, for the destruction bit

    local voidMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, this.VoidMachineVariant)

    for i, voidMachine in ipairs(voidMachines) do
        local v_sprite = voidMachine:GetSprite()
        local v_data = voidMachine:GetData()

        if voidMachine.SubType == 0 then
            if v_sprite:IsPlaying("Wiggle") and v_sprite:GetFrame() == 17 then v_sprite:Play("Prize") end
            if v_sprite:IsFinished("Prize") then v_sprite:Play("Idle") end

            if v_sprite:IsEventTriggered("Prize") then
                while v_data.somethingWicked_payoutAmount > 0 do
                    local coinType
                    for index, value in pairs(this.Coins) do
                        if index <= v_data.somethingWicked_payoutAmount then
                            coinType = value
                            v_data.somethingWicked_payoutAmount = v_data.somethingWicked_payoutAmount - index 
                            break
                        end
                    end

                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, coinType, voidMachine.Position, RandomVector() * 5, voidMachine) 
                end 

                v_data.somethingWicked_payoutAmount = nil

                local randInt = voidMachine:GetDropRNG():RandomInt(3)
                if randInt == 1 then
                    --Dead Machine ):
                    local newMachine = Isaac.Spawn(EntityType.ENTITY_SLOT, this.VoidMachineVariant, 1, voidMachine.Position, Vector.Zero, voidMachine) 
                    newMachine:GetSprite():Play("Death")
                    voidMachine:Remove()
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, newMachine.Position, Vector.Zero, newMachine)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)
                else SomethingWicked.sfx:Play(SoundEffect.SOUND_HEARTOUT, 1, 0) end
            end

		    if (voidMachine.Position - player.Position):Length() <= 20
            and v_sprite:IsPlaying("Idle")
            and not player:HasInvincibility() then
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

                hearts = math.ceil(math.abs(hearts) * (((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType() == PlayerType.SOMETHINGWICKED_ABIAH)
                or voidMachine.SpawnerType == EntityType.ENTITY_PLAYER)
                and 1.2 or 0.8))
                v_data.somethingWicked_payoutAmount = hearts
                v_sprite:Play("Wiggle")
            end

            if voidMachine.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
                v_sprite:Play("Death", true)
            end
        else
            if v_sprite:IsPlaying("Death") and v_sprite:GetFrame() == 7  then
                v_sprite:Play("Broken")
            end
        end
    end
end

function this:VoidMachineNewRoom()
    for _, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(TrinketType.SOMETHINGWICKED_VOID_HEART) then
            for _, oldmachine in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, 2)) do
                Isaac.Spawn(EntityType.ENTITY_SLOT, this.VoidMachineVariant, 0, oldmachine.Position, Vector.Zero, oldmachine) 
                oldmachine:Remove()
            end
            break
        end
    end

    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, this.VoidMachineVariant, 1)) do
        value:Remove()
    end
end

this.Coins = {
    [10] = CoinSubType.COIN_DIME,
    [5] = CoinSubType.COIN_NICKEL,
    [1] = CoinSubType.COIN_PENNY
}

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.VoidMachineUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.VoidMachineNewRoom)

this.MachinePosition = Vector(480, 160)
function this:RoomEnter()
    for _, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:GetPlayerType() == PlayerType.SOMETHINGWICKED_ABIAH then
            local game = SomethingWicked.game
            local level = game:GetLevel()
            local room = game:GetRoom()
            if room:IsFirstVisit()
            and room:GetType() == RoomType.ROOM_SHOP then
                Isaac.Spawn(EntityType.ENTITY_SLOT, this.VoidMachineVariant, 0, Isaac.GetFreeNearPosition(this.MachinePosition, 10), Vector.Zero, nil)
            end
            break
        end
    end
end]]
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.RoomEnter)

--[[if EID then
    EID:addBirthright(PlayerType.SOMETHINGWICKED_ABIAH, "↑ Void Machines gives 1.5x more coins")
end]]


--SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, this.PlayerUpdate)

--[[function this:PlayerUpdate(player)
    if player:GetPlayerType() ~= PlayerType.SOMETHINGWICKED_ABIAH then
        return
    end
    local p_data = player:GetData()
    local hearts = player:GetHearts()

    local queueItem = player.QueuedItem.Item 
    if queueItem
    and queueItem.AddHearts
    and queueItem.AddHearts > 0 then
        p_data.SomethingWickedPData.QueuedAbiahHearts = queueItem.AddHearts
        if player:IsExtraAnimationFinished() ~= true then 
            if p_data.SomethingWickedPData.PreviousRedHearts ~= hearts then
                p_data.SomethingWickedPData.PreviousRedHearts = hearts
            end
        else
        end
    elseif p_data.SomethingWickedPData.QueuedAbiahHearts
    and p_data.SomethingWickedPData.PreviousRedHearts
    and player:IsExtraAnimationFinished() then
        player:AddHearts(p_data.SomethingWickedPData.PreviousRedHearts - player:GetHearts())
        player:AddBlackHearts(p_data.SomethingWickedPData.QueuedAbiahHearts / 2)

        p_data.SomethingWickedPData.QueuedAbiahHearts = nil
        p_data.SomethingWickedPData.PreviousRedHearts = nil

        local effects = player:GetEffects()
        if effects:GetNullEffect(NullItemID.ID_LOST_CURSE) == nil 
        and effects:GetNullEffect(NullItemID.ID_JACOBS_CURSE) == nil then
            player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 30)
        end
    end
end]]

