-- Initial options frame
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")
local mmFrameWidth            = 600
local mmFrameHeight           = 600

--Set Title of the Mount Music setting frame
local title                   = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -4) -- a little padding from the very top
title:SetJustifyH("CENTER")
title:SetText("Mount Music Settings")
local file, _, flags = title:GetFont()
title:SetFont(file, 14, flags)


mountMusicSettingsFrame:SetPoint("CENTER")
mountMusicSettingsFrame:SetSize(mmFrameHeight, mmFrameWidth)

-- Make frame movable
mountMusicSettingsFrame:SetMovable(true)
mountMusicSettingsFrame:EnableMouse(true)
mountMusicSettingsFrame:RegisterForDrag("LeftButton")
mountMusicSettingsFrame:SetScript("OnDragStart", mountMusicSettingsFrame.StartMoving)
mountMusicSettingsFrame:SetScript("OnDragStop", mountMusicSettingsFrame.StopMovingOrSizing)

-- Make frame resizable
mountMusicSettingsFrame:SetResizable(true)

-- Resize handle (bottom-right corner)
local resizeButton = CreateFrame("Button", nil, mountMusicSettingsFrame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT", -4, 4)
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function()
    mountMusicSettingsFrame:StartSizing("BOTTOMRIGHT")
end)
resizeButton:SetScript("OnMouseUp", function()
    mountMusicSettingsFrame:StopMovingOrSizing()
end)


-- Ensure saved variable exists
MountMusicDB = MountMusicDB or {}

-- Load LibDBIcon
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Create a basic minimap button (no LDB)
local button = {
    icon = "Interface\\Icons\\ability_mount_ridinghorse",
    -- What happens when the minimap icon is clicked
    OnClick = function(_, button)
        if mountMusicSettingsFrame:IsShown() then
            mountMusicSettingsFrame:Hide()
        else
            mountMusicSettingsFrame:Show()
        end
    end,
    -- Tooltip text
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Mount Music")
        tooltip:AddLine("Click to open settings.", 1, 1, 1)
    end,
}

-- Register it with LibDBIcon directly
LDBIcon:Register("MountMusic", button, MountMusicDB.minimap)


--Check for first time mounting up--
local alreadyMounted = false

--Initial position of mount ui element in the options panel --
local mountUiYPos = 230;

--Number of mounts --
local numMounts = GetNumCompanions("MOUNT")



local minibtn = CreateFrame("Button", nil, Minimap)
minibtn:SetFrameLevel(8)
minibtn:SetSize(32, 32)
minibtn:SetMovable(true)

minibtn:SetNormalTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetPushedTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Yellow.png")

--Expansion table
local vanillaDropdownValues = {
    ["Darnassus Intro"] = 53183,
    ["Darnassus Walking 1"] = 53184,
    ["Druid Grove"] = 53187,
    ["Warrior Terrace"] = 53188,
    ["Gnomeregan 01"] = 53189,
    ["Gnomeregan 02"] = 53190,
    ["Ironforge Intro"] = 53191,
    ["Ironforge Walking 01"] = 53192,
    ["Tinkertown Intro Moment"] = 53196,
    ["Orgrimmar 01 Moment"] = 53197,
    ["Orgrimmar 01 Zone"] = 53198,
    ["Orgrimmar 02 Moment"] = 53199,
    ["Orgrimmar 02 Zone"] = 53200,
    ["Orgrimmar Intro Moment"] = 53201,
    ["Stormwind 01 Moment"] = 53202,
    ["Stormwind High Seas Moment"] = 53210,
    ["Stormwind Intro Moment"] = 53211,
    ["Thunder Bluff Intro"] = 53212,
    ["Thunder Bluff Walking 01"] = 53213,
    ["Undercity 01 Zone"] = 53216,
    ["Undercity Intro Moment"] = 53219,
    ["BC Main Theme"] = 53220,
    ["BCCredits Lament of the Highborne"] = 53221,
    ["WotLK Main Title"] = 53222,
    ["WoW Main Theme"] = 53223,
    ["Angelic 01"] = 53224,
    ["Battle 03"] = 53227,
    ["Enchanted Forest"] = 53453
}

