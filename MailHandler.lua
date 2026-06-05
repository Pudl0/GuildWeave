GuildWeave.MailHandler = {}
local Localization = GuildWeave.Localization

function GuildWeave.MailHandler:HideMinimapMail()
	local mail = MiniMapMailFrame or MiniMapMailIcon
	if not mail then return end

	-- Stop Blizzard from updating/showing it
	if mail.UnregisterAllEvents then
		mail:UnregisterAllEvents()
	end

	-- Hide it now
	mail:Hide()

	-- Make it non-interactive
	mail:SetAlpha(0)
	mail:SetScript("OnEnter", nil)
	mail:SetScript("OnLeave", nil)

	-- Prevent future :Show() calls
	if mail.Show then
		mail.Show = function() end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MAIL_INBOX_UPDATE")

-- Returns true if the mail at index is safe to leave in the inbox (self, guild member, system, or already read).
local function IsSafeSender(index)
    -- indices: 3=sender, 9=wasRead, 12=canReply, 13=isGM
    local _, _, sender, _, _, _, _, _, wasRead, _, _, canReply, isGM = GetInboxHeaderInfo(index)

    if isGM then return true end          -- official Blizzard mail
    if not canReply then return true end  -- system mail (AH, postmaster, NPCs)
    if not sender or sender == "" then return true end
    if sender == UnitName("player") then return true end
    if wasRead then return true end
    if GuildWeave.GuildCache:IsGuildMember(sender) then return true end

    return false
end

-- Warning popup shown when a player clicks mail from a non-guild member.
StaticPopupDialogs["CONFIRM_DELETE_NON_GUILD_MAIL"] = {
    text = Localization["MAIL_NON_GUILD_WARNING"],
    button1 = Localization["MAIL_DELETE_BTN"],
    button2 = Localization["MAIL_CANCEL_BTN"],
    OnAccept = function(_, data)
        if data and data.slot then
            if InboxItemCanDelete(data.slot) then
                DeleteInboxItem(data.slot)
            else
                ReturnInboxItem(data.slot)
            end
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Disables "Open All" buttons to prevent accidental bulk-opens
local function KillButton(btn)
    if not btn or btn.isDead then return end
    btn:Disable()
    btn:SetAlpha(0.3)

    -- Invisible blocker so other addons can't click through to it either
    local blocker = CreateFrame("Button", nil, btn)
    blocker:SetAllPoints()
    blocker:SetFrameLevel(btn:GetFrameLevel() + 2)
    blocker:EnableMouse(true)
    blocker:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(Localization["MAIL_BUTTON_LOCKED"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    blocker:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Prevent the button from being re-enabled
    hooksecurefunc(btn, "Enable", function() btn:Disable() end)
    btn.isDead = true
end

-- Scans the current inbox page and applies guards/colours per sender
local function UniversalScan()
    if not MailFrame:IsVisible() then return end

    local numItems = GetInboxNumItems()
    local itemsPerPage = INBOXITEMS_TO_DISPLAY
    local currentPage = InboxFrame.pageNum or 1

    for i = 1, itemsPerPage do
        local mailIndex = ((currentPage - 1) * itemsPerPage) + i

        if mailIndex <= numItems then
            local item = _G["MailItem"..i]
            local senderText = _G["MailItem"..i.."Sender"]
            local button = _G["MailItem"..i.."Button"]

            if item and button then
                local _, _, _, _, _, _, _, itemCount = GetInboxHeaderInfo(mailIndex)

                if not IsSafeSender(mailIndex) then
                    -- Non-guild sender: highlight name red
                    if senderText then senderText:SetTextColor(1, 0, 0) end

                    if not button.mailGuard then
                        button.mailGuard = CreateFrame("Button", nil, button)
                        button.mailGuard:SetAllPoints()
                        button.mailGuard:SetFrameLevel(button:GetFrameLevel() + 10)
                        button.mailGuard:EnableMouse(true)
                    end

                    button.mailGuard:SetScript("OnClick", function()
                        local d = StaticPopup_Show("CONFIRM_DELETE_NON_GUILD_MAIL")
                        if d then d.data = {slot = mailIndex, itemCount = itemCount} end
                    end)
                    button.mailGuard:Show()
                else
                    -- Safe sender: gold name, no guard
                    if senderText then senderText:SetTextColor(1, 0.8, 0) end
                    if button.mailGuard then button.mailGuard:Hide() end
                end
            end
        else
            -- Fewer than itemsPerPage mails on the last page — hide guards on empty slots
            local button = _G["MailItem"..i.."Button"]
            if button and button.mailGuard then button.mailGuard:Hide() end
        end
    end

    -- Disable "Open All" buttons from mail addons
    if MailFrame and MailFrame:IsVisible() then
        local mailButtons = {
            "OpenAllMail",
            "AutoLootMailButton"
        }

        for _, btnName in ipairs(mailButtons) do
            local btn = _G[btnName]
            if btn and btn:IsVisible() then
                KillButton(btn)
            end
        end

        -- Scan MailFrame children for open-all buttons by text or name
        local f = MailFrame:GetChildren()
        if f then
            for i = 1, select("#", MailFrame:GetChildren()) do
                local child = select(i, MailFrame:GetChildren())
                if child and child:IsObjectType("Button") and child:IsVisible() then
                    local txt = child.GetText and child:GetText()
                    local name = child.GetName and child:GetName() or ""
                    if txt and (txt:find("Open All") or txt:find("Alle öffnen")) or
                       name:find("OpenAll") then
                        if not name:find("MailItem") then
                            KillButton(child)
                        end
                    end
                end
            end
        end
    end
end

local function DelayedScan()
    C_Timer.After(0.05, UniversalScan)
end

frame:SetScript("OnEvent", function(_, event)
    if event == "MAIL_INBOX_UPDATE" then
        DelayedScan()
    end
end)

MailFrame:HookScript("OnShow", DelayedScan)

-- Called by Blizzard whenever the inbox visually refreshes
hooksecurefunc("InboxFrame_Update", function()
    DelayedScan()
end)

if MailFrameTab1 then
    MailFrameTab1:HookScript("OnClick", DelayedScan)
end

local errorListener = CreateFrame("Frame")
errorListener:RegisterEvent("UI_ERROR_MESSAGE")
errorListener:SetScript("OnEvent", function(_, _, _, msg)
    if msg == ERR_MAIL_TARGET_NOT_FOUND then
        if UIErrorsFrame then UIErrorsFrame:Clear() end
        GuildWeave:Print(Localization["MAIL_DELETED_ERROR"])
    end
end)
