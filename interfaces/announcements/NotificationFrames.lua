-- NotificationFrames.lua
-- Shared factory for the animated announcement popups (death, level-up, cap).
-- The paired DeathAnnouncement / LevelUpAnnouncement files call this to build
-- their frame, then set backdrop colours, text, and animation start-delays.

-- Builds a 380x200 popup: 96px icon on top, large header, wrapped body text,
-- and a 4-step animation group. Returns the frame with these fields:
--   .icon .header .bodyText .animGroup .moveDownAgain .fadeOut
-- The frame is created hidden and is NOT positioned or backdropped here.
function GuildWeave.CreateAnnouncementFrame(name, frameLevel)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(380, 200)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(frameLevel)
    f:Hide()

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(96, 96)
    icon:SetPoint("TOP", f, "TOP", 0, -14)
    f.icon = icon

    local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOP", icon, "BOTTOM", 0, -20)
    f.header = header

    local bodyText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bodyText:SetJustifyH("CENTER")
    bodyText:SetJustifyV("TOP")
    bodyText:SetPoint("TOP",   header, "BOTTOM", 0, -8)
    bodyText:SetPoint("LEFT",  f, "LEFT",  12, 0)
    bodyText:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    bodyText:SetShadowColor(0, 0, 0, 1)
    bodyText:SetShadowOffset(1, -1)
    f.bodyText = bodyText

    -- Animation: slide down, hold, slide down again + fade out.
    -- Start-delays for moveDownAgain/fadeOut are set per announcement type by the caller.
    local ag = f:CreateAnimationGroup()

    local moveDown = ag:CreateAnimation("Translation")
    moveDown:SetDuration(0.6)
    moveDown:SetOffset(0, -50)
    moveDown:SetSmoothing("OUT")

    local moveDownAgain = ag:CreateAnimation("Translation")
    moveDownAgain:SetDuration(0.8)
    moveDownAgain:SetOffset(0, -50)
    moveDownAgain:SetSmoothing("IN")

    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetDuration(0.5)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetSmoothing("IN")

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetDuration(1.5)
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetSmoothing("OUT")

    f.animGroup     = ag
    f.moveDownAgain = moveDownAgain
    f.fadeOut       = fadeOut

    return f
end
