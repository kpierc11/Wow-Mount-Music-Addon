local mount_music_settings_frame = CreateFrame("Frame", "MountMusicOptionsPanel", InterfaceOptionsFramePanelContainer)

mount_music_settings_frame.panel = CreateFrame("Frame")

mount_music_settings_frame.panel.name = "Mount Music"

local cb = CreateFrame("CheckButton", nil, mount_music_settings_frame.panel, "InterfaceOptionsCheckButtonTemplate")
cb:SetPoint("TOPLEFT", 20, -20)

InterfaceOptions_AddCategory(mount_music_settings_frame.panel)