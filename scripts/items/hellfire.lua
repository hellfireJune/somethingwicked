local this = {}
CollectibleType.SOMETHINGWICKED_HELLFIRE = Isaac.GetItemIdByName("Hellfire")

local function procChance(player)
    return 1
end
local shouldMakeDMGCrazy = false
function this:OnTakeDMG(ent, amount, flags, source, dmgCooldown)
    if shouldMakeDMGCrazy then
        return
    end
    ent = ent:ToNPC()
    if not ent
    or not ent:IsEnemy() then
        return
    end

    local e_data = ent:GetData()
    if e_data.somethingWicked_hellfirePrimedFrames and e_data.somethingWicked_hellfirePrimedFrames <= 0 then
        return
    end
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_HELLFIRE)
    if flag and player then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_HELLFIRE)
        if e_data.somethingWicked_isHellfireMarked == nil then
            e_data.somethingWicked_isHellfireMarked = c_rng:RandomFloat() < procChance(player)
        end
    end
    if e_data.somethingWicked_isHellfireMarked then
        shouldMakeDMGCrazy = true
        ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, dmgCooldown)
        shouldMakeDMGCrazy = false
        return false
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnTakeDMG)

function this:NPCUpdate(ent)
    local e_data = ent:GetData()
    if not e_data.somethingWicked_isHellfireMarked then
        return
    end
    if e_data.somethingWicked_hellfirePrimedFrames ~= nil then
        e_data.somethingWicked_hellfirePrimedFrames = e_data.somethingWicked_hellfirePrimedFrames - 1
        local shouldFlash = e_data.somethingWicked_hellfirePrimedFrames % 5 == 4
        if shouldFlash then
            local color = Color(1, 1, 1, 1, 1)
            ent:SetColor(color, 8, 3, true, false)
        elseif e_data.somethingWicked_hellfirePrimedFrames == 0 then
            Game():BombTearflagEffects(ent.Position, 1, TearFlags.TEAR_BRIMSTONE_BOMB, Isaac.GetPlayer(0), 1)
            ent:BloodExplode()
        end
    elseif ent.HitPoints < 0.1 then
        e_data.somethingWicked_hellfirePrimedFrames = 30
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)

this.EIDEntries = {}
return this