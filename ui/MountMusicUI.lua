local mountMusicSettingsFrame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")
local mmFrameWidth            = 800
local mmFrameHeight           = 600

--Set Title of the Mount Music setting frame
local title                   = mountMusicSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -4) -- a little padding from the very top
title:SetJustifyH("CENTER")
title:SetText("Mount Music Settings")
local file, _, flags = title:GetFont()
title:SetFont(file, 14, flags)

-- Ensure saved variable exists
MountMusicDB = MountMusicDB or {}


mountMusicSettingsFrame:SetPoint("CENTER")
mountMusicSettingsFrame:SetSize(mmFrameWidth, mmFrameHeight)

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


local ScrollBox = CreateFrame("Frame", nil, mountMusicSettingsFrame, "WowScrollBoxList")
ScrollBox:SetPoint("LEFT", 20, 0)
ScrollBox:SetSize(300, 480)

local ScrollBar = CreateFrame("EventFrame", nil, mountMusicSettingsFrame, "MinimalScrollBar")
ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT", 20, 0)
ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT", 20, 0)


local ScrollView = CreateScrollBoxListLinearView()

ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)


local function Initializer(button, data)
    if not button.initialized then
        button.initialized = true

        button.bg = CreateFrame("Frame", nil, button, "InsetFrameTemplate")
        button.bg:SetAllPoints(button)

        button.iconBtn = CreateFrame("Button", nil, button)
        button.iconBtn:SetSize(40, 40)
        button.iconBtn:SetPoint("LEFT", button, "LEFT", 5, 0)

        button.icon = button.iconBtn:CreateTexture(nil, "ARTWORK")
        button.icon:SetAllPoints(button.iconBtn)

        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.text:SetPoint("TOPLEFT", button.iconBtn, "TOPRIGHT", 6, 0)
        button.text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -8, 0)
        button.text:SetWordWrap(true)
        button.text:SetJustifyH("CENTER")
        button.text:SetJustifyV("MIDDLE")

        button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")

        local selectedTex = button:CreateTexture(nil, "OVERLAY")
        selectedTex:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue")
        selectedTex:SetBlendMode("ADD")
        selectedTex:SetAllPoints(button)
        selectedTex:Hide()
        button.selectedTex = selectedTex

        button:SetScript("OnClick", function(self)
            local isSelected = self.selectedTex:IsShown()
            if not isSelected then
                self.selectedTex:SetShown(true)
            else
                self.selectedTex:SetShown(false)
            end
        end)
    end

    button.data = data
    button.icon:SetTexture(data.Icon)
    button.text:SetText(data.MountName)
end

-- The first argument here can either be a frame type or frame template. We're just passing the "UIPanelButtonTemplate" template here
ScrollView:SetElementInitializer("button", Initializer)

-- -- Optional Resetter function which you can use to reset your frame or data element.
-- local function Resetter(button, data)

-- end
-- ScrollView:SetElementResetter(Resetter)
ScrollView:SetElementExtent(50)
local DataProvider = CreateDataProvider()
ScrollView:SetDataProvider(DataProvider)


local mountIDs = C_MountJournal.GetMountIDs()

--  local creatureName, creatureID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected =
--         C_MountJournal.GetDisplayedMountInfo(1)

local data = {}
for mountID, value in pairs(mountIDs) do
    local creatureName, spellID, icon, _, _, _, _, _, _, shouldHideOnChar, isCollected = C_MountJournal.GetMountInfoByID(
        mountID)
    if creatureName and not shouldHideOnChar then
        table.insert(data, {
            MountID = mountID,
            MountName = creatureName,
            Icon = icon,
            IsCollected = isCollected,
        })
    end
end

DataProvider:InsertTable(data)


-- Creating our search box, whenever the user changes the text in this box, it will refresh the display
local SearchBox = CreateFrame("EditBox", nil, mountMusicSettingsFrame, "SearchBoxTemplate")
SearchBox:SetPoint("TOPLEFT", mountMusicSettingsFrame, 30, -30)
SearchBox:SetAutoFocus(false)
SearchBox:SetSize(145, 24)


local filterState = {
    collectedOnly = false,
    favoritesOnly = false,
}

local filterBtn = CreateFrame("DropdownButton", nil, mountMusicSettingsFrame, "WowStyle1FilterDropdownTemplate")
filterBtn:SetSize(95, 22)
filterBtn:SetPoint("TOPRIGHT", mountMusicSettingsFrame, "TOPRIGHT", -30, -30)
filterBtn:SetText("Filter")

-- Setup the dropdown menu options
filterBtn:SetupMenu(function(dropdown, rootDescription)
    rootDescription:CreateCheckbox("Collected Only", function()
        return filterState.collectedOnly
    end, function()
        filterState.collectedOnly = not filterState.collectedOnly
        -- RefreshMountList() -- Call your function that rebuilds the DataProvider
    end)

    rootDescription:CreateCheckbox("Favorites Only", function()
        return filterState.favoritesOnly
    end, function()
        filterState.favoritesOnly = not filterState.favoritesOnly
        -- RefreshMountList()
    end)
end)


local section = CreateFrame("Frame", nil, mountMusicSettingsFrame)
section:SetSize(300, 28)
section.isExpanded = false

local header = CreateFrame("Button", nil, section, "BackdropTemplate")
header:SetPoint("RIGHT", 0, 0)
header:SetPoint("RIGHT", 0, 0)
header:SetHeight(28)

header.label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header.label:SetPoint("LEFT", 8, 0)
header.label:SetText(titleText)

header.chevron = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
header.chevron:SetPoint("RIGHT", -8, 0)
header.chevron:SetText("+")

local body = CreateFrame("Frame", nil, section)
body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
body:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
body:SetHeight(bodyHeight or 80)
body:Hide()

function section:SetExpanded(expanded)
    self.isExpanded = not not expanded
    body:SetShown(self.isExpanded)
    header.chevron:SetText(self.isExpanded and "-" or "+")
    if self.isExpanded then
        self:SetHeight(header:GetHeight() + body:GetHeight() + 2)
    else
        self:SetHeight(header:GetHeight())
    end
    if parent.LayoutSections then
        parent:LayoutSections()
    end
end

header:SetScript("OnClick", function()
    section:SetExpanded(not section.isExpanded)
end)

section.header = header
section.body = body


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



local minibtn = CreateFrame("Button", nil, Minimap)
minibtn:SetFrameLevel(8)
minibtn:SetSize(32, 32)
minibtn:SetMovable(true)

minibtn:SetNormalTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetPushedTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Yellow.png")
