-- Initial options frame
--Check for first time mounting up--
local alreadyMounted          = false

--Initial position of mount ui element in the options panel --
local mountUiYPos             = 230;

--Number of mounts --
local numMounts               = GetNumCompanions("MOUNT")

--Create Mount Music ui components for the options panel
local function createMountUiElements(id, yPos)
    local width = 45
    local height = 45
    local x = 10
    local creatureName, creatureID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected =
        C_MountJournal.GetDisplayedMountInfo(id)

    local frame = CreateFrame("Frame", nil, mountMusicSettingsFrame, "ToolTipBorderedFrameTemplate")
    frame:SetPoint("CENTER", x, yPos)
    frame:SetWidth(600 - 80)
    frame:SetHeight(70)

    local mountIconButton = CreateFrame("Button", nil, frame)

    mountIconButton:SetSize(width, height)
    mountIconButton:SetPoint("LEFT", 20, 0)
    mountIconButton:SetScript("OnClick", function()
        CastSpellByName(creatureName)
    end)

    mountIconButton.Texture = frame:CreateTexture("mount music top icon",
        "ARTWORK")
    mountIconButton.Texture:SetWidth(width)
    mountIconButton.Texture:SetHeight(height)
    mountIconButton.Texture:SetPoint("LEFT", 20, 0)
    mountIconButton.Texture:SetTexture(icon)

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.Text:SetPoint("LEFT", 75, 0)
    frame.Text:SetWidth(200)
    frame.Text:SetWordWrap(true)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetText(creatureName)


    local dropDown = CreateFrame("Frame", "mountMusicUiDropdown" .. id, frame,
        "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", 0, 0)
    dropDown:SetWidth(200)
    UIDropDownMenu_SetWidth(dropDown, 200)

    -- Set visible label font
    local textRegion = _G["mountMusicUiDropdown" .. id .. "Text"]
    if textRegion then
        textRegion:SetFont("Fonts\\FRIZQT__.TTF", 14)
    end

    if selectedMountMusicValues and selectedMountMusicValues[creatureID] then
        local selectedSongName, selectedSongFileId = next(selectedMountMusicValues[creatureID])
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

        -- Top Level --
        if level == 1 then
            info.text = "No Music"
            info.value = "noMusic"
            info.checked = selectedSongName == "noMusic"
            info.fontObject = GameFontNormal
            info.func = handleDropdownSelect
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "City Music", true, "cityMusic"
            info.fontObject = GameFontNormal
            info.checked = false
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Expansion Themes", true, "expansionThemes"
            info.fontObject = GameFontNormal
            info.checked = false
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Musical Moments", true, "musicMoments"
            info.fontObject = GameFontNormal
            info.checked = false
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Zone Music", true, "zoneMusic"
            info.fontObject = GameFontNormal
            info.checked = false
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Raids", true, "raids"
            info.fontObject = GameFontNormal
            info.checked = false
            UIDropDownMenu_AddButton(info)
        end

        --Second Level --
        if menuList == "cityMusic" then
            info.text, info.hasArrow, info.menuList = "Stormwind", true, "stormwind"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Orgrimmar", true, "orgrimmar"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Thunderbluff", true, "thunderbluff"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Darnassus", true, "darnassus"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Ironforge", true, "ironforge"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Silvermoon", true, "silvermoon"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Gnomeragan", true, "gnomeregan"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "expansionThemes" then
            for key, value in pairs(musicTableExpansionThemes) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "musicMoments" then
            info.text, info.hasArrow, info.menuList = "Battle", true, "battle"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Magic", true, "magic"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Mystery", true, "mystery"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Misc", true, "misc"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "zoneMusic" then
            info.text, info.hasArrow, info.menuList = "Vanilla", true, "vanilla"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Burning Crusade", true, "burningCrusade"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Lich King", true, "lichKing"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "raids" then
            info.text, info.hasArrow, info.menuList = "Karazhan", true, "karazhan"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Naxxramas", true, "naxxramas"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Ahn Quiraj", true, "ahnQuiraj"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Tempest Keep", true, "tempestKeep"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Black Temple", true, "blackTemple"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Sunwell", true, "sunwell"
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
        end

        --City Level --
        if menuList == "stormwind" then
            for key, value in pairs(musicTableStormwind) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "orgrimmar" then
            for key, value in pairs(musicTableOrgrimmar) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "thunderbluff" then
            for key, value in pairs(musicTableThunderbluff) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "undercity" then
            for key, value in pairs(musicTableUndercity) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.fontObject = GameFontNormal
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "darnassus" then
            for key, value in pairs(musicTableDarnassus) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ironforge" then
            for key, value in pairs(musicTableIronforge) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "silvermoon" then
            for key, value in pairs(musicTableSilvermoon) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "gnomeregan" then
            for key, value in pairs(musicTableGnomeregan) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        end

        --Magical Moments --
        if menuList == "battle" then
            for key, value in pairs(musicTableBattle) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "magic" then
            for key, value in pairs(musicTableMagic) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "mystery" then
            for key, value in pairs(musicTableMystery) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "misc" then
            for key, value in pairs(musicTableMisc) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        end



        --Zone Music --
        if menuList == "vanilla" then
            for key, value in pairs(musicTableZoneVanilla) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "burningCrusade" then
            for key, value in pairs(musicTableZoneTbc) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "lichKing" then
            for key, value in pairs(musicTableZoneWrath) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        end


        --Raids --
        if menuList == "karazhan" then
            for key, value in pairs(musicTableKarazhan) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "naxxramas" then
            for key, value in pairs(musicTableNaxxramas) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ahnQuiraj" then
            for key, value in pairs(musicTableAhnQiraj) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "tempestKeep" then
            for key, value in pairs(musicTableTempestKeep) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "blackTemple" then
            for key, value in pairs(musicTableBlackTemple) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "sunwell" then
            for key, value in pairs(musicTableSunwell) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
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
-- if (numMounts ~= 0 and selectedMountMusicValues ~= nil) then
--     for i = 1, numMounts do
--         createMountUiElements(i, mountUiYPos)
--         mountUiYPos = mountUiYPos - 90
--     end
-- else
--     local heading = CreateFrame("Frame", nil, mountMusicSettingsFrame)
--     heading:SetSize(400, 60) -- Set a reasonable size for the heading
--     heading:SetPoint("CENTER", 0, 0)

