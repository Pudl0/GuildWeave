-- GenericPopup.lua
-- Rule-block and cap notification popup.

GuildWeave.Popup = {}

local frame = CreateFrame("Frame", "GuildWeavePopupFrame", UIParent, "BackdropTemplate")
frame:SetSize(370, 160)
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:Hide()

local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetSize(40, 40)
icon:SetPoint("TOP", frame, "TOP", 0, -30)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", icon, "BOTTOM", 0, -5)

local message = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
message:SetSize(320, 0)
message:SetJustifyH("CENTER")
message:SetPoint("TOP", title, "BOTTOM", 0, -5)

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
