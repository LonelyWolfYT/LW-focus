local zoomed, camera = false, nil
local FIRST_PERSON = 4

local function interpolateFOV(currentFOV, targetFOV, speed)
    return currentFOV + (targetFOV - currentFOV) / speed
end

local function isPlayerInFirstPerson()
    return Config.DisableInFirstPerson and GetFollowPedCamViewMode() == FIRST_PERSON
end

local function resetZoomCamera()
    if camera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(camera, false)
        camera = nil
    end
end

local function activateZoomCamera()
    if not camera then
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(camera, true)
        RenderScriptCams(true, false, 0, true, true)
    end
end

local function startZoomUpdater()
    if not camera then return end
    CreateThread(function()
        local targetFOV, speed = Config.zoomFOV, Config.zoomSpeed
        local normalFOV = Config.normalFOV

        while zoomed and camera do
            -- Avoid constant calls if player doesn't move much
            local camCoord = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            local currentFOV = GetCamFov(camera)
            local newFOV = interpolateFOV(currentFOV, targetFOV, speed)

            if math.abs(newFOV - currentFOV) > 0.05 then
                SetCamFov(camera, newFOV)
            end

            SetCamCoord(camera, camCoord)
            SetCamRot(camera, camRot, 2)

            if isPlayerInFirstPerson() then
                zoomed = false
                break
            end

            Wait(1) -- Slight delay reduces CPU load dramatically
        end

        if camera then
            local cur = GetCamFov(camera)
            while math.abs(cur - normalFOV) > 0.3 do
                cur = interpolateFOV(cur, normalFOV, speed)
                SetCamFov(camera, cur)
                Wait(1)
            end
            resetZoomCamera()
        end
    end)
end

local function startDisableControlsThread()
    if not (Config.disableShooting or Config.disableAiming) then return end
    CreateThread(function()
        local disableShoot, disableAim = Config.disableShooting, Config.disableAiming
        while zoomed do
            if disableShoot then
                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end
            if disableAim then
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 68, true)
            end
            Wait(2) -- control disabling doesn’t need to run every frame
        end
    end)
end

lib.addKeybind({
    name = 'zoom_camera',
    description = 'Hold to Zoom Camera',
    defaultKey = Config.ZoomKey or 'Z',
    onPressed = function()
        if zoomed or isPlayerInFirstPerson() then return end
        zoomed = true
        activateZoomCamera()
        startZoomUpdater()
        startDisableControlsThread()
    end,
    onReleased = function()
        zoomed = false
    end,
    onHold = true
})


--[[--------------------------------------------------------------------
-- ✅ CUSTOM CAMERA SWITCH CONTROL (replaces "V")
--------------------------------------------------------------------
if Config.CameraSwitch then 
CreateThread(function()
    local allowedModes = Config.AllowedCameraModes
    local switchKey = Config.CameraSwitchKey

    while true do
        Wait(0)

        -- Disable default camera switch (V)
        DisableControlAction(0, switchKey, true)

        if IsDisabledControlJustPressed(0, switchKey) then
            local currentMode = GetFollowPedCamViewMode()

            if currentMode == FIRST_PERSON and allowedModes["THIRD_PERSON_MEDIUM"] then
                SetFollowPedCamViewMode(THIRD_PERSON_MEDIUM)
            elseif currentMode == THIRD_PERSON_MEDIUM and allowedModes["FIRST_PERSON"] then
                SetFollowPedCamViewMode(FIRST_PERSON)
            elseif allowedModes["FIRST_PERSON"] then
                SetFollowPedCamViewMode(FIRST_PERSON)
            else
                SetFollowPedCamViewMode(THIRD_PERSON_MEDIUM)
            end
        end
    end
end)
end ]]--


