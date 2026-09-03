-- GuildPanel/GuildPanel.lua
-- Guild member panel: namespace, data, rows, main frame, and filter panel.
-- The panel, its title bar, and the filter flyout are all built here in Lua.

GuildWeave.GuildPanel = {}
local GP = GuildWeave.GuildPanel
local Localization = GuildWeave.Localization

GP.PANEL_NAME = "GuildWeaveGuildPanel"
GP.ROW_H      = 20
GP.TITLE_H    = 30
GP.COL_H      = 20

GP.COLUMNS = {
    { label = Localization["LBL_NAME"],         width = 132 },
    { label = Localization["LBL_LVL"],          width = 30  },
    { label = Localization["PANEL_COL_RANK"],   width = 92  },
    { label = Localization["LBL_ZONE"],         width = 98  },
    { label = Localization["PANEL_COL_ROLE"],   width = 60  },
    { label = Localization["PANEL_COL_DEATHS"], width = 40  },
}

local ROLE_ABBREV = { Tank = "T", Heal = "H", DPS = "D" }
local function AbbreviateRole(role)
    if not role or role == "" then return "" end
    local parts = {}
    for part in role:gmatch("[^/]+") do
        table.insert(parts, ROLE_ABBREV[part] or part)
    end
    return table.concat(parts, "/")
end

GP.PAD_X   = 16
GP.FRAME_W = 0
GP.FRAME_H = 460

GP.sortCol     = 0
GP.sortAsc     = true
GP.hideOffline = true
GP.ROLE_ORDER  = { Tank = 1, Heal = 2, DPS = 3 }

GP.filterName  = ""
GP.filterRoles = {}
GP.filterProf  = nil

local function TotalColWidth()
    local w = 0
    for _, c in ipairs(GP.COLUMNS) do w = w + c.width end
    return w
end
GP.TotalColWidth = TotalColWidth

local BACKDROP = GuildWeave.Constants.PANEL_BACKDROP

-- ── Data ──────────────────────────────────────────────────────────────────────

-- Returns profName, profDisplayString for a given profile slot.
local function ProfData(profile, slot)
    if not profile then return nil, nil end
    local name = profile["prof" .. slot]
    if not name then return nil, nil end
    local rank = profile["prof" .. slot .. "rank"]
    return name, rank and (name .. " (" .. rank .. ")") or name
end

function GP.BuildRosterData()
    local data    = {}
    local ownName = UnitName("player")

    for _, member in ipairs(GuildWeave.GuildCache:GetFullRoster()) do
        local shortName = member.name
        local isOwn     = shortName == ownName
        local role, prof1, prof2, profName1, profName2, discord, deaths

        if isOwn then
            local p  = GuildWeaveOwnProfile or {}
            role     = p.role or ""
            profName1, prof1 = ProfData(p, 1)
            profName2, prof2 = ProfData(p, 2)
            discord  = DiscordHandle or ""
            deaths   = CharacterDeaths or 0
        else
            local profile = GuildWeaveProfileCache and GuildWeaveProfileCache[shortName]
            role     = profile and profile.role    or ""
            profName1, prof1 = ProfData(profile, 1)
            profName2, prof2 = ProfData(profile, 2)
            discord  = profile and profile.discord or ""
            deaths   = profile and profile.deaths
        end

        table.insert(data, {
            name         = shortName,
            level        = member.level            or 0,
            rank         = member.rank             or "",
            rankIndex    = member.rankIndex        or 99,
            classDisplay = member.classDisplayName or "",
            classToken   = member.class            or "",
            zone         = member.zone             or "",
            note         = member.publicNote       or "",
            online       = member.isOnline == true,
            role         = role,
            prof1        = prof1,   prof2     = prof2,
            profName1    = profName1, profName2 = profName2,
            discord      = discord,
            deaths       = deaths,
        })
    end

    return data
end

