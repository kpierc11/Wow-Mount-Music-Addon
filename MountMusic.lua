-- Initial options frame
--Check for first time mounting up--
local alreadyMounted          = false

--Initial position of mount ui element in the options panel --
local mountUiYPos             = 230;

--Number of mounts --
local numMounts               = GetNumCompanions("MOUNT")

--Create Mount Music ui components for the options panel
local function createMountUiElements(id, yPos, formName, formIcon, mountData)
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

    local mountIconButton = CreateFrame("Button", nil, frame)

    mountIconButton:SetSize(width, height)
    mountIconButton:SetPoint("LEFT", 20, 0)
    if not formName then
        if not mountData or mountData.isCollected then
            mountIconButton:SetScript("OnClick", function()
                CastSpellByName(creatureName)
            end)
        else
            mountIconButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Mount not acquired yet", 1, 0.82, 0)
                GameTooltip:Show()
            end)
            mountIconButton:SetScript("OnLeave", GameTooltip_Hide)
        end
    end

    mountIconButton.Texture = frame:CreateTexture("mount music top icon",
        "ARTWORK")
    mountIconButton.Texture:SetWidth(width)
    mountIconButton.Texture:SetHeight(height)
    mountIconButton.Texture:SetPoint("LEFT", 20, 0)
    mountIconButton.Texture:SetTexture(icon)
    if mountData and not mountData.isCollected then
        mountIconButton.Texture:SetDesaturated(true)
        mountIconButton.Texture:SetVertexColor(0.45, 0.45, 0.45)
    end

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.Text:SetPoint("LEFT", 75, 0)
    frame.Text:SetWidth(200)
    frame.Text:SetWordWrap(true)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetText(creatureName)
    if mountData and not mountData.isCollected then
        frame.Text:SetTextColor(0.55, 0.55, 0.55)
    end


    local dropDown = CreateFrame("Frame", "mountMusicUiDropdown" .. nextUiRowId, frame,
        "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", 0, 0)
    dropDown:SetWidth(200)
    UIDropDownMenu_SetWidth(dropDown, 200)

    -- Set visible label font
    local textRegion = _G["mountMusicUiDropdown" .. nextUiRowId .. "Text"]
    if textRegion then
        textRegion:SetFont("Fonts\\FRIZQT__.TTF", 14)
    end

    if musicValues and musicValues[creatureID] then
        local selectedSongName, selectedSongFileId = next(musicValues[creatureID])
        UIDropDownMenu_SetText(dropDown, selectedSongName)
    else
        UIDropDownMenu_SetText(dropDown, "Select a song")
    end
    if mountData and not mountData.isCollected then
        UIDropDownMenu_DisableDropDown(dropDown)
    end


    local function handleDropdownSelect(self)
        local selectedText = self:GetText() -- Get the selected text from the button
        local selectedValue = self.value
        UIDropDownMenu_SetSelectedValue(dropDown, selectedValue)
        UIDropDownMenu_SetText(dropDown, selectedText)
        musicValues[creatureID] = { [selectedText] = selectedValue }
        if formName and druidFormSaveButton then
            druidFormSaveButton:SetText("Save")
        end
    end


    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local selectedSongName, selectedSongFileId = {}

        if musicValues[creatureID] then
            selectedSongName, selectedSongFileId = next(musicValues[creatureID])
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

    return frame
end



local druidFormDefinitions = {
    { name = "Bear Form", spellID = 5487, fallbackIcon = "Interface\\Icons\\Ability_Racial_BearForm" },
    { name = "Dire Bear Form", spellID = 9634, fallbackIcon = "Interface\\Icons\\Ability_Racial_BearForm" },
    { name = "Cat Form", spellID = 768, fallbackIcon = "Interface\\Icons\\Ability_Druid_CatForm" },
    { name = "Travel Form", spellID = 783, fallbackIcon = "Interface\\Icons\\Ability_Druid_TravelForm" },
    { name = "Aquatic Form", spellID = 1066, fallbackIcon = "Interface\\Icons\\Ability_Druid_AquaticForm" },
    { name = "Moonkin Form", spellID = 24858, fallbackIcon = "Interface\\Icons\\Spell_Nature_ForceOfNature" },
}

local druidFormNamesBySpellID = {}
for _, form in ipairs(druidFormDefinitions) do
    druidFormNamesBySpellID[form.spellID] = form.name
end

local playDruidFormMusic

local function getMountJournalEntries()
    local entries = {}
    if C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountInfoByID then
        for _, mountID in ipairs(C_MountJournal.GetMountIDs() or {}) do
            local name, spellID, icon, _, _, _, _, _, _, hideOnChar, isCollected =
                C_MountJournal.GetMountInfoByID(mountID)
            if name and not hideOnChar then
                table.insert(entries, {
                    mountID = mountID,
                    name = name,
                    spellID = spellID,
                    icon = icon,
                    isCollected = isCollected,
                })
            end
        end
    else
        for mountIndex = 1, numMounts do
            local name, spellID, icon = C_MountJournal.GetDisplayedMountInfo(mountIndex)
            if name then
                table.insert(entries, {
                    mountID = spellID,
                    name = name,
                    spellID = spellID,
                    icon = icon,
                    isCollected = true,
                })
            end
        end
    end
    table.sort(entries, function(left, right)
        return left.name < right.name
    end)
    return entries
