Config = {}

-- Zoom settings
Config.ZoomKey = 'Z'
Config.zoomFOV = 20.0
Config.normalFOV = 50.0
Config.zoomSpeed = 2.0

-- Disable controls
Config.disableShooting = true
Config.disableAiming = true
Config.DisableInFirstPerson = true
Config.CameraSwitch = true


-- Key used for switching camera (default: V)
-- Reference: https://docs.fivem.net/docs/game-references/controls/
Config.CameraSwitchKey = 0 -- INPUT_SELECT_NEXT_CAMERA

-- Allowed camera modes (cycle will only toggle between these)
-- Available: FIRST_PERSON = 4, THIRD_PERSON_NEAR = 0, THIRD_PERSON_MEDIUM = 1, THIRD_PERSON_FAR = 2, CINEMATIC = 3
Config.AllowedCameraModes = { FIRST_PERSON = true, THIRD_PERSON_MEDIUM = true }  --(under development)