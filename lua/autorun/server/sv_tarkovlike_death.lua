util.AddNetworkString("TLDE_UpdateConvars")
util.AddNetworkString("TLDE_PlayerDeath")

-- ConVars.
CreateConVar("tlde_enabled", "1", { FCVAR_ARCHIVE }, "Enable or disable the Tarkov-like death effect.")
CreateConVar("tlde_fade_enabled", "1", { FCVAR_ARCHIVE },
    "Enable or disable the fade to black effect on death. Disabling this will also disable block respawn and sounds fading out.")
CreateConVar("tlde_fade_delay", "2.0", { FCVAR_ARCHIVE }, "Time in seconds before starting the death fade effect.")
CreateConVar("tlde_fade_time", "0.25", { FCVAR_ARCHIVE }, "Time in seconds for the death fade effect to complete.")
CreateConVar("tlde_block_respawn", "1", { FCVAR_ARCHIVE },
    "Block player respawn until the death fade effect is complete.")
CreateConVar("tlde_forward_offset", "-3.0", { FCVAR_ARCHIVE }, "Forward offset for the death camera.")
CreateConVar("tlde_sound_fade_enabled", "1", { FCVAR_ARCHIVE }, "Enable or disable sounds fading out on death.")
CreateConVar("tlde_hide_head", "1", { FCVAR_ARCHIVE }, "Enable or disable hiding the player's head on death.")
CreateConVar("tlde_extra_alive_check", "0", { FCVAR_ARCHIVE },
    "Enable or disable an extra check to see if the player is dead before applying the death effect. This can help with issues where the death effects still apply even after the player has respawned, but may show a frame of default third person death.")

CreateConVar("tlde_hs_enabled", "0", { FCVAR_ARCHIVE },
    "Enable or disable different fade delay and time settings on headshot.")
CreateConVar("tlde_hs_fade_delay", "0", { FCVAR_ARCHIVE },
    "Time in seconds before starting the fade effect when killed by a headshot.")
CreateConVar("tlde_hs_fade_time", "0", { FCVAR_ARCHIVE },
    "Time in seconds for the fade effect to complete when killed by a headshot.")

CreateConVar("tlde_randomize_fade", "0", { FCVAR_ARCHIVE }, "Randomize the fade delay and time for death effects.")
CreateConVar("tlde_randomize_fade_delay_min", "2.0", { FCVAR_ARCHIVE }, "Minimum value for randomizing the fade delay.")
CreateConVar("tlde_randomize_fade_delay_max", "3.0", { FCVAR_ARCHIVE }, "Maximum value for randomizing the fade delay.")
CreateConVar("tlde_randomize_fade_time_min", "0.25", { FCVAR_ARCHIVE }, "Minimum value for randomizing the fade time.")
CreateConVar("tlde_randomize_fade_time_max", "0.5", { FCVAR_ARCHIVE }, "Maximum value for randomizing the fade time.")

-- Send convars to all players, or only for a specific player if ply argument is supplied.
local function UpdateConvars(ply)
    net.Start("TLDE_UpdateConvars")
    net.WriteBool(GetConVar("tlde_enabled"):GetBool())
    net.WriteBool(GetConVar("tlde_fade_enabled"):GetBool())
    net.WriteFloat(GetConVar("tlde_fade_delay"):GetFloat())
    net.WriteFloat(GetConVar("tlde_fade_time"):GetFloat())
    net.WriteBool(GetConVar("tlde_block_respawn"):GetBool())
    net.WriteFloat(GetConVar("tlde_forward_offset"):GetFloat())
    net.WriteBool(GetConVar("tlde_sound_fade_enabled"):GetBool())
    net.WriteBool(GetConVar("tlde_hide_head"):GetBool())
    net.WriteBool(GetConVar("tlde_extra_alive_check"):GetBool())
    net.WriteBool(GetConVar("tlde_hs_enabled"):GetBool())
    net.WriteFloat(GetConVar("tlde_hs_fade_delay"):GetFloat())
    net.WriteFloat(GetConVar("tlde_hs_fade_time"):GetFloat())
    net.WriteBool(GetConVar("tlde_randomize_fade"):GetBool())
    net.WriteFloat(GetConVar("tlde_randomize_fade_delay_min"):GetFloat())
    net.WriteFloat(GetConVar("tlde_randomize_fade_delay_max"):GetFloat())
    net.WriteFloat(GetConVar("tlde_randomize_fade_time_min"):GetFloat())
    net.WriteFloat(GetConVar("tlde_randomize_fade_time_max"):GetFloat())

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

-- Disable default death and beeping sound.
hook.Add("PlayerDeathSound", "TLDE_PlayerDeathSound", function()
    if GetConVar("tlde_enabled"):GetBool() then
        return true
    end
end)

-- Track whether the kill was a headshot.
hook.Add("ScalePlayerDamage", "TLDE_ScalePlayerDamage", function(ply, hitgroup)
    if hitgroup == HITGROUP_HEAD then
        ply.TLDE_Headshot = true
    end
end)

hook.Add("PostEntityTakeDamage", "TLDE_PostEntityTakeDamage", function(ent)
    if ent:IsPlayer() then
        ent.TLDE_Headshot = false
    end
end)

hook.Add("PlayerSpawn", "TLDE_PlayerSpawn", function(ply)
    ply.TLDE_Headshot = false
end)

-- Notify the client when they die and whether it was a headshot.
hook.Add("PlayerDeath", "TLDE_PlayerDeath", function(victim)
    net.Start("TLDE_PlayerDeath")
    net.WriteBool(victim.TLDE_Headshot == true)
    net.Send(victim)

    victim.TLDE_Headshot = false
end)

-- Update convars when they are changed.
cvars.AddChangeCallback("tlde_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_delay", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_time", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_block_respawn", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_forward_offset", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_sound_fade_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_hide_head", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_extra_alive_check", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_hs_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_hs_fade_delay", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_hs_fade_time", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_randomize_fade", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_randomize_fade_delay_min", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_randomize_fade_delay_max", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_randomize_fade_time_min", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_randomize_fade_time_max", function() UpdateConvars() end)

-- Update convars for the player when they initially spawn.
hook.Add("PlayerInitialSpawn", "TLDE_PlayerInitialSpawn", function(ply) UpdateConvars(ply) end)
