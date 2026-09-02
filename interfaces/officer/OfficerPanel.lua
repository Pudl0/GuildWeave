-- OfficerPanel.lua
-- Tabbed officer panel: Rules (read/write for officers, read-only for members),
-- Inactive Members, Members (roster overview with Discord/professions columns),
-- and Discord (Discord-handle-to-alts overview) — the latter three officer-only.
-- Frame is built in BuildPanel(); tab bar by GuildWeave.Shared.CreateTabSwitcher.

GuildWeave.OfficerPanel = {}
local OfficerPanel = GuildWeave.OfficerPanel
local Localization = GuildWeave.Localization

OfficerPanel.PANEL_W = 480
OfficerPanel.PANEL_H = 420
OfficerPanel.TITLE_H = 28
OfficerPanel.TAB_H   = 24

local frame

local function IsOfficer()
    return CanGuildRemove()
end
OfficerPanel.IsOfficer = IsOfficer

OfficerPanel.membersFilter = { filterName = "" }
OfficerPanel.discordFilter = { filterName = "" }

-- ── Rules tab ─────────────────────────────────────────────────────────────────

local function BuildRulesTab(rc)
    local officer = IsOfficer()

    local ruleDefs = {
        { key = "mail",  label = Localization["OFFICER_RULE_MAIL"],  dbKey = "mailRule" },
        { key = "ah",    label = Localization["OFFICER_RULE_AH"],    dbKey = "auctionHouseRule" },
        { key = "trade", label = Localization["OFFICER_RULE_TRADE"], dbKey = "tradeRule" },
        { key = "group", label = Localization["OFFICER_RULE_GROUP"], dbKey = "groupingRule" },
        { key = "duel",  label = Localization["OFFICER_RULE_DUEL"],  dbKey = nil },
    }

    local checkboxes = {}
    local yOff = -8
    for _, rule in ipairs(ruleDefs) do
        local cb = CreateFrame("CheckButton", nil, rc, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", rc, "TOPLEFT", 8, yOff)
        cb:SetSize(24, 24)

        local cblbl = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cblbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        cblbl:SetText(rule.label)

        if rule.dbKey then
            cb:SetChecked(GuildWeave.InfoRules[rule.dbKey] == 1)
        else
            cb:SetChecked(GuildWeaveDB and GuildWeaveDB.auto_decline_duels == true)
        end

        if not officer then
            cb:Disable()
            cblbl:SetTextColor(0.5, 0.5, 0.5, 1)
        end

        checkboxes[rule.key] = cb
        yOff = yOff - 30
    end

    -- Cap level input
    yOff = yOff - 10
    local capLbl = rc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    capLbl:SetPoint("TOPLEFT", rc, "TOPLEFT", 8, yOff)
    capLbl:SetText(Localization["OFFICER_CAP_LABEL"])
    if not officer then capLbl:SetTextColor(0.5, 0.5, 0.5, 1) end

    local capEb = CreateFrame("EditBox", nil, rc, BackdropTemplateMixin and "BackdropTemplate")
    capEb:SetSize(50, 22)
    capEb:SetPoint("LEFT", capLbl, "RIGHT", 8, 0)
    capEb:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
    capEb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    capEb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    capEb:SetFontObject("GameFontHighlight")
    capEb:SetTextInsets(4, 4, 0, 0)
    capEb:SetAutoFocus(false)
    capEb:SetMaxLetters(3)
    capEb:SetNumeric(true)
    capEb:SetText(tostring(GuildWeave.Rules.CurrentCap or 0))
    if not officer then capEb:Disable() end

    if not officer then
        yOff = yOff - 40
        local notice = rc:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        notice:SetPoint("TOPLEFT", rc, "TOPLEFT", 8, yOff)
        notice:SetTextColor(0.6, 0.6, 0.6, 1)
        notice:SetText(Localization["OFFICER_VIEW_ONLY"])
    end

    if officer then
        local updateBtn = CreateFrame("Button", nil, rc, "UIPanelButtonTemplate")
        updateBtn:SetSize(140, 26)
        updateBtn:SetPoint("BOTTOM", rc, "BOTTOM", 0, 10)
        updateBtn:SetText(Localization["OFFICER_UPDATE_BTN"])
        updateBtn:SetScript("OnClick", function()
            local cap = tonumber(capEb:GetText()) or 0
            GuildWeave:WriteGuildInfo(
                checkboxes.mail:GetChecked(),
                checkboxes.ah:GetChecked(),
                checkboxes.trade:GetChecked(),
                checkboxes.group:GetChecked(),
                cap
            )
            GuildWeaveDB = GuildWeaveDB or {}
            GuildWeaveDB.auto_decline_duels = checkboxes.duel:GetChecked() == true
        end)
    end
end

-- ── Members tab ───────────────────────────────────────────────────────────────

local function BuildMembersData()
    local data    = {}
    local ownName = UnitName("player")

    for _, member in ipairs(GuildWeave.GuildCache:GetFullRoster()) do
        local shortName = member.name
        local discord, prof1, prof2

        if shortName == ownName then
            discord = DiscordHandle or ""
            local p = GuildWeaveOwnProfile or {}
            prof1, prof2 = p.prof1, p.prof2
        else
            local profile = GuildWeaveProfileCache and GuildWeaveProfileCache[shortName]
            discord = profile and profile.discord or ""
            prof1   = profile and profile.prof1
            prof2   = profile and profile.prof2
        end

        local profs = prof1 and (prof2 and (prof1 .. ", " .. prof2) or prof1) or ""

        table.insert(data, {
            name    = shortName,
            level   = member.level or 0,
            online  = member.isOnline == true,
            discord = discord,
            profs   = profs,
        })
    end

    table.sort(data, function(a, b)
        if a.online ~= b.online then return a.online end
        return a.name < b.name
    end)

    return data
end

local function BuildMembersTab(mc)
    local MCOLS = {
        { label = Localization["LBL_NAME"],        x = 0,   w = 110 },
        { label = Localization["LBL_LEVEL"],       x = 114, w = 40  },
        { label = Localization["LBL_DISCORD"],     x = 158, w = 130 },
        { label = Localization["LBL_PROFESSIONS"], x = 292, w = 152 },
    }
    for _, col in ipairs(MCOLS) do
        local hdr = mc:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hdr:SetPoint("TOPLEFT", mc, "TOPLEFT", col.x + 4, -6)
        hdr:SetWidth(col.w)
        hdr:SetJustifyH("LEFT")
        hdr:SetText(col.label)
        hdr:SetTextColor(1, 0.82, 0, 1)
    end

    local mDiv = mc:CreateTexture(nil, "ARTWORK")
    mDiv:SetHeight(1)
    mDiv:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    mDiv:SetPoint("TOPLEFT",  mc, "TOPLEFT",  4, -22)
    mDiv:SetPoint("TOPRIGHT", mc, "TOPRIGHT", -4, -22)

    local mFilterBtn = CreateFrame("Button", nil, mc, "UIPanelButtonTemplate")
    mFilterBtn:SetSize(70, 22)
    mFilterBtn:SetPoint("BOTTOMRIGHT", mc, "BOTTOMRIGHT", -4, 8)
    mFilterBtn:SetText(Localization["LBL_FILTER"])
    mFilterBtn:SetScript("OnClick", function()
        local fp = OfficerPanel.tabFilterPanels and OfficerPanel.tabFilterPanels.members
        if fp then fp:SetShown(not fp:IsShown()) end
    end)

    local mScrollFrame = CreateFrame("ScrollFrame", nil, mc, "UIPanelScrollFrameTemplate")
    mScrollFrame:SetPoint("TOPLEFT",     mc, "TOPLEFT",     4, -26)
    mScrollFrame:SetPoint("BOTTOMRIGHT", mc, "BOTTOMRIGHT", -20, 36)
    mScrollFrame:EnableMouseWheel(true)
    mScrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        sf:SetVerticalScroll(
            math.max(0, math.min(sf:GetVerticalScrollRange(), sf:GetVerticalScroll() - delta * 20))
        )
    end)

    local mScrollChild = CreateFrame("Frame", nil, mScrollFrame)
    mScrollChild:SetWidth(OfficerPanel.PANEL_W - 16 - 20)
    mScrollChild:SetHeight(1)
    mScrollFrame:SetScrollChild(mScrollChild)

    mc.rows = {}

    local function Refresh()
        if not mc:IsShown() then return end
        for _, row in ipairs(mc.rows) do row:Hide() end
        wipe(mc.rows)

        local list = BuildMembersData()

        local mf   = OfficerPanel.membersFilter
        local srch = (mf.filterName or ""):lower()
        if srch ~= "" then
            local out = {}
            for _, e in ipairs(list) do
                if (e.name or ""):lower():find(srch, 1, true) then table.insert(out, e) end
            end
            list = out
        end

        if #list == 0 then
            local msg = mScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", mScrollChild, "TOPLEFT", 4, 0)
            msg:SetText(Localization["OFFICER_MEMBERS_NONE_FOUND"])
            msg:SetTextColor(0.6, 0.6, 0.6, 1)
            table.insert(mc.rows, msg)
            mScrollChild:SetHeight(20)
            return
        end

        local ROW_H = 20
        for idx, entry in ipairs(list) do
            local row = CreateFrame("Frame", nil, mScrollChild)
            row:SetSize(mScrollChild:GetWidth(), ROW_H)
            row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_H)
            row:EnableMouse(true)

            if idx % 2 == 0 then
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(1, 1, 1, 0.03)
            end

            row:SetScript("OnMouseUp", function(_, button)
                if button == "RightButton" then
                    OfficerPanel:ShowMemberContextMenu(entry.name)
                end
            end)

            local nameFs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameFs:SetPoint("LEFT", row, "LEFT", 4, 0)
            nameFs:SetWidth(106)
            nameFs:SetJustifyH("LEFT")
            nameFs:SetText(GuildWeave:SanitizeText(entry.name))
            nameFs:SetTextColor(entry.online and 0.27 or 0.5, entry.online and 1 or 0.5, entry.online and 0.27 or 0.5, 1)

            local levelFs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            levelFs:SetPoint("LEFT", row, "LEFT", 118, 0)
            levelFs:SetWidth(36)
            levelFs:SetJustifyH("LEFT")
            levelFs:SetText(tostring(entry.level))

            local discordFs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            discordFs:SetPoint("LEFT", row, "LEFT", 162, 0)
            discordFs:SetWidth(126)
            discordFs:SetJustifyH("LEFT")
            discordFs:SetText(GuildWeave:SanitizeText(entry.discord))
            discordFs:SetTextColor(0.55, 0.55, 0.9, 1)

            local profsFs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            profsFs:SetPoint("LEFT", row, "LEFT", 296, 0)
            profsFs:SetWidth(148)
            profsFs:SetJustifyH("LEFT")
            profsFs:SetText(entry.profs)
            profsFs:SetTextColor(0.9, 0.75, 0.4, 1)

            table.insert(mc.rows, row)
        end

        mScrollChild:SetHeight(math.max(1, #list * ROW_H))
        mScrollFrame:SetVerticalScroll(0)
    end

    mc.Refresh = Refresh
    OfficerPanel.RefreshMembers = Refresh
end

-- ── Discord tab ───────────────────────────────────────────────────────────────

local function BuildDiscordData()
    local byHandle = {}
    local ownName  = UnitName("player")

    for i = 1, GetNumGuildMembers() or 0 do
        local name, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
        if name then
            local shortName = GuildWeave:RemoveRealmFromName(name)
            local handle
            if shortName == ownName then
                handle = DiscordHandle
            elseif GuildWeaveProfileCache and GuildWeaveProfileCache[shortName] then
                handle = GuildWeaveProfileCache[shortName].discord
            end
            handle = handle and strtrim(handle) or ""

            if handle ~= "" then
                local key = string.lower(handle)
                if not byHandle[key] then
                    byHandle[key] = { handle = handle, chars = {}, online = 0 }
                end
                table.insert(byHandle[key].chars, shortName)
                if isOnline then byHandle[key].online = byHandle[key].online + 1 end
            end
        end
    end

    local list = {}
    for _, group in pairs(byHandle) do
        table.sort(group.chars)
        table.insert(list, {
            handle = group.handle,
            count  = #group.chars,
            names  = table.concat(group.chars, ", "),
        })
    end
    table.sort(list, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return string.lower(a.handle) < string.lower(b.handle)
    end)
    return list
end

local function BuildDiscordTab(dc)
    local DCOLS = {
        { label = Localization["LBL_DISCORD"],    x = 0,   w = 150 },
        { label = Localization["LBL_CHARS"],      x = 154, w = 42  },
        { label = Localization["LBL_CHARACTERS"], x = 200, w = 250 },
    }
    for _, col in ipairs(DCOLS) do
        local hdr = dc:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hdr:SetPoint("TOPLEFT", dc, "TOPLEFT", col.x + 4, -6)
        hdr:SetWidth(col.w)
        hdr:SetJustifyH("LEFT")
        hdr:SetText(col.label)
        hdr:SetTextColor(1, 0.82, 0, 1)
    end

    local dDiv = dc:CreateTexture(nil, "ARTWORK")
    dDiv:SetHeight(1)
    dDiv:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    dDiv:SetPoint("TOPLEFT",  dc, "TOPLEFT",  4, -22)
    dDiv:SetPoint("TOPRIGHT", dc, "TOPRIGHT", -4, -22)

    local dFilterBtn = CreateFrame("Button", nil, dc, "UIPanelButtonTemplate")
    dFilterBtn:SetSize(70, 22)
    dFilterBtn:SetPoint("BOTTOMRIGHT", dc, "BOTTOMRIGHT", -4, 8)
    dFilterBtn:SetText(Localization["LBL_FILTER"])
    dFilterBtn:SetScript("OnClick", function()
        local fp = OfficerPanel.tabFilterPanels and OfficerPanel.tabFilterPanels.discord
        if fp then fp:SetShown(not fp:IsShown()) end
    end)

    local dScrollFrame = CreateFrame("ScrollFrame", nil, dc, "UIPanelScrollFrameTemplate")
    dScrollFrame:SetPoint("TOPLEFT",     dc, "TOPLEFT",     4, -26)
    dScrollFrame:SetPoint("BOTTOMRIGHT", dc, "BOTTOMRIGHT", -20, 36)
    dScrollFrame:EnableMouseWheel(true)
    dScrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        sf:SetVerticalScroll(
            math.max(0, math.min(sf:GetVerticalScrollRange(), sf:GetVerticalScroll() - delta * 20))
        )
    end)

    local dScrollChild = CreateFrame("Frame", nil, dScrollFrame)
    dScrollChild:SetWidth(OfficerPanel.PANEL_W - 16 - 20)
    dScrollChild:SetHeight(1)
    dScrollFrame:SetScrollChild(dScrollChild)

    dc.rows = {}

    local function Refresh()
        if not dc:IsShown() then return end
        for _, row in ipairs(dc.rows) do row:Hide() end
        wipe(dc.rows)

        local raw  = BuildDiscordData()
        local df   = OfficerPanel.discordFilter
        local srch = (df.filterName or ""):lower()
        local list = raw
        if srch ~= "" then
            list = {}
            for _, e in ipairs(raw) do
                if (e.handle or ""):lower():find(srch, 1, true) or
                   (e.names  or ""):lower():find(srch, 1, true) then
                    table.insert(list, e)
                end
            end
        end

        if #list == 0 then
            local msg = dScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", dScrollChild, "TOPLEFT", 4, 0)
            msg:SetText(Localization["OFFICER_DISCORD_NONE_FOUND"])
            msg:SetTextColor(0.6, 0.6, 0.6, 1)
            table.insert(dc.rows, msg)
            dScrollChild:SetHeight(20)
            return
        end

        local ROW_H = 20
        for idx, entry in ipairs(list) do
            local row = CreateFrame("Frame", nil, dScrollChild)
            row:SetSize(dScrollChild:GetWidth(), ROW_H)
            row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_H)

            if idx % 2 == 0 then
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(1, 1, 1, 0.03)
            end

            local function Cell(text, xPos, w, r, g, b)
                local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                fs:SetPoint("LEFT", row, "LEFT", xPos + 4, 0)
                fs:SetWidth(w)
                fs:SetJustifyH("LEFT")
                fs:SetText(text)
                if r then fs:SetTextColor(r, g, b, 1) end
            end

            Cell(GuildWeave:SanitizeText(entry.handle), 0,   146, 0.65, 0.65, 1)
            Cell(tostring(entry.count),                 154, 38,  1,    0.82, 0)
            Cell(GuildWeave:SanitizeText(entry.names),  200, 246)

            table.insert(dc.rows, row)
        end

        dScrollChild:SetHeight(math.max(1, #list * ROW_H))
        dScrollFrame:SetVerticalScroll(0)
    end

    dc.Refresh = Refresh
    OfficerPanel.RefreshDiscordHandles = Refresh
end

-- ── Frame ─────────────────────────────────────────────────────────────────────

local function BuildPanel()
    local officer = IsOfficer()

    local f = CreateFrame("Frame", "GuildWeaveOfficerPanel", UIParent, "BackdropTemplate")
    f:SetSize(OfficerPanel.PANEL_W, OfficerPanel.PANEL_H)
    f:SetFrameStrata("DIALOG")
    f:SetPoint("CENTER", UIParent, "CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:Hide()

    f:SetBackdrop(GuildWeave.Constants.PANEL_BACKDROP)
    f:SetBackdropColor(0.07, 0.07, 0.07, 0.96)
    f:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        GuildWeave:SaveFramePosition(self, "officerpanel_position")
    end)
    GuildWeave:RestoreFramePosition(f, "officerpanel_position")
    GuildWeave:RegisterFrameForEscape(f)

    -- Title bar
    local titleBg = f:CreateTexture(nil, "BACKGROUND")
    titleBg:SetPoint("TOPLEFT",  f, "TOPLEFT",   4, -4)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    titleBg:SetHeight(OfficerPanel.TITLE_H - 4)
    titleBg:SetColorTexture(0.12, 0.12, 0.12, 1)

    local titleIcon = f:CreateTexture(nil, "OVERLAY")
    titleIcon:SetSize(18, 18)
    titleIcon:SetPoint("LEFT", titleBg, "LEFT", 6, 0)
    titleIcon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 4, 0)
    title:SetText(Localization["OFFICER_PANEL_TITLE"])
    title:SetTextColor(1, 0.82, 0, 1)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local tabDefs = {
        { id = "rules", label = Localization["OFFICER_TAB_RULES"] },
    }
    if officer then
        table.insert(tabDefs, {
            id = "inactive", label = Localization["OFFICER_TAB_INACTIVE"],
            onSelected = function()
                C_GuildInfo.GuildRoster()
                C_Timer.After(0.3, OfficerPanel.RefreshInactive)
            end,
        })
        table.insert(tabDefs, {
            id = "members", label = Localization["OFFICER_TAB_MEMBERS"],
            onSelected = function()
                C_GuildInfo.GuildRoster()
                C_Timer.After(0.3, OfficerPanel.RefreshMembers)
            end,
        })
        table.insert(tabDefs, {
            id = "discord", label = Localization["OFFICER_TAB_DISCORD"],
            onSelected = function()
                C_GuildInfo.GuildRoster()
                C_Timer.After(0.3, OfficerPanel.RefreshDiscordHandles)
            end,
        })
    end

    local switcher = GuildWeave.Shared.CreateTabSwitcher({
        parent     = f,
        width      = OfficerPanel.PANEL_W - 16,
        tabHeight  = OfficerPanel.TAB_H,
        topOffset  = -(OfficerPanel.TITLE_H + 6),
        contentTop = -(OfficerPanel.TITLE_H + OfficerPanel.TAB_H + 14),
        tabDefs    = tabDefs,
        defaultTab = "rules",
    })

    OfficerPanel.tabFilterPanels = switcher.filterPanels
    f.switcher = switcher

    BuildRulesTab(switcher.tabContents["rules"])
    if officer then
        OfficerPanel.BuildInactiveTab(switcher.tabContents["inactive"])
        BuildMembersTab(switcher.tabContents["members"])
        BuildDiscordTab(switcher.tabContents["discord"])

        switcher.filterPanels.members = GuildWeave.Shared.CreateFilterPanel({
            panelName   = "GuildWeaveOfficerMembers",
            anchorFrame = f,
            filterState = OfficerPanel.membersFilter,
            showRoles   = false,
            getDataFn   = nil,
            onChangeFn  = function() OfficerPanel.RefreshMembers() end,
        })
        switcher.filterPanels.discord = GuildWeave.Shared.CreateFilterPanel({
            panelName   = "GuildWeaveOfficerDiscord",
            anchorFrame = f,
            filterState = OfficerPanel.discordFilter,
            showRoles   = false,
            getDataFn   = nil,
            onChangeFn  = function() OfficerPanel.RefreshDiscordHandles() end,
        })
    end

    f:HookScript("OnHide", function()
        for _, fp in pairs(OfficerPanel.tabFilterPanels) do
            if fp then fp:Hide() end
        end
    end)

    return f
end

-- ── Public API ────────────────────────────────────────────────────────────────

function GuildWeave.OfficerPanel:Toggle()
    if not frame then frame = BuildPanel() end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
