BINDING_NAME_GUILDWEAVE_TOGGLE_GUILDPANEL = "Guild Panel"
BINDING_NAME_GUILDWEAVE_TOGGLE_OFFICERPANEL = "Officer Panel"

function GuildWeave_Binding_ToggleGuildPanel()
    GuildWeave.GuildPanel:Toggle()
end

function GuildWeave_Binding_ToggleOfficerPanel()
    GuildWeave.OfficerPanel:Toggle()
end
