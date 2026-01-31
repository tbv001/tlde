local util = util
local CreateConVar = CreateConVar
local net = net
local GetConVar = GetConVar
local hook = hook
local cvars = cvars

util.AddNetworkString("TLDE_UpdateConvars")

-- ConVars.
CreateConVar("tlde_enabled", "1", {FCVAR_ARCHIVE}, "Enable or disable the Tarkov-like death effect.")
CreateConVar("tlde_fade_enabled", "1", {FCVAR_ARCHIVE}, "Enable or disable the fade to black effect on death. Disabling this will also disable block respawn and sounds fading out.")
CreateConVar("tlde_fade_delay", "2.0", {FCVAR_ARCHIVE}, "Time in seconds before starting the death fade effect.")
CreateConVar("tlde_fade_time", "0.25", {FCVAR_ARCHIVE}, "Time in seconds for the death fade effect to complete.")
CreateConVar("tlde_block_respawn", "1", {FCVAR_ARCHIVE}, "Block player respawn until the death fade effect is complete.")
CreateConVar("tlde_forward_offset", "-3.0", {FCVAR_ARCHIVE}, "Forward offset for the death camera.")
CreateConVar("tlde_sound_fade_enabled", "1", {FCVAR_ARCHIVE}, "Enable or disable sounds fading out on death.")
CreateConVar("tlde_hide_head", "1", {FCVAR_ARCHIVE}, "Enable or disable hiding the player's head on death.")

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

-- Update convars when they are changed.
cvars.AddChangeCallback("tlde_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_delay", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_fade_time", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_block_respawn", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_forward_offset", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_sound_fade_enabled", function() UpdateConvars() end)
cvars.AddChangeCallback("tlde_hide_head", function() UpdateConvars() end)

-- Update convars for the player when they initially spawn.
hook.Add("PlayerInitialSpawn", "TLDE_PlayerInitialSpawn", function(ply) UpdateConvars(ply) end)