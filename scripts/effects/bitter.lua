local mod = SomethingWicked

local function NPCUpdate(_, npc)
    local e_data = npc:GetData()
    if e_data.somethingWicked_bitterDuration ~= nil then
        e_data.somethingWicked_bitterDuration = e_data.somethingWicked_bitterDuration - 1
        if e_data.somethingWicked_bitterDuration <= 0 then
            e_data.somethingWicked_bitterDuration = nil
            e_data.somethingWicked_bitterParent = nil
        elseif e_data.somethingWicked_bitterDuration % 20 == 1 then
            npc:TakeDamage(e_data.somethingWicked_bitterParent.Damage * 2, DamageFlag.DAMAGE_NOKILL, EntityRef(e_data.somethingWicked_bitterParent), 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)