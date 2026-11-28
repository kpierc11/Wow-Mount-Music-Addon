
-- ---------------------------------------------------------------------------
-- SETTINGS FRAME
-- ---------------------------------------------------------------------------
local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")

-- Frame title
local title                   = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 12, -4)
title:SetJustifyH("LEFT")
title:SetText("Mount Music Settings")
local file, _, flags = title:GetFont()
title:SetFont(file, 14, flags)


mountMusicSettingsFrame:SetPoint("CENTER")
mountMusicSettingsFrame:SetSize(800, 700)
mountMusicSettingsFrame:Hide()

-- Make the frame movable
mountMusicSettingsFrame:SetMovable(true)
mountMusicSettingsFrame:EnableMouse(true)
mountMusicSettingsFrame:RegisterForDrag("LeftButton")
mountMusicSettingsFrame:SetScript("OnDragStart", mountMusicSettingsFrame.StartMoving)
mountMusicSettingsFrame:SetScript("OnDragStop", mountMusicSettingsFrame.StopMovingOrSizing)


-- ---------------------------------------------------------------------------
-- SAVED VARIABLES AND SELECTION DRAFT
-- ---------------------------------------------------------------------------
MountMusicDB = MountMusicDB or {}
if type(MountMusicDB.minimap) ~= "table" then
    MountMusicDB.minimap = {}
end
local function getMountCollectionFilter()
    if type(MountMusicDB.mountCollectionFilter) ~= "table" then
        MountMusicDB.mountCollectionFilter = {}
    end
    local filters = MountMusicDB.mountCollectionFilter
    if filters.collected == nil then
        filters.collected = true
    end
    if filters.uncollected == nil then
        filters.uncollected = true
    end
    return filters
end
getMountCollectionFilter()
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
local savedMountMusicSelections = type(MountMusicDB.mountMusicSelections) == "table"
        and MountMusicDB.mountMusicSelections
    or selectedMountMusicValues
local savedDruidFormMusicSelections = type(MountMusicDB.druidFormMusicSelections) == "table"
        and MountMusicDB.druidFormMusicSelections
    or selectedDruidFormMusicValues
local selectedMountMusicDraft = copyMusicSelections(
    type(MountMusicDB.pendingMountMusicDraft) == "table"
        and MountMusicDB.pendingMountMusicDraft
        or savedMountMusicSelections
)
local selectedDruidFormMusicDraft = copyMusicSelections(
    type(MountMusicDB.pendingDruidFormMusicDraft) == "table"
        and MountMusicDB.pendingDruidFormMusicDraft
        or savedDruidFormMusicSelections
)
local function persistDraftMusicSelections()
    MountMusicDB.mountMusicSelections = copyMusicSelections(selectedMountMusicDraft)
    MountMusicDB.druidFormMusicSelections = copyMusicSelections(selectedDruidFormMusicDraft)
end
local function saveDraftMusicSelections()
    persistDraftMusicSelections()
    replaceMusicSelections(selectedMountMusicValues, selectedMountMusicDraft)
    replaceMusicSelections(selectedDruidFormMusicValues, selectedDruidFormMusicDraft)
    MountMusicDB.pendingMountMusicDraft = nil
    MountMusicDB.pendingDruidFormMusicDraft = nil
end
local saveButton
local mountEntries = {}
local settingsRowsBuilt = false
local buildAssignmentPages
local mountBook
local druidBook
local updateMusicPlayback
local stopMusicNow
local toggleMusicStop
local toggleAutoPlay
local playRandomMusic
local playAutoplayTrack
local refreshMusicPlayer
local refreshScreenAutoPlayButton
local currentMusicKey
local currentMusicFileID
local currentMusicTrackName
local currentMusicStartedAt
local manualPlaybackOverride = false
local manualPlaybackTargetKey
local pausedTargetKey
local settingsOpenToken = 0

-- ---------------------------------------------------------------------------
-- MINIMAP BUTTON
-- ---------------------------------------------------------------------------
local LDBIcon = LibStub("LibDBIcon-1.0")

local button = {
    icon = "Interface\\Icons\\ability_mount_ridinghorse",
    OnClick = function()
        if mountMusicSettingsFrame:IsShown() then
            mountMusicSettingsFrame:Hide()
        else
            mountMusicSettingsFrame:Show()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Mount Music")
        tooltip:AddLine("Click to open Mount Music settings.", 1, 1, 1)
    end,
}

LDBIcon:Register("MountMusic", button, MountMusicDB.minimap)
local function saveMinimapButtonPosition(position)
    if type(MountMusicDB.minimap) ~= "table" then
        MountMusicDB.minimap = {}
    end
    MountMusicDB.minimap.minimapPos = position
    local icon = LDBIcon:GetMinimapButton("MountMusic")
    if icon then
        icon.db = MountMusicDB.minimap
    end
end

local minimapButton = LDBIcon:GetMinimapButton("MountMusic")
if minimapButton then
    minimapButton:HookScript("OnDragStop", function()
        local cursorX, cursorY = GetCursorPosition()
        local minimapX, minimapY = Minimap:GetCenter()
        local scale = Minimap:GetEffectiveScale()
        if cursorX and cursorY and minimapX and minimapY and scale then
            saveMinimapButtonPosition(
                math.deg(math.atan2(cursorY / scale - minimapY, cursorX / scale - minimapX)) % 360
            )
        end
    end)
end

-- ---------------------------------------------------------------------------
-- MUSIC CATALOG
-- ---------------------------------------------------------------------------
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
local musicTableExpansionThemes = {
    ["bc main theme"] = 53220,
    ["bccredits lament of the highborne"] = 53221,
    ["wotlk main title"] = 53222,
    ["wow main theme"] = 53223
}
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

