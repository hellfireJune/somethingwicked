local this = {}
this.EnemyType = EntityType.ENTITY_CYCLOPIA
this.EnemyVariant = Isaac.GetEntityVariantByName("Experiment")

function this:AI(npc)
    if npc and npc.Variant == this.EnemyVariant then
        local sprite = npc:GetSprite()
        local target = npc:GetPlayerTarget()

        if sprite:IsOverlayPlaying("Attack") and sprite:GetOverlayFrame() == 3 then
            local params = ProjectileParams()
            params.Spread = 1

            npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized( 9), 1, params)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.AI, this.EnemyType)