-- ConVars.
CreateConVar("tlde_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable or disable the Tarkov-like death effect.")
CreateConVar("tlde_fade_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable or disable the fade to black effect on death. Disabling this will also disable block respawn and sounds fading out.")
CreateConVar("tlde_fade_delay", "2.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Time in seconds before starting the death fade effect.")
CreateConVar("tlde_fade_time", "0.25", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Time in seconds for the death fade effect to complete.")
CreateConVar("tlde_block_respawn", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Block player respawn until the death fade effect is complete.")
CreateConVar("tlde_forward_offset", "-3.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Forward offset for the death camera.")
CreateConVar("tlde_sound_fade_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable or disable sounds fading out on death.")
CreateConVar("tlde_hide_head", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable or disable hiding the player's head on death.")

-- Disable default death and beeping sound.
hook.Add("PlayerDeathSound", "TLDE_PlayerDeathSound", function() 
    if GetConVar("tlde_enabled"):GetBool() then
        return true
    end
end)