local SORT_KEY = {
    [1] = function(e) return e.name or ""                end,
    [2] = function(e) return e.level or 0               end,
    [3] = function(e) return e.rankIndex                 end,
    [4] = function(e) return e.zone or ""               end,
    [5] = function(e)
        local min = 99
        for part in (e.role or ""):gmatch("[^/]+") do
            local o = GP.ROLE_ORDER[part] or 99
            if o < min then min = o end
        end
        return min
    end,
    [6] = function(e) return e.deaths or -1              end,
}

function GP.SortData(data)
    table.sort(data, function(a, b)
        if a.online ~= b.online then return a.online end
        local fn = SORT_KEY[GP.sortCol]
        if not fn then return a.name < b.name end
        local va, vb = fn(a), fn(b)
        if va == vb then return a.name < b.name end
        if GP.sortAsc then return va < vb else return va > vb end
    end)
end

-- ── Rows ──────────────────────────────────────────────────────────────────────

local function ClassColor(token)
    local c = RAID_CLASS_COLORS and token and RAID_CLASS_COLORS[token]
    if c then return c.r, c.g, c.b end
    return 1, 1, 1
end

function GP.ShowMemberTooltip(anchor, entry)
    local r, g, b = ClassColor(entry.classToken)
    GameTooltip:SetOwner(anchor, "ANCHOR_LEFT", -10, -50)
    GameTooltip:ClearLines()

    GameTooltip:AddLine(entry.name, r, g, b)
    GameTooltip:AddDoubleLine(Localization["PANEL_TIP_CLASS"],
        entry.classDisplay ~= "" and entry.classDisplay or "-",
        0.65, 0.65, 0.65, r, g, b)
    GameTooltip:AddDoubleLine(Localization["PANEL_TIP_RANK"],
        entry.rank ~= "" and entry.rank or "-",
        0.65, 0.65, 0.65, 1, 1, 1)
    if entry.zone ~= "" then
        GameTooltip:AddDoubleLine(Localization["LBL_ZONE_COLON"], GuildWeave:SanitizeText(entry.zone), 0.65, 0.65, 0.65, 1, 1, 1)
    end

    local safeNote = entry.note ~= "" and GuildWeave:SanitizeText(entry.note) or nil
    if safeNote then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(Localization["PANEL_TIP_NOTE"], safeNote, 0.65, 0.65, 0.65, 1, 0.9, 0.5, true)
    end

    local hasProfile = entry.role ~= "" or entry.discord ~= "" or entry.prof1 or entry.prof2
    if hasProfile then
        GameTooltip:AddLine(" ")
        if entry.role    ~= "" then GameTooltip:AddDoubleLine(Localization["PANEL_TIP_ROLE"],  entry.role,    0.65, 0.65, 0.65, 1,    1,    1)   end
        if entry.discord ~= "" then GameTooltip:AddDoubleLine(Localization["LBL_DISCORD_COLON"],           GuildWeave:SanitizeText(entry.discord), 0.65, 0.65, 0.65, 0.55, 0.55, 0.9) end
        if entry.prof1         then GameTooltip:AddDoubleLine(Localization["PANEL_TIP_PROF1"], entry.prof1,   0.65, 0.65, 0.65, 0.9,  0.75, 0.4) end
        if entry.prof2         then GameTooltip:AddDoubleLine(Localization["PANEL_TIP_PROF2"], entry.prof2,   0.65, 0.65, 0.65, 0.9,  0.75, 0.4) end
    end

    if entry.deaths ~= nil then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(Localization["PANEL_TIP_DEATHS"], tostring(entry.deaths), 0.65, 0.65, 0.65, 1, 1, 1)
    end

    GameTooltip:Show()
end

