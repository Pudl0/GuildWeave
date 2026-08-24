-- Initialize EventManager first
GuildWeave.EventManager:Initialize()

-- Initialize core addon modules.
GuildWeave.Global:Initialize()
GuildWeave.GuildCache:Initialize()
GuildWeave.Death:Initialize()
GuildWeave.Rules:Initialize()
GuildWeave.LevelUps:Initialize()
GuildWeave.PvPAnnouncement:Initialize()
GuildWeave.Debug:Initialize()
GuildWeave.GuildProfiles:Initialize()
GuildWeave.Broadcast:Initialize()
GuildWeave:InitializeProfileData()
GuildWeave:InitializeSetupWizard()
GuildWeave.GuildPanel:Initialize()

GuildWeave:InitializeOptionsDB()

-- Initialize minimap icon functionality.
GuildWeave:InitMinimapIcon()