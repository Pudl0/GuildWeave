-- DeathAnnouncement.lua
-- Displays animated death announcements when guild members die.

GuildWeave.DeathAnnouncement = {}
local Localization = GuildWeave.Localization

-- ── Full popup ───────────────────────────────────────────────────────────────

local frame     = GuildWeave.CreateAnnouncementFrame("DeathMessageFrame", 1000)
local bodyText  = frame.bodyText
local animGroup = frame.animGroup

frame:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
frame:SetBackdropColor(0.12, 0, 0, 0.92)
frame:SetBackdropBorderColor(1, 0.15, 0.15, 1)
GuildWeave:RestoreFramePosition(frame, "deathannouncement_position", "TOP", 0, 0)
frame.icon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)
frame.header:SetText(Localization["DEATH_ANNOUNCEMENT_HEADER"])
frame.header:SetTextColor(1, 0.2, 0.2, 1)
bodyText:SetTextColor(1, 0.1, 0.1, 1)

-- Animation delays are fixed for death announcements (~5 s total).
frame.moveDownAgain:SetStartDelay(3.5)
frame.fadeOut:SetStartDelay(3.5)

animGroup:SetScript("OnFinished", function()
	frame:Hide()
	GuildWeave.AnnouncementQueue:Finished()
end)

-- Shows the death message with animation (routed through the announcement queue).
function GuildWeave.DeathAnnouncement:ShowDeathMessage(message)
	if not GuildWeaveDB["deathmessages"] then return end
	GuildWeave.AnnouncementQueue:Push(function()
		bodyText:SetText(GuildWeave:SanitizeText(message))
		frame:SetAlpha(0)
		frame:Show()
		animGroup:Stop()
		animGroup:Play()
		if GuildWeaveDB["deathmessages_sound"] then
			GuildWeave:PlayAnnouncementSound(GuildWeave.Constants.SOUNDS.DEATH_ANNOUNCEMENT)
		end
	end)
end

-- ── Compact death notice ─────────────────────────────────────────────────────
-- Shown top-right instead of the full popup when the local player is in an
-- instance (or always, via the deathframe_always_small option) so a full-screen
-- popup never lands mid-pull. Name only, no sound; full detail stays in the log.

local smallFrame = CreateFrame("Frame", "DeathMessageSmallFrame", UIParent, "BackdropTemplate")
smallFrame:SetSize(220, 40)
smallFrame:SetFrameStrata("FULLSCREEN_DIALOG")
smallFrame:SetFrameLevel(1000)
smallFrame:Hide()
smallFrame:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
smallFrame:SetBackdropColor(0.12, 0, 0, 0.85)
smallFrame:SetBackdropBorderColor(1, 0.15, 0.15, 1)
GuildWeave:RestoreFramePosition(smallFrame, "smalldeathannouncement_position", "TOPRIGHT", -20, -200)

local smallText = smallFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
smallText:SetPoint("TOPLEFT",     smallFrame, "TOPLEFT",      8, -6)
smallText:SetPoint("BOTTOMRIGHT", smallFrame, "BOTTOMRIGHT", -8,  6)
smallText:SetJustifyH("CENTER")
smallText:SetJustifyV("MIDDLE")
smallText:SetTextColor(1, 0.3, 0.3, 1)

local smallAnimGroup = smallFrame:CreateAnimationGroup()
local smallFadeIn = smallAnimGroup:CreateAnimation("Alpha")
smallFadeIn:SetDuration(0.3)
smallFadeIn:SetFromAlpha(0)
smallFadeIn:SetToAlpha(1)
local smallFadeOut = smallAnimGroup:CreateAnimation("Alpha")
smallFadeOut:SetStartDelay(2.5)
smallFadeOut:SetDuration(0.7)
smallFadeOut:SetFromAlpha(1)
smallFadeOut:SetToAlpha(0)

smallAnimGroup:SetScript("OnFinished", function()
	smallFrame:Hide()
	GuildWeave.AnnouncementQueue:Finished()
end)

-- Shows the compact death notice (routed through the announcement queue).
function GuildWeave.DeathAnnouncement:ShowSmallDeathMessage(name)
	if not GuildWeaveDB["deathmessages"] then return end
	GuildWeave.AnnouncementQueue:Push(function()
		smallText:SetText(string.format(Localization["DEATH_SMALL_MSG"], GuildWeave:SanitizeText(name)))
		smallFrame:SetAlpha(0)
		smallFrame:Show()
		smallAnimGroup:Stop()
		smallAnimGroup:Play()
	end)
end
