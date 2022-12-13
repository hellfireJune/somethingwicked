local this = {}
CollectibleType.SOMETHINGWICKED_BROKEN_BELL = Isaac.GetItemIdByName("Broken Bell")

local maxFrames = 36
function this:PlayerUpdate(player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_BROKEN_BELL) then
        return
    end

    local p_data = player:GetData() p_data.somethingWicked_brokenBellCountDown = p_data.somethingWicked_brokenBellCountDown or 0
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        p_data.somethingWicked_brokenBellCountDown = p_data.somethingWicked_brokenBellCountDown + 1
    else
        p_data.somethingWicked_brokenBellCountDown = 0
    end

    if p_data.somethingWicked_brokenBellCountDown >= maxFrames then
        
        for _, ent in ipairs(Isaac.FindInRadius(player.Position, 80, 8)) do
            if not ent:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
                local veloc = ent.Position - player.Position
                veloc = (veloc:Normalized():Resized(100)) - veloc

                ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
                ent:AddVelocity(veloc)
            end
        end
        p_data.somethingWicked_brokenBellCountDown = 0
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
this.EIDEntries = {}
return this