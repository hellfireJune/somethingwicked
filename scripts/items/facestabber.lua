local this = {}
CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE = Isaac.GetItemIdByName("Facestabber")
TearVariant.SOMETHINGWICKED_FACESTABBER = Isaac.GetEntityVariantByName("Facestabber")

function this:UseItem(_, _, player, flags)
    return SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
end

local maxFrames = 24
function this:PEffectUpdate(player)
    local d = player:GetData()
    if player:IsHoldingItem() 
    and d.somethingWicked_isHoldingItem[CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] == true then
        d.somethingWicked_guillotineData = d.somethingWicked_guillotineData or 
        {
            Charge = 0,
            Direction = Direction.NO_DIRECTION
        }

        local direction = player:GetFireDirection()
        if direction ~= Direction.NO_DIRECTION then
            d.somethingWicked_guillotineData.Charge = math.min(d.somethingWicked_guillotineData.Charge + 1, maxFrames)
            d.somethingWicked_guillotineData.Direction = direction
        elseif d.somethingWicked_guillotineData.Charge > 0 then
            local mult = SomethingWicked.EnemyHelpers:Lerp(0.2, 2, d.somethingWicked_guillotineData.Charge / maxFrames)
            local velocity = (SomethingWicked.HoldItemHelpers:AimToVector(d.somethingWicked_guillotineData.Direction) * 10 + player.Velocity) * mult
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, player.Position, velocity, player):ToTear() --player:FireTear(player.Position, , false, true, false) make this not inherit tear effects
            tear.CollisionDamage = player.Damage * 2 * mult
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)

            local t_data = tear:GetData()
            t_data.somethingWicked_guillotineData = {
                Charge = mult,
            }
            --tear:ChangeVariant()

            tear:Update()

            
            local _, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
            player:AnimateCollectible(CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE, "HideItem", "PlayerPickupSparkle")
            d.somethingWicked_isHoldingItem[CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] = false
            player:DischargeActiveItem(slot)

            d.somethingWicked_guillotineData = nil
        end
    end
end

function this:KnifeCollision(tear, collider)
    collider = collider:ToNPC()
    if not collider
    or not collider:IsVulnerableEnemy() then
        return
    end

    local t_data = tear:GetData()
    if t_data.somethingWicked_guillotineData == nil then
        return
    end

    if tear.StickTarget then
        
    elseif tear.CollisionDamage > collider.HitPoints then
        tear.StickTarget = collider
        tear.StickTimer = 30
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.KnifeCollision)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] = {
        desc = ""
    }
}
return this