-- ---------------------------------------------------------------------------
-- MUSIC TRACK INDEX AND RANDOM SELECTION
-- ---------------------------------------------------------------------------
local allMusicTracks = {}
local seenMusicFileIDs = {}
local musicTrackByFileID = {}
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


-- ---------------------------------------------------------------------------
-- SETTINGS TABS
-- ---------------------------------------------------------------------------
local mountTabButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
mountTabButton:SetSize(140, 26)
mountTabButton:SetPoint("TOPLEFT", 12, -42)
mountTabButton:SetText("Mounts")
mountTabButton:Hide()

local druidTabButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
druidTabButton:SetSize(190, 26)
druidTabButton:SetPoint("LEFT", mountTabButton, "RIGHT", 12, 0)
druidTabButton:SetText("Druid Forms")
druidTabButton:Hide()
druidTabButton:SetScript("OnEnter", function(self)
    if not self:IsEnabled() then
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("You need to be on a Druid to use this tab.")
        GameTooltip:Show()
    end
end)
druidTabButton:SetScript("OnLeave", GameTooltip_Hide)

local mountScrollFrame = CreateFrame("Frame", nil, mountMusicSettingsFrame)
mountScrollFrame:SetPoint("TOPLEFT", 12, -75)
mountScrollFrame:SetPoint("BOTTOMRIGHT", -12, 60)
mountScrollFrame:Hide()

local mountScrollChild = CreateFrame("Frame", nil, mountScrollFrame)
mountScrollChild:SetAllPoints()

local druidScrollFrame = CreateFrame("Frame", nil, mountMusicSettingsFrame)
druidScrollFrame:SetPoint("TOPLEFT", 12, -75)
druidScrollFrame:SetPoint("BOTTOMRIGHT", -12, 60)
druidScrollFrame:Hide()

local druidScrollChild = CreateFrame("Frame", nil, druidScrollFrame)
druidScrollChild:SetAllPoints()

local function selectSettingsTab(tab)
    local _, classToken = UnitClass("player")
    local isDruid = classToken == "DRUID"
    if tab == "druid" then
        if not isDruid then
            return
        end
    end

    MountMusicDB.assignmentTab = tab
    mountTabButton:SetEnabled(tab ~= "mounts")
    druidTabButton:SetEnabled(isDruid and tab ~= "druid")
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

-- ---------------------------------------------------------------------------
-- ON-SCREEN TRACK DISPLAY
-- ---------------------------------------------------------------------------
local screenTrackButton
local refreshScreenTrackButton
local screenTrackFrame = CreateFrame("Frame", "MountMusicScreenTrackFrame", UIParent, "BackdropTemplate")
screenTrackFrame:SetSize(275, 78)
screenTrackFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
screenTrackFrame:SetBackdropColor(0.035, 0.045, 0.06, 0.96)
screenTrackFrame:SetBackdropBorderColor(0.72, 0.56, 0.28, 0.9)
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
screenTrackCloseButton:SetSize(16, 16)
screenTrackCloseButton:SetPoint("TOPRIGHT", -4, -4)
screenTrackCloseButton:SetScript("OnClick", function()
    MountMusicDB.screenTrackVisible = false
    screenTrackFrame:Hide()
    if refreshScreenTrackButton then
        refreshScreenTrackButton()
    end
end)

local screenTrackNameText = screenTrackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
screenTrackNameText:SetPoint("TOPLEFT", 18, -10)
screenTrackNameText:SetWidth(220)
screenTrackNameText:SetFontObject(GameFontNormal)
screenTrackNameText:SetJustifyH("LEFT")
screenTrackNameText:SetWordWrap(false)
screenTrackNameText:SetTextColor(1, 0.88, 0.62)
screenTrackNameText:SetText("No Music Playing")

local screenTrackStatusText = screenTrackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
screenTrackStatusText:SetPoint("TOPLEFT", screenTrackNameText, "BOTTOMLEFT", 0, -3)
screenTrackStatusText:SetWidth(220)
screenTrackStatusText:SetJustifyH("LEFT")
screenTrackStatusText:SetWordWrap(false)
screenTrackStatusText:SetTextColor(0.65, 0.69, 0.74)
screenTrackStatusText:SetText("No Music Playing")

local screenTrackAccent = screenTrackFrame:CreateTexture(nil, "ARTWORK")
screenTrackAccent:SetPoint("TOPLEFT", 10, -10)
screenTrackAccent:SetSize(3, 30)
screenTrackAccent:SetTexture("Interface\\Buttons\\WHITE8X8")
screenTrackAccent:SetVertexColor(0.92, 0.68, 0.28, 0.95)

local screenStopButton = CreateFrame("Button", nil, screenTrackFrame)
screenStopButton:SetSize(28, 26)
screenStopButton:SetPoint("BOTTOMLEFT", 10, 7)
screenStopButton:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "BLEND")
screenStopButton:GetHighlightTexture():SetVertexColor(0.82, 0.62, 0.3, 0.18)
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

local screenRandomTrackButton = CreateFrame("Button", nil, screenTrackFrame, "UIPanelButtonTemplate")
screenRandomTrackButton:SetSize(120, 24)
screenRandomTrackButton:SetPoint("LEFT", screenStopButton, "RIGHT", 6, 0)
screenRandomTrackButton:SetText("Random Track")
screenRandomTrackButton:SetScript("OnClick", function()
    playRandomMusic()
end)
local screenAutoPlayButton = CreateFrame("Button", nil, screenTrackFrame, "UIPanelButtonTemplate")
screenAutoPlayButton:SetSize(100, 24)
screenAutoPlayButton:SetPoint("BOTTOMRIGHT", -10, 7)
refreshScreenAutoPlayButton = function()
    screenAutoPlayButton:SetText(MountMusicDB.autoPlayEnabled and "Auto Play: On" or "Auto Play: Off")