function GP.CreateRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(TotalColWidth(), GP.ROW_H)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * GP.ROW_H)
    row:EnableMouse(true)
    row:SetFrameLevel(parent:GetFrameLevel() + 2)

    if index % 2 == 0 then
        local stripe = row:CreateTexture(nil, "BACKGROUND")
        stripe:SetAllPoints()
        stripe:SetColorTexture(1, 1, 1, 0.04)
    end

    local hl = row:CreateTexture(nil, "BACKGROUND")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 0.82, 0, 0.08)
    hl:Hide()
    row.hl = hl

    row.cells = {}
    local xOff = 0
    for i, col in ipairs(GP.COLUMNS) do
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetWidth(col.width - 2)
        fs:SetHeight(GP.ROW_H)
        fs:SetPoint("LEFT", row, "LEFT", xOff + 2, 0)
        fs:SetJustifyH(i == 2 and "CENTER" or "LEFT")
        row.cells[i] = fs
        xOff = xOff + col.width
    end

    return row
end

-- ── Main frame ────────────────────────────────────────────────────────────────

function GuildWeave.GuildPanel:Create()
    if self.frame then return end

    GP.FRAME_W = TotalColWidth() + GP.PAD_X + 8

    local f = CreateFrame("Frame", GP.PANEL_NAME, UIParent, "BackdropTemplate")
    f:SetSize(GP.FRAME_W, GP.FRAME_H)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:Hide()
    f:SetBackdrop(BACKDROP)
    f:SetBackdropColor(0.07, 0.07, 0.07, 0.96)
    f:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)

    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        GuildWeave:SaveFramePosition(self, "guildpanel_position")
    end)

    f:SetPoint("CENTER", UIParent, "CENTER")
    GuildWeave:RestoreFramePosition(f, "guildpanel_position")

    -- Title bar
    local titleBg = f:CreateTexture(nil, "BACKGROUND")
    titleBg:SetPoint("TOPLEFT",  f, "TOPLEFT",   4, -4)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    titleBg:SetHeight(GP.TITLE_H - 4)
    titleBg:SetColorTexture(0.12, 0.12, 0.12, 1)

    local titleIcon = f:CreateTexture(nil, "OVERLAY")
    titleIcon:SetSize(18, 18)
    titleIcon:SetPoint("LEFT", titleBg, "LEFT", 4, 0)
    titleIcon:SetTexture(GuildWeave.Constants.MEDIA.GUILD_LOGO)

    local titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleIcon, "RIGHT", 4, 0)
    titleText:SetText(GuildWeave.name)
    titleText:SetTextColor(1, 0.82, 0, 1)

    local countLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countLabel:SetPoint("RIGHT", titleBg, "RIGHT", -28, 0)
    countLabel:SetTextColor(0.6, 0.6, 0.6, 1)
    self.countLabel = countLabel

    -- Divider under the column-header row
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    divider:SetPoint("TOPLEFT",  f, "TOPLEFT",   8, -(GP.TITLE_H + 3 + GP.COL_H))
    divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -(GP.TITLE_H + 3 + GP.COL_H))

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        if GuildWeave.GuildPanel.filterPanel    then GuildWeave.GuildPanel.filterPanel:Hide()    end
        if GuildWeave.GuildPanel.filterProfList then GuildWeave.GuildPanel.filterProfList:Hide() end
    end)

    local filterBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    filterBtn:SetSize(70, 20)
    filterBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 6)
    filterBtn:SetText(Localization["LBL_FILTER"])
    filterBtn:SetScript("OnClick", function() GuildWeave.GuildPanel:ToggleFilterPanel() end)

    -- Hide-offline toggle (stateful button)
    local hideBtn = CreateFrame("Button", nil, f)
    hideBtn:SetSize(60, GP.TITLE_H - 4)
    hideBtn:SetPoint("RIGHT", countLabel, "LEFT", -6, 0)
    hideBtn:EnableMouse(true)
    local hideLbl = hideBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideLbl:SetAllPoints()
    hideLbl:SetJustifyH("RIGHT")
    hideLbl:SetText(Localization["LBL_OFFLINE"])
    local function UpdateHideBtnColor()
        hideLbl:SetTextColor(
            GP.hideOffline and 1 or 0.45, GP.hideOffline and 0.82 or 0.45, GP.hideOffline and 0 or 0.45, 1)
    end
    UpdateHideBtnColor()
    hideBtn:SetScript("OnClick",  function() GP.hideOffline = not GP.hideOffline; UpdateHideBtnColor(); GuildWeave.GuildPanel:Refresh() end)
    hideBtn:SetScript("OnEnter", function() hideLbl:SetTextColor(1, 1, 0.7, 1) end)
    hideBtn:SetScript("OnLeave", UpdateHideBtnColor)

    -- Column headers (dynamic — loop over COLUMNS)
    self.headerBtns = {}
    local xOff = 8
    for i, col in ipairs(GP.COLUMNS) do
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(col.width - 2, GP.COL_H)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", xOff, -(GP.TITLE_H + 3))
        btn:EnableMouse(true)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetAllPoints()
        lbl:SetJustifyH(i == 2 and "CENTER" or "LEFT")
        lbl:SetTextColor(1, 0.82, 0, 1)
        lbl:SetText(col.label)
        btn.lbl = lbl

        local colIdx = i
        btn:SetScript("OnClick", function()
            if GP.sortCol == colIdx then GP.sortAsc = not GP.sortAsc
            else GP.sortCol = colIdx; GP.sortAsc = true end
            GuildWeave.GuildPanel:Refresh()
        end)
        btn:SetScript("OnEnter", function() lbl:SetTextColor(1, 1, 0.7, 1) end)
        btn:SetScript("OnLeave", function()
            if GP.sortCol == colIdx then lbl:SetTextColor(1, 1, 0.45, 1)
            else lbl:SetTextColor(1, 0.82, 0, 1) end
        end)

        self.headerBtns[i] = btn
        xOff = xOff + col.width
    end

    local scrollFrame = CreateFrame("ScrollFrame", nil, f)
    scrollFrame:SetPoint("TOPLEFT",     f, "TOPLEFT",      8, -(GP.TITLE_H + 6 + GP.COL_H))
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8,  30)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        local step = GP.ROW_H * 3
        sf:SetVerticalScroll(math.max(0, math.min(sf:GetVerticalScrollRange(), sf:GetVerticalScroll() - delta * step)))
    end)

    local content = CreateFrame("Frame", GP.PANEL_NAME .. "Content", scrollFrame)
    content:SetWidth(TotalColWidth())
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    f.scrollFrame = scrollFrame
    f.content     = content
    f.rows        = {}
    self.frame    = f
