local zoomed = false
local camera = nil

local function interpolateFOV(currentFOV, targetFOV, speed)
    return currentFOV + (targetFOV - currentFOV) / speed
end

-- Keybind setup using ox_lib
lib.addKeybind({
    name = 'zoom_camera',
    description = 'Hold to Zoom Camera',
    defaultKey = Config.ZoomKey,
    onPressed = function()
        zoomed = true
        if not camera then
            camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamActive(camera, true)
            RenderScriptCams(true, false, 0, true, true)
        end
        SetCamCoord(camera, GetGameplayCamCoord())
        SetCamRot(camera, GetGameplayCamRot(2), 2)
    end,
    onReleased = function()
        zoomed = false
    end,
    onHold = true
})

-- Disable shooting/aiming while zoomed
CreateThread(function()
    while true do
        Wait(0)
        -- Disable controls while zoomed
        if zoomed then
            if Config.disableShooting then
        -- FULL BLOCK FOR SHOOTING
        DisablePlayerFiring(PlayerId(), true)                -- HARD prevent firing
        DisableControlAction(0, 24, true)                    -- INPUT_ATTACK
        DisableControlAction(0, 69, true)                    -- INPUT_VEH_ATTACK
        DisableControlAction(0, 92, true)                    -- INPUT_VEH_PASSENGER_ATTACK
        DisableControlAction(0, 114, true)                   -- INPUT_VEH_FLY_ATTACK
        DisableControlAction(0, 140, true)                   -- Melee light
        DisableControlAction(0, 141, true)                   -- Melee heavy
        DisableControlAction(0, 142, true)                   -- Melee alternate
    end
    if Config.disableAiming then
        DisableControlAction(0, 25, true) -- INPUT_AIM
        DisableControlAction(0, 68, true) -- Vehicle Aim
    end
end

    end
end)

-- Zoom logic thread
CreateThread(function()
    while true do
        Wait(0)
        local targetFOV = zoomed and Config.zoomFOV or Config.normalFOV

        if camera then
            local currentFOV = GetCamFov(camera)
            local newFOV = interpolateFOV(currentFOV, targetFOV, Config.zoomSpeed)
            SetCamFov(camera, newFOV)
            SetCamCoord(camera, GetGameplayCamCoord())
            SetCamRot(camera, GetGameplayCamRot(2), 2)

            if not zoomed and math.abs(newFOV - Config.normalFOV) < 1.0 then
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(camera, false)
                camera = nil
            end
        end
    end
end)
