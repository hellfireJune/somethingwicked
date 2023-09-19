local mod = SomethingWicked

function mod:BitterStatusUpdate(npc)
    local e_data = npc:GetData()
    if e_data.sw_bitterDuration ~= nil then
        e_data.sw_bitterDuration = e_data.sw_bitterDuration - 1
        if e_data.sw_bitterDuration <= 0 then
            e_data.sw_bitterDuration = nil
            e_data.sw_bitterParent = nil
        elseif e_data.sw_bitterDuration % 20 == 1 then
            npc:TakeDamage(e_data.sw_bitterParent.Damage * 2, DamageFlag.DAMAGE_NOKILL, EntityRef(e_data.sw_bitterParent), 1)
        end
    end
end