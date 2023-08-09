local this = {}
this.wickedFire = 23
this.CurseDuration = 5.5

function this:UseItem(_, _, player, flags)
    return SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE)
end

function this:PlayerUpdate(player)
    if SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE) then
        
        local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, this.wickedFire, player.Position, SomethingWicked.HoldItemHelpers:GetUseDirection(player):Resized(18), player)
        fire = fire:ToEffect()
        fire.Timeout = 20
        fire.CollisionDamage = 5
    end
end

local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.BLUE_FLAME
    and fire.SubType == this.wickedFire then
        if e_data.sw_curseTick and e_data.sw_curseTick > 0
        then
            return false
        end
        --[[local fireSprite = fire:GetSprite()
        fireSprite:Play("Disappear")
        fire.CollisionDamage = 0]]--

        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            SomethingWicked:UtilAddCurse(ent, this.CurseDuration)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnEnemyTakeDMG)


function  this:OnWispDie(entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_CURSED_CANDLE then
        local smolFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, this.wickedFire, entity.Position, Vector.Zero, entity):ToEffect()
        smolFire.Timeout = 15
        smolFire.SpriteScale = Vector(0.75, 0.75)
    end
end

function this:RemoveWisps()
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE)
    if wisps ~= nil and #wisps > 0 then
        for _, wisp in ipairs(wisps) do
            wisp:Remove()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.RemoveWisps)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnWispDie, EntityType.ENTITY_FAMILIAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CURSED_CANDLE] = {
        desc = "Throws a curse flame on use#This cursed flame curses enemies for 6 seconds on contact#Cursed enemies will take 1.5x damage, and the curse effect will last for 6 seconds",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Throws a curse flame on use","This cursed flame curses enemies on contact","Cursed enemies will take 1.5x damage, and the curse effect will last for 6 seconds"})
    }
}
return this