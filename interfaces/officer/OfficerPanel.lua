-- OfficerPanel.lua
-- Tabbed officer panel: Rules tab (read/write for officers, read-only for members)
-- and Inactive Members tab (officers only).
-- Frame shell defined in OfficerPanel.xml.

GuildWeave.OfficerPanel = {}

local frame
local currentTab = "rules"

local function IsOfficer()
    return CanGuildRemove()
end

-- ── Frame wiring ──────────────────────────────────────────────────────────────

local function BuildPanel()
    local f = GuildWeaveOfficerPanel

    f:SetBackdrop(GuildWeave.Constants.BACKDROP)
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        GuildWeave:SaveFramePosition(self, "officerpanel_position")
    end)
    GuildWeave:RestoreFramePosition(f, "officerpanel_position")

    local title = _G["GuildWeaveOfficerPanelTitle"]
    title:SetText("GuildWeave — Officer Panel")
    title:SetTextColor(1, 0.82, 0, 1)

    _G["GuildWeaveOfficerPanelCloseBtn"]:SetScript("OnClick", function() f:Hide() end)

    local tabBtns = {
        rules    = _G["GuildWeaveOfficerPanelTabRules"],
        inactive = _G["GuildWeaveOfficerPanelTabInactive"],
    }
    local tabContents = {
        rules    = _G["GuildWeaveOfficerPanelRulesContent"],
        inactive = _G["GuildWeaveOfficerPanelInactiveContent"],
    }

    tabBtns.rules:SetText("Rules")
    tabBtns.inactive:SetText("Inactive Members")

    local function SwitchTab(id)
        currentTab = id
        for tid, content in pairs(tabContents) do content:SetShown(tid == id) end
        for tid, btn in pairs(tabBtns) do
            btn:SetNormalFontObject(tid == id and GameFontHighlight or GameFontNormal)
        end
    end

    -- ── Rules tab content ──────────────────────────────────────────────────
    local rc      = tabContents["rules"]
    local officer = IsOfficer()

    local ruleDefs = {
        { label = "Block mailbox usage",             dbKey = "mailRule" },
        { label = "Block auction house",             dbKey = "auctionHouseRule" },
        { label = "Block trade with non-members",    dbKey = "tradeRule" },
        { label = "Block grouping with non-members", dbKey = "groupingRule" },
        { label = "Auto-decline duels",              dbKey = nil },
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

        checkboxes[rule.label] = cb
        yOff = yOff - 30
    end

    -- Cap level input
    yOff = yOff - 10
    local capLbl = rc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    capLbl:SetPoint("TOPLEFT", rc, "TOPLEFT", 8, yOff)
    capLbl:SetText("Current level cap:")
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
        notice:SetText("View only — officer access required to change rules")
    end

    if officer then
        local updateBtn = CreateFrame("Button", nil, rc, "UIPanelButtonTemplate")
        updateBtn:SetSize(140, 26)
        updateBtn:SetPoint("BOTTOM", rc, "BOTTOM", 0, 10)
        updateBtn:SetText("Update Guild Info")
        updateBtn:SetScript("OnClick", function()
            local cap = tonumber(capEb:GetText()) or 0
            GuildWeave:WriteGuildInfo(
                checkboxes["Block mailbox usage"]:GetChecked(),
                checkboxes["Block auction house"]:GetChecked(),
                checkboxes["Block trade with non-members"]:GetChecked(),
                checkboxes["Block grouping with non-members"]:GetChecked(),
                cap
            )
            GuildWeaveDB = GuildWeaveDB or {}
            GuildWeaveDB.auto_decline_duels = checkboxes["Auto-decline duels"]:GetChecked() == true
        end)
    end

    -- ── Inactive Members tab ───────────────────────────────────────────────
    tabBtns["inactive"]:SetScript("OnClick", function()
        SwitchTab("inactive")
        if officer then
            GuildWeave:ToggleInactivityWindow()
        else
            GuildWeave:Print("Inactive member list is visible to officers only.")
        end
    end)
    tabBtns["rules"]:SetScript("OnClick", function() SwitchTab("rules") end)

    SwitchTab("rules")

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
