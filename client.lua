local zoomed = false
local camera = nil
local lastAllowedCam = 0


-- ox_lib Keybind: Zoom hold
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

-- Thread: Disable controls & manage view mode
CreateThread(function()
    while true do
        Wait(0)
        if zoomed then
            -- Lock view modes
            enforceCameraView()

            -- Disable camera toggle key (V)
            DisableControlAction(0, 0, true)

            -- Shooting & Melee
            if Config.disableShooting then
                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end

            -- Aiming
            if Config.disableAiming then
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 68, true)
            end
        else
            Wait(100) -- Reduce CPU usage when not zooming
        end
    end
end)

-- Thread: Handle camera FOV update
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
        else
            Wait(100) -- Reduce usage when no camera
        end
    end
end)