end
refreshScreenAutoPlayButton()
screenAutoPlayButton:SetScript("OnClick", function()
    toggleAutoPlay()
end)

local function styleScreenActionButton(button)
    local normalTexture = button:GetNormalTexture()
    if normalTexture then
        normalTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
        normalTexture:SetVertexColor(0.12, 0.14, 0.17, 0.95)
    end
    local pushedTexture = button:GetPushedTexture()
    if pushedTexture then
        pushedTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
        pushedTexture:SetVertexColor(0.34, 0.25, 0.12, 0.95)
    end
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "BLEND")
    button:GetHighlightTexture():SetVertexColor(0.82, 0.62, 0.3, 0.22)
    local label = button:GetFontString()
    if label then
        label:SetTextColor(0.96, 0.9, 0.76)
    end
end

styleScreenActionButton(screenRandomTrackButton)
styleScreenActionButton(screenAutoPlayButton)

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

setControlTooltip(screenStopButton, "Stop Music")

-- ---------------------------------------------------------------------------
-- SETTINGS PLAYBACK CONTROLS
-- ---------------------------------------------------------------------------
local stopButton = CreateFrame("Button", nil, mountMusicSettingsFrame)
stopButton:SetSize(30, 26)
stopButton:SetPoint("BOTTOMLEFT", 12, 14)
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

local randomTrackButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
randomTrackButton:SetSize(140, 26)
randomTrackButton:SetPoint("LEFT", stopButton, "RIGHT", 6, 0)
randomTrackButton:SetText("Random Track")
randomTrackButton:SetScript("OnClick", function()
    playRandomMusic()
end)

local autoPlayButton = CreateFrame("Button", nil, mountMusicSettingsFrame, "UIPanelButtonTemplate")
autoPlayButton:SetSize(112, 26)
autoPlayButton:SetPoint("LEFT", randomTrackButton, "RIGHT", 8, 0)
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

local function setModernHoverHighlight(button)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "BLEND")
    button:GetHighlightTexture():SetVertexColor(0.82, 0.58, 0.16, 0.22)
end

-- ---------------------------------------------------------------------------
-- DRUID FORM DEFINITIONS
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- MOUNT JOURNAL AND DRUID HELPERS
-- ---------------------------------------------------------------------------
local function getMountJournalEntries()
    local entriesBySpellID = {}
    if C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountInfoByID then
        for _, mountID in ipairs(C_MountJournal.GetMountIDs() or {}) do
            local name, spellID, icon, _, _, _, _, _, _, hideOnChar, isCollected =
                C_MountJournal.GetMountInfoByID(mountID)
            local existing = spellID and entriesBySpellID[spellID]
            if name and not hideOnChar and spellID
                and (not existing or (isCollected and not existing.isCollected)) then
                entriesBySpellID[spellID] = {
                    mountID = mountID,
                    name = name,
                    spellID = spellID,
                    icon = icon,
                    isCollected = isCollected,
                }
            end
        end
    end
    local entries = {}
    for _, entry in pairs(entriesBySpellID) do
        table.insert(entries, entry)
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

-- ---------------------------------------------------------------------------
-- SETTINGS PAGE BUILD
-- ---------------------------------------------------------------------------
local function buildSettingsRows()
    mountEntries = getMountJournalEntries()
    buildAssignmentPages()

    local _, classToken = UnitClass("player")
    mountTabButton:Show()
    druidTabButton:Show()
    if classToken == "DRUID" then
        druidTabButton:SetSize(140, 26)
        druidTabButton:SetText("Druid Forms")
        druidTabButton:SetEnabled(MountMusicDB.assignmentTab ~= "druid")
    else
        druidTabButton:SetSize(190, 26)
        druidTabButton:SetText("Druid Forms (Need Druid)")
        druidTabButton:Disable()
    end
    settingsRowsBuilt = true
    local initialTab = classToken == "DRUID" and MountMusicDB.assignmentTab == "druid"
        and "druid" or "mounts"
    selectSettingsTab(initialTab)
end


-- ---------------------------------------------------------------------------
-- ACTIVE TARGET AND PLAYBACK STATE
-- ---------------------------------------------------------------------------
local manualPlaySequence = 0
local formTransitionToken = 0
local formTransitionPending = false
local cachedDruidFormName

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
    local function rememberFormName(formName)
        cachedDruidFormName = formName
        return formName
    end

    if InCombatLockdown and InCombatLockdown() then
        if GetShapeshiftFormID then
            local formID = GetShapeshiftFormID()
            local formName = druidFormNamesByFormID[formID]
            if formName or (formID and formID ~= 0) then
                return rememberFormName(formName or cachedDruidFormName)
            end
            return rememberFormName(nil)
        end
        return cachedDruidFormName
    end

    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for auraIndex = 1, 255 do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", auraIndex, "HELPFUL")
            if not aura then
                break
            end
            local formName = getDruidFormNameForAura(aura.name, aura.spellId)
            if formName then
                return rememberFormName(formName)
            end
        end
    elseif UnitAura then
        for auraIndex = 1, 40 do
            local auraName, _, _, _, _, _, _, _, _, spellID = UnitAura("player", auraIndex, "HELPFUL")
            local formName = getDruidFormNameForAura(auraName, spellID)
            if formName then
                return rememberFormName(formName)
            end
        end
    end

    if GetShapeshiftFormID then
        local formName = druidFormNamesByFormID[GetShapeshiftFormID()]
        if formName then
            return rememberFormName(formName)
        end
    end

    if GetShapeshiftFormInfo then
        local function getNameForActiveForm(formIndex)
            local _, isActive, _, spellID = GetShapeshiftFormInfo(formIndex)
            if isActive then
                return rememberFormName(getDruidFormNameForSpellID(spellID))
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
                return rememberFormName(form.name)
            end
        end
    end

    return rememberFormName(nil)
