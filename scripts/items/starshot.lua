local this = {}
CollectibleType.SOMETHINGWICKED_STAR_SHOT = Isaac.GetItemIdByName("Star Shot")
PlayerType.SOMETHINGWICKED_WORMWOOD = Isaac.GetPlayerTypeByName("Wormwood")
this.effect = Isaac.GetEntityVariantByName("Wormwood target")
this.range = 200
this.amountToShoot = 4
this.waitTickMultiplier = 5
--Going to do smth different for wormwood, this is allllll getting scrapped

function  this:TearInit(tear)
    if tear.SpawnerType == EntityType.ENTITY_PLAYER then
        local player = tear.SpawnerEntity:ToPlayer()

        if false then --player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_SHOT) or
        --player:GetPlayerType() == PlayerType.PLAYER_WORMWOOD then

            local p_data = player:GetData()
            if p_data.somethingwicked_wormwoodtarget == nil or p_data.somethingwicked_wormwoodtarget[this.amountToShoot]:Exists() ~= true then
                --[[local offset = player:GetAimDirection() * this.range
                p_data.somethingwicked_wormwoodtarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, this.effect, 0, tear.SpawnerEntity.Position + offset, Vector.Zero, tear.SpawnerEntity)
                p_data.somethingwicked_wormwoodtarget.Parent = tear.SpawnerEntity]]
                p_data.somethingwicked_wormwoodtarget = {}
                for i = 1, this.amountToShoot, 1 do
                    local offset = player:GetAimDirection() * (this.range * (i / this.amountToShoot))
                    p_data.somethingwicked_wormwoodtarget[i] = Isaac.Spawn(EntityType.ENTITY_EFFECT, this.effect, 0, tear.SpawnerEntity.Position + offset, Vector.Zero, tear.SpawnerEntity)
                    p_data.somethingwicked_wormwoodtarget[i].Parent = tear.SpawnerEntity

                    local e_data = p_data.somethingwicked_wormwoodtarget[i]:GetData()
                    e_data.somethingwicked_wormwoodPreProcessedWaitTick = this.waitTickMultiplier * (i - 1)
                    e_data.somethingwicked_wormwoodBeamCount = i

                    if i == this.amountToShoot then
                        p_data.somethingwicked_wormwoodtarget[i].SpriteScale = Vector(2, 2)
                    end
                end
            end
            tear:Remove()
        end
    end
end

function this:EffectUpdate(effect)
    local player = effect.Parent:ToPlayer()
    local e_data = effect:GetData()

    if e_data.somethingwicked_wormwoodWaitTick == nil then
        e_data.somethingwicked_wormwoodWaitTick = e_data.somethingwicked_wormwoodPreProcessedWaitTick
    end

    
   
    if e_data.somethingwicked_wormwoodBeamAttacking == nil and player:GetFireDirection() ~= Direction.NO_DIRECTION then
        local offset = player:GetAimDirection():Normalized() * (this.range * (e_data.somethingwicked_wormwoodBeamCount / this.amountToShoot))
        effect.Position = player.Position + offset
    else 
        e_data.somethingwicked_wormwoodBeamAttacking = true
        if e_data.somethingwicked_wormwoodWaitTick < 0 then
            local crackTheSky = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, effect.Position, Vector.Zero, player):ToEffect()
            crackTheSky.SpriteScale = effect.SpriteScale
            crackTheSky.Size = 35 * crackTheSky.SpriteScale.X
            
            crackTheSky.GridCollisionClass = 4
            effect:Remove()
        else
            --print(e_data.somethingwicked_wormwoodWaitTick)
            e_data.somethingwicked_wormwoodWaitTick =- 1
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, this.TearInit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.EffectUpdate, this.effect)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STAR_SHOT] = {
        desc = "!!! Viewing of this item is prohibited. If you see this item, please report it to your local authorities immediately.#Please do not tell any trustable people about this item. Please pretend this never appeared.",
            Hide = true,
    }
}
return this