--Expansion table
local tbcDropdownValues = {
    ["Assembly Chamber Walk 1"] = 53700,
    ["Assembly Chamber Walk 2"] = 53701,
    ["Fel Energy Walk"] = 53702,
    ["Isle of Dark Walk 1"] = 53703,
    ["Isle of Dark Walk 2"] = 53704,
    ["Isle of Dark Walk 3"] = 53705,
    ["Isle of Light Walk 1"] = 53706,
    ["Isle of Light Walk 2"] = 53707,
    ["Isle of Light Walk 3"] = 53708,
    ["Isle of Meditation Walk 1"] = 53709,
    ["Isle of Meditation Walk 2"] = 53710,
    ["Magister's Terrace Walk 3"] = 53718,
    ["Magister's Terrace Walk 4"] = 53719,
    ["Magister's Terrace Walk 5"] = 53720,
    ["Plateau Arrival Walk"] = 53721,
    ["Plateau Sunwell Walk 1"] = 53722,
    ["Plateau Sunwell Walk 2"] = 53723,
    ["Plateau Sunwell Walk 3"] = 53724,
    ["Plateau Sunwell Walk 4"] = 53725,
    ["Quel'Danas Walk 1"] = 53728,
    ["Quel'Danas Walk 2"] = 53729,
    ["Sanctum Walk"] = 53730,
    ["Shorel'aran Walk"] = 53731,
    ["Sunwell Bombing Run"] = 53732,
    ["Sunwell Flyby"] = 53733,
    ["The Sunwell's Well Walk 1"] = 53734,
    ["The Sunwell's Well Walk 2"] = 53735,
    ["The Sunwell's Well Walk 3"] = 53736,
}

--Expansion table
local wotlkDropdownValues = {
    ["Abomination Boss 1"] = 53591,
    ["Abomination Boss 2"] = 53592,
    ["Abomination Wing 1"] = 53593,
    ["Abomination Wing 2"] = 53594,
    ["Abomination Wing 3"] = 53595,
    ["Frost Wyrm 1"] = 53596,
    ["Frost Wyrm 2"] = 53597,
    ["Frost Wyrm 3"] = 53598,
    ["Frost Wyrm 4"] = 53599,
    ["Hub Base 1"] = 53600,
    ["Hub Base 2"] = 53601,
    ["Kel'Thuzad 1"] = 53602,
    ["Kel'Thuzad 2"] = 53603,
    ["Kel'Thuzad 3"] = 53604,
    ["Plague Boss 1"] = 53605,
    ["Plague Wing 1"] = 53606,
    ["Plague Wing 2"] = 53607,
    ["Plague Wing 3"] = 53608,
    ["Spider Boss 1"] = 53609,
    ["Spider Boss 2"] = 53610,
    ["Spider Wing 1"] = 53611,
    ["Spider Wing 2"] = 53612,
    ["Spider Wing 3"] = 53613,
    ["Walking 1"] = 53614,
    ["Walking 2"] = 53615,
    ["Walking 3"] = 53616,
    ["Walking 4"] = 53617,
    ["Walking 5"] = 53618,
    ["Walking 6"] = 53619,
    ["secret song"] = "secret song"
}


-- Create the scrolling parent frame and size it to fit inside the options panel
local scrollFrame = CreateFrame("ScrollFrame", nil, mountMusicSettingsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 3, -50)
scrollFrame:SetPoint("BOTTOMRIGHT", -50, 4)

-- Scrolling child frame, set its width to fit, and give it an arbitrary minimum height
local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(mmFrameWidth - 50)
scrollChild:SetHeight(mmFrameHeight / 3)