end

local function getActiveMusicTarget()
    local formName = getCurrentDruidFormName()
    if formName then
        return "form:" .. formName, selectedDruidFormMusicValues[formName], "form"
    end

    if #mountEntries == 0 then
        mountEntries = getMountJournalEntries()
    end
    if C_MountJournal and C_MountJournal.GetMountInfoByID then
        for _, mountData in ipairs(mountEntries) do
            local _, creatureID, _, isActive = C_MountJournal.GetMountInfoByID(mountData.mountID)
            if isActive then
                return "mount:" .. tostring(creatureID), selectedMountMusicValues[creatureID], "mount"
            end
        end
    end
end

refreshMusicPlayer = function()
    local playbackState
    if MountMusicDB.musicStoppedByAddon or GetCVar("Sound_EnableMusic") == "0" then
        playbackState = "Stopped"
    elseif currentMusicFileID and (not IsMusicPlaying or IsMusicPlaying()) then
        playbackState = "Playing"
    else
        playbackState = "No Music Playing"
    end
    local screenTrackName = currentMusicTrackName or "No Music Playing"
    if #screenTrackName > 24 then
        screenTrackName = screenTrackName:sub(1, 21) .. "..."
    end
    screenTrackNameText:SetText(screenTrackName)
    screenTrackStatusText:SetText(playbackState)
    if playbackState == "Playing" then
        screenTrackStatusText:SetTextColor(0.48, 0.82, 0.58)
    elseif playbackState == "Stopped" then
        screenTrackStatusText:SetTextColor(0.92, 0.68, 0.34)
    else
        screenTrackStatusText:SetTextColor(0.65, 0.69, 0.74)
    end
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
    refreshMusicPlayer()
    return true
end

-- ---------------------------------------------------------------------------
-- MUSIC ASSIGNMENT MENU DATA
-- ---------------------------------------------------------------------------
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

local assignmentAccordionRoots = {
    { text = "City Music", menuList = "cityMusic", children = playerMenuCategories.cityMusic },
    { text = "Expansion Themes", menuList = "expansionThemes" },
    { text = "Musical Moments", menuList = "musicMoments", children = playerMenuCategories.musicMoments },
    { text = "Raids", menuList = "raids", children = playerMenuCategories.raids },
    { text = "Zone Music", menuList = "zoneMusic", children = playerMenuCategories.zoneMusic },
}

-- ---------------------------------------------------------------------------
-- MUSIC ASSIGNMENT UI
-- ---------------------------------------------------------------------------
local function setCollectionHover(button)
    setModernHoverHighlight(button)
end

local function getBookSelection(book)
    if not book.selectedEntity then
        return nil, nil
    end
    local selections = book.kind == "mount" and selectedMountMusicDraft or selectedDruidFormMusicDraft
    local assignment = selections[book.selectedEntity.id]
    if assignment then
        return next(assignment)
    end
    return nil, nil
end

local function refreshBookSelection(book)
    local entity = book.selectedEntity
    if not entity then
        book.entityTitle:SetText(book.pageTitle)
        book.assignmentText:SetText("Select an entry on the left")
        book.randomButton:SetEnabled(false)
        book.noMusicButton:SetEnabled(false)
    else
        local songName, fileID = getBookSelection(book)
        book.entityTitle:SetText(entity.name)
        book.assignmentText:SetText(
            fileID == "noMusic" and "Assigned: No Music"
                or songName and ("Assigned: " .. songName)
                or "No song assigned"
        )
        local canAssign = book.kind ~= "mount" or entity.isCollected ~= false
        book.randomButton:SetEnabled(canAssign)
        book.noMusicButton:SetEnabled(canAssign)
    end
    book.playNowButton:SetEnabled(book.previewTrackFileID ~= nil)

    for _, row in ipairs(book.entityRows) do
        if row.entity then
            row.selectionTexture:SetShown(entity and row.entity.id == entity.id)
            local selections = book.kind == "mount" and selectedMountMusicDraft or selectedDruidFormMusicDraft
            local assignment = selections[row.entity.id]
            local songName, fileID
            if assignment then
                songName, fileID = next(assignment)
            end
            local assignmentLabel = fileID == "noMusic" and "No Music"
                or songName or "Choose a song"
            if book.kind == "mount" and row.entity.isCollected == false then
                assignmentLabel = "Locked - " .. assignmentLabel
            end
            row.assignmentText:SetText(assignmentLabel)
        end
    end

    if book.renderAccordion then
        book.renderAccordion()
    end
end

local function assignBookTrack(book, songName, fileID)
    if not book.selectedEntity then
        return
    end
    if book.kind == "mount" and book.selectedEntity.isCollected == false then
        return
    end

    if fileID == "noMusic" then
        book.previewTrackName = nil
        book.previewTrackFileID = nil
    else
        book.previewTrackName = songName
        book.previewTrackFileID = fileID
    end
    local selections = book.kind == "mount" and selectedMountMusicDraft or selectedDruidFormMusicDraft
    selections[book.selectedEntity.id] = { [songName] = fileID }
    MountMusicDB.pendingMountMusicDraft = copyMusicSelections(selectedMountMusicDraft)
    MountMusicDB.pendingDruidFormMusicDraft = copyMusicSelections(selectedDruidFormMusicDraft)
    persistDraftMusicSelections()
    saveButton:SetText("Save")
    saveButton:SetEnabled(true)
    refreshBookSelection(book)
end

local function enableMouseWheelScrolling(scrollFrame, stepSize)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:HookScript("OnMouseWheel", function(self, delta)
        local maxScroll = self:GetVerticalScrollRange()
        local scroll = self:GetVerticalScroll() - (delta * stepSize)
        self:SetVerticalScroll(math.max(0, math.min(maxScroll, scroll)))
    end)
