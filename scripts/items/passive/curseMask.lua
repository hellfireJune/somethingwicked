local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local function OnDamage(_, player, amount, flag)
    player = player:ToPlayer()
    if player:HasCollectible(mod.ITEMS.CURSE_MASK)
    and flag & DamageFlag.DAMAGE_CURSED_DOOR ~= 0 then
        local p_data = player:GetData()
        p_data.WickedPData.CurseRoomsHealedOff = p_data.WickedPData.CurseRoomsHealedOff or {} 

        local room = game:GetRoom()
        local door = room:GetGridEntityFromPos(player.Position)

        if door then
            door = door:ToDoor()
            if door then
                local idx = door.TargetRoomType == RoomType.ROOM_CURSE and door.TargetRoomIndex or game:GetLevel():GetCurrentRoomIndex()
                if not mod:UtilTableHasValue(p_data.WickedPData.CurseRoomsHealedOff, idx) then
                    table.insert(p_data.WickedPData.CurseRoomsHealedOff, idx)
                    player:AddHearts(2)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                    sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
        
                    local color = Color(1, 1, 1, 1, 0.5)
                    player:SetColor(color, 8, 3, true, false)
                    player:SetMinDamageCooldown(40)
                end
            end
        end
        
        return false
    end
end

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnDamage, EntityType.ENTITY_PLAYER)