end

local function filter(data, predicate)
    local result = {}
    for _, e in ipairs(data) do if predicate(e) then table.insert(result, e) end end
    return result
end

function GuildWeave.GuildPanel:Refresh()
    if not self.frame then return end

    self.data     = GP.BuildRosterData()
    local allData = self.data

    local onlineCount = 0
    for _, e in ipairs(allData) do if e.online then onlineCount = onlineCount + 1 end end
    if self.countLabel then
        self.countLabel:SetText(onlineCount .. " / " .. #allData .. " online")
    end

    local data = GP.hideOffline and filter(allData, function(e) return e.online end) or allData
    if GP.filterName ~= "" then
        local s = GP.filterName:lower()
        data = filter(data, function(e) return (e.name or ""):lower():find(s, 1, true) end)
    end
    if next(GP.filterRoles) then
        data = filter(data, function(e)
            for part in (e.role or ""):gmatch("[^/]+") do
                if GP.filterRoles[part] then return true end
            end
        end)
    end
    if GP.filterProf then
        data = filter(data, function(e) return e.profName1 == GP.filterProf or e.profName2 == GP.filterProf end)
    end

    GP.SortData(data)

    for i, btn in ipairs(self.headerBtns or {}) do
        if i == GP.sortCol then
            btn.lbl:SetText(GP.COLUMNS[i].label .. (GP.sortAsc and " ^" or " v"))
            btn.lbl:SetTextColor(1, 1, 0.45, 1)
        else
            btn.lbl:SetText(GP.COLUMNS[i].label)
            btn.lbl:SetTextColor(1, 0.82, 0, 1)
        end
    end

    local content = self.frame.content
    local rows    = self.frame.rows

    for i = 1, math.max(#data, #rows) do
        if i <= #data then
            if not rows[i] then rows[i] = GP.CreateRow(content, i) end
            local row   = rows[i]
            local entry = data[i]
            row._entry  = entry

            local nameCol = entry.online and "|cff44ff44" or "|cff888888"
            row.cells[1]:SetText(nameCol .. GuildWeave:SanitizeText(entry.name) .. "|r")
            row.cells[2]:SetText(tostring(entry.level))
            row.cells[3]:SetText(GuildWeave:SanitizeText(entry.rank))
            row.cells[4]:SetText(GuildWeave:SanitizeText(entry.zone))
            row.cells[5]:SetText(AbbreviateRole(entry.role))
            row.cells[6]:SetText(entry.deaths ~= nil and tostring(entry.deaths) or "")

            row:SetScript("OnEnter", function() row.hl:Show(); GP.ShowMemberTooltip(row, entry) end)
            row:SetScript("OnLeave", function() row.hl:Hide(); GameTooltip:Hide() end)
            row:SetScript("OnMouseDown", function(_, button)
                if button == "RightButton" then
                    SetItemRef("player:" .. entry.name,
                        "|Hplayer:" .. entry.name .. "|h[" .. entry.name .. "]|h", "RightButton")
                end
            end)
            row:Show()
        elseif rows[i] then
            rows[i]:SetScript("OnEnter", nil)
            rows[i]:SetScript("OnLeave", nil)
            rows[i]:SetScript("OnMouseDown", nil)
            rows[i]:Hide()
        end
    end

    content:SetHeight(math.max(1, #data * GP.ROW_H))
    self.frame.scrollFrame:SetVerticalScroll(0)
end

function GuildWeave.GuildPanel:Toggle()
    if not self.frame then self:Create() end
    if self.frame:IsShown() then
        self.frame:Hide()
        if self.filterPanel    then self.filterPanel:Hide()    end
        if self.filterProfList then self.filterProfList:Hide() end
    else
        self:Refresh()
        self.frame:Show()
    end
end

function GuildWeave.GuildPanel:Initialize()
    GuildWeave.EventManager:RegisterHandler("GUILD_ROSTER_UPDATE", function()
        if GuildWeave.GuildPanel.frame and GuildWeave.GuildPanel.frame:IsShown() then
            C_Timer.After(0, function() GuildWeave.GuildPanel:Refresh() end)
        end
    end, 0, "GuildPanelRefresh")
end

-- ── Filter panel ──────────────────────────────────────────────────────────────

function GuildWeave.GuildPanel:CreateFilterPanel()
    if self.filterPanel then return end
    local f    = self.frame
    local FP_W = 205
    local PAD  = 10
    local INNER_W = FP_W - PAD * 2

    local fp = CreateFrame("Frame", "GuildWeaveGuildPanelFilter", UIParent, "BackdropTemplate")
    fp:SetFrameStrata("HIGH")
    fp:SetSize(FP_W, 230)
    fp:SetBackdrop(BACKDROP)
    fp:SetBackdropColor(0.07, 0.07, 0.07, 0.97)
    fp:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    fp:SetPoint("TOPLEFT", f, "TOPRIGHT", 6, 0)
    fp:Hide()

    local titleLbl = fp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLbl:SetPoint("TOPLEFT", fp, "TOPLEFT", PAD, -PAD)
    titleLbl:SetText(Localization["LBL_FILTER"])
    titleLbl:SetTextColor(1, 0.82, 0, 1)

    local nameLbl = fp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLbl:SetPoint("TOPLEFT", titleLbl, "BOTTOMLEFT", 0, -10)
    nameLbl:SetText(Localization["LBL_NAME_COLON"])
    nameLbl:SetTextColor(0.8, 0.8, 0.8, 1)

    local nameEB = CreateFrame("EditBox", nil, fp, BackdropTemplateMixin and "BackdropTemplate")
    nameEB:SetSize(INNER_W, 24)
    nameEB:SetPoint("TOPLEFT", nameLbl, "BOTTOMLEFT", 0, -4)
    nameEB:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
    nameEB:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    nameEB:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    nameEB:SetFontObject("GameFontHighlight")
    nameEB:SetTextInsets(6, 6, 0, 0)
    nameEB:SetAutoFocus(false)
    nameEB:SetMaxLetters(50)
    nameEB:SetScript("OnTextChanged", function(eb)
        GP.filterName = eb:GetText():match("^%s*(.-)%s*$") or ""
        GuildWeave.GuildPanel:Refresh()
    end)
    nameEB:SetScript("OnEscapePressed", function(eb) eb:ClearFocus() end)

    local roleLbl = fp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    roleLbl:SetPoint("TOPLEFT", nameEB, "BOTTOMLEFT", 0, -10)
    roleLbl:SetText(Localization["FILTER_ROLE"])
    roleLbl:SetTextColor(0.8, 0.8, 0.8, 1)

    local roleBtns = {}
    local roles    = GuildWeave.Constants.ROLES
    local rbW      = math.floor((INNER_W - 4 * (#roles - 1)) / #roles)

    for i, roleName in ipairs(roles) do
        local btn = CreateFrame("Button", nil, fp)
        btn:SetSize(rbW, 24)
        btn:SetPoint("TOPLEFT", roleLbl, "BOTTOMLEFT", (i - 1) * (rbW + 4), -4)
        btn:EnableMouse(true)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.18, 0.18, 0.18, 0.9)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER")
        lbl:SetText(roleName)

        btn._active = false
        local function UpdateBtn()
            if btn._active then bg:SetColorTexture(0.28, 0.20, 0.0, 1); lbl:SetTextColor(1, 0.82, 0, 1)
            else                bg:SetColorTexture(0.18, 0.18, 0.18, 0.9); lbl:SetTextColor(0.6, 0.6, 0.6, 1) end
        end
        btn.UpdateAppearance = UpdateBtn
        UpdateBtn()

        btn:SetScript("OnClick", function()
            btn._active = not btn._active
            GP.filterRoles[roleName] = btn._active or nil
            UpdateBtn()
            GuildWeave.GuildPanel:Refresh()
        end)
        btn:SetScript("OnEnter", function() lbl:SetTextColor(1, 1, 0.7, 1) end)
        btn:SetScript("OnLeave", UpdateBtn)
        roleBtns[i] = btn
    end

    local profLbl = fp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profLbl:SetPoint("TOPLEFT", roleBtns[1], "BOTTOMLEFT", 0, -12)
    profLbl:SetText(Localization["FILTER_PROFESSION"])
    profLbl:SetTextColor(0.8, 0.8, 0.8, 1)

    local profBtn = CreateFrame("Button", nil, fp, "UIPanelButtonTemplate")
    profBtn:SetSize(INNER_W, 24)
    profBtn:SetPoint("TOPLEFT", profLbl, "BOTTOMLEFT", 0, -4)
    profBtn:SetText(Localization["FILTER_ALL_PROFS"])

    local profList = CreateFrame("Frame", "GuildWeaveGuildPanelProfList", UIParent, "BackdropTemplate")
    profList:SetFrameStrata("TOOLTIP")
    profList:SetSize(INNER_W, 10)
    profList:SetBackdrop(BACKDROP)
    profList:SetBackdropColor(0.05, 0.05, 0.05, 0.98)
    profList:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    profList:SetPoint("TOPLEFT", profBtn, "BOTTOMLEFT", 0, -2)
    profList:Hide()
    profList.btns = {}

    local function BuildProfList()
        local seen, profs = {}, {}
        if self.data then
            for _, e in ipairs(self.data) do
                for _, pn in ipairs({ e.profName1, e.profName2 }) do
                    if pn and not seen[pn] then seen[pn] = true; table.insert(profs, pn) end
                end
            end
        end
        table.sort(profs)

        for _, b in ipairs(profList.btns) do b:Hide() end
        profList.btns = {}

        local ITEM_H = 20
        local yOff   = -4

        local function addItem(label, onClickFn, isActive)
            local btn = CreateFrame("Button", nil, profList)
            btn:SetSize(INNER_W - 8, ITEM_H)
            btn:SetPoint("TOPLEFT", profList, "TOPLEFT", 4, yOff)
            btn:EnableMouse(true)
            local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lbl:SetAllPoints()
            lbl:SetJustifyH("LEFT")
            lbl:SetText(label)
            lbl:SetTextColor(isActive and 1 or 0.75, isActive and 0.82 or 0.75, isActive and 0 or 0.75, 1)
            btn:SetScript("OnClick", onClickFn)
            btn:SetScript("OnEnter", function() lbl:SetTextColor(1, 1, 0.7, 1) end)
            btn:SetScript("OnLeave", function()
                lbl:SetTextColor(isActive and 1 or 0.75, isActive and 0.82 or 0.75, isActive and 0 or 0.75, 1)
            end)
            table.insert(profList.btns, btn)
            yOff = yOff - ITEM_H - 2
        end

        addItem(Localization["FILTER_ALL_PROFS"], function()
            GP.filterProf = nil
            profBtn:SetText(Localization["FILTER_ALL_PROFS"])
            profList:Hide()
            GuildWeave.GuildPanel:Refresh()
        end, GP.filterProf == nil)

        for _, pn in ipairs(profs) do
            local name = pn
            addItem(name, function()
                GP.filterProf = name
                profBtn:SetText(name)
                profList:Hide()
                GuildWeave.GuildPanel:Refresh()
            end, GP.filterProf == name)
        end

        profList:SetHeight(math.abs(yOff) + 4)
    end

    profBtn:SetScript("OnClick", function()
        if profList:IsShown() then profList:Hide() else BuildProfList(); profList:Show() end
    end)

    local resetBtn = CreateFrame("Button", nil, fp, "UIPanelButtonTemplate")
    resetBtn:SetSize(INNER_W, 24)
    resetBtn:SetPoint("TOPLEFT", profBtn, "BOTTOMLEFT", 0, -12)
    resetBtn:SetText(Localization["FILTER_RESET"])
    resetBtn:SetScript("OnClick", function()
        GP.filterName  = ""
        GP.filterRoles = {}
        GP.filterProf  = nil
        nameEB:SetText("")
        profBtn:SetText(Localization["FILTER_ALL_PROFS"])
        profList:Hide()
        for _, btn in ipairs(roleBtns) do btn._active = false; btn.UpdateAppearance() end
        GuildWeave.GuildPanel:Refresh()
    end)

    self.filterPanel    = fp
    self.filterProfList = profList
    self.filterNameEB   = nameEB
    self.filterRoleBtns = roleBtns
    self.filterProfBtn  = profBtn
end

function GuildWeave.GuildPanel:ToggleFilterPanel()
    if not self.filterPanel then self:CreateFilterPanel() end
    if self.filterPanel:IsShown() then
        self.filterPanel:Hide()
        if self.filterProfList then self.filterProfList:Hide() end
    else
        self.filterPanel:Show()
    end
end