end

local function createAssignmentBook(page, kind, pageTitle)
    local book = {
        kind = kind,
        pageTitle = pageTitle,
        entityRows = {},
        accordionRows = {},
        openCategory = nil,
        openSubcategory = nil,
    }

    book.leftPage = CreateFrame("Frame", nil, page, "ToolTipBorderedFrameTemplate")
    book.leftPage:SetPoint("TOPLEFT", page, "TOPLEFT", 5, -5)
    book.leftPage:SetPoint("BOTTOMRIGHT", page, "BOTTOMLEFT", 305, 5)

    book.rightPage = CreateFrame("Frame", nil, page, "ToolTipBorderedFrameTemplate")
    book.rightPage:SetPoint("TOPLEFT", page, "TOPLEFT", 311, -5)
    book.rightPage:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -5, 5)

    book.pageHeading = book.leftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    book.pageHeading:SetPoint("TOPLEFT", 10, -8)
    book.pageHeading:SetText(pageTitle)
    book.pageHeading:SetTextColor(1, 0.82, 0)

    if kind == "mount" then
        book.mountFilterBar = CreateFrame("Frame", nil, book.leftPage)
        book.mountFilterBar:SetPoint("TOPLEFT", book.leftPage, "TOPLEFT", 10, -30)
        book.mountFilterBar:SetPoint("TOPRIGHT", book.leftPage, "TOPRIGHT", -10, -30)
        book.mountFilterBar:SetHeight(24)

        book.searchBox = CreateFrame("EditBox", nil, book.leftPage, "InputBoxTemplate")
        book.searchBox:SetSize(104, 22)
        book.searchBox:SetPoint("LEFT", book.mountFilterBar, "LEFT", 8, 0)
        book.searchBox:SetTextInsets(10, 6, 0, 0)
        book.searchBox:SetAutoFocus(false)
        book.searchBox:SetMaxLetters(80)
        book.searchBox:SetScript("OnEscapePressed", function(self)
            self:SetText("")
            self:ClearFocus()
        end)

        book.searchPlaceholder = book.searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        book.searchPlaceholder:SetPoint("LEFT", 10, 0)
        book.searchPlaceholder:SetText("Search mounts...")
        book.searchPlaceholder:Show()

        book.searchBox:SetScript("OnEditFocusGained", function()
            book.searchPlaceholder:Hide()
        end)
        book.searchBox:SetScript("OnEditFocusLost", function()
            book.searchPlaceholder:SetShown(book.searchBox:GetText() == "")
        end)
        book.searchBox:SetScript("OnTextChanged", function(self)
            book.searchPlaceholder:SetShown(self:GetText() == "")
            if book.setEntities and book.allEntities then
                book.setEntities(book.allEntities, MountMusicDB.selectedMountAssignmentID)
            end
        end)

        book.collectionFilterDropdown = CreateFrame(
            "Frame",
            nil,
            book.leftPage,
            "UIDropDownMenuTemplate"
        )
        book.collectionFilterDropdown:SetPoint("RIGHT", book.mountFilterBar, "RIGHT")
        UIDropDownMenu_SetWidth(book.collectionFilterDropdown, 116)
        book.searchBox:SetPoint("RIGHT", book.collectionFilterDropdown, "LEFT", 8, 0)

        local function refreshCollectionFilterDropdown()
            local filters = getMountCollectionFilter()
            local label
            if filters.collected and filters.uncollected then
                label = "All Mounts"
            elseif filters.collected then
                label = "Collected"
            elseif filters.uncollected then
                label = "Uncollected"
            else
                label = "None"
            end
            UIDropDownMenu_SetText(book.collectionFilterDropdown, label)
        end

        UIDropDownMenu_Initialize(book.collectionFilterDropdown, function(_, level)
            for _, filter in ipairs({
                { key = "collected", text = "Collected" },
                { key = "uncollected", text = "Uncollected" },
            }) do
                local filterKey = filter.key
                local info = UIDropDownMenu_CreateInfo()
                info.text = filter.text
                info.isNotRadio = true
                info.keepShownOnClick = true
                info.checked = function()
                    return getMountCollectionFilter()[filterKey]
                end
                info.func = function()
                    local filters = getMountCollectionFilter()
                    filters[filterKey] = not filters[filterKey]
                    refreshCollectionFilterDropdown()
                    if book.setEntities and book.allEntities then
                        book.setEntities(book.allEntities, MountMusicDB.selectedMountAssignmentID)
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        refreshCollectionFilterDropdown()
    end

    book.listScroll = CreateFrame("ScrollFrame", nil, book.leftPage, "ScrollFrameTemplate")
    book.listScroll:SetPoint("TOPLEFT", book.leftPage, "TOPLEFT", 8, kind == "mount" and -58 or -26)
    book.listScroll:SetPoint("BOTTOMRIGHT", book.leftPage, "BOTTOMRIGHT", -24, 16)
    enableMouseWheelScrolling(book.listScroll, 56)
    book.listContent = CreateFrame("Frame", nil, book.listScroll)
    book.listContent:SetWidth(245)
    book.listScroll:SetScrollChild(book.listContent)

    book.emptyText = book.listContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    book.emptyText:SetPoint("TOPLEFT", 8, -8)
    book.emptyText:SetWidth(180)
    book.emptyText:SetJustifyH("LEFT")

    book.entityTitle = book.rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    book.entityTitle:SetPoint("TOPLEFT", book.rightPage, "TOPLEFT", 10, -8)
    book.entityTitle:SetPoint("RIGHT", book.rightPage, "RIGHT", -10, 0)
    book.entityTitle:SetJustifyH("LEFT")
    book.entityTitle:SetTextColor(1, 0.82, 0)

    book.assignmentText = book.rightPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    book.assignmentText:SetPoint("TOPLEFT", book.entityTitle, "BOTTOMLEFT", 0, -3)
    book.assignmentText:SetPoint("RIGHT", book.rightPage, "RIGHT", -10, 0)
    book.assignmentText:SetJustifyH("LEFT")

    book.randomButton = CreateFrame("Button", nil, book.rightPage, "UIPanelButtonTemplate")
    book.randomButton:SetSize(112, 22)
    book.randomButton:SetPoint("TOPLEFT", book.assignmentText, "BOTTOMLEFT", 0, -6)
    book.randomButton:SetText("Assign Random")
    book.randomButton:SetScript("OnClick", function()
        local track = getRandomMusicTrack()
        if not track then
            print("MountMusic: No music tracks are available.")
            return
        end
        assignBookTrack(book, track.name, track.fileID)
    end)

    book.noMusicButton = CreateFrame("Button", nil, book.rightPage, "UIPanelButtonTemplate")
    book.noMusicButton:SetSize(90, 22)
    book.noMusicButton:SetPoint("LEFT", book.randomButton, "RIGHT", 6, 0)
    book.noMusicButton:SetText("No Music")
    book.noMusicButton:SetScript("OnClick", function()
        assignBookTrack(book, "No Music", "noMusic")
    end)

    book.playNowButton = CreateFrame("Button", nil, book.rightPage, "UIPanelButtonTemplate")
    book.playNowButton:SetSize(90, 22)
    book.playNowButton:SetPoint("LEFT", book.noMusicButton, "RIGHT", 6, 0)
    book.playNowButton:SetText("Play Now")
    book.playNowButton:SetEnabled(false)
    book.playNowButton:SetScript("OnClick", function()
        local fileID = book.previewTrackFileID
        if not fileID then
            return
        end

        manualPlaySequence = manualPlaySequence + 1
        if startMusicTrack(
            fileID,
            "manual:assignment:" .. manualPlaySequence,
            book.previewTrackName
        ) then
            manualPlaybackOverride = true
            manualPlaybackTargetKey = getActiveMusicTarget()
        end
    end)

    book.accordionScroll = CreateFrame("ScrollFrame", nil, book.rightPage, "ScrollFrameTemplate")
    book.accordionScroll:SetPoint("TOPLEFT", book.randomButton, "BOTTOMLEFT", 0, -8)
    book.accordionScroll:SetPoint("BOTTOMRIGHT", book.rightPage, "BOTTOMRIGHT", -26, 8)
    enableMouseWheelScrolling(book.accordionScroll, 24)
    book.accordionContent = CreateFrame("Frame", nil, book.accordionScroll)
    local function updateAccordionContentWidth()
        book.accordionContent:SetWidth(math.max(305, book.accordionScroll:GetWidth()))
    end
    book.accordionScroll:HookScript("OnSizeChanged", updateAccordionContentWidth)
    updateAccordionContentWidth()
    book.accordionScroll:SetScrollChild(book.accordionContent)

    local function renderEntityRows()
        local entities = book.visibleEntities or {}
        local rowHeight = 52
        local rowStep = 56
        local iconSize = 40
        local textOffset = iconSize + 12
        local textWidth = book.listContent:GetWidth() - textOffset - 8
        local firstIndex = math.max(1, math.floor(book.listScroll:GetVerticalScroll() / rowStep))
        local visibleCount = math.ceil(book.listScroll:GetHeight() / rowStep) + 2
        local lastIndex = math.min(#entities, firstIndex + visibleCount - 1)
        local rowNumber = 0

        for entityIndex = firstIndex, lastIndex do
            rowNumber = rowNumber + 1
            local row = book.entityRows[rowNumber]
            if not row then
                row = CreateFrame("Button", nil, book.listContent)
                row:SetHeight(rowHeight)
                setCollectionHover(row)
                row.border = CreateFrame("Frame", nil, row, "BackdropTemplate")
                row.border:SetAllPoints(row)
                row.border:SetFrameLevel(row:GetFrameLevel() + 3)
                row.border:EnableMouse(false)
                row.border:SetBackdrop({
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 8,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 },
                })
                row.border:SetBackdropBorderColor(0.65, 0.5, 0.25, 0.55)
                row.selectionTexture = row:CreateTexture(nil, "BACKGROUND")
                row.selectionTexture:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -3)
                row.selectionTexture:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -3, 3)
                row.selectionTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
                row.selectionTexture:SetVertexColor(0.6, 0.42, 0.12, 0.28)
                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(iconSize, iconSize)
                row.icon:SetPoint("LEFT", 4, 0)
                row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                row.nameText:SetPoint("TOPLEFT", row, "TOPLEFT", textOffset, -13)
                row.nameText:SetWordWrap(false)
                row.nameText:SetJustifyH("CENTER")
                row.assignmentText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.assignmentText:SetPoint("TOPLEFT", row.nameText, "BOTTOMLEFT", 0, -1)
                row.assignmentText:SetWordWrap(false)
                row.assignmentText:SetJustifyH("CENTER")
                row.assignmentText:SetTextColor(0.75, 0.72, 0.62)
                book.entityRows[rowNumber] = row
            end

            local entity = entities[entityIndex]
            local currentEntity = entity
            row.entity = entity
            row:ClearAllPoints()
            row:SetPoint(
                "TOPLEFT",
                book.listContent,
                "TOPLEFT",
                4,
                -(8 + (entityIndex - 1) * rowStep)
            )
            row:SetWidth(book.listContent:GetWidth() - 8)
            row.nameText:SetWidth(textWidth)
            row.assignmentText:SetWidth(textWidth)
            row.icon:SetTexture(entity.icon)
            row.nameText:SetText(entity.name)
            local isLockedMount = book.kind == "mount" and entity.isCollected == false
            row.icon:SetDesaturated(isLockedMount)
            if isLockedMount then
                row.icon:SetVertexColor(0.5, 0.5, 0.5)
                row.nameText:SetTextColor(0.55, 0.55, 0.55)
            else
                row.icon:SetVertexColor(1, 1, 1)
                row.nameText:SetTextColor(1, 0.82, 0)
            end
            row.selectionTexture:SetShown(
                book.selectedEntity and book.selectedEntity.id == entity.id
            )
            local selections = book.kind == "mount"
                and selectedMountMusicDraft or selectedDruidFormMusicDraft
            local assignment = selections[entity.id]
            local songName, fileID
            if assignment then
                songName, fileID = next(assignment)
            end
            local assignmentLabel = fileID == "noMusic" and "No Music"
                or songName or "Choose a song"
            if book.kind == "mount" and entity.isCollected == false then
                assignmentLabel = "Locked - " .. assignmentLabel
            end
            row.assignmentText:SetText(assignmentLabel)
            row:SetScript("OnClick", function()
                book.selectedEntity = currentEntity
                if book.kind == "mount" then
                    MountMusicDB.selectedMountAssignmentID = currentEntity.id
                else
                    MountMusicDB.selectedDruidFormAssignmentName = currentEntity.id
                end
                local assignedName, assignedFileID = getBookSelection(book)
                if assignedFileID and assignedFileID ~= "noMusic" then
                    book.previewTrackName = assignedName
                    book.previewTrackFileID = assignedFileID
                else
                    book.previewTrackName = nil
                    book.previewTrackFileID = nil
                end
                refreshBookSelection(book)
            end)
            row:Show()
        end

        for index = rowNumber + 1, #book.entityRows do
            book.entityRows[index].entity = nil
            book.entityRows[index]:Hide()
        end
    end
    book.renderEntityRows = renderEntityRows
    book.listScroll:HookScript("OnVerticalScroll", function()
        book.renderEntityRows()
    end)

    function book.setEntities(entities, savedEntityID)
        book.allEntities = entities

        local visibleEntities = {}
        local searchText = book.searchBox and string.lower(book.searchBox:GetText()) or ""
        searchText = string.gsub(searchText, "^%s+", "")
        searchText = string.gsub(searchText, "%s+$", "")
        local filters = getMountCollectionFilter()

        for _, entity in ipairs(entities) do
            local matchesCollection = book.kind ~= "mount"
                or (entity.isCollected == false and filters.uncollected)
                or (entity.isCollected ~= false and filters.collected)
            local matchesSearch = searchText == ""
                or string.find(string.lower(entity.name), searchText, 1, true)
            if matchesCollection and matchesSearch then
                table.insert(visibleEntities, entity)
            end
        end
        book.visibleEntities = visibleEntities

        local selectedEntity
        for _, entity in ipairs(visibleEntities) do
            if entity.id == savedEntityID then
                selectedEntity = entity
                break
            end
        end
        book.selectedEntity = selectedEntity or visibleEntities[1]
        local assignedName, assignedFileID = getBookSelection(book)
        if assignedFileID and assignedFileID ~= "noMusic" then
            book.previewTrackName = assignedName
            book.previewTrackFileID = assignedFileID
        else
            book.previewTrackName = nil
            book.previewTrackFileID = nil
        end

        book.listContent:SetWidth(math.max(220, book.listScroll:GetWidth()))
        book.emptyText:SetText(#visibleEntities == 0 and "No entries available" or "")
        book.listContent:SetHeight(math.max(
            book.listScroll:GetHeight(),
            (#visibleEntities * 56) + 16
        ))
        book.listScroll:UpdateScrollChildRect()
        book.listScroll:SetVerticalScroll(0)
        book.renderEntityRows()
        refreshBookSelection(book)
    end

    local function getAccordionRow(index)
        local row = book.accordionRows[index]
        if row then
            return row
        end

        row = CreateFrame("Button", nil, book.accordionContent)
        setCollectionHover(row)
        row.selectionTexture = row:CreateTexture(nil, "BACKGROUND")
        row.selectionTexture:SetAllPoints()
        row.selectionTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
        row.selectionTexture:SetVertexColor(0.55, 0.38, 0.1, 0.3)
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.label:SetJustifyH("LEFT")
        book.accordionRows[index] = row
        return row
    end

    local function renderAccordion()
        local scrollPosition = book.accordionScroll:GetVerticalScroll()
        local rowIndex = 0
        local yPos = 6
        local canAssign = book.selectedEntity ~= nil
            and (book.kind ~= "mount" or book.selectedEntity.isCollected ~= false)
        local selectedSongName, selectedFileID = getBookSelection(book)

        local function addRow(text, indent, height, selected, onClick, color)
            rowIndex = rowIndex + 1
            local row = getAccordionRow(rowIndex)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", book.accordionContent, "TOPLEFT", 4, -yPos)
            row:SetSize(book.accordionContent:GetWidth() - 8, height)
            row.label:ClearAllPoints()
            row.label:SetPoint("LEFT", row, "LEFT", 8 + indent, 0)
            row.label:SetWidth(row:GetWidth() - 14 - indent)
            row.label:SetText(text)
            local idleColor = selected and { 1, 0.9, 0.45 } or color
            row.label:SetTextColor(idleColor[1], idleColor[2], idleColor[3])
            row:SetScript("OnEnter", function(self)
                self.label:SetTextColor(1, 1, 1)
            end)
            row:SetScript("OnLeave", function(self)
                self.label:SetTextColor(idleColor[1], idleColor[2], idleColor[3])
            end)
            row.selectionTexture:SetShown(selected == true)
            row:SetScript("OnClick", onClick)
            row:SetEnabled(onClick ~= nil)
            row:Show()
            yPos = yPos + height
        end

        local function addTracks(menuList, indent)
            local musicTable = playerMusicTablesByMenuList[menuList]
            if not musicTable then
                return
            end
            for trackName, fileID in sortedMusicPairs(musicTable) do
                local name, trackID = trackName, fileID
                local isAssigned = selectedSongName == name and selectedFileID == trackID
                local isPreview = book.previewTrackName == name and book.previewTrackFileID == trackID
                addRow(name, indent, 24, isAssigned or isPreview, function()
                    book.previewTrackName = name
                    book.previewTrackFileID = trackID
                    if canAssign then
                        assignBookTrack(book, name, trackID)
                    else
                        refreshBookSelection(book)
                    end
                end, { 0.92, 0.9, 0.82 })
            end
        end

        for _, category in ipairs(assignmentAccordionRoots) do
            local root = category
            local isOpen = book.openCategory == root.menuList
            addRow((isOpen and "v  " or ">  ") .. root.text, 0, 25, false, function()
                if isOpen then
                    book.openCategory = nil
                else
                    book.openCategory = root.menuList
                end
                book.openSubcategory = nil
                renderAccordion()
            end, { 1, 0.82, 0 })

            if isOpen then
                if root.children then
                    for _, subcategory in ipairs(root.children) do
                        local sub = subcategory
                        local subOpen = book.openSubcategory == sub.menuList
                        addRow((subOpen and "v  " or ">  ") .. sub.text, 10, 23, false, function()
                            if subOpen then
                                book.openSubcategory = nil
                            else
                                book.openSubcategory = sub.menuList
                            end
                            renderAccordion()
                        end, { 0.92, 0.78, 0.38 })
                        if subOpen then
                            addTracks(sub.menuList, 24)
                        end
                    end
                else
                    addTracks(root.menuList, 12)
                end
            end
            yPos = yPos + 3
        end

        for index = rowIndex + 1, #book.accordionRows do
            book.accordionRows[index]:Hide()
        end
        book.accordionContent:SetHeight(math.max(book.accordionScroll:GetHeight(), yPos + 6))
        book.accordionScroll:UpdateScrollChildRect()
        book.accordionScroll:SetVerticalScroll(scrollPosition)
    end

    book.renderAccordion = renderAccordion
    book.setEntities({}, nil)
    return book
end

buildAssignmentPages = function()
    if not mountBook then
        mountBook = createAssignmentBook(mountScrollChild, "mount", "Mounts")
        druidBook = createAssignmentBook(druidScrollChild, "druid", "Druid Forms")
    end

    local mountEntities = {}
    for _, mountData in ipairs(mountEntries) do
        if mountData.spellID then
            table.insert(mountEntities, {
                id = mountData.spellID,
                name = mountData.name,
                icon = mountData.icon,
                isCollected = mountData.isCollected,
            })
        end
    end
    mountBook.setEntities(mountEntities, MountMusicDB.selectedMountAssignmentID)

    local _, classToken = UnitClass("player")
    local formEntities = {}
    if classToken == "DRUID" then
        for _, form in ipairs(druidFormDefinitions) do
            table.insert(formEntities, {
                id = form.name,
                name = form.name,
                icon = getDruidFormIcon(form),
            })
        end
    end
    druidBook.setEntities(formEntities, MountMusicDB.selectedDruidFormAssignmentName)
    refreshMusicPlayer()
end

local function restoreMusicAfterFormChange()
    if not MountMusicDB.musicStoppedByAddon then
        return
    end

    SetCVar("Sound_EnableMusic", "1")
    MountMusicDB.musicStoppedByAddon = nil
    pausedTargetKey = nil
    setPlaybackButtonVisual(false)
end

-- ---------------------------------------------------------------------------
-- PLAYBACK ACTIONS
-- ---------------------------------------------------------------------------
stopMusicNow = function()
    pausedTargetKey = getActiveMusicTarget()
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

updateMusicPlayback = function()
    if formTransitionPending then
        return
    end
    if MountMusicDB.autoPlayEnabled then
        refreshMusicPlayer()
        if MountMusicDB.musicStoppedByAddon or GetCVar("Sound_EnableMusic") == "0" then
            return
        end
        if not currentMusicFileID then
            playAutoplayTrack()
        end
        return
    end
    local targetKey, selection, targetType = getActiveMusicTarget()
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

-- ---------------------------------------------------------------------------
-- FORM AND AUTO-PLAY WATCHERS
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- EVENT HANDLING
-- ---------------------------------------------------------------------------
local function onEvent(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MountMusic" then
            print("MountMusic version 1.0.0 loaded. Enjoy!")
            print("Click the Mount Music minimap icon to open and load settings.")
        end
    end
    if event == "PLAYER_LOGOUT" then
        local icon = LDBIcon:GetMinimapButton("MountMusic")
        local minimapPosition = icon and icon.db and icon.db.minimapPos
            or icon and icon.minimapPos
        if type(minimapPosition) == "number" then
            saveMinimapButtonPosition(minimapPosition)
        end
        if type(MountMusicDB.pendingMountMusicDraft) == "table"
            or type(MountMusicDB.pendingDruidFormMusicDraft) == "table" then
            saveDraftMusicSelections()
        end
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
end

-- Register addon events
mountMusicSettingsFrame:RegisterEvent("ADDON_LOADED")
mountMusicSettingsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mountMusicSettingsFrame:RegisterEvent("PLAYER_LOGOUT")
mountMusicSettingsFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
mountMusicSettingsFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
mountMusicSettingsFrame:RegisterUnitEvent("UNIT_AURA", "player")
mountMusicSettingsFrame:SetScript("OnEvent", onEvent)
