--Initial options frame--
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent)

--Check for first time mounting up--
local alreadyMounted = false

--Initial position of mount ui element in the options panel --
local mountUiYPos = 230;

--Number of mounts --
local numMounts = GetNumCompanions("MOUNT")

--City Music
local musicTableStormwind = {
    ["stormwind 01 moment"] = 53202,
    ["stormwind 02 moment"] = 53202,
    ["stormwind 03 moment"] = 53202,
    ["stormwind 04 zone"] = 53202,
    ["stormwind 05 zone"] = 53202,
    ["stormwind 06 zone"] = 53202,
    ["stormwind 07 zone"] = 53208,
    ["stormwind 08 zone"] = 53209,
    ["stormwind highseas moment"] = 53210,
    ["stormwind intro moment"] = 53211

}

local musicTableOrgrimmar = {
    ["orgrimmar 01 moment"] = 53197,
    ["orgrimmar 01 zone"] = 53198,
    ["orgrimmar 02 moment"] = 53199,
    ["orgrimmar 02 zone"] = 53200,
    ["orgrimmar intro moment"] = 53201

}

local musicTableThunderbluff = {
    ["thunderbluff intro"] = 53212,
    ["thunderbluff walking 01"] = 53213,
    ["thunderbluff walking 02"] = 53214,
    ["thunderbluff walking 03"] = 53215

}

local musicTableUndercity = {
    ["undercity 01 zone"] = 53216,
    ["undercity 02 zone"] = 53217,
    ["undercity 03 zone"] = 53218,
    ["undercityintro moment"] = 53219

}

local musicTableDarnassus = {
    ["Darnassus Intro"] = 53183,
    ["Darnassus Walking 1"] = 53184,
    ["Darnassus Walking 2"] = 53185,
    ["Darnassus Walking 3"] = 53186,
    ["Druid Grove"] = 53187,
    ["Warrior Terrace"] = 53188
}

local musicTableIronforge = {
    ["Ironforge Intro"] = 53191,
    ["Ironforge Walking 01"] = 53192,
    ["Ironforge Walking 02"] = 53193,
    ["Ironforge Walking 03 (Glenn)"] = 53194,
    ["Ironforge Walking 04"] = 53195,
    ["Tinkertown Intro Moment"] = 53196
}

local musicTableSilvermoon = {
    ["Silvermoon Intro"] = 53473,
    ["Silvermoon Walk Day 01"] = 53474,
    ["Silvermoon Walk Day 02"] = 53475,
    ["Silvermoon Walk Day 03"] = 53476,
    ["Silvermoon Walk Night 01"] = 53477,
    ["Silvermoon Walk Night 02"] = 53478,
    ["Silvermoon Walk Night 03"] = 53479,
    ["Scene Silver Purpose"] = 4888067
}

local musicTableGnomeregan = {
    ["Gnomeregan 01 Zone"] = 53189,
    ["Gnomeregan 02 Zone"] = 53190
}

--Expansion themes --
local musicTableExpansionThemes = {
    ["bc main theme"] = 53220,
    ["bccredits lament of the highborne"] = 53221,
    ["wotlk main title"] = 53222,
    ["wow main theme"] = 53223
}


--Musical Moments --
local musicTableBattle = {
    ["angelic01"] = 53224,
    ["battle01"] = 53225,
    ["battle02"] = 53226,
    ["battle03"] = 53227,
    ["battle04"] = 53228,
    ["battle05"] = 53229,
    ["battle06"] = 53230,
}

local musicTableMagic = {
    ["gloomy01"] = 53231,
    ["gloomy02"] = 53232,
    ["guldansentrancetheme"] = 53233,
    ["haunted01"] = 53234,
    ["haunted02"] = 53235,
    ["magic01 moment"] = 53236,
    ["magic01 zone1"] = 53237,
    ["magic01 zone2"] = 53238,
}

