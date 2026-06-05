-- MiniMapIcon.lua
-- Creates and manages the minimap icon for the addon

local LDB    = LibStub("LibDataBroker-1.1", true)
local DBIcon = LibStub("LibDBIcon-1.0", true)

if LDB then
    GuildWeave.minimapDataObject = LDB:NewDataObject("GuildWeave", {
        type  = "launcher",
        label = "GuildWeave",
        icon  = GuildWeave.Constants.MEDIA.MINIMAP_ICON,
        OnClick = function(clickedFrame, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    GuildWeave:ToggleDeathlog()
                else
                    GuildWeave.GuildPanel:Toggle()
                end
            elseif button == "RightButton" then
                GuildWeave.OfficerPanel:Toggle()
            end
        end,
        OnEnter = function(selfFrame)
            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
            GameTooltip:AddLine("GuildWeave", 1, 0.7, 0.9)
            GameTooltip:AddLine("Version: " .. (GuildWeave.version or "Unknown"), 1, 1, 1)
            GameTooltip:AddLine("Left-click: Show guild panel", 1, 1, 1)
            GameTooltip:AddLine("Shift+Left-click: Show death log", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Right-click: Officer panel", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end,
        OnLeave = function()
            GameTooltip:Hide()
        end
    })
end

function GuildWeave:InitMinimapIcon()
    if not DBIcon or not GuildWeave.minimapDataObject then return end

    if not GuildWeave.minimapRegistered then
        GuildWeave.db = GuildWeave.db or {}
        GuildWeave.db.minimap = GuildWeave.db.minimap or { hide = false }
        DBIcon:Register("GuildWeave", GuildWeave.minimapDataObject, GuildWeave.db.minimap)
        GuildWeave.minimapRegistered = true
    end
end
