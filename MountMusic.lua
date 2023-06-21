--Create initial frame--
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent)

--Table varible to hold frames containers for the mount textureKits
local mount_music_frame_containers = {}

--Create options panel  --
mountMusicSettingsFrame.panel = CreateFrame("Frame")
mountMusicSettingsFrame.panel.name = "Mount Music"

InterfaceOptions_AddCategory(mountMusicSettingsFrame.panel)

local function playMountMusic(self, event, unit)
    local numMounts = GetNumCompanions("MOUNT")

    if numMounts > 0 then
        if IsMounted() then
            for i = 1, numMounts do
                local creatureID, creatureName, creatureSpellID, icon, isSummoned, mountType = GetCompanionInfo("MOUNT",
                    i)
                if isSummoned and creatureName == "Dreadsteed" then
                    print(creatureName, icon)
                    SetCVar("Sound_MusicVolume", 0.3)
                    PlayMusic("Interface/AddOns/MountMusic/audio-files/rag-boss-fight.mp3")
                else
                    if isSummoned and creatureName == "Fiery Warhorse" then
                        print(creatureName, icon)
                        SetCVar("Sound_MusicVolume", 0.3)
                        PlayMusic("Interface/AddOns/MountMusic/audio-files/kharazan-theme.mp3")
                    end
                end
            end
        else
            print("Music stopped")
            StopMusic()
        end
    else
        print("Looks like you don't have any mounts.")
    end
end


mountMusicSettingsFrame:RegisterUnitEvent("UNIT_AURA", "player")
mountMusicSettingsFrame:RegisterEvent("ADDON_LOADED")
mountMusicSettingsFrame:SetScript("OnLoad", playMountMusic)
mountMusicSettingsFrame:SetScript("OnEvent", playMountMusic)


-- local btn = CreateFrame("Button", nil, mount_music_settings_frame.panel, "UIPanelButtonTemplate")
-- btn:SetPoint("CENTER")
-- btn:SetSize(80, 20)
-- btn:SetText("hello")

-- btn:SetMovable(true)
-- btn:EnableMouse(true)
-- btn:RegisterForDrag("LeftButton")
-- btn:SetScript("OnDragStart", btn.StartMoving)
-- btn:SetScript("OnDragStop", btn.StopMovingOrSizing)

-- btn:SetScript("OnClick", handleClick)


-- -- Create a frame to hold the mount icon --
-- local texture = CreateFrame("Frame", nil, mount_music_settings_frame.panel)
-- texture:SetPoint("LEFT", 50, 200)
-- texture:SetSize(80, 20)

-- local newTexture = texture:CreateTexture("mount music top icon", "BACKGROUND")

-- newTexture:SetWidth(200)
-- newTexture:SetHeight(100)
-- newTexture:SetPoint("TOPLEFT")
-- newTexture:SetTexture("Interface\\GLUES\\COMMON\\gamelogo-wrathofthelichking.blp")


-- mount_music_settings_frame:SetScript("OnLoad", mount_music_settings_frame.InitFrame)
-- Create Artwork Layer within the main options panel --