local musicTableMystery = {
    ["mystery ahnqirajintro1"] = 53239,
    ["mystery01 zone"] = 53240,
    ["mystery02 zone"] = 53241,
    ["mystery03 zone"] = 53242,
    ["mystery04 zone"] = 53243,
    ["mystery05 zone"] = 53244,
    ["mystery06 zone"] = 53245,
    ["mystery07 zone"] = 53246,
    ["mystery08 zone"] = 53247,
    ["mystery09 zone"] = 53248,
    ["mystery10 zone"] = 53249,
}

local musicTableMisc = {
    ["sacred01"] = 53250,
    ["sacred02"] = 53251,
    ["spooky01 moment"] = 53252,
    ["swamp01"] = 53253,
    ["zulgurubvoodoo"] = 53254,
    ["alliancefirepole"] = 53255,
    ["darkmoonfaire 1"] = 53256,
    ["darkmoonfaire 2"] = 53257,
    ["darkmoonfaire 3"] = 53258,
    ["darkmoonfaire 4"] = 53259,
    ["hordefirepole"] = 53260,

}



-- Zone music --
local musicTableZoneVanilla = {
    ["Bloodmyst Isle Nagaintro 01"] = 53360,
    ["Bloodmyst Isle Satyr Walk Uni 01"] = 53362,
    ["Caverns of Time Brazens Flight Intro Uni"] = 53379,
    ["Day Forest 01"] = 53492,
    ["Day Forest 02"] = 53493,
    ["Day Forest 03"] = 53494,
    ["Night Forest 01"] = 53495,
    ["Night Forest 02"] = 53496,
    ["Night Forest 03"] = 53497,
    ["Night Forest 04"] = 53498,
    ["Day Desert 01"] = 53432,
    ["Day Desert 02"] = 53433,
    ["Day Desert 03"] = 53434,
    ["Night Desert 01"] = 53435,
    ["Night Desert 02"] = 53436,
    ["Night Desert 03"] = 53437
}

local musicTableZoneTbc = {
    ["Blades Edge Dry Forest Walk"] = 53350,
    ["Blades Edge Ogre Walk"] = 53358,
    ["Hellfire Peninsula Ogre Walk 01"] = 53520,
    ["Hellfire Peninsula Ogre Walk 02"] = 53521,
    ["Outland General Blood Elf Base Walk Uni 01"] = 53642,
    ["Terokkar Forest Auchindoun Walk Uni 01"] = 53796,
    ["Terokkar Forest Bone Walk Uni 02"] = 53800,
    ["Terokkar Forest Forest Walk Uni 01"] = 53803,
    ["Terokkar Forest Forest Walk Uni 02"] = 53804,
    ["Terokkar Forest Forest Walk Uni 03"] = 53805,
    ["Terokkar Forest Shattrath Walk Uni 01"] = 53806,
    ["Terokkar Forest Shattrath Walk Uni 02"] = 53807,
    ["Terokkar Forest Shattrath Walk Uni 03"] = 53808,
}

local musicTableZoneWrath = {
    ["Borean Tundra General Walk Day 01"] = 53367,
    ["Borean Tundra General Walk Day 02"] = 53368,
    ["Borean Tundra General Walk Day 03"] = 53369,
    ["Borean Tundra Tusk Kaskala Night 02"] = 53378,
    ["Dragonblight General Walk Night 01"] = 53443,
    ["Dragonblight General Walk Night 02"] = 53444,
    ["Grizzly Hills General Walk B Night 01"] = 165492,
    ["Grizzly Hills General Walk B Night 02"] = 165493,
    ["Howling Fjord Tusk Kamagua Day 01"] = 53537,
    ["Howling Fjord Tusk Kamagua Day 02"] = 53538,
}


