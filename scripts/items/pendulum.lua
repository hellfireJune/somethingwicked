local this = {}
local mod = SomethingWicked

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, p_data)
    p_data.sw_ddChance = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_PENDULUM) + p_data.sw_ddChance
end)

--local defaultcolor = Color(50, 50, 50, 1, 0)
function this:ProjectileInit(proj)
    if proj.FrameCount ~= 1 then
        return
    end
    if not mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_PENDULUM) then
        return
    end

    proj.ChangeFlags = proj.ChangeFlags & ~ProjectileFlags.SMART
    proj:ClearProjectileFlags(ProjectileFlags.SMART)

    --proj.Color = defaultcolor
    
    local sprite = proj:GetSprite()
    sprite:Load("gfx/009.006_hush projectile.anm2", true)
    sprite:ReplaceSpritesheet(0, "gfx/sw_pendulumprojectile.png")
    sprite:LoadGraphics()
    proj:AddScale(0)
    sprite:Play("RegularTear6")
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, this.ProjectileInit)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PENDULUM] = {
        desc = "?",
        Hide = true
    }
}
return this