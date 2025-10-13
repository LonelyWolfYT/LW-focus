local zoomed = false
local camera = nil

-- Camera mode constants
local THIRD_PERSON_NEAR = 0
local THIRD_PERSON_MEDIUM = 1
local THIRD_PERSON_FAR = 2
local CINEMATIC = 3
local FIRST_PERSON = 4

-- Smooth FOV interpolation
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
    SetCamCoord(camera, GetGameplayCamCoord())
    SetCamRot(camera, GetGameplayCamRot(2), 2)
end

-- Zoom updater: runs only while zooming
local function startZoomUpdater()
    if not camera then return end
    CreateThread(function()
        while zoomed and camera do
            local targetFOV = Config.zoomFOV
            local currentFOV = GetCamFov(camera)
            local newFOV = interpolateFOV(currentFOV, targetFOV, Config.zoomSpeed)
            SetCamFov(camera, newFOV)
            SetCamCoord(camera, GetGameplayCamCoord())
            SetCamRot(camera, GetGameplayCamRot(2), 2)

            if isPlayerInFirstPerson() then
                zoomed = false
                break
            end

            Wait(0)
        end

        if camera then
            local cur = GetCamFov(camera)
            while math.abs(cur - Config.normalFOV) > 0.5 do
                cur = interpolateFOV(cur, Config.normalFOV, Config.zoomSpeed)
                SetCamFov(camera, cur)
                Wait(0)
            end
            resetZoomCamera()
        end
    end)
end

-- Disable shooting and aiming while zoomed
local function startDisableControlsThread()
    CreateThread(function()
        while zoomed do
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
            if Config.disableAiming then
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 68, true)
            end
            Wait(0)
        end
    end)
end

-- Keybind for zoom (ox_lib)
lib.addKeybind({
    name = 'zoom_camera',
    description = 'Hold to Zoom Camera',
    defaultKey = Config.ZoomKey or 'Z',
    onPressed = function()
        if isPlayerInFirstPerson() then return end
        if zoomed then return end
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

--------------------------------------------------------------------
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
end