--Raids --
-- Music table for Karazhan
local musicTableKarazhan = {
    ["Backstage Walk Uni 01"] = 53547,
    ["Backstage Walk Uni 02"] = 53548,
    ["Foyer Intro Uni 01"] = 53549,
    ["Foyer Walk Uni 01"] = 53550,
    ["Foyer Walk Uni 02"] = 53551,
    ["Foyer Walk Uni 03"] = 53552,
    ["Foyer Walk Uni 04"] = 53553,
    ["General Walk Uni 01"] = 53554,
    ["General Walk Uni 02"] = 53555,
    ["Library Walk Uni 04"] = 53564,
    ["Malchezar Walk Uni 01"] = 53565,
    ["Malchezar Walk Uni 02"] = 53566,
    ["Malchezar Walk Uni 03"] = 53567,
    ["Opera Harpsi Walk Uni 01"] = 53568,
    ["Opera Organ Walk Uni 01"] = 53569,
    ["Stable Intro Uni 01"] = 53570,
    ["Stable Walk Uni 01"] = 53571,
    ["Stable Walk Uni 02"] = 53572,
    ["Stable Walk Uni 03"] = 53573,
    ["Tower Walk Uni 01"] = 53574,
    ["Tower Walk Uni 02"] = 53575,
    ["Tower Walk Uni 03"] = 53576,
}

-- Music table for Naxxramas
local musicTableNaxxramas = {
    ["Abomination Boss 1"] = 53591,
    ["Abomination Boss 2"] = 53592,
    ["Abomination Wing 1"] = 53593,
    ["Abomination Wing 2"] = 53594,
    ["Abomination Wing 3"] = 53595,
    ["Frostwyrm 1"] = 53596,
    ["Frostwyrm 2"] = 53597,
    ["Frostwyrm 3"] = 53598,
    ["Frostwyrm 4"] = 53599,
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
    ["Walking 6"] = 53619
}

-- Music table for Ahn'Qiraj
local musicTableAhnQiraj = {
    ["Ahn'Qiraj Intro 1"] = 53261,
    ["Ahn'Qiraj Exterior Walking 1"] = 53262,
    ["Ahn'Qiraj Exterior Walking 2"] = 53263,
    ["Ahn'Qiraj Exterior Walking 3"] = 53264,
    ["Ahn'Qiraj Exterior Walking 4"] = 53265,
    ["Ahn'Qiraj Interior 1"] = 53266,
    ["Ahn'Qiraj Interior 2"] = 53267,
    ["Ahn'Qiraj Interior 3"] = 53268,
    ["Ahn'Qiraj Interior Center Room 1"] = 53269,
    ["Ahn'Qiraj Interior Intro Main"] = 53270,
    ["Ahn'Qiraj King Room"] = 53271,
    ["Ahn'Qiraj Triangle Room 1"] = 53272,
    ["Ahn'Qiraj Triangle Room 2"] = 53273,
    ["Ahn'Qiraj Triangle Room 3"] = 53274,
    ["Ahn'Qiraj Triangle Room 4"] = 53275,
    ["Ahn'Qiraj Triangle Room 5"] = 53276,
    ["Ahn'Qiraj Triangle Room 6"] = 53277
}

-- Music table for Tempest Keep
local musicTableTempestKeep = {
    ["Tempest Keep Amb 11"] = 53779,
    ["Tempest Keep Amb 12"] = 53780,
    ["Tempest Keep Amb 13"] = 53781,
    ["Tempest Keep Amb 14"] = 53782,
    ["Tempest Keep Amb 16"] = 53783,
    ["Tempest Keep Amb 17"] = 53784,
    ["Tempest Keep Amb 18"] = 53785,
    ["Tempest Keep Amb 19"] = 53786,
    ["Tempest Keep Amb 20"] = 53787,
    ["Tempest Keep Amb 22"] = 53788,
    ["Tempest Keep Amb 23"] = 53789,
    ["Tempest Keep Btl 10"] = 53790,
    ["Tempest Keep Btl 11"] = 53791,
    ["Tempest Keep Btl 13"] = 53792,
    ["Tempest Keep Stg 14"] = 53793,
    ["Tempest Keep Stg 15"] = 53794
}

