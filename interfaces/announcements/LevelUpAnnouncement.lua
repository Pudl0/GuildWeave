-- LevelUpAnnouncement.lua
-- Displays animated level-up and cap announcements when guild members reach milestones.
-- Routes through AnnouncementQueue so it never overrides death or other announcements.
-- LevelUpFrame is defined in NotificationFrames.xml (AnnouncementFrameTemplate).

GuildWeave.LevelUpAnnouncement = {}
local Localization = GuildWeave.Localization

-- Named children from the XML template (expanded from $parent → LevelUpFrame).
-- AnimationGroup is globally named; individual animations are retrieved via GetAnimations().
local icon      = _G["LevelUpFrameIcon"]
local header    = _G["LevelUpFrameHeader"]
local bodyText  = _G["LevelUpFrameBodyText"]
local animGroup = _G["LevelUpFrameAnimGroup"]
-- XML order: moveDown(1), moveDownAgain(2), fadeIn(3), fadeOut(4)
local anims         = {animGroup:GetAnimations()}
local moveDownAgain = anims[2]
local fadeOut       = anims[4]

-- Configure icon (colours and delays are set per-call in ShowDirect).
GuildWeave:RestoreFramePosition(LevelUpFrame, "levelupannouncement_position", "TOP", 0, 0)
icon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)
bodyText:SetShadowColor(0, 0, 0, 1)
bodyText:SetShadowOffset(1, -1)

-- Notify the queue when the animation finishes.
animGroup:SetScript("OnFinished", function()
	LevelUpFrame:Hide()
	GuildWeave.AnnouncementQueue:Finished()
end)

-- Internal: actually show the frame (called from inside a queue slot).
-- levelup: ~6 s total (delay 4.5), cap: ~9 s total (delay 7.5).
local function ShowDirect(name, level, isCap)
	LevelUpFrame:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
	if isCap then
		moveDownAgain:SetStartDelay(7.5)
		fadeOut:SetStartDelay(7.5)
		LevelUpFrame:SetBackdropColor(0, 0.06, 0.12, 0.92)
		LevelUpFrame:SetBackdropBorderColor(0.4, 1, 1, 1)
		header:SetText(Localization["CAP_ANNOUNCEMENT_HEADER"])
		header:SetTextColor(0.4, 1, 1, 1)
		bodyText:SetTextColor(0.4, 1, 1, 1)
	else
		moveDownAgain:SetStartDelay(4.5)
		fadeOut:SetStartDelay(4.5)
		LevelUpFrame:SetBackdropColor(0.1, 0.07, 0, 0.92)
		LevelUpFrame:SetBackdropBorderColor(1, 0.84, 0, 1)
		header:SetText(Localization["LEVELUP_ANNOUNCEMENT_HEADER"])
		header:SetTextColor(1, 0.84, 0, 1)
		bodyText:SetTextColor(1, 0.84, 0, 1)
	end
	bodyText:SetText(string.format(Localization["LEVELUP_ANNOUNCEMENT_BODY"], GuildWeave:SanitizeText(name), level))
	LevelUpFrame:SetAlpha(0)
	LevelUpFrame:Show()
	animGroup:Stop()
	animGroup:Play()
end

-- Public: queue a milestone level-up announcement (gold theme, ~6 s).
function GuildWeave.LevelUpAnnouncement:ShowMessage(name, level)
	if not GuildWeaveDB["levelmessages"] then return end
	GuildWeave.AnnouncementQueue:Push(function()
		ShowDirect(name, level, false)
		if GuildWeaveDB["levelmessages_sound"] then
			GuildWeave:PlayAnnouncementSound(GuildWeave.Constants.SOUNDS.LEVELUP_ANNOUNCEMENT)
		end
	end)
end

-- Public: queue a cap announcement (cyan theme, ~9 s).
function GuildWeave.LevelUpAnnouncement:ShowCap(name, level)
	if not GuildWeaveDB["capmessages"] then return end
	GuildWeave.AnnouncementQueue:Push(function()
		ShowDirect(name, level, true)
		if GuildWeaveDB["capmessages_sound"] then
			GuildWeave:PlayAnnouncementSound(GuildWeave.Constants.SOUNDS.CAP_ANNOUNCEMENT)
		end
	end)
end
