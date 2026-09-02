-- PvPAnnouncement.lua
-- Shows a popup warning when the player targets a PvP-flagged unit.

GuildWeave.PvPAnnouncement = {}
local Localization = GuildWeave.Localization

GuildWeave.lastPvPAlert = {}

local frame = CreateFrame("Frame", "GuildWeavePvPFrame", UIParent, "BackdropTemplate")
frame:SetSize(320, 110)
frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:Hide()

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", frame, "TOP", 0, -20)

local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
nameText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 25)

function GuildWeave.PvPAnnouncement:Initialize()
    frame:SetBackdrop(GuildWeave.Constants.DARK_BACKDROP)
    frame:SetBackdropBorderColor(1, 0.55, 0.73, 1)
    frame:SetBackdropColor(0, 0, 0, 0.30)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
    GuildWeave:RestoreFramePosition(frame, "pvpwarning_position", "CENTER", 0, 0)
    titleText:SetTextColor(1, 0.55, 0.73)
    nameText:SetTextColor(1, 0.82, 0)

    GuildWeave.EventManager:RegisterHandler("PLAYER_TARGET_CHANGED",
        function()
            if GuildWeaveDB["pvp_alert"] == false then return end
            if not GuildWeave:IsInBattleground() then
                GuildWeave.PvPAnnouncement:CheckTargetPvP()
            end
        end, 0, "PvPTargetChecker")
end

function GuildWeave.PvPAnnouncement:CheckTargetPvP()
    local unit = "target"
    if not UnitExists(unit) or not UnitIsPVP(unit) then return end

    local name = UnitName(unit) or Localization["DEATH_UNKNOWN"]

    if not UnitIsPlayer(unit) then
        local playerFaction = UnitFactionGroup("player")
        local targetFaction = UnitFactionGroup(unit)
        if targetFaction and targetFaction ~= playerFaction then
            GuildWeave.PvPAnnouncement:ShowWarning(name .. " (" .. targetFaction .. " NPC)")
        end
        return
    end

    local now = GetTime()
    local lastAlert = GuildWeave.lastPvPAlert[name] or 0

    if (now - lastAlert) > GuildWeave.Constants.COOLDOWNS.PVP_ALERT then
        GuildWeave.lastPvPAlert[name] = now
        GuildWeave.PvPAnnouncement:ShowWarning(string.format(Localization["PVP_FLAGGED"], name))
    end
end

function GuildWeave.PvPAnnouncement:ShowWarning(text)
    titleText:SetText(Localization["PVP_WARNING_TITLE"])
    nameText:SetText(text)
    frame:SetAlpha(1)
    frame:Show()

    if GuildWeaveDB["pvp_alert_sound"] then
        PlaySound(GuildWeave.Constants.SOUNDS.PVP_ALERT)
    end

    C_Timer.After(1, function()
        UIFrameFadeOut(frame, 1, 1, 0)
        C_Timer.After(1, function()
            frame:Hide()
        end)
    end)
end