-- Music table for Black Temple
local musicTableBlackTemple = {
    ["Arrival Walk Hero 01"] = 53305,
    ["Arrival Walk Uni 02"] = 53306,
    ["Arrival Walk Uni 03"] = 53307,
    ["Arrival Walk Uni 04"] = 53308,
    ["Illidari Walk Hero 09"] = 53309,
    ["Illidari Walk Uni 01"] = 53310,
    ["Illidari Walk Uni 02"] = 53311,
    ["Illidari Walk Uni 11"] = 53319,
    ["Karabor Walk Uni 01"] = 53320,
    ["Karabor Walk Uni 02"] = 53321,
    ["Karabor Walk Uni 03"] = 53322,
    ["Karabor Walk Uni 04"] = 53323,
    ["Prelude Event 01"] = 53324,
    ["Reliquary Walk Hero 01"] = 53325,
    ["Reliquary Walk Uni 02"] = 53326,
    ["Reliquary Walk Uni 03"] = 53327,
    ["Reliquary Walk Uni 04"] = 53328,
    ["Sanctuary Walk Uni 08"] = 53340,
    ["Storm Walk Hero 02"] = 53341,
    ["Storm Walk Uni 01"] = 53342,
    ["Storm Walk Uni 03"] = 53343,
    ["Storm Walk Uni 04"] = 53344,
    ["Summit Walk Uni 01"] = 53345,
    ["Summit Walk Uni 02"] = 53346
}

