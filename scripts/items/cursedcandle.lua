local this = {}
CollectibleType.SOMETHINGWICKED_CURSED_CANDLE = Isaac.GetItemIdByName("Cursed Candle")
this.wickedFire = 23
this.CurseColor = Color(1, 1, 1, 1, 0.1, 0, 0.3)
this.CurseDuration = 5.5

function this:UseItem(_, _, player, flags)
    return SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE)
end

function this:PlayerUpdate(player)
    if SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE) then
        
        local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, this.wickedFire, player.Position, SomethingWicked.HoldItemHelpers:GetUseDirection(player):Resized(10), player)
        fire = fire:ToEffect()
        fire:SetTimeout(20)
        fire.CollisionDamage = 5
    end
end

function this:OnEnemyTakeDMG(ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.BLUE_FLAME
    and fire.SubType == this.wickedFire  then
        if e_data.somethingWicked_curseTick and e_data.somethingWicked_curseTick > 0
        then
            return false
        end
        --[[local fireSprite = fire:GetSprite()
        fireSprite:Play("Disappear")
        fire.CollisionDamage = 0]]--

        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            SomethingWicked:UtilAddCurse(ent, this.CurseDuration)
        end
    elseif e_data.somethingWicked_curseTick and e_data.somethingWicked_curseTick > 0 and e_data.somethingWicked_isDoingCurseDamage ~= true then
        e_data.somethingWicked_isDoingCurseDamage = true
        ent:TakeDamage(amount * 1.5, flags, EntityRef(ent), dmgCooldown)
        e_data.somethingWicked_isDoingCurseDamage = nil
        return false
    end
end

function SomethingWicked:UtilAddCurse(ent, time)
    local e_data = ent:GetData()
    
    time = 30 * time
    e_data.somethingWicked_curseTick = (e_data.somethingWicked_curseTick or 0) + time
    ent:SetColor(this.CurseColor, e_data.somethingWicked_curseTick, 1, false, false)
end

function this:NPCUpdate(ent)
    local e_data = ent:GetData()
    if e_data.somethingWicked_curseTick and e_data.somethingWicked_curseTick > 0 then 
        e_data.somethingWicked_curseTick = e_data.somethingWicked_curseTick - 1
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_CURSED_CANDLE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEnemyTakeDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)


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
        desc = "Throws a curse flame on use#This cursed flame curses enemies on contact#Cursed enemies will take 1.5x damage, and the curse effect will last for 6 seconds",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Throws a curse flame on use","This cursed flame curses enemies on contact","Cursed enemies will take 1.5x damage, and the curse effect will last for 6 seconds"})
    }
}
return this