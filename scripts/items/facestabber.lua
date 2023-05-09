local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE = Isaac.GetItemIdByName("Facestabber")
TearVariant.SOMETHINGWICKED_FACESTABBER = Isaac.GetEntityVariantByName("Facestabber")

local chargebar = Sprite()
chargebar:Load("gfx/chargebar.anm2", true)

local dmgMult = 1.5
function this:UseItem(_, _, player, flags)
    return mod.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
end

local maxFrames = 18
function this:PEffectUpdate(player)
    local d = player:GetData()
    if player:IsHoldingItem() 
    and d.somethingWicked_isHoldingItem[CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] == true then
        d.sw_guillotineData = d.sw_guillotineData or 
        {
            Charge = 0,
            Direction = Direction.NO_DIRECTION
        }

        local direction = player:GetFireDirection()
        if direction ~= Direction.NO_DIRECTION then
            d.sw_guillotineData.Charge = math.min(d.sw_guillotineData.Charge + 1, maxFrames)
            d.sw_guillotineData.Direction = direction
        elseif d.sw_guillotineData.Charge > 0 then
            local mult = mod.EnemyHelpers:Lerp(0.2, 2, d.sw_guillotineData.Charge / maxFrames)
            local velocity = (mod.HoldItemHelpers:AimToVector(d.sw_guillotineData.Direction) * 10 + player.Velocity) * mult*1.5
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, player.Position, velocity, player):ToTear() --player:FireTear(player.Position, , false, true, false) make this not inherit tear effects
            tear.CollisionDamage = player.Damage * mult
            tear:AddTearFlags(TearFlags.TEAR_BOOGER)
            tear:ChangeVariant(TearVariant.SOMETHINGWICKED_FACESTABBER, 1)

            local t_data = tear:GetData()
            t_data.sw_guillotine = true

            tear:Update()

            
            local _, slot = mod.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
            player:AnimateCollectible(CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE, "HideItem", "PlayerPickupSparkle")
            d.somethingWicked_isHoldingItem[CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] = false
            player:DischargeActiveItem(slot)

            d.sw_guillotineData = nil
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
    if not t_data.sw_guillotine then
        return
    end

    if tear.StickTarget then
        local sticker = tear.StickTarget

        local e_data = sticker:GetData()
        if e_data.sw_itgoesitgoesitgoes == nil then
            collider:BloodExplode()
            mod.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
        end
        e_data.sw_itgoesitgoesitgoes = 2

        sticker:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        print(tear.StickTimer)
    end
end

local renderOffset = Vector(18, -42)
function this:PlayerRender(player, offset)
	if not Options.ChargeBars then
        return
    end
    if mod.game:GetRoom():GetRenderMode() > 2 then
        return
    end

    local d = player:GetData()
    if not d.sw_guillotineRender then
        if not d.sw_guillotineData then
            return
        end
        d.sw_guillotineRender = {}
    end

    if d.sw_guillotineData then
        d.sw_guillotineRender.dspr = -1
        if d.sw_guillotineRender.chrg and d.sw_guillotineRender.chrg > 1 then
            if d.sw_guillotineData.Charge < 1 then
                d.sw_guillotineRender.chrg = math.ceil(((d.sw_guillotineData.Charge/maxFrames)*100)+1)
            else
                d.sw_guillotineRender.chrg = d.sw_guillotineRender.chrg + 1
            end

            if d.sw_guillotineRender.chrg <= 101 then
                chargebar:SetFrame("Charging", d.sw_guillotineRender.chrg)
            elseif d.sw_guillotineRender.chrg <= 113 then
                chargebar:SetFrame("StartCharged", d.sw_guillotineRender.chrg-101)
            else
                chargebar:SetFrame("Charged", (d.sw_guillotineRender.chrg-113)%6)
            end
        end
    else
        d.sw_guillotineRender.dspr = (d.sw_guillotineRender.dspr or -1) +1
        chargebar:SetFrame("Dissapear", d.sw_guillotineRender.dspr)

        if d.sw_guillotineRender.dspr > 9 then
            d.sw_guillotineRender = nil
            return
        end
    end

    local pos = Isaac.WorldToScreen(player.Position + (renderOffset*player.SpriteScale) + offset)
    chargebar:Render(pos)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.KnifeCollision)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, this.PlayerRender)

local myFavouriteBool = false
local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()

    if e_data.sw_itgoesitgoesitgoes ~= nil and not myFavouriteBool then
        myFavouriteBool = true
        ent:TakeDamage(amount * dmgMult, flags, EntityRef(ent), dmgCooldown)
        myFavouriteBool = false --with love
        return false
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnEnemyTakeDMG)

local function NPCUpdate(_, ent)
    local e_data = ent:GetData()
    if e_data.sw_itgoesitgoesitgoes and e_data.sw_itgoesitgoesitgoes > 0 then 
        e_data.sw_itgoesitgoesitgoes = e_data.sw_itgoesitgoesitgoes - 1

        if e_data.sw_itgoesitgoesitgoes <= 0 then
           e_data.sw_itgoesitgoesitgoes = nil 
        end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_FLYING_GUILLOTINE] = {
        desc = "",
        Hide = true,
    }
}
return this