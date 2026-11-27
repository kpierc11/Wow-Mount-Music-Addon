-- Initial options frame
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")
local mmFrameWidth            = 600
local mmFrameHeight           = 500

--Set Title of the Mount Music setting frame
local title                   = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 12, -4)
title:SetJustifyH("LEFT")
title:SetText("Mount Music Settings")
local file, _, flags = title:GetFont()
title:SetFont(file, 14, flags)


mountMusicSettingsFrame:SetPoint("CENTER")
mountMusicSettingsFrame:SetSize(mmFrameWidth, mmFrameHeight)
mountMusicSettingsFrame:Hide()

-- Make frame movable
mountMusicSettingsFrame:SetMovable(true)
mountMusicSettingsFrame:EnableMouse(true)
mountMusicSettingsFrame:RegisterForDrag("LeftButton")
mountMusicSettingsFrame:SetScript("OnDragStart", mountMusicSettingsFrame.StartMoving)
mountMusicSettingsFrame:SetScript("OnDragStop", mountMusicSettingsFrame.StopMovingOrSizing)


-- Ensure saved variable exists
MountMusicDB = MountMusicDB or {}
selectedMountMusicValues = selectedMountMusicValues or {}
selectedDruidFormMusicValues = selectedDruidFormMusicValues or {}
local function copyMusicSelections(source)
    local copy = {}
    for key, selection in pairs(source) do
        if type(selection) == "table" then
            local songName, fileID = next(selection)
            if songName then
                copy[key] = { [songName] = fileID }
            end
        end
    end
    return copy
end
local function replaceMusicSelections(destination, source)
    wipe(destination)
    for key, selection in pairs(source) do
        local songName, fileID = next(selection)
        if songName then
            destination[key] = { [songName] = fileID }
        end
    end
end
local selectedMountMusicDraft = copyMusicSelections(
    type(MountMusicDB.pendingMountMusicDraft) == "table"
        and MountMusicDB.pendingMountMusicDraft
        or selectedMountMusicValues
)
local selectedDruidFormMusicDraft = copyMusicSelections(
    type(MountMusicDB.pendingDruidFormMusicDraft) == "table"
        and MountMusicDB.pendingDruidFormMusicDraft
        or selectedDruidFormMusicValues
)
local function saveDraftMusicSelections()
    replaceMusicSelections(selectedMountMusicValues, selectedMountMusicDraft)
    replaceMusicSelections(selectedDruidFormMusicValues, selectedDruidFormMusicDraft)
    MountMusicDB.pendingMountMusicDraft = nil
    MountMusicDB.pendingDruidFormMusicDraft = nil
end
local saveButton
local settingsContentFrames = {}
local mountEntries = {}
local druidFormContentHeight = 0
local settingsRowsBuilt = false
local nextUiRowId = 0
local updateMusicPlayback
local stopMusicNow
local toggleMusicStop
local toggleAutoPlay
local playRandomMusic
local playPreviousMusic
local skipMusic
local playAutoplayTrack
local refreshMusicPlayer
local refreshScreenAutoPlayButton
local musicLibraryDropdown
local currentMusicKey
local currentMusicFileID
local currentMusicTrackName
local currentMusicStartedAt
local currentActiveTargetName
local manualPlaybackOverride = false
local manualPlaybackTargetKey
local pausedTargetKey
local settingsOpenToken = 0

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
        tooltip:AddLine("Click to open Mount Music settings.", 1, 1, 1)
    end,
}

-- Register it with LibDBIcon directly
LDBIcon:Register("MountMusic", button, MountMusicDB.minimap)


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

local allMusicTracks = {}
local seenMusicFileIDs = {}
local musicTrackByFileID = {}
local musicTrackIndexByFileID = {}
for _, musicTable in ipairs({
    musicTableStormwind,
    musicTableOrgrimmar,
    musicTableThunderbluff,
    musicTableUndercity,
    musicTableDarnassus,
    musicTableIronforge,
    musicTableSilvermoon,
    musicTableGnomeregan,
    musicTableExpansionThemes,
    musicTableBattle,
    musicTableMagic,
    musicTableMystery,
    musicTableMisc,
    musicTableZoneVanilla,
    musicTableZoneTbc,
    musicTableZoneWrath,
    musicTableKarazhan,
    musicTableNaxxramas,
    musicTableAhnQiraj,
    musicTableTempestKeep,
    musicTableBlackTemple,
    musicTableSunwell,
}) do
    for songName, fileID in pairs(musicTable) do
        if not seenMusicFileIDs[fileID] then
            seenMusicFileIDs[fileID] = true
            local track = { name = songName, fileID = fileID }
            table.insert(allMusicTracks, track)
            musicTrackByFileID[fileID] = track
        end
    end
end
table.sort(allMusicTracks, function(left, right)
    local leftLower, rightLower = string.lower(left.name), string.lower(right.name)
    if leftLower == rightLower then
        return left.name < right.name
    end
    return leftLower < rightLower
end)
for index, track in ipairs(allMusicTracks) do
    musicTrackIndexByFileID[track.fileID] = index
end

