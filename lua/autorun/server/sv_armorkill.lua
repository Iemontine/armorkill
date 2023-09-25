CreateConVar("armorkill_enabled", 1, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "whether ammo on kill is enabled", 0, 1)
CreateConVar("armorkill_headshots_only", 0, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "only headshots give armor", 0, 1)
CreateConVar("armorkill_overkills_are_headshots", 0, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "should one-shots be counted as headshots?", 0, 1)
CreateConVar("armorkill_max", 100, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "max armor reachable by kill", 0)
CreateConVar("armorkill_chance", 100, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "chance as a percent that the kill gives armor", 0, 100)
CreateConVar("armorkill_multiplier", 1.5, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "how many ammo pickups to give back per kill", 0, 10)
CreateClientConVar("armorkill_mute", 0, true, false, "\n1 = muted\n0 = not muted", 0, 1)

local headshot = false
hook.Add("ScaleNPCDamage", "ArmorKill", function(npc, hitgroup, dmginfo)
    if GetConVar("armorkill_enabled"):GetBool() and GetConVar("armorkill_headshots_only"):GetBool() then
        if hitgroup == HITGROUP_HEAD or (GetConVar("armorkill_overkills_are_headshots"):GetBool() and (npc:GetMaxHealth() - dmginfo:GetDamage() <= 0)) then
            headshot = true
        end
    end
end)

hook.Add("OnNPCKilled", "ArmorKill", function( npc, attacker, inflictor)
    if GetConVar("armorkill_enabled"):GetBool() and GetConVar("armorkill_headshots_only"):GetBool() then
        if (GetConVar("armorkill_overkills_are_headshots"):GetBool() and inflictor:IsValid() and inflictor:GetClass() == 'prop_combine_ball') then
            headshot = true            
        end
    end
    if GetConVar("armorkill_enabled"):GetBool() then
        if IsValid(attacker) and attacker:IsPlayer() then
            if GetConVar("armorkill_headshots_only"):GetBool() and !headshot then
                headshot = false
                return -- exit hook
            end
            headshot = false
            
            local chance = 100 * math.random()
            if chance < GetConVar("armorkill_chance"):GetFloat() then -- math.random() * 100 gives number between 0 and 100
                if !GetConVar("armorkill_mute"):GetBool() and attacker:Armor() < GetConVar("armorkill_max"):GetFloat() then 
                    attacker:EmitSound("items/battery_pickup.wav", 75, 100) 
                end
                attacker:SetArmor(math.max(math.min(attacker:Armor() + 10*GetConVar("armorkill_multiplier"):GetFloat(), GetConVar("armorkill_max"):GetInt()), attacker:Armor()))
            end
        end
    end
end)

hook.Add("PlayerDeath", "ArmorKill", function( victim, inflictor, attacker)
    if GetConVar("armorkill_enabled"):GetBool() and GetConVar("armorkill_headshots_only"):GetBool() then
        if (GetConVar("armorkill_overkills_are_headshots"):GetBool() and inflictor == 'prop_combine_ball') then
            headshot = true            
        end
    end
    if GetConVar("armorkill_enabled"):GetBool() then
        if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) and victim:IsPlayer() and victim ~= attacker then
            if GetConVar("armorkill_headshots_only"):GetBool() and !headshot then
                headshot = false
                return -- exit hook
            end
            headshot = false
            
            local chance = 100 * math.random()
            if chance < GetConVar("armorkill_chance"):GetFloat() then -- math.random() * 100 gives number between 0 and 100
                if !GetConVar("armorkill_mute"):GetBool() and attacker:Armor() < GetConVar("armorkill_max"):GetFloat() then 
                    attacker:EmitSound("items/battery_pickup.wav", 75, 100) 
                end
                attacker:SetArmor(math.max(math.min(attacker:Armor() + 10*GetConVar("armorkill_multiplier"):GetFloat(), GetConVar("armorkill_max"):GetInt()), attacker:Armor()))
            end
        end
    end
end)