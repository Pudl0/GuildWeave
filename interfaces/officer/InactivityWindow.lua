-- InactivityWindow.lua
-- Displays a list of inactive guild members for officers.
-- Frame shell defined in InactivityWindow.xml.

local Localization = GuildWeave.Localization

local window       -- GuildWeaveInactivityWindow, wired on first open
local scrollChild
local trashFrame
local inactiveRows = {}

local function WireWindow()
    local f = GuildWeaveInactivityWindow

    f:SetBackdrop(GuildWeave.Constants.BACKDROP)
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    local header = _G["GuildWeaveInactivityWindowHeader"]
    header:SetText(string.format(Localization["INACTIVE_HEADER"], GuildWeave.Constants.INACTIVE_DAYS_THRESHOLD))

    _G["GuildWeaveInactivityWindowCloseBtn"]:SetScript("OnClick", function() f:Hide() end)

    local scrollFrame = _G["GuildWeaveInactivityWindowScrollFrame"]

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth() - 20)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Column headers
    local headerRow = CreateFrame("Frame", nil, scrollChild)
    headerRow:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
    headerRow:SetWidth(scrollChild:GetWidth() - 20)
    headerRow:SetHeight(20)

    local cols = {
        { text = "Name",                                 x = 0,   w = 150, align = "LEFT" },
        { text = "Level",                                x = 160, w = 40,  align = "CENTER" },
        { text = Localization["INACTIVE_COL_RANK"],      x = 210, w = 120, align = "LEFT" },
        { text = Localization["INACTIVE_COL_OFFLINE"],   x = 340, w = 80,  align = "LEFT" },
    }
    for _, col in ipairs(cols) do
        local fs = headerRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", headerRow, "TOPLEFT", col.x, 0)
        fs:SetWidth(col.w)
        fs:SetJustifyH(col.align)
        fs:SetText(col.text)
    end

    -- Row container (positioned below header row)
    local container = CreateFrame("Frame", nil, scrollChild)
    container:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -35)
    container:SetWidth(scrollChild:GetWidth() - 20)
    container:SetHeight(1)

    trashFrame = CreateFrame("Frame")
    trashFrame:Hide()

    local function UpdateWindow()
        for _, row in ipairs(inactiveRows) do
            row:Hide()
            row:SetParent(trashFrame)
        end
        wipe(inactiveRows)

        if not IsInGuild() then return end

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

        local ROW_H   = 20
        local rowYOff = 0
        if #members > 0 then
            for _, m in ipairs(members) do
                local row = CreateFrame("Frame", nil, container)
                row:SetSize(container:GetWidth(), ROW_H)
                row:SetPoint("TOPLEFT", 0, rowYOff)

                local function addCell(x, w, align, text)
                    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    fs:SetPoint("TOPLEFT", row, "TOPLEFT", x, 0)
                    fs:SetWidth(w)
                    fs:SetJustifyH(align)
                    fs:SetText(text)
                end
                addCell(0,   150, "LEFT",   m.name)
                addCell(160, 40,  "CENTER", m.level)
                addCell(210, 120, "LEFT",   m.rank)
                addCell(340, 80,  "LEFT",   m.displayDuration)

                if CanGuildRemove() then
                    local kick = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                    kick:SetSize(80, ROW_H - 2)
                    kick:SetPoint("TOPLEFT", row, "TOPLEFT", 430, 0)
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

                table.insert(inactiveRows, row)
                rowYOff = rowYOff - ROW_H
            end
            container:SetHeight(math.max(1, #members * ROW_H))
        else
            local none = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            none:SetPoint("TOP", container, "TOP", 0, 0)
            none:SetText(Localization["INACTIVE_NONE_FOUND"])
            table.insert(inactiveRows, none)
            container:SetHeight(20)
        end

        scrollChild:SetHeight(math.max(scrollFrame:GetHeight(), math.abs(rowYOff) + 50))
        scrollFrame:SetVerticalScroll(0)
    end

    f.Update = UpdateWindow
    return f
end

function GuildWeave:ToggleInactivityWindow()
    if not window then window = WireWindow() end
    if window:IsShown() then
        window:Hide()
    else
        window:Show()
        window:Update()
    end
end