end

local function getDruidFormIcon(form)
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(form.spellID) or form.fallbackIcon
    end
    if GetSpellTexture then
        return GetSpellTexture(form.spellID) or form.fallbackIcon
    end
    if GetSpellInfo then
        local _, _, icon = GetSpellInfo(form.spellID)
        return icon or form.fallbackIcon
    end
    return form.fallbackIcon
end

local function createDruidFormUiElements(yPos)
    local _, classToken = UnitClass("player")
    if classToken ~= "DRUID" then
        return yPos
    end

    local heading = CreateFrame("Frame", nil, scrollChild)
    table.insert(settingsContentFrames, heading)
    heading:SetSize(400, 40)
    heading:SetPoint("TOP", 0, -yPos)
    heading.text = heading:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading.text:SetPoint("CENTER")
    heading.text:SetText("Druid Forms")

    yPos = yPos + 50
    for formIndex, form in ipairs(druidFormDefinitions) do
        createMountUiElements("form" .. formIndex, yPos, form.name, getDruidFormIcon(form))
        yPos = yPos + 90
    end

    return yPos + 20
end

local function buildSettingsRows()
    for _, frame in ipairs(settingsContentFrames) do
        frame:Hide()
    end
    wipe(settingsContentFrames)

    mountEntries = getMountJournalEntries()
    local yPos = mountUiYPos
    for _, mountData in ipairs(mountEntries) do
        createMountUiElements(mountData.mountID, yPos, nil, nil, mountData)
        yPos = yPos + 90
    end
    yPos = createDruidFormUiElements(yPos)

    scrollChild:SetHeight(math.max(mmFrameHeight / 3, yPos + 24))
end


-- Play music when mounted --
local currentlyPlayingDruidFormMusic = false
local currentlyPlayingDruidFormKey
local currentlyPlayingDruidSongFileId
local formMusicFadePending = false
local formMusicFadeToken = 0

local function cancelFormMusicFade()
    formMusicFadeToken = formMusicFadeToken + 1
    formMusicFadePending = false
end

local function clearDruidFormMusicState()
    currentlyPlayingDruidFormMusic = false
    currentlyPlayingDruidFormKey = nil
    currentlyPlayingDruidSongFileId = nil
end

local function playMountMusic()
    if IsMounted() and alreadyMounted == false then
        cancelFormMusicFade()
        if currentlyPlayingDruidFormMusic then
            StopMusic()
            clearDruidFormMusicState()
        end
        local function startAssignedMountMusic(creatureID)
            if selectedMountMusicValues[creatureID] then
                SetCVar("Sound_MusicVolume", 0.5)
                SetCVar("Sound_AmbienceVolume", 0.1)
                SetCVar("Sound_SFXVolume", 0.3)
                local songName, selectedSongFileId = next(selectedMountMusicValues[creatureID])
                if songName == "secret song" then
                    StopMusic()
                    PlayMusic("Interface/AddOns/MountMusic/audio-files/secret-song.mp3")
                    alreadyMounted = true
                elseif selectedSongFileId then
                    StopMusic()
                    PlayMusic(selectedSongFileId)
                    alreadyMounted = true
                end
            end
        end

        if C_MountJournal and C_MountJournal.GetMountInfoByID then
            for _, mountData in ipairs(mountEntries) do
                local _, creatureID, _, isActive = C_MountJournal.GetMountInfoByID(mountData.mountID)
                if isActive then
                    startAssignedMountMusic(creatureID)
                    break
                end
            end
        else
            for i = 1, numMounts do
                local _, creatureID, _, isSummoned = C_MountJournal.GetDisplayedMountInfo(i)
                if isSummoned then
                    startAssignedMountMusic(creatureID)
                end
            end
        end
    elseif IsMounted() == false and alreadyMounted then
        if not currentlyPlayingDruidFormMusic then
            StopMusic()
        end
        alreadyMounted = false
    end
end


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
            if selectedDruidFormMusicValues == nil then
                _G.selectedDruidFormMusicValues = {}
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
            playDruidFormMusic()
        end
    end
    if event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_ENTERING_WORLD" then
        playDruidFormMusic()
    end
    if event == "PLAYER_STARTED_SWIMMING" or event == "PLAYER_STOPPED_SWIMMING" then
        playDruidFormMusic()
    end
end

--Register events and scripts --
mountMusicSettingsFrame:RegisterEvent("ADDON_LOADED")
mountMusicSettingsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mountMusicSettingsFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
mountMusicSettingsFrame:RegisterEvent("PLAYER_STARTED_SWIMMING")
mountMusicSettingsFrame:RegisterEvent("PLAYER_STOPPED_SWIMMING")
mountMusicSettingsFrame:RegisterUnitEvent("UNIT_AURA", "player")
mountMusicSettingsFrame:SetScript("OnEvent", onEvent)