--Create Mount Music ui components for the options panel
local function createMountUiElements(id, yPos)
    local width = 45
    local height = 45
    local x = 10
    local creatureName, creatureID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected =
        C_MountJournal.GetDisplayedMountInfo(id)

    local frame = CreateFrame("Frame", "mountMusicUiElement" .. id, scrollChild,
        "ToolTipBorderedFrameTemplate")
    frame:SetPoint("CENTER", x, yPos)
    frame:SetWidth(600 - 80)
    frame:SetHeight(70)


    frame.Texture = frame:CreateTexture(nil, "ARTWORK")
    frame.Texture:SetSize(width, height)
    frame.Texture:SetPoint("LEFT", 20, 0)
    frame.Texture:SetTexture(icon)

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.Text:SetPoint("LEFT", 75, 0)
    frame.Text:SetWidth(200)
    frame.Text:SetWordWrap(true)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetText(creatureName)

    -- Optional: change font size
    local fontFile, _, flags = frame.Text:GetFont()
    frame.Text:SetFont(fontFile, 14, flags)


    local dropDown = CreateFrame("Frame", "mountMusicUiDropdown" .. id, frame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", 0, 0)
    dropDown:SetWidth(200)
    UIDropDownMenu_SetWidth(dropDown, 200)

    -- Set visible label font
    local textRegion = _G["mountMusicUiDropdown" .. id .. "Text"]
    if textRegion then
        textRegion:SetFont("Fonts\\FRIZQT__.TTF", 14)
    end

    if selectedMountMusicValues and selectedMountMusicValues[creatureID] then
        local selectedSongName = next(selectedMountMusicValues[creatureID])
        UIDropDownMenu_SetText(dropDown, selectedSongName)
    else
        UIDropDownMenu_SetText(dropDown, "Select a song")
    end


    local function handleDropdownSelect(self)
        local selectedText = self:GetText() -- Get the selected text from the button
        local selectedValue = self.value
        UIDropDownMenu_SetSelectedValue(dropDown, selectedValue)
        UIDropDownMenu_SetText(dropDown, selectedText)
        selectedMountMusicValues[creatureID] = { [selectedText] = selectedValue }
    end


    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local selectedSongName, selectedSongFileId = {}

        if selectedMountMusicValues[creatureID] then
            selectedSongName, selectedSongFileId = next(selectedMountMusicValues[creatureID])
        end

        if level == 1 then
            info.text, info.hasArrow, info.menuList = "Vanilla", true, "vanilla"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Tbc", true, "burningCrusade"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Wotlk", true, "wrath"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info)
        elseif menuList == "vanilla" then
            for key, value in pairs(vanillaDropdownValues) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                info.fontObject = GameFontNormal
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "burningCrusade" then
            for key, value in pairs(tbcDropdownValues) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                info.fontObject = GameFontNormal
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "wrath" then
            for key, value in pairs(wotlkDropdownValues) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                info.fontObject = GameFontNormal
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
end



-- Play music when mounted --
local function playMountMusic()
    if IsMounted() and alreadyMounted == false then
        for i = 1, numMounts do
            local creatureName, creatureID, icon, isSummoned, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected =
                C_MountJournal.GetDisplayedMountInfo(i)

            if isSummoned then
                SetCVar("Sound_MusicVolume", 0.5)
                SetCVar("Sound_AmbienceVolume", 0.1)
                SetCVar("Sound_SFXVolume", 0.3)
                if selectedMountMusicValues[creatureID] ~= nil then
                    local _, selectedSongFileId = next(selectedMountMusicValues[creatureID])
                    print(_)
                    if (_ == "secret song") then
                        PlayMusic("Interface/AddOns/MountMusic/audio-files/secret-song.mp3")
                        alreadyMounted = true
                    elseif selectedSongFileId then
                        PlayMusic(selectedSongFileId)
                        alreadyMounted = true
                    end
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
    local heading = CreateFrame("Frame", nil, mountMusicSettingsFrame)
    heading:SetSize(400, 60) -- Set a reasonable size for the heading
    heading:SetPoint("CENTER", 0, 0)

    heading.text = heading:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading.text:SetPoint("CENTER", 0, 0)
    heading.text:SetWidth(400)
    heading.text:SetJustifyH("CENTER")
    heading.text:SetJustifyV("TOP")
    heading.text:SetWordWrap(true)
    heading.text:SetText("Click generate mount data and then select songs you want played when riding specific mounts.")

    local f = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
    f:SetSize(180, 30)
    f:SetPoint("CENTER", 0, -50)
    f:SetText("Generate Mount Data")
    f:SetScript("OnClick", function()
        local firstLoadNumMounts = GetNumCompanions("Mount")
        numMounts = firstLoadNumMounts
        for i = 1, firstLoadNumMounts do
            createMountUiElements(i, mountUiYPos)
            mountUiYPos = mountUiYPos - 90
        end
        heading:Hide()
        f:Hide()
    end)
end



--Handle events
local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MountMusic" then
            print("MountMusic version 1.0.0 loaded. Enjoy!")
            print("Please go into the mount music options settings and generate mount data.")
            print("If you don't have any mounts this addon will not work.")
            print("Wow looks like you have over: " .. numMounts .. " " .. " mounts! ")
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
