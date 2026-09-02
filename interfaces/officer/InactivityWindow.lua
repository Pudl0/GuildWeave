-- InactivityWindow.lua
-- Inactive Members tab content for the officer panel.

local Localization = GuildWeave.Localization

local function BuildInactiveTab(content)
    local ICOLS = {
        { label = Localization["LBL_NAME"],             x = 0,   w = 110 },
        { label = Localization["LBL_LEVEL"],            x = 114, w = 40  },
        { label = Localization["INACTIVE_COL_RANK"],    x = 158, w = 110 },
        { label = Localization["INACTIVE_COL_OFFLINE"], x = 272, w = 80  },
    }
    for _, col in ipairs(ICOLS) do
        local hdr = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hdr:SetPoint("TOPLEFT", content, "TOPLEFT", col.x + 4, -20)
        hdr:SetWidth(col.w)
        hdr:SetJustifyH("LEFT")
        hdr:SetText(col.label)
        hdr:SetTextColor(1, 0.82, 0, 1)
    end

    local threshold = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    threshold:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
    threshold:SetTextColor(0.6, 0.6, 0.6, 1)
    threshold:SetText(string.format(Localization["INACTIVE_HEADER"], GuildWeave.Constants.INACTIVE_DAYS_THRESHOLD))

    local div = content:CreateTexture(nil, "ARTWORK")
    div:SetHeight(1)
    div:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    div:SetPoint("TOPLEFT",  content, "TOPLEFT",  4, -36)
    div:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, -36)

    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     content, "TOPLEFT",     4, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 8)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        sf:SetVerticalScroll(
            math.max(0, math.min(sf:GetVerticalScrollRange(), sf:GetVerticalScroll() - delta * 20))
        )
    end)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(content:GetWidth() - 24)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    content.rows = {}

    local function Refresh()
        if not content:IsShown() then return end
        for _, row in ipairs(content.rows) do row:Hide() end
        wipe(content.rows)

        local members = {}
        for _, member in ipairs(GuildWeave.GuildCache:GetFullRoster()) do
            if not member.isOnline then
                local y  = member.yearsOffline  or 0
                local mo = member.monthsOffline or 0
                local d  = member.daysOffline   or 0
                local isInactive, dur = false, Localization["INACTIVE_UNKNOWN"]
                if y > 0 then
                    isInactive, dur = true, string.format(Localization["INACTIVE_DUR_Y"], y)
                elseif mo > 0 then
                    isInactive, dur = true, string.format(Localization["INACTIVE_DUR_M"], mo)
                elseif d >= GuildWeave.Constants.INACTIVE_DAYS_THRESHOLD then
                    isInactive, dur = true, string.format(Localization["INACTIVE_DUR_D"], d)
                end
                if isInactive then
                    table.insert(members, {
                        name            = member.name,
                        fullName        = member.fullName,
                        level           = member.level or 0,
                        rank            = member.rank  or Localization["INACTIVE_UNKNOWN"],
                        displayDuration = dur,
                        sortableDays    = member.totalDaysOffline or 0,
                    })
                end
            end
        end

        table.sort(members, function(a, b)
            if a.sortableDays == b.sortableDays then return (a.level or 0) > (b.level or 0) end
            return a.sortableDays > b.sortableDays
        end)

        if #members == 0 then
            local msg = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 4, 0)
            msg:SetText(Localization["INACTIVE_NONE_FOUND"])
            msg:SetTextColor(0.6, 0.6, 0.6, 1)
            table.insert(content.rows, msg)
            scrollChild:SetHeight(20)
            return
        end

        local ROW_H = 20
        for idx, m in ipairs(members) do
            local row = CreateFrame("Frame", nil, scrollChild)
            row:SetSize(scrollChild:GetWidth(), ROW_H)
            row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_H)

            if idx % 2 == 0 then
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(1, 1, 1, 0.03)
            end

            local function Cell(text, xPos, w)
                local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                fs:SetPoint("LEFT", row, "LEFT", xPos + 4, 0)
                fs:SetWidth(w)
                fs:SetJustifyH("LEFT")
                fs:SetText(text)
                return fs
            end

            Cell(GuildWeave:SanitizeText(m.name), 0,   106)
            Cell(tostring(m.level),               114, 36)
            Cell(GuildWeave:SanitizeText(m.rank),  158, 106)
            Cell(m.displayDuration,                272, 76)

            if CanGuildRemove() then
                local kick = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                kick:SetSize(64, ROW_H - 2)
                kick:SetPoint("LEFT", row, "LEFT", 356, 0)
                kick:SetText(Localization["INACTIVE_REMOVE_BTN"])
                kick:SetScript("OnClick", function()
                    if not CanGuildRemove() then
                        GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR ..
                            Localization["INACTIVE_NO_PERM"] .. "|r")
                        return
                    end
                    StaticPopup_Show("CONFIRM_GUILD_KICK", m.fullName, nil, { memberName = m.fullName })
                end)
            end

            table.insert(content.rows, row)
        end

        scrollChild:SetHeight(math.max(1, #members * ROW_H))
        scrollFrame:SetVerticalScroll(0)
    end

    content.Refresh = Refresh
    GuildWeave.OfficerPanel.RefreshInactive = Refresh
end

GuildWeave.OfficerPanel.BuildInactiveTab = BuildInactiveTab
