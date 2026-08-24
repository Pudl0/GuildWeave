-- GenericPopup.lua
-- Rule-block and cap notification popup. Frame defined in GenericPopup.xml.

GuildWeave.Popup = {}

local frame   = GuildWeavePopupFrame
local icon    = _G["GuildWeavePopupFrameIcon"]
local title   = _G["GuildWeavePopupFrameTitle"]
local message = _G["GuildWeavePopupFrameMessage"]
local activeTimer

frame:SetBackdrop(GuildWeave.Constants.BACKDROP)
frame:SetBackdropColor(0, 0, 0, 0.50)
frame:SetBackdropBorderColor(1, 0.55, 0.73, 0)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
GuildWeave:RestoreFramePosition(frame, "genericpopup_position", "TOP", 0, -150)
icon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
title:SetTextColor(1, 0.55, 0.73)

-- options: { title (required), message (required), displayTime (default 3) }
function GuildWeave.Popup:Show(options)
    if not options or not options.title or not options.message then return end

    if activeTimer then activeTimer:Cancel() end

    title:SetText(options.title)
    message:SetText(options.message)
    frame:SetAlpha(1)
    frame:Show()

    activeTimer = C_Timer.NewTimer(options.displayTime or 3, function()
        UIFrameFadeOut(frame, 1, 1, 0)
        C_Timer.After(1, function() frame:Hide() end)
    end)
end

function GuildWeave.Popup:HideAll()
    if activeTimer then activeTimer:Cancel() end
    frame:Hide()
end
