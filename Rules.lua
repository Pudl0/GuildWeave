-- Global table for rules
local Localization = GuildWeave.Localization
GuildWeave.Rules = {}

GuildWeave.InfoRules = {
    mailRule = 1,
    auctionHouseRule = 1,
    tradeRule = 1,
    groupingRule = 1
}

-- Current level cap (fetched from guild info)
GuildWeave.Rules.CurrentCap = 0

function GuildWeave.Rules:GetRules(callback)
    local text = GetGuildInfoText()
    if text == nil or text == "" then
        if callback then
            C_Timer.After(2, function()
                GuildWeave.Rules:GetRules(callback)
            end)
            return nil
        else
            C_Timer.After(2, function()
                GuildWeave.Rules:GetRules()
            end)
            return nil
        end
    end

    if callback then
        callback(text)
        return nil
    end

    return text
end

function GuildWeave.Rules:LoadFromGuildInfo()
    GuildWeave.Rules:GetRules(function(text)
        if not text then return end

        -- Parse four individual rule digits: GuildWeave:1111
        local mailRule, auctionHouseRule, tradeRule, groupingRule =
            text:match(GuildWeave.Constants.RULES_KEY .. ":(%d)(%d)(%d)(%d)")

        GuildWeave.InfoRules.mailRule         = tonumber(mailRule)         or GuildWeave.InfoRules.mailRule
        GuildWeave.InfoRules.auctionHouseRule = tonumber(auctionHouseRule) or GuildWeave.InfoRules.auctionHouseRule
        GuildWeave.InfoRules.tradeRule        = tonumber(tradeRule)        or GuildWeave.InfoRules.tradeRule
        GuildWeave.InfoRules.groupingRule     = tonumber(groupingRule)     or GuildWeave.InfoRules.groupingRule

        -- Parse level cap: GuildWeave-Cap:40
        local currentCap = text:match(GuildWeave.Constants.RULES_CAP_KEY .. ":(%d+)")
        if currentCap then
            GuildWeave.Rules.CurrentCap = tonumber(currentCap)
            GuildWeave.LevelUps:CheckForCap(UnitLevel("player"))
        end

        GuildWeave:Print("Rules loaded.")
    end)
end

-- Rule: Completely prohibit mailbox usage
function GuildWeave.Rules:ProhibitMailboxUsage()
    if tonumber(GuildWeave.InfoRules.mailRule) ~= 1 then return end
    CloseMail()
    GuildWeave.Popup:Show({
        title = Localization["MAILBOX_BLOCKED_TITLE"],
        message = Localization["MAILBOX_BLOCKED_MSG"]
    })
end

-- Rule: Prohibit auction house usage
function GuildWeave.Rules:ProhibitAuctionhouseUsage()
    if tonumber(GuildWeave.InfoRules.auctionHouseRule) == 0 then
        return
    end

    if CloseAuctionHouse then
        CloseAuctionHouse()
    end
    if AuctionFrame and AuctionFrame:IsShown() then
        AuctionFrame:Hide()
    end
    GuildWeave.Popup:Show({
        title = Localization["AH_BLOCKED_TITLE"],
        message = Localization["AH_BLOCKED_MSG"]
    })
end

-- Rule: Prohibit trading with players outside the guild
function GuildWeave.Rules:ProhibitTradeWithNonGuildMembers()
    if tonumber(GuildWeave.InfoRules.tradeRule) == 0 then
        return
    end

    local inPvP = GuildWeave:IsInBattleground() or GuildWeave:IsInRaid() or GuildWeave:IsInArena()
    if inPvP then return end

    local tradePartner = UnitName("NPC")
    if tradePartner then
        local isInGuild = C_GuildInfo.MemberExistsByName(tradePartner)
        if not isInGuild then
            CancelTrade()
            GuildWeave.Popup:Show({
                title = Localization["TRADE_BLOCKED_TITLE"],
                message = Localization["TRADE_BLOCKED_MSG"]
            })
        end
    end
end

-- Rule: Prohibit grouping with players outside the guild
function GuildWeave.Rules:ProhibitGroupingWithNonGuildMembers()
    if tonumber(GuildWeave.InfoRules.groupingRule) == 0 then
        return
    end

    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers do
        local unit = "party" .. i
        if not UnitExists(unit) then
            unit = "raid" .. i
        end

        -- Skip disconnected players — they'll be checked again when they reconnect
        if UnitExists(unit) and UnitIsConnected(unit) then
            local memberName = UnitName(unit)
            if memberName and memberName ~= UNKNOWNOBJECT and memberName ~= "" then
                if not GuildWeave.GuildCache:IsGuildMember(memberName) then
                    LeaveParty()
                    GuildWeave.Popup:Show({
                        title = Localization["GROUP_LEFT_TITLE"],
                        message = Localization["GROUP_LEFT_MSG"],
                        displayTime = 3
                    })
                    return
                end
            end
        end
    end
end

function GuildWeave.Rules:AutoDeclineDuels()
	if(not GuildWeaveDB.auto_decline_duels) then
		return
	end

	CancelDuel()
end

-- Initialize rules
function GuildWeave.Rules:Initialize()
    -- Always register MAIL_SHOW; ProhibitMailboxUsage checks the rule at call-time
    -- so it behaves correctly once the async guild-info load completes.
    GuildWeave.EventManager:RegisterHandler("MAIL_SHOW", function()
        GuildWeave.Rules:ProhibitMailboxUsage()
    end, 0, "RuleMailbox")

    GuildWeave.Rules:LoadFromGuildInfo()

    -- Defer minimap-mail hide until the rule is actually known (LoadFromGuildInfo is async)
    GuildWeave.Rules:GetRules(function()
        if tonumber(GuildWeave.InfoRules.mailRule) == 1 then
            GuildWeave.MailHandler:HideMinimapMail()
        end
    end)

	GuildWeave.EventManager:RegisterHandler("AUCTION_HOUSE_SHOW",
		function()
			GuildWeave.Rules:ProhibitAuctionhouseUsage()
		end, 0, "RuleAuctionHouse")

	GuildWeave.EventManager:RegisterHandler("TRADE_SHOW",
		function()
			GuildWeave.Rules:ProhibitTradeWithNonGuildMembers()
		end, 0, "RuleTrade")

	-- Instantly decline party invites from non-guild members
	GuildWeave.EventManager:RegisterHandler("PARTY_INVITE_REQUEST",
		function(event, sender)
            if tonumber(GuildWeave.InfoRules.groupingRule) == 0 then
                return
            end

			local isInGuild = GuildWeave.GuildCache:IsGuildMember(sender)
			if not isInGuild then
				StaticPopup_Hide("PARTY_INVITE")
				DeclineGroup()
			end
		end, 0, "PartyInviteCheck")

	-- Check group members on roster updates
	GuildWeave.EventManager:RegisterHandler("GROUP_ROSTER_UPDATE",
		function()
			GuildWeave.Rules:ProhibitGroupingWithNonGuildMembers()
		end, 0, "GroupRosterCheck")

	GuildWeave.EventManager:RegisterHandler("RAID_ROSTER_UPDATE",
		function()
			GuildWeave.Rules:ProhibitGroupingWithNonGuildMembers()
		end, 0, "RaidRosterCheck")

    GuildWeave.EventManager:RegisterHandler("DUEL_REQUESTED",
		function()
			GuildWeave.Rules:AutoDeclineDuels()
		end, 0, "DuelAutoDecline")
end