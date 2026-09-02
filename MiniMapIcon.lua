-- MiniMapIcon.lua
-- Creates and manages the minimap icon for the addon

local LDB    = LibStub("LibDataBroker-1.1", true)
local DBIcon = LibStub("LibDBIcon-1.0", true)
local Localization = GuildWeave.Localization

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
                if IsInGuild() then
                    GuildWeave.OfficerPanel:Toggle()
                end
            end
        end,
        OnEnter = function(selfFrame)
            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
            GameTooltip:AddLine("GuildWeave", 1, 0.7, 0.9)
            GameTooltip:AddLine(Localization["LBL_VERSION_COLON"] .. " " .. (GuildWeave.version or Localization["DEATH_UNKNOWN"]), 1, 1, 1)
            GameTooltip:AddLine(Localization["MINIMAP_LEFT"], 1, 1, 1)
            GameTooltip:AddLine(Localization["MINIMAP_SHIFT_LEFT"], 0.8, 0.8, 0.8)
            if IsInGuild() then
                GameTooltip:AddLine(Localization["MINIMAP_RIGHT"], 0.8, 0.8, 0.8)
            end
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
        GuildWeaveDB = GuildWeaveDB or {}
        GuildWeaveDB.minimap = GuildWeaveDB.minimap or { hide = false }
        DBIcon:Register("GuildWeave", GuildWeave.minimapDataObject, GuildWeaveDB.minimap)
        GuildWeave.minimapRegistered = true
    end
end
