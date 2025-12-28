local matGradientDown = Material("gui/gradient_down")
local matGradientUp = Material("gui/gradient_up")
local soundNeedReset = false
local deathStart = 0
local ragdollEnt

-- Adjust the camera to the ragdoll's eye attachment position.
hook.Add("CalcView", "TLDE_CalcView", function(ply, pos, angles, fov)
    if GetConVar("tlde_enabled"):GetBool() then
        local ragdoll = ply:GetRagdollEntity()
        local observedEnt = ply:GetObserverTarget() -- Ragdoll mods usually set the player's observer target to the player's ragdoll.

        -- A fix for the player dead body's head missing after respawn, mainly for ragdoll mods that keeps the player's dead body.
        if ragdollEnt and IsValid(ragdollEnt) and deathStart == 0 then
            local head = ragdollEnt:LookupBone("ValveBiped.Bip01_Head1")
            if head then
                ragdollEnt:ManipulateBoneScale(head, Vector(1, 1, 1))
            end
            ragdollEnt = nil
        end

        if soundNeedReset and deathStart == 0 then
            LocalPlayer():ConCommand("soundfade 0 1")
            soundNeedReset = false
        end

        if not ply:Alive() and (IsValid(ragdoll) or (IsValid(observedEnt) and observedEnt:GetClass() == "prop_ragdoll")) then
            local curEnt = IsValid(ragdoll) and ragdoll or observedEnt

            local head = curEnt:LookupBone("ValveBiped.Bip01_Head1")
            if head and GetConVar("tlde_hide_head"):GetBool() then
                curEnt:ManipulateBoneScale(head, Vector(0, 0, 0))
                ragdollEnt = curEnt
            end

            -- Getting the first attachment as a fallback if the "eyes" attachment is missing might unintentionally put the camera somewhere else.
            local eyeAttachment = curEnt:GetAttachment(curEnt:LookupAttachment("eyes")) or curEnt:GetAttachment(1)
            if eyeAttachment then
                if deathStart == 0 then deathStart = CurTime() end

                local view = {
                    origin = eyeAttachment.Pos + (eyeAttachment.Ang:Forward() * GetConVar("tlde_forward_offset"):GetFloat()),
                    angles = eyeAttachment.Ang,
                    fov = fov,
                    drawviewer = false,
                    znear = 0.1 -- Might cause depth precision buffer issues by setting it too low, but I think it works fine.
                }
                
                return view
            end
        else
            deathStart = 0
        end
    else
        deathStart = 0
    end
end)

-- Fade to black.
hook.Add("HUDPaint", "TLDE_HUDPaint", function()
    if GetConVar("tlde_enabled"):GetBool() and GetConVar("tlde_fade_enabled"):GetBool() then
        if deathStart ~= 0 then
            local fadeDelay = GetConVar("tlde_fade_delay"):GetFloat()
            local fadeTime = GetConVar("tlde_fade_time"):GetFloat()

            local elapsed = CurTime() - deathStart
            
            if elapsed > fadeDelay then
                local progress = math.Clamp((elapsed - fadeDelay) / fadeTime, 0, 1)
                local gradientSize = ScrH() * 0.5
                local lidHeight = Lerp(progress, -gradientSize, ScrH() / 2)

                -- Fade out sounds.
                if not soundNeedReset and GetConVar("tlde_sound_fade_enabled"):GetBool() then
                    LocalPlayer():ConCommand("soundfade 100 999999999 [" .. fadeTime .. " " .. fadeTime .. "]")
                    soundNeedReset = true
                end

                -- Vignette.
                surface.SetDrawColor(0, 0, 0, 255 * progress)
                surface.SetMaterial(matGradientDown)
                surface.DrawTexturedRectRotated(gradientSize / 2, ScrH() / 2, ScrH(), gradientSize, 90)
                surface.DrawTexturedRectRotated(ScrW() - gradientSize / 2, ScrH() / 2, ScrH(), gradientSize, -90)
                
                surface.SetDrawColor(0, 0, 0, 255)
                
                -- Top eyelid.
                surface.DrawRect(0, 0, ScrW(), math.max(0, lidHeight)) 
                surface.SetMaterial(matGradientDown)
                surface.DrawTexturedRect(0, lidHeight, ScrW(), gradientSize)

                -- Bottom eyelid.
                surface.DrawRect(0, ScrH() - lidHeight, ScrW(), math.max(0, lidHeight + 10))
                surface.SetMaterial(matGradientUp)
                surface.DrawTexturedRect(0, ScrH() - lidHeight - gradientSize, ScrW(), gradientSize)
            end
        end
    end
end)

-- Disable input until fade is complete.
hook.Add("CreateMove", "TLDE_CreateMove", function(cmd)
    if GetConVar("tlde_enabled"):GetBool() and GetConVar("tlde_block_respawn"):GetBool() and GetConVar("tlde_fade_enabled"):GetBool() then
        if deathStart ~= 0 then
            local fadeDelay = GetConVar("tlde_fade_delay"):GetFloat()
            local fadeTime = GetConVar("tlde_fade_time"):GetFloat()

            local elapsed = CurTime() - deathStart
            if elapsed < (fadeDelay + fadeTime) + 0.5 then
                cmd:ClearButtons()
            end
        end
    end
end)

-- Disable death red screen.
hook.Add("HUDShouldDraw", "TLDE_HUDShouldDraw", function(name)
    if GetConVar("tlde_enabled"):GetBool() then
        if deathStart ~= 0 then
            if name == "CHudDamageIndicator" then
                return false
            end
        end
    end
end)