-- Music table for Sunwell
local musicTableSunwell = {
    ["Assembly Chamber Walk Uni 01"] = 53700,
    ["Assembly Chamber Walk Uni 02"] = 53701,
    ["Fel Energy Walk Uni 01"] = 53702,
    ["Isle Dark Walk Uni 01"] = 53703,
    ["Isle Dark Walk Uni 02"] = 53704,
    ["Isle Dark Walk Uni 03"] = 53705,
    ["Isle Light Walk Uni 01"] = 53706,
    ["Isle Light Walk Uni 02"] = 53707,
    ["Isle Light Walk Uni 03"] = 53708,
    ["Isle Med Walk Uni 01"] = 53709,
    ["Isle Med Walk Uni 02"] = 53710,
    ["Isle Med Walk Uni 03"] = 53711,
    ["Magisters Arrival Walk Uni 01"] = 53712,
    ["Magisters Asylum Walk Uni 01"] = 53713,
    ["Magisters Asylum Walk Uni 02"] = 53714,
    ["Magisters Asylum Walk Uni 03"] = 53715,
    ["Magisters Terrace Walk Uni 01"] = 53716,
    ["Magisters Terrace Walk Uni 02"] = 53717,
    ["Magisters Terrace Walk Uni 03"] = 53718,
    ["Magisters Terrace Walk Uni 04"] = 53719,
    ["Magisters Terrace Walk Uni 05"] = 53720,
    ["Plateau Sunwell Arrival Walk Uni 01"] = 53721,
    ["Plateau Sunwell Walk Uni 01"] = 53722,
    ["Plateau Sunwell Walk Uni 02"] = 53723,
    ["Plateau Sunwell Walk Uni 03"] = 53724,
    ["Plateau Sunwell Walk Uni 04"] = 53725,
    ["Plateau Sunwell Walk Uni 05"] = 53726
}


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
    local creatureName, creatureID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetDisplayedMountInfo(id)

    local frame = CreateFrame("Frame", "mountMusicUiElement" .. id, scrollChild,
        "ToolTipBorderedFrameTemplate")
    frame:SetPoint("LEFT", x, yPos)
    frame:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 80)
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
    frame.Text:SetText(creatureName)


    local dropDown = CreateFrame("Frame", "mountMusicUiDropdown" .. id, frame,
        "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", 0, 0)
    dropDown:SetWidth(200)
    UIDropDownMenu_SetWidth(dropDown, 200)

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
            info.text, info.hasArrow, info.menuList = "City Music", true, "cityMusic"
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Expansion Themes", true, "expansionThemes"
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Musical Moments", true, "musicMoments"
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Zone Music", true, "zoneMusic"
            UIDropDownMenu_AddButton(info)
            info.text, info.hasArrow, info.menuList = "Raids", true, "raids"
            UIDropDownMenu_AddButton(info)
        end

        --Second Level --
        if menuList == "cityMusic" then
            info.text, info.hasArrow, info.menuList = "Stormwind", true, "stormwind"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Orgrimmar", true, "orgrimmar"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Thunderbluff", true, "thunderbluff"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Darnassus", true, "darnassus"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Ironforge", true, "ironforge"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Silvermoon", true, "silvermoon"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Gnomeragan", true, "gnomeregan"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "expansionThemes" then
            for key, value in pairs(musicTableExpansionThemes) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "musicMoments" then
            info.text, info.hasArrow, info.menuList = "Battle", true, "battle"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Magic", true, "magic"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Mystery", true, "mystery"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Misc", true, "misc"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "zoneMusic" then
            info.text, info.hasArrow, info.menuList = "Vanilla", true, "vanilla"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Burning Crusade", true, "burningCrusade"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Lich King", true, "lichKing"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "raids" then
            info.text, info.hasArrow, info.menuList = "Karazhan", true, "karazhan"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Naxxramas", true, "naxxramas"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Ahn Quiraj", true, "ahnQuiraj"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Tempest Keep", true, "tempestKeep"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Black Temple", true, "blackTemple"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.hasArrow, info.menuList = "Sunwell", true, "sunwell"
            UIDropDownMenu_AddButton(info, level)
        end

        --City Level --
        if menuList == "stormwind" then
            for key, value in pairs(musicTableStormwind) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "orgrimmar" then
            for key, value in pairs(musicTableOrgrimmar) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "thunderbluff" then
            for key, value in pairs(musicTableThunderbluff) do
                info.text = tostring(key)
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
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "darnassus" then
            for key, value in pairs(musicTableDarnassus) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ironforge" then
            for key, value in pairs(musicTableIronforge) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "silvermoon" then
            for key, value in pairs(musicTableSilvermoon) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "gnomeregan" then
            for key, value in pairs(musicTableGnomeregan) do
                info.text = tostring(key)
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
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "magic" then
            for key, value in pairs(musicTableMagic) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "mystery" then
            for key, value in pairs(musicTableMystery) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "misc" then
            for key, value in pairs(musicTableMisc) do
                info.text = tostring(key)
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
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "burningCrusade" then
            for key, value in pairs(musicTableZoneTbc) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "lichKing" then
            for key, value in pairs(musicTableZoneWrath) do
                info.text = tostring(key)
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
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "naxxramas" then
            for key, value in pairs(musicTableNaxxramas) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ahnQuiraj" then
            for key, value in pairs(musicTableAhnQiraj) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "tempestKeep" then
            for key, value in pairs(musicTableTempestKeep) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "blackTemple" then
            for key, value in pairs(musicTableBlackTemple) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "sunwell" then
            for key, value in pairs(musicTableSunwell) do
                info.text = tostring(key)
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
            local creatureName, creatureID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetDisplayedMountInfo(i)

            if active then
                SetCVar("Sound_MusicVolume", 0.5)
                SetCVar("Sound_AmbienceVolume", 0.1)
                SetCVar("Sound_SFXVolume", 0.3)
                if selectedMountMusicValues[creatureID] ~= nil then
                    local _, selectedSongFileId = next(selectedMountMusicValues[creatureID])
                    if selectedSongFileId then
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
            print("\124cff00ccffMountMusic version 1.1.0 loaded. Enjoy!\124r")
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
