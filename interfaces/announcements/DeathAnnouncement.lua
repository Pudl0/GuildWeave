-- DeathAnnouncement.lua
-- Displays animated death announcements when guild members die.
-- DeathMessageFrame is defined in NotificationFrames.xml (AnnouncementFrameTemplate).

GuildWeave.DeathAnnouncement = {}
local Localization = GuildWeave.Localization

-- Named children from the XML template (expanded from $parent → DeathMessageFrame).
-- AnimationGroup is globally named; individual animations are retrieved via GetAnimations().
local icon      = _G["DeathMessageFrameIcon"]
local header    = _G["DeathMessageFrameHeader"]
local bodyText  = _G["DeathMessageFrameBodyText"]
local animGroup = _G["DeathMessageFrameAnimGroup"]
-- XML order: moveDown(1), moveDownAgain(2), fadeIn(3), fadeOut(4)
local anims         = {animGroup:GetAnimations()}
local moveDownAgain = anims[2]
local fadeOut       = anims[4]

-- Configure backdrop, colours, and static text.
DeathMessageFrame:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
DeathMessageFrame:SetBackdropColor(0.12, 0, 0, 0.92)
DeathMessageFrame:SetBackdropBorderColor(1, 0.15, 0.15, 1)
GuildWeave:RestoreFramePosition(DeathMessageFrame, "deathannouncement_position", "TOP", 0, 0)
icon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)
header:SetText(Localization["DEATH_ANNOUNCEMENT_HEADER"])
header:SetTextColor(1, 0.2, 0.2, 1)
bodyText:SetTextColor(1, 0.1, 0.1, 1)
bodyText:SetShadowColor(0, 0, 0, 1)
bodyText:SetShadowOffset(1, -1)

-- Animation delays are fixed for death announcements (~5 s total).
moveDownAgain:SetStartDelay(3.5)
fadeOut:SetStartDelay(3.5)

-- Notify the queue when the animation finishes.
animGroup:SetScript("OnFinished", function()
	DeathMessageFrame:Hide()
	GuildWeave.AnnouncementQueue:Finished()
end)

-- Shows the death message with animation (routed through the announcement queue).
function GuildWeave.DeathAnnouncement:ShowDeathMessage(message)
	if not GuildWeaveDB["deathmessages"] then return end
	GuildWeave.AnnouncementQueue:Push(function()
		bodyText:SetText(GuildWeave:SanitizeText(message))
		DeathMessageFrame:SetAlpha(0)
		DeathMessageFrame:Show()
		animGroup:Stop()
		animGroup:Play()
		if GuildWeaveDB["deathmessages_sound"] then
			GuildWeave:PlayAnnouncementSound(GuildWeave.Constants.SOUNDS.DEATH_ANNOUNCEMENT)
		end
	end)
end