--     heading.text = heading:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
--     heading.text:SetPoint("CENTER", 0, 0)
--     heading.text:SetWidth(400)
--     heading.text:SetJustifyH("CENTER")
--     heading.text:SetJustifyV("TOP")
--     heading.text:SetWordWrap(true)
--     heading.text:SetText("Click generate mount data and then select songs you want played when riding specific mounts.")

--     local f = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
--     f:SetSize(180, 30)
--     f:SetPoint("CENTER", 0, -50)
--     f:SetText("Generate Mount Data")
--     f:SetScript("OnClick", function()
--         local firstLoadNumMounts = GetNumCompanions("Mount")
--         numMounts = firstLoadNumMounts
--         for i = 1, firstLoadNumMounts do
--             createMountUiElements(i, mountUiYPos)
--             mountUiYPos = mountUiYPos - 90
--         end
--         heading:Hide()
--         f:Hide()
--     end)
-- end

local function showMountUI()
    for i = 1, numMounts do
        createMountUiElements(i, mountUiYPos)
        mountUiYPos = mountUiYPos - 90
    end
end

--Handle events
local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MountMusic" then
            print("MountMusic version 1.0.0 loaded. Enjoy!")
            print("Please go into the mount music options settings and generate mount data.")
            print("If you don't have any mounts this addon will not work.")
            if selectedMountMusicValues == nil then
                _G.selectedMountMusicValues = {}
            end
        end
        for i = 1, numMounts do
            createMountUiElements(i, mountUiYPos)
            mountUiYPos = mountUiYPos - 90
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
