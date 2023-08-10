--Initial options frame--
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent)

--Check for first time mounting up--
local alreadyMounted = false

--Initial position of mount ui element in the options panel --
local mountUiYPos = 230;

--Number of mounts --
local numMounts = GetNumCompanions("MOUNT")

--Expansion table
local mountMusicDropdownValues = {
    "no music", "chrono-trigger-main-theme.mp3",
    "Duel-of-the-Fates.ogg",
    "ff10-battle-theme.mp3", "Final-Fantasy-Battle.ogg", "kharazan-theme.mp3", "rag-boss-fight.mp3",
    "take-me-home.ogg",
    "cyberpunk.mp3"
}

--Music files for dropDown selection
-- local mountMusicDropdownValues = { "no music", "chrono-trigger-main-theme.mp3",
--     "Duel-of-the-Fates.ogg",
--     "ff10-battle-theme.mp3", "Final-Fantasy-Battle.ogg", "kharazan-theme.mp3", "rag-boss-fight.mp3", "take-me-home.ogg",
--     "cyberpunk.mp3" }

--Create options panel  --
mountMusicSettingsFrame.panel = CreateFrame("Frame")
mountMusicSettingsFrame.panel.name = "Mount Music"

-- Add this frame to the category options
InterfaceOptions_AddCategory(mountMusicSettingsFrame.panel)

-- Create the scrolling parent frame and size it to fit inside the options panel
local scrollFrame = CreateFrame("ScrollFrame", nil, mountMusicSettingsFrame.panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 3, -4)
scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

-- Scrolling child frame, set its width to fit, and give it an arbitrary minimum height
local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 18)
scrollChild:SetHeight(600)


--Create Mount Music ui components for the options panel
local function createMountUiElements(id, yPos)
    local width = 45
    local height = 45
    local x = 10
    local creatureID, creatureName, creatureSpellID, icon, isSummoned, mountType = GetCompanionInfo("MOUNT",
        id)

    local frame = CreateFrame("Frame", "mountMusicUiElement" .. id, scrollChild,
        "ToolTipBorderedFrameTemplate")
    frame:SetPoint("LEFT", x, yPos)
    frame:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 80)
    frame:SetHeight(70)


    frame.Texture = frame:CreateTexture("mount music top icon",
        "ARTWORK")
    frame.Texture:SetWidth(width)
    frame.Texture:SetHeight(height)
    frame.Texture:SetPoint("LEFT", 20, 0)
    frame.Texture:SetTexture(icon)

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.Text:SetPoint("LEFT", 75, 0)
    frame.Text:SetText(creatureName)


    local dropDown = CreateFrame("Frame", "mountMusicUiDropdown" .. id, frame,
        "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", 0, 0)
    dropDown:SetWidth(200)
    UIDropDownMenu_SetWidth(dropDown, 200)

    if selectedMountMusicValues ~= nil and selectedMountMusicValues[creatureID] ~= nil then
        UIDropDownMenu_SetText(dropDown, selectedMountMusicValues[creatureID])
    else
        UIDropDownMenu_SetText(dropDown, "Select a song")
    end

    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for key, value in pairs(mountMusicDropdownValues) do
            info.text = value
            info.value = value
            info.func = function(self)
                UIDropDownMenu_SetSelectedValue(dropDown, self.value)
                UIDropDownMenu_SetText(dropDown, self.value)
                selectedMountMusicValues[creatureID] = self.value
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end



-- Play music when mounted --
local function playMountMusic()
    if IsMounted() and alreadyMounted == false then
        for i = 1, numMounts do
            local creatureID, creatureName, creatureSpellID, icon, isSummoned, mountType = GetCompanionInfo("MOUNT",
                i)

            if isSummoned then
                SetCVar("Sound_MusicVolume", 0.5)
                SetCVar("Sound_AmbienceVolume", 0.1)
                SetCVar("Sound_SFXVolume", 0.3)
                if selectedMountMusicValues[creatureID] ~= nil then
                    PlayMusic("Interface/AddOns/MountMusic/audio-files/" .. selectedMountMusicValues[creatureID])
                    alreadyMounted = true
                end
            end
        end
    elseif IsMounted() == false then
        StopMusic()
        alreadyMounted = false
    end
end


--NumMounts always seems to be zero on player login.
--If it is not zero create the mount ui elements else create a button that will generate the mount music ui.
if (numMounts ~= 0 and selectedMountMusicValues ~= nil) then
    for i = 1, numMounts do
        createMountUiElements(i, mountUiYPos)
        mountUiYPos = mountUiYPos - 90
    end
else
    local heading = CreateFrame("Frame", nil, mountMusicSettingsFrame.panel)
    heading:SetWidth(50)
    heading:SetHeight(50)
    heading:SetPoint("TOPLEFT")
    heading.text = heading:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading.text:SetPoint("TOPLEFT", 0, 0)
    heading.text:SetText("Mount Music")


    local bodyText = CreateFrame("Frame", nil, mountMusicSettingsFrame.panel)
    bodyText:SetWidth(50)
    bodyText:SetHeight(50)
    bodyText:SetPoint("TOPLEFT", 0, 0)
    bodyText.text = bodyText:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    bodyText.text:SetPoint("TOPLEFT", 0, -30)
    bodyText.text:SetText("Select songs you want played when riding specific mounts.")



    local f = CreateFrame("Button", nil, mountMusicSettingsFrame.panel, "UIPanelButtonTemplate")
    f:SetSize(180, 30)
    f:SetPoint("TOPLEFT", 0, -50)
    f:SetText("Generate Mount Data")
    f:SetScript("OnClick", function()
        local firstLoadNumMounts = GetNumCompanions("Mount")
        numMounts = firstLoadNumMounts
        for i = 1, firstLoadNumMounts do
            createMountUiElements(i, mountUiYPos)
            mountUiYPos = mountUiYPos - 90
        end
        heading:Hide()
        bodyText:Hide()
        f:Hide()
    end)
end



--Handle events
local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MountMusic" then
            print("\124cff00ccffMountMusic version 1.0.0 loaded. Enjoy!\124r")
            print("\124cff00ccffPlease go into the mount music options settings and generate mount data.\124r")
            print("\124cff00ccffIf you don't have any mounts this addon will not work.\124r")
            if selectedMountMusicValues == nil then
                _G.selectedMountMusicValues = {}
            end
        end
    end
    if event == "UNIT_AURA" then
        local unitID = ...
        if (unitID == "player") then
            playMountMusic()
        end
    end
end

--Register events and scripts --
mountMusicSettingsFrame:RegisterEvent("ADDON_LOADED")
mountMusicSettingsFrame:RegisterUnitEvent("UNIT_AURA", "player")
mountMusicSettingsFrame:SetScript("OnEvent", onEvent)