local function getRandomMusicTrack(excludedFileID)
    if #allMusicTracks == 0 then
        return nil
    end
    local candidates = {}
    for _, track in ipairs(allMusicTracks) do
        if track.fileID ~= excludedFileID then
            table.insert(candidates, track)
        end
    end
    if #candidates == 0 then
        candidates = allMusicTracks
    end
    return candidates[math.random(#candidates)]
end

local function getRandomUnassignedMusicTrack()
    local selectedFileIDs = {}
    for _, musicValues in ipairs({
        selectedMountMusicValues,
        selectedDruidFormMusicValues,
        selectedMountMusicDraft,
        selectedDruidFormMusicDraft,
    }) do
        for _, selection in pairs(musicValues) do
            local _, fileID = next(selection)
            if fileID and fileID ~= "noMusic" then
                selectedFileIDs[fileID] = true
            end
        end
    end

    local candidates = {}
    for _, track in ipairs(allMusicTracks) do
        if not selectedFileIDs[track.fileID] then
            table.insert(candidates, track)
        end
    end
    if #candidates == 0 then
        return nil
    end
    return candidates[math.random(#candidates)]
end


local mountTabButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
mountTabButton:SetSize(110, 26)
mountTabButton:SetPoint("TOPLEFT", 12, -42)
mountTabButton:SetText("Mounts")
mountTabButton:Hide()

local druidTabButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
druidTabButton:SetSize(110, 26)
druidTabButton:SetPoint("LEFT", mountTabButton, "RIGHT", 4, 0)
druidTabButton:SetText("Druid Forms")
druidTabButton:Hide()

local mountScrollFrame = CreateFrame("ScrollFrame", nil, mountMusicSettingsFrame, "UIPanelScrollFrameTemplate")
mountScrollFrame:SetPoint("TOPLEFT", 12, -75)
mountScrollFrame:SetPoint("BOTTOMRIGHT", -35, 161)
mountScrollFrame:Hide()

local mountScrollChild = CreateFrame("Frame")
mountScrollChild:SetWidth(mmFrameWidth - 80)
mountScrollFrame:SetScrollChild(mountScrollChild)

local druidScrollFrame = CreateFrame("ScrollFrame", nil, mountMusicSettingsFrame, "UIPanelScrollFrameTemplate")
druidScrollFrame:SetPoint("TOPLEFT", 12, -75)
druidScrollFrame:SetPoint("BOTTOMRIGHT", -35, 161)
druidScrollFrame:Hide()

local druidScrollChild = CreateFrame("Frame")
druidScrollChild:SetWidth(mmFrameWidth - 80)
druidScrollFrame:SetScrollChild(druidScrollChild)

local function selectSettingsTab(tab)
    if tab == "druid" then
        local _, classToken = UnitClass("player")
        if classToken ~= "DRUID" then
            return
        end
    end

    mountTabButton:SetEnabled(tab ~= "mounts")
    druidTabButton:SetEnabled(tab ~= "druid")
    if settingsRowsBuilt then
        if tab == "mounts" then
            mountScrollFrame:Show()
            druidScrollFrame:Hide()
        else
            mountScrollFrame:Hide()
            druidScrollFrame:Show()
        end
    end
end

mountTabButton:SetScript("OnClick", function()
    selectSettingsTab("mounts")
end)
druidTabButton:SetScript("OnClick", function()
    selectSettingsTab("druid")
end)

saveButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
saveButton:SetSize(84, 26)
saveButton:SetPoint("BOTTOMRIGHT", -120, 14)
saveButton:SetText("Save")
saveButton:SetEnabled(false)
saveButton:SetScript("OnClick", function()
    saveDraftMusicSelections()
    manualPlaybackOverride = false
    manualPlaybackTargetKey = nil
    saveButton:SetText("Saved")
    saveButton:SetEnabled(false)
    if updateMusicPlayback then
        updateMusicPlayback()
    end
end)
if type(MountMusicDB.pendingMountMusicDraft) == "table"
    or type(MountMusicDB.pendingDruidFormMusicDraft) == "table" then
    saveButton:SetEnabled(true)
end

local closeButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
closeButton:SetSize(100, 26)
closeButton:SetPoint("BOTTOMRIGHT", -12, 14)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    mountMusicSettingsFrame:Hide()
end)

local musicLibraryDropdownName = "mountMusicPlayerTrackDropdown"
musicLibraryDropdown = CreateFrame("Frame", musicLibraryDropdownName, mountMusicSettingsFrame, "UIDropDownMenuTemplate")
musicLibraryDropdown:SetPoint("BOTTOMLEFT", mountMusicSettingsFrame, "BOTTOMLEFT", -5, 110)
musicLibraryDropdown:SetWidth(180)
UIDropDownMenu_SetWidth(musicLibraryDropdown, 180)
musicLibraryDropdown:SetFrameLevel(mountMusicSettingsFrame:GetFrameLevel() + 20)
UIDropDownMenu_SetText(musicLibraryDropdown, "Select a track")
local musicLibraryText = _G[musicLibraryDropdownName .. "Text"]
if musicLibraryText then
    musicLibraryText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    musicLibraryText:SetTextColor(1, 0.82, 0)
end

local playerTrackText = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerTrackText:SetPoint("TOPLEFT", musicLibraryText, "BOTTOMLEFT", 0, -12)
playerTrackText:SetWidth(390)
playerTrackText:SetJustifyH("LEFT")
playerTrackText:SetText("...")

local playerStatusText = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
playerStatusText:SetPoint("TOPLEFT", playerTrackText, "BOTTOMLEFT", 0, -2)
playerStatusText:SetWidth(240)
playerStatusText:SetJustifyH("LEFT")
playerStatusText:SetText("No Music Playing")

local screenTrackButton
local refreshScreenTrackButton
local screenTrackFrame = CreateFrame("Frame", "MountMusicScreenTrackFrame", UIParent, "TooltipBorderedFrameTemplate")
screenTrackFrame:SetSize(200, 72)
screenTrackFrame:SetFrameStrata("DIALOG")
screenTrackFrame:SetClampedToScreen(true)
screenTrackFrame:SetMovable(true)
screenTrackFrame:EnableMouse(true)
screenTrackFrame:RegisterForDrag("LeftButton")
screenTrackFrame:SetPoint(
    MountMusicDB.screenTrackPoint or "CENTER",
    UIParent,
    MountMusicDB.screenTrackRelativePoint or MountMusicDB.screenTrackPoint or "CENTER",
    MountMusicDB.screenTrackX or 0,
    MountMusicDB.screenTrackY or 120
)
screenTrackFrame:SetScript("OnDragStart", screenTrackFrame.StartMoving)
screenTrackFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint(1)
    MountMusicDB.screenTrackPoint = point
    MountMusicDB.screenTrackRelativePoint = relativePoint
    MountMusicDB.screenTrackX = x
    MountMusicDB.screenTrackY = y
end)

local screenTrackCloseButton = CreateFrame("Button", nil, screenTrackFrame, "UIPanelCloseButton")
screenTrackCloseButton:SetSize(18, 18)
screenTrackCloseButton:SetPoint("TOPRIGHT", -1, -1)
screenTrackCloseButton:SetScript("OnClick", function()
    MountMusicDB.screenTrackVisible = false
    screenTrackFrame:Hide()
    if refreshScreenTrackButton then
        refreshScreenTrackButton()
    end
end)

local screenTrackNameText = screenTrackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
screenTrackNameText:SetPoint("TOPLEFT", 8, -8)
screenTrackNameText:SetWidth(165)
screenTrackNameText:SetFontObject(GameFontNormalSmall)
screenTrackNameText:SetJustifyH("LEFT")
screenTrackNameText:SetWordWrap(false)
screenTrackNameText:SetText("No Music Playing")

local screenTrackStatusText = screenTrackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
screenTrackStatusText:SetPoint("TOPLEFT", screenTrackNameText, "BOTTOMLEFT", 0, -2)
screenTrackStatusText:SetWidth(165)
screenTrackStatusText:SetJustifyH("LEFT")
screenTrackStatusText:SetWordWrap(false)
screenTrackStatusText:SetText("No Music Playing")

local screenPreviousButton = CreateFrame("Button", nil, screenTrackFrame)
screenPreviousButton:SetSize(22, 22)
screenPreviousButton:SetPoint("BOTTOMLEFT", 10, 5)
screenPreviousButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
screenPreviousButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
screenPreviousButton:SetScript("OnClick", function()
    playPreviousMusic()
end)

local screenStopButton = CreateFrame("Button", nil, screenTrackFrame)
screenStopButton:SetSize(26, 26)
screenStopButton:SetPoint("LEFT", screenPreviousButton, "RIGHT", 5, 0)
local screenStopIcon = screenStopButton:CreateTexture(nil, "ARTWORK")
screenStopIcon:SetSize(10, 10)
screenStopIcon:SetPoint("CENTER")
screenStopIcon:SetTexture("Interface\\Buttons\\WHITE8X8")
screenStopIcon:SetVertexColor(1, 1, 1, 1)
local screenPlayIconLeft = screenStopButton:CreateTexture(nil, "ARTWORK")
screenPlayIconLeft:SetSize(3, 10)
screenPlayIconLeft:SetPoint("CENTER", -3, 0)
screenPlayIconLeft:SetTexture("Interface\\Buttons\\WHITE8X8")
screenPlayIconLeft:SetVertexColor(1, 1, 1, 1)
local screenPlayIconRight = screenStopButton:CreateTexture(nil, "ARTWORK")
screenPlayIconRight:SetSize(3, 10)
screenPlayIconRight:SetPoint("CENTER", 3, 0)
screenPlayIconRight:SetTexture("Interface\\Buttons\\WHITE8X8")
screenPlayIconRight:SetVertexColor(1, 1, 1, 1)
screenStopButton:SetScript("OnClick", function()
    toggleMusicStop()
end)

local screenSkipButton = CreateFrame("Button", nil, screenTrackFrame)
screenSkipButton:SetSize(22, 22)
screenSkipButton:SetPoint("LEFT", screenStopButton, "RIGHT", 5, 0)
screenSkipButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
screenSkipButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
screenSkipButton:SetScript("OnClick", function()
    skipMusic()
end)
local screenAutoPlayButton = CreateFrame("Button", nil, screenTrackFrame, "UIPanelButtonTemplate")
screenAutoPlayButton:SetSize(100, 24)
screenAutoPlayButton:SetPoint("BOTTOMRIGHT", -8, 5)
refreshScreenAutoPlayButton = function()
    screenAutoPlayButton:SetText(MountMusicDB.autoPlayEnabled and "Auto Play: On" or "Auto Play: Off")
end
refreshScreenAutoPlayButton()
screenAutoPlayButton:SetScript("OnClick", function()
    toggleAutoPlay()
end)

if MountMusicDB.screenTrackVisible then
    screenTrackFrame:Show()
else
    screenTrackFrame:Hide()
end

local function setControlTooltip(button, text)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
end

setControlTooltip(screenPreviousButton, "Play Previous Song")
setControlTooltip(screenSkipButton, "Play Random Track")
setControlTooltip(screenStopButton, "Stop Music")

local previousButton = CreateFrame("Button", nil, mountMusicSettingsFrame)
previousButton:SetSize(26, 26)
previousButton:SetPoint("BOTTOMLEFT", 12, 14)
previousButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
previousButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
previousButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
setControlTooltip(previousButton, "Play Previous Song")
previousButton:SetScript("OnClick", function()
    playPreviousMusic()
end)

local stopButton = CreateFrame("Button", nil, mountMusicSettingsFrame)
stopButton:SetSize(30, 26)
stopButton:SetPoint("LEFT", previousButton, "RIGHT", 6, 0)
local stopIcon = stopButton:CreateTexture(nil, "ARTWORK")
stopIcon:SetSize(12, 12)
stopIcon:SetPoint("CENTER")
stopIcon:SetTexture("Interface\\Buttons\\WHITE8X8")
stopIcon:SetVertexColor(1, 1, 1, 1)
local playIconLeft = stopButton:CreateTexture(nil, "ARTWORK")
playIconLeft:SetSize(3, 12)
playIconLeft:SetPoint("CENTER", -3, 0)
playIconLeft:SetTexture("Interface\\Buttons\\WHITE8X8")
playIconLeft:SetVertexColor(1, 1, 1, 1)
local playIconRight = stopButton:CreateTexture(nil, "ARTWORK")
playIconRight:SetSize(3, 12)
playIconRight:SetPoint("CENTER", 3, 0)
playIconRight:SetTexture("Interface\\Buttons\\WHITE8X8")
playIconRight:SetVertexColor(1, 1, 1, 1)

local function setPlaybackButtonVisual(isStopped)
    if isStopped then
        playIconLeft:Show()
        playIconRight:Show()
        stopIcon:Hide()
        screenPlayIconLeft:Show()
        screenPlayIconRight:Show()
        screenStopIcon:Hide()
        setControlTooltip(stopButton, "Play Music")
        setControlTooltip(screenStopButton, "Play Music")
    else
        playIconLeft:Hide()
        playIconRight:Hide()
        stopIcon:Show()
        screenPlayIconLeft:Hide()
        screenPlayIconRight:Hide()
        screenStopIcon:Show()
        setControlTooltip(stopButton, "Stop Music")
        setControlTooltip(screenStopButton, "Stop Music")
    end
end

setPlaybackButtonVisual(
    MountMusicDB.musicStoppedByAddon == true or GetCVar("Sound_EnableMusic") == "0"
)
stopButton:SetScript("OnClick", function()
    toggleMusicStop()
end)

local skipButton = CreateFrame("Button", nil, mountMusicSettingsFrame)
skipButton:SetSize(26, 26)
skipButton:SetPoint("LEFT", stopButton, "RIGHT", 6, 0)
skipButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
skipButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
skipButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
setControlTooltip(skipButton, "Play Random Track")
skipButton:SetScript("OnClick", function()
    skipMusic()
end)

local autoPlayButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
autoPlayButton:SetSize(112, 26)
autoPlayButton:SetPoint("LEFT", skipButton, "RIGHT", 8, 0)
local function refreshAutoPlayButton()
    autoPlayButton:SetText(MountMusicDB.autoPlayEnabled and "Auto Play: On" or "Auto Play: Off")
end
refreshAutoPlayButton()
autoPlayButton:SetScript("OnClick", function()
    toggleAutoPlay()
end)

screenTrackButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
screenTrackButton:SetSize(128, 26)
screenTrackButton:SetPoint("LEFT", autoPlayButton, "RIGHT", 8, 0)
refreshScreenTrackButton = function()
    screenTrackButton:SetText(MountMusicDB.screenTrackVisible and "Remove" or "Add to Screen")
end
refreshScreenTrackButton()
screenTrackButton:SetScript("OnClick", function()
    MountMusicDB.screenTrackVisible = not MountMusicDB.screenTrackVisible
    refreshScreenTrackButton()
    if MountMusicDB.screenTrackVisible then
        screenTrackFrame:Show()
    else
        screenTrackFrame:Hide()
    end
end)


local function sortedMusicPairs(musicTable)
    local names = {}
    for name in pairs(musicTable) do
        table.insert(names, name)
    end
    table.sort(names, function(left, right)
        local leftLower, rightLower = string.lower(left), string.lower(right)
        if leftLower == rightLower then
            return left < right
        end
        return leftLower < rightLower
    end)

    local index = 0
    return function()
        index = index + 1
        local name = names[index]
        if name then
            return name, musicTable[name]
        end
    end
end

--Create Mount Music ui components for the options panel
local function createMountUiElements(container, yPos, formName, formIcon, mountData)
    local x = 10
    local creatureName, creatureID, icon, isCollected
    if formName then
        creatureName, creatureID, icon = formName, formName, formIcon
    elseif mountData then
        creatureName, creatureID, icon, isCollected = mountData.name, mountData.spellID, mountData.icon,
            mountData.isCollected
    end
    if not creatureName or not creatureID then
        return
    end

    local frame = CreateFrame("Frame", nil, container, "ToolTipBorderedFrameTemplate")
    frame:SetPoint("TOPLEFT", x, -yPos)
    frame:SetWidth(container:GetWidth() - (x * 2))
    frame:SetHeight(44)
    table.insert(settingsContentFrames, frame)

    local mountIconButton = CreateFrame("Button", nil, frame)

    mountIconButton:SetSize(44, 44)
    mountIconButton:SetPoint("LEFT", 14, 0)
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

    mountIconButton.Texture = mountIconButton:CreateTexture(nil, "ARTWORK")
    mountIconButton.Texture:SetPoint("TOPLEFT", 5, -5)
    mountIconButton.Texture:SetPoint("BOTTOMRIGHT", -5, 5)
    mountIconButton.Texture:SetTexture(icon)
    if mountData and not mountData.isCollected then
        mountIconButton.Texture:SetDesaturated(true)
        mountIconButton.Texture:SetVertexColor(0.45, 0.45, 0.45)
    end

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.Text:SetPoint("LEFT", 60, 0)
    frame.Text:SetWidth(frame:GetWidth() - 255)
    frame.Text:SetWordWrap(true)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetText(creatureName)
    if mountData and not mountData.isCollected then
        frame.Text:SetTextColor(0.55, 0.55, 0.55)
    end


    nextUiRowId = nextUiRowId + 1
    local dropDownName = "mountMusicUiDropdown" .. nextUiRowId
    local dropDown = CreateFrame("Frame", dropDownName, frame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("RIGHT", -8, 0)
    dropDown:SetWidth(180)
    UIDropDownMenu_SetWidth(dropDown, 180)

    -- Set visible label font
    local textRegion = _G[dropDownName .. "Text"]
    if textRegion then
        textRegion:SetFont("Fonts\\FRIZQT__.TTF", 14)
        textRegion:SetTextColor(1, 0.82, 0)
    end

    local musicValues = formName and selectedDruidFormMusicDraft or selectedMountMusicDraft
    if musicValues[creatureID] then
        local selectedSongName, selectedSongFileID = next(musicValues[creatureID])
        UIDropDownMenu_SetSelectedValue(dropDown, selectedSongFileID)
        UIDropDownMenu_SetText(dropDown, selectedSongName)
    else
        UIDropDownMenu_SetText(dropDown, "Select a song")
    end
    local function setDraftSelection(songName, fileID)
        UIDropDownMenu_SetSelectedValue(dropDown, fileID)
        UIDropDownMenu_SetText(dropDown, songName)
        musicValues[creatureID] = { [songName] = fileID }
        MountMusicDB.pendingMountMusicDraft = copyMusicSelections(selectedMountMusicDraft)
        MountMusicDB.pendingDruidFormMusicDraft = copyMusicSelections(selectedDruidFormMusicDraft)
        saveButton:SetText("Save")
        saveButton:SetEnabled(true)
    end

    local function handleDropdownSelect(self)
        setDraftSelection(self:GetText(), self.value)
    end

    if mountData and not mountData.isCollected then
        UIDropDownMenu_DisableDropDown(dropDown)
    end

    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local selectedSongName, selectedSongFileId

        if musicValues[creatureID] then
            selectedSongName, selectedSongFileId = next(musicValues[creatureID])
        end

        -- Top Level --
        if level == 1 then
            local rootItems = {
                {
                    text = "Assign Random",
                    value = "assignRandom",
                    func = function()
                        local track = getRandomMusicTrack()
                        if not track then
                            print("MountMusic: No music tracks are available.")
                            return
                        end
                        setDraftSelection(track.name, track.fileID)
                    end,
                },
                { text = "City Music", menuList = "cityMusic" },
                { text = "Expansion Themes", menuList = "expansionThemes" },
                { text = "Musical Moments", menuList = "musicMoments" },
                {
                    text = "No Music",
                    value = "noMusic",
                    checked = selectedSongFileId == "noMusic",
                    func = handleDropdownSelect,
                },
                { text = "Raids", menuList = "raids" },
                { text = "Zone Music", menuList = "zoneMusic" },
            }
            table.sort(rootItems, function(left, right)
                return string.lower(left.text) < string.lower(right.text)
            end)
            for _, item in ipairs(rootItems) do
                info.text = item.text
                info.value = item.value
                info.hasArrow = item.menuList and true or nil
                info.menuList = item.menuList
                info.checked = item.checked or false
                info.func = item.func
                info.fontObject = GameFontNormal
                UIDropDownMenu_AddButton(info, level)
            end
        end

        --Second Level --
        if menuList == "cityMusic" then
            info.value = nil
            info.func = nil
            info.hasArrow = true
            info.fontObject = GameFontNormal
            info.text, info.menuList = "Darnassus", "darnassus"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Gnomeregan", "gnomeregan"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Ironforge", "ironforge"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Orgrimmar", "orgrimmar"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Silvermoon", "silvermoon"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Stormwind", "stormwind"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Thunderbluff", "thunderbluff"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "expansionThemes" then
            for key, value in sortedMusicPairs(musicTableExpansionThemes) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "musicMoments" then
            info.value = nil
            info.func = nil
            info.checked = false
            info.hasArrow = true
            info.fontObject = GameFontNormal
            info.text, info.menuList = "Battle", "battle"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Magic", "magic"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Misc", "misc"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Mystery", "mystery"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "zoneMusic" then
            info.value = nil
            info.func = nil
            info.checked = false
            info.hasArrow = true
            info.fontObject = GameFontNormal
            info.text, info.menuList = "Burning Crusade", "burningCrusade"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Lich King", "lichKing"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Vanilla", "vanilla"
            UIDropDownMenu_AddButton(info, level)
        elseif menuList == "raids" then
            info.value = nil
            info.func = nil
            info.checked = false
            info.hasArrow = true
            info.fontObject = GameFontNormal
            info.text, info.menuList = "Ahn Quiraj", "ahnQuiraj"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Black Temple", "blackTemple"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Karazhan", "karazhan"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Naxxramas", "naxxramas"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Sunwell", "sunwell"
            UIDropDownMenu_AddButton(info, level)
            info.text, info.menuList = "Tempest Keep", "tempestKeep"
            UIDropDownMenu_AddButton(info, level)
        end

        --City Level --
        if menuList == "stormwind" then
            for key, value in sortedMusicPairs(musicTableStormwind) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "orgrimmar" then
            for key, value in sortedMusicPairs(musicTableOrgrimmar) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "thunderbluff" then
            for key, value in sortedMusicPairs(musicTableThunderbluff) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "undercity" then
            for key, value in sortedMusicPairs(musicTableUndercity) do
                info.text = tostring(key)
                info.value = value
                info.checked = selectedSongName == key
                info.fontObject = GameFontNormal
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "darnassus" then
            for key, value in sortedMusicPairs(musicTableDarnassus) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ironforge" then
            for key, value in sortedMusicPairs(musicTableIronforge) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "silvermoon" then
            for key, value in sortedMusicPairs(musicTableSilvermoon) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "gnomeregan" then
            for key, value in sortedMusicPairs(musicTableGnomeregan) do
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
            for key, value in sortedMusicPairs(musicTableBattle) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "magic" then
            for key, value in sortedMusicPairs(musicTableMagic) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "mystery" then
            for key, value in sortedMusicPairs(musicTableMystery) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "misc" then
            for key, value in sortedMusicPairs(musicTableMisc) do
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
            for key, value in sortedMusicPairs(musicTableZoneVanilla) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "burningCrusade" then
            for key, value in sortedMusicPairs(musicTableZoneTbc) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "lichKing" then
            for key, value in sortedMusicPairs(musicTableZoneWrath) do
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
            for key, value in sortedMusicPairs(musicTableKarazhan) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "naxxramas" then
            for key, value in sortedMusicPairs(musicTableNaxxramas) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "ahnQuiraj" then
            for key, value in sortedMusicPairs(musicTableAhnQiraj) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "tempestKeep" then
            for key, value in sortedMusicPairs(musicTableTempestKeep) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "blackTemple" then
            for key, value in sortedMusicPairs(musicTableBlackTemple) do
                info.text = tostring(key)
                info.fontObject = GameFontNormal
                info.value = value
                info.checked = selectedSongName == key
                info.func = handleDropdownSelect
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == "sunwell" then
            for key, value in sortedMusicPairs(musicTableSunwell) do
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
local druidFormNamesByAuraName = {}
for _, form in ipairs(druidFormDefinitions) do
    druidFormNamesBySpellID[form.spellID] = form.name
    druidFormNamesByAuraName[string.lower(form.name)] = form.name
    local spellName
    if C_Spell and C_Spell.GetSpellName then
        spellName = C_Spell.GetSpellName(form.spellID)
    end
    if not spellName and GetSpellInfo then
        spellName = GetSpellInfo(form.spellID)
    end
    if spellName then
        druidFormNamesByAuraName[string.lower(spellName)] = form.name
    end
end
druidFormNamesByAuraName["flight form"] = "Travel Form"
druidFormNamesByAuraName["swift flight form"] = "Travel Form"

local druidFormNamesByFormID = {
    -- GetShapeshiftFormID returns form IDs, which differ from the spell IDs above.
    [1] = "Cat Form",
    [3] = "Travel Form",
    [4] = "Aquatic Form",
    [5] = "Bear Form",
    [8] = "Dire Bear Form",
    [27] = "Travel Form",
    [29] = "Travel Form",
    [31] = "Moonkin Form",
    [35] = "Moonkin Form",
}

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

local function createDruidFormUiElements()
    local _, classToken = UnitClass("player")
    if classToken ~= "DRUID" then
        return 0
    end

    local yPos = 0
    for _, form in ipairs(druidFormDefinitions) do
        createMountUiElements(druidScrollChild, yPos, form.name, getDruidFormIcon(form))
        yPos = yPos + 44
    end

    return yPos
end

local function buildSettingsRows()
    for _, frame in ipairs(settingsContentFrames) do
        frame:Hide()
    end
    wipe(settingsContentFrames)

    mountEntries = getMountJournalEntries()
    mountScrollFrame:SetVerticalScroll(0)
    druidScrollFrame:SetVerticalScroll(0)
    local yPos = 0
    for _, mountData in ipairs(mountEntries) do
        createMountUiElements(mountScrollChild, yPos, nil, nil, mountData)
        yPos = yPos + 44
    end
    mountScrollChild:SetHeight(math.max(mountScrollFrame:GetHeight(), yPos))

    local _, classToken = UnitClass("player")
    if classToken == "DRUID" then
        druidFormContentHeight = createDruidFormUiElements()
        druidScrollChild:SetHeight(math.max(druidScrollFrame:GetHeight(), druidFormContentHeight))
        druidTabButton:Show()
    else
        druidFormContentHeight = 0
        druidTabButton:Hide()
    end

    mountTabButton:Show()
    settingsRowsBuilt = true
    selectSettingsTab("mounts")
end


-- Track and manage the selected mount/form music.
local manualPlaySequence = 0
local playbackHistory = {}
local playbackHistoryPosition = 0
local navigatingPlaybackHistory = false
local formTransitionToken = 0
local formTransitionPending = false

local function getDruidFormNameForSpellID(spellID)
    if not spellID then
        return nil
    end
    local formName = druidFormNamesBySpellID[spellID]
    if formName then
        return formName
    end

    local spellName
    if C_Spell and C_Spell.GetSpellName then
        spellName = C_Spell.GetSpellName(spellID)
    end
    if not spellName and GetSpellInfo then
        spellName = GetSpellInfo(spellID)
    end
    if spellName then
        for _, form in ipairs(druidFormDefinitions) do
            if form.name == spellName then
                return form.name
            end
        end
    end
end

local function getDruidFormNameForAura(auraName, spellID)
    local formName = getDruidFormNameForSpellID(spellID)
    if formName then
        return formName
    end
    if not auraName then
        return nil
    end
    return druidFormNamesByAuraName[string.lower(auraName)]
end

local function getCurrentDruidFormName()
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for auraIndex = 1, 255 do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", auraIndex, "HELPFUL")
            if not aura then
                break
            end
            local formName = getDruidFormNameForAura(aura.name, aura.spellId)
            if formName then
                return formName
            end
        end
    elseif UnitAura then
        for auraIndex = 1, 40 do
            local auraName, _, _, _, _, _, _, _, _, spellID = UnitAura("player", auraIndex, "HELPFUL")
            local formName = getDruidFormNameForAura(auraName, spellID)
            if formName then
                return formName
            end
        end
    end

    if GetShapeshiftFormID then
        local formName = druidFormNamesByFormID[GetShapeshiftFormID()]
        if formName then
            return formName
        end
    end

    if GetShapeshiftFormInfo then
        local function getNameForActiveForm(formIndex)
            local _, isActive, _, spellID = GetShapeshiftFormInfo(formIndex)
            if isActive then
                return getDruidFormNameForSpellID(spellID)
            end
        end

        if GetShapeshiftForm then
            local formIndex = GetShapeshiftForm()
            if formIndex and formIndex > 0 then
                local formName = getNameForActiveForm(formIndex)
                if formName then
                    return formName
                end
            end
        end

        if GetNumShapeshiftForms then
            for formIndex = 1, GetNumShapeshiftForms() do
                local formName = getNameForActiveForm(formIndex)
                if formName then
                    return formName
                end
            end
        end
    end

    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for _, form in ipairs(druidFormDefinitions) do
            if C_UnitAuras.GetPlayerAuraBySpellID(form.spellID) then
                return form.name
            end
        end
    end
end

local function getActiveMusicTarget()
    local formName = getCurrentDruidFormName()
    if formName then
        return "form:" .. formName, selectedDruidFormMusicValues[formName], "form", formName
    end

    if #mountEntries == 0 then
        mountEntries = getMountJournalEntries()
    end
    if C_MountJournal and C_MountJournal.GetMountInfoByID then
        for _, mountData in ipairs(mountEntries) do
            local _, creatureID, _, isActive = C_MountJournal.GetMountInfoByID(mountData.mountID)
            if isActive then
                return "mount:" .. tostring(creatureID), selectedMountMusicValues[creatureID], "mount", mountData.name
            end
        end
    end
end

refreshMusicPlayer = function()
    if currentMusicFileID then
        playerTrackText:SetText(currentMusicTrackName or "Now Playing")
        if musicLibraryDropdown and musicTrackByFileID[currentMusicFileID] then
            MountMusicDB.playerLibraryTrackFileID = currentMusicFileID
            UIDropDownMenu_SetSelectedValue(musicLibraryDropdown, currentMusicFileID)
            UIDropDownMenu_SetText(musicLibraryDropdown, currentMusicTrackName or "Select a track")
        end
    else
        playerTrackText:SetText("...")
    end

    local playbackState
    if MountMusicDB.musicStoppedByAddon or GetCVar("Sound_EnableMusic") == "0" then
        playbackState = "Stopped"
    elseif currentMusicFileID and (not IsMusicPlaying or IsMusicPlaying()) then
        playbackState = "Playing"
    else
        playbackState = "No Music Playing"
    end
    playerStatusText:SetText(
        playbackState .. (currentActiveTargetName and " - " .. currentActiveTargetName or "")
    )
    local screenTrackName = currentMusicTrackName or "No Music Playing"
    if #screenTrackName > 24 then
        screenTrackName = screenTrackName:sub(1, 21) .. "..."
    end
    screenTrackNameText:SetText(screenTrackName)
    screenTrackStatusText:SetText(playbackState)
end

local function recordMusicHistory(fileID)
    if navigatingPlaybackHistory or not musicTrackIndexByFileID[fileID] then
        return
    end
    if playbackHistory[playbackHistoryPosition] == fileID then
        return
    end

    while #playbackHistory > playbackHistoryPosition do
        table.remove(playbackHistory)
    end
    table.insert(playbackHistory, fileID)
    playbackHistoryPosition = #playbackHistory
end

local function stopCurrentMusic(forceStop)
    local musicIsPlaying = forceStop or currentMusicFileID ~= nil
    if IsMusicPlaying and IsMusicPlaying() then
        musicIsPlaying = true
    end
    if musicIsPlaying then
        StopMusic()
    end
    currentMusicKey = nil
    currentMusicFileID = nil
    currentMusicTrackName = nil
    currentMusicStartedAt = nil
    refreshMusicPlayer()
end

local function startMusicTrack(fileID, trackKey, trackName)
    if not fileID or fileID == "noMusic" then
        return false
    end
    if GetCVar("Sound_EnableMusic") ~= "1" then
        SetCVar("Sound_EnableMusic", "1")
    end
    MountMusicDB.musicStoppedByAddon = nil
    MountMusicDB.musicStopRestoreValue = nil
    pausedTargetKey = nil
    setPlaybackButtonVisual(false)
    if trackKey == currentMusicKey
        and fileID == currentMusicFileID
        and (not IsMusicPlaying or IsMusicPlaying()) then
        return true
    end

    stopCurrentMusic()
    PlayMusic(fileID)
    currentMusicKey = trackKey
    currentMusicFileID = fileID
    currentMusicStartedAt = GetTime()
    currentMusicTrackName = trackName or (musicTrackByFileID[fileID] and musicTrackByFileID[fileID].name)
        or tostring(fileID)
    recordMusicHistory(fileID)
    refreshMusicPlayer()
    return true
end

local playerMenuCategories = {
    cityMusic = {
        { text = "Darnassus", menuList = "darnassus" },
        { text = "Gnomeregan", menuList = "gnomeregan" },
        { text = "Ironforge", menuList = "ironforge" },
        { text = "Orgrimmar", menuList = "orgrimmar" },
        { text = "Silvermoon", menuList = "silvermoon" },
        { text = "Stormwind", menuList = "stormwind" },
        { text = "Thunderbluff", menuList = "thunderbluff" },
    },
    musicMoments = {
        { text = "Battle", menuList = "battle" },
        { text = "Magic", menuList = "magic" },
        { text = "Misc", menuList = "misc" },
        { text = "Mystery", menuList = "mystery" },
    },
    raids = {
        { text = "Ahn Quiraj", menuList = "ahnQuiraj" },
        { text = "Black Temple", menuList = "blackTemple" },
        { text = "Karazhan", menuList = "karazhan" },
        { text = "Naxxramas", menuList = "naxxramas" },
        { text = "Sunwell", menuList = "sunwell" },
        { text = "Tempest Keep", menuList = "tempestKeep" },
    },
    zoneMusic = {
        { text = "Burning Crusade", menuList = "burningCrusade" },
        { text = "Lich King", menuList = "lichKing" },
        { text = "Vanilla", menuList = "vanilla" },
    },
}

local playerMusicTablesByMenuList = {
    ahnQuiraj = musicTableAhnQiraj,
    battle = musicTableBattle,
    blackTemple = musicTableBlackTemple,
    burningCrusade = musicTableZoneTbc,
    darnassus = musicTableDarnassus,
    expansionThemes = musicTableExpansionThemes,
    gnomeregan = musicTableGnomeregan,
    ironforge = musicTableIronforge,
    karazhan = musicTableKarazhan,
    lichKing = musicTableZoneWrath,
    magic = musicTableMagic,
    misc = musicTableMisc,
    mystery = musicTableMystery,
    naxxramas = musicTableNaxxramas,
    orgrimmar = musicTableOrgrimmar,
    silvermoon = musicTableSilvermoon,
    stormwind = musicTableStormwind,
    sunwell = musicTableSunwell,
    tempestKeep = musicTableTempestKeep,
    thunderbluff = musicTableThunderbluff,
    vanilla = musicTableZoneVanilla,
}

local function playPlayerDropdownTrack(button)
    manualPlaySequence = manualPlaySequence + 1
    if startMusicTrack(button.value, "manual:library:" .. manualPlaySequence, button:GetText()) then
        MountMusicDB.playerLibraryTrackFileID = button.value
        manualPlaybackOverride = true
        manualPlaybackTargetKey = getActiveMusicTarget()
        UIDropDownMenu_SetSelectedValue(musicLibraryDropdown, button.value)
        UIDropDownMenu_SetText(musicLibraryDropdown, button:GetText())
    end
end

local function addPlayerDropdownTracks(musicTable, level)
    for trackName, fileID in sortedMusicPairs(musicTable) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = trackName
        info.value = fileID
        info.checked = MountMusicDB.playerLibraryTrackFileID == fileID
        info.fontObject = GameFontNormal
        info.func = playPlayerDropdownTrack
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(musicLibraryDropdown, function(_, level, menuList)
    if level == 1 then
        local rootItems = {
            { text = "City Music", menuList = "cityMusic" },
            { text = "Expansion Themes", menuList = "expansionThemes" },
            { text = "Musical Moments", menuList = "musicMoments" },
            { text = "No Music", value = "noMusic" },
            { text = "Raids", menuList = "raids" },
            { text = "Zone Music", menuList = "zoneMusic" },
        }
        for _, item in ipairs(rootItems) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.text
            info.value = item.value
            info.menuList = item.menuList
            info.hasArrow = item.menuList and true or nil
            info.checked = item.value == "noMusic" and not currentMusicFileID or false
            info.fontObject = GameFontNormal
            if item.value == "noMusic" then
                info.func = function()
                    MountMusicDB.playerLibraryTrackFileID = "noMusic"
                    manualPlaybackOverride = true
                    manualPlaybackTargetKey = getActiveMusicTarget()
                    stopCurrentMusic(true)
                    UIDropDownMenu_SetSelectedValue(musicLibraryDropdown, "noMusic")
                    UIDropDownMenu_SetText(musicLibraryDropdown, "No Music")
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
        return
    end

    local categories = playerMenuCategories[menuList]
    if categories then
        for _, category in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = category.text
            info.menuList = category.menuList
            info.hasArrow = true
            info.fontObject = GameFontNormal
            UIDropDownMenu_AddButton(info, level)
        end
        return
    end

    local musicTable = playerMusicTablesByMenuList[menuList]
    if musicTable then
        addPlayerDropdownTracks(musicTable, level)
    end
end)

local savedPlayerLibraryTrack = musicTrackByFileID[MountMusicDB.playerLibraryTrackFileID]
if MountMusicDB.playerLibraryTrackFileID == "noMusic" then
    UIDropDownMenu_SetSelectedValue(musicLibraryDropdown, "noMusic")
    UIDropDownMenu_SetText(musicLibraryDropdown, "No Music")
elseif savedPlayerLibraryTrack then
    UIDropDownMenu_SetSelectedValue(musicLibraryDropdown, savedPlayerLibraryTrack.fileID)
    UIDropDownMenu_SetText(musicLibraryDropdown, savedPlayerLibraryTrack.name)
end

local function restoreMusicAfterFormChange()
    if not MountMusicDB.musicStoppedByAddon then
        return
    end

    SetCVar("Sound_EnableMusic", "1")
    MountMusicDB.musicStoppedByAddon = nil
    MountMusicDB.musicStopRestoreValue = nil
    pausedTargetKey = nil
    setPlaybackButtonVisual(false)
end

stopMusicNow = function()
    pausedTargetKey = getActiveMusicTarget()
    MountMusicDB.musicStopRestoreValue = "1"
    MountMusicDB.musicStoppedByAddon = true
    setPlaybackButtonVisual(true)
    -- Retain the track ID so Play can restart it.
    StopMusic()
    SetCVar("Sound_EnableMusic", "0")
    refreshMusicPlayer()
end

toggleMusicStop = function()
    if not MountMusicDB.musicStoppedByAddon and GetCVar("Sound_EnableMusic") ~= "0" then
        stopMusicNow()
        return
    end

    SetCVar("Sound_EnableMusic", "1")
    MountMusicDB.musicStoppedByAddon = nil
    MountMusicDB.musicStopRestoreValue = nil
    pausedTargetKey = nil
    setPlaybackButtonVisual(false)

    if currentMusicFileID then
        PlayMusic(currentMusicFileID)
        currentMusicStartedAt = GetTime()
    elseif not currentMusicFileID and updateMusicPlayback then
        updateMusicPlayback()
    end
    refreshMusicPlayer()
end

playRandomMusic = function()
    local track = getRandomUnassignedMusicTrack()
    if not track then
        print("MountMusic: All available music tracks are already assigned.")
        return
    end
    manualPlaySequence = manualPlaySequence + 1
    if startMusicTrack(track.fileID, "random:" .. manualPlaySequence, track.name) then
        manualPlaybackOverride = true
        manualPlaybackTargetKey = getActiveMusicTarget()
    end
end

playAutoplayTrack = function()
    local track = getRandomMusicTrack(currentMusicFileID)
    if not track then
        print("MountMusic: No music tracks are available for Auto Play.")
        return false
    end

    manualPlaybackOverride = false
    manualPlaybackTargetKey = nil
    manualPlaySequence = manualPlaySequence + 1
    currentActiveTargetName = "Auto Play"
    return startMusicTrack(track.fileID, "autoplay:" .. manualPlaySequence, track.name)
end

toggleAutoPlay = function()
    MountMusicDB.autoPlayEnabled = not MountMusicDB.autoPlayEnabled
    refreshAutoPlayButton()
    refreshScreenAutoPlayButton()
    if MountMusicDB.autoPlayEnabled then
        manualPlaybackOverride = false
        manualPlaybackTargetKey = nil
    end
    updateMusicPlayback()
end

playPreviousMusic = function()
    if #allMusicTracks == 0 then
        print("MountMusic: No music tracks are available.")
        return
    end

    local track
    if playbackHistoryPosition > 1 then
        playbackHistoryPosition = playbackHistoryPosition - 1
        track = musicTrackByFileID[playbackHistory[playbackHistoryPosition]]
        navigatingPlaybackHistory = true
    else
        local currentIndex = musicTrackIndexByFileID[currentMusicFileID]
        if not currentIndex then
            print("MountMusic: No previous song is available.")
            return
        end
        local previousIndex = ((currentIndex - 2) % #allMusicTracks) + 1
        track = allMusicTracks[previousIndex]
    end

    manualPlaySequence = manualPlaySequence + 1
    local started = startMusicTrack(track.fileID, "manual:previous:" .. manualPlaySequence, track.name)
    navigatingPlaybackHistory = false
    if started then
        manualPlaybackOverride = true
        manualPlaybackTargetKey = getActiveMusicTarget()
    end
end

skipMusic = function()
    playRandomMusic()
end

updateMusicPlayback = function()
    if formTransitionPending then
        return
    end
    if MountMusicDB.autoPlayEnabled then
        currentActiveTargetName = "Auto Play"
        refreshMusicPlayer()
        if MountMusicDB.musicStoppedByAddon or GetCVar("Sound_EnableMusic") == "0" then
            return
        end
        if not currentMusicFileID then
            playAutoplayTrack()
        end
        return
    end
    local targetKey, selection, targetType, targetName = getActiveMusicTarget()
    currentActiveTargetName = targetName
    refreshMusicPlayer()
    if MountMusicDB.musicStoppedByAddon then
        if targetKey == pausedTargetKey then
            return
        end
        restoreMusicAfterFormChange()
    end
    if manualPlaybackOverride then
        if targetKey == manualPlaybackTargetKey then
            return
        end
        manualPlaybackOverride = false
        manualPlaybackTargetKey = nil
    end
    if not targetKey then
        stopCurrentMusic()
        return
    end

    local songName, fileID
    if type(selection) == "table" then
        songName, fileID = next(selection)
    end
    if targetType == "mount" and songName == "secret song" then
        fileID = "Interface/AddOns/MountMusic/audio-files/secret-song.mp3"
    end

    if not fileID or fileID == "noMusic" then
        stopCurrentMusic()
        return
    end
    startMusicTrack(fileID, targetKey, songName)
end

local lastObservedDruidFormName = getCurrentDruidFormName()
local druidFormCheckElapsed = 0
local druidFormTracker = CreateFrame("Frame")
druidFormTracker:SetScript("OnUpdate", function(_, elapsed)
    if formTransitionPending then
        return
    end

    druidFormCheckElapsed = druidFormCheckElapsed + elapsed
    if druidFormCheckElapsed < 0.25 then
        return
    end
    druidFormCheckElapsed = 0

    local _, classToken = UnitClass("player")
    if classToken ~= "DRUID" then
        return
    end

    local formName = getCurrentDruidFormName()
    if formName ~= lastObservedDruidFormName then
        lastObservedDruidFormName = formName
        manualPlaybackOverride = false
        manualPlaybackTargetKey = nil
        updateMusicPlayback()
    end
end)

local autoPlayCheckElapsed = 0
local autoPlayTracker = CreateFrame("Frame")
autoPlayTracker:SetScript("OnUpdate", function(_, elapsed)
    if not MountMusicDB.autoPlayEnabled then
        return
    end
    if MountMusicDB.musicStoppedByAddon or GetCVar("Sound_EnableMusic") == "0" then
        return
    end

    autoPlayCheckElapsed = autoPlayCheckElapsed + elapsed
    if autoPlayCheckElapsed < 0.5 then
        return
    end
    autoPlayCheckElapsed = 0

    if not currentMusicFileID then
        playAutoplayTrack()
    elseif currentMusicStartedAt
        and GetTime() - currentMusicStartedAt >= 3
        and IsMusicPlaying
        and not IsMusicPlaying() then
        playAutoplayTrack()
    end
end)


mountMusicSettingsFrame:HookScript("OnShow", function()
    settingsOpenToken = settingsOpenToken + 1
    local openToken = settingsOpenToken
    C_Timer.After(0.1, function()
        if openToken ~= settingsOpenToken or not mountMusicSettingsFrame:IsShown() then
            return
        end
        buildSettingsRows()
        if #mountEntries == 0 then
            print("MountMusic: No mounts were found in the Mount Journal.")
        end
    end)
end)

mountMusicSettingsFrame:HookScript("OnHide", function()
    settingsOpenToken = settingsOpenToken + 1
end)



--Handle events
local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MountMusic" then
            print("MountMusic version 1.0.0 loaded. Enjoy!")
            print("Click the Mount Music minimap icon to open and load settings.")
            if selectedMountMusicValues == nil then
                _G.selectedMountMusicValues = {}
            end
            if selectedDruidFormMusicValues == nil then
                _G.selectedDruidFormMusicValues = {}
            end
        end
    end
    if event == "PLAYER_LOGOUT"
        and (type(MountMusicDB.pendingMountMusicDraft) == "table"
            or type(MountMusicDB.pendingDruidFormMusicDraft) == "table") then
        saveDraftMusicSelections()
    end
    if event == "UNIT_AURA" then
        local unitID = ...
        if (unitID == "player") then
            updateMusicPlayback()
        end
    end
    if event == "UPDATE_SHAPESHIFT_FORM" then
        manualPlaybackOverride = false
        manualPlaybackTargetKey = nil
        stopCurrentMusic(true)
        formTransitionPending = true
        formTransitionToken = formTransitionToken + 1
        local transitionToken = formTransitionToken
        C_Timer.After(0.1, function()
            if transitionToken == formTransitionToken then
                formTransitionPending = false
                restoreMusicAfterFormChange()
                updateMusicPlayback()
            end
        end)
        C_Timer.After(0.3, function()
            if transitionToken == formTransitionToken then
                updateMusicPlayback()
            end
        end)
        C_Timer.After(0.6, function()
            if transitionToken == formTransitionToken then
                updateMusicPlayback()
            end
        end)
        C_Timer.After(1, function()
            if transitionToken == formTransitionToken then
                updateMusicPlayback()
            end
        end)
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED"
        or event == "PLAYER_ENTERING_WORLD" then
        manualPlaybackOverride = false
        manualPlaybackTargetKey = nil
        updateMusicPlayback()
        C_Timer.After(0.1, function()
            updateMusicPlayback()
        end)
    end
    if event == "PLAYER_STARTED_SWIMMING" or event == "PLAYER_STOPPED_SWIMMING" then
        updateMusicPlayback()
    end
end

--Register events and scripts --
mountMusicSettingsFrame:RegisterEvent("ADDON_LOADED")
mountMusicSettingsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mountMusicSettingsFrame:RegisterEvent("PLAYER_LOGOUT")
mountMusicSettingsFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
mountMusicSettingsFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
mountMusicSettingsFrame:RegisterEvent("PLAYER_STARTED_SWIMMING")
mountMusicSettingsFrame:RegisterEvent("PLAYER_STOPPED_SWIMMING")
mountMusicSettingsFrame:RegisterUnitEvent("UNIT_AURA", "player")
mountMusicSettingsFrame:SetScript("OnEvent", onEvent)
