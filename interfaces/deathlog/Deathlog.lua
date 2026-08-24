-- Deathlog.lua
-- Manages the death log window. Deathlog frame is declared in Deathlog.xml.

local FONT_SMALL = "GameFontNormalSmall"

local MIN_WIDTH = 250
local MIN_HEIGHT = 120
local MAX_WIDTH = 500
local MAX_HEIGHT = 350
local HEADER_HEIGHT = 30
local ROW_HEIGHT = 14
local LEFT_PADDING = 10
local RIGHT_PADDING = 10
local Localization = GuildWeave.Localization

local function CalculateColumnLayout(frameWidth)
    local availableWidth = frameWidth - LEFT_PADDING - RIGHT_PADDING
    return {
        math.floor(availableWidth * 0.40),
        math.floor(availableWidth * 0.40),
        math.floor(availableWidth * 0.20)
    }
end

local function CalculateMaxRows(frameHeight)
    local availableHeight = frameHeight - HEADER_HEIGHT - 30
    return math.max(1, math.floor(availableHeight / ROW_HEIGHT))
end

local function UpdateDeathlogLayout(frame)
    if not frame.columnHeaders or not frame.rows then return end

    local frameWidth = frame:GetWidth()
    local frameHeight = frame:GetHeight()
    local columnWidths = CalculateColumnLayout(frameWidth)
    local maxRows = CalculateMaxRows(frameHeight)

    local xOffset = LEFT_PADDING
    for i, header in ipairs(frame.columnHeaders) do
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, -HEADER_HEIGHT)
        header:SetWidth(columnWidths[i])
        if i == 3 then
            header:SetJustifyH("CENTER")
        else
            header:SetJustifyH("LEFT")
        end
        xOffset = xOffset + columnWidths[i] + 5
    end

    for i = 1, #frame.rows do
        local row = frame.rows[i]
        local rowFrame = frame.rowFrames[i]
        local highlight = frame.rowHighlights[i]
        local yOffset = -HEADER_HEIGHT - 20 - ((i - 1) * ROW_HEIGHT)

        if i <= maxRows then
            highlight:ClearAllPoints()
            highlight:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
            highlight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, yOffset)

            xOffset = LEFT_PADDING
            for j = 1, #row do
                row[j]:ClearAllPoints()
                row[j]:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset - 2)
                row[j]:SetWidth(columnWidths[j])
                if j == 3 then
                    row[j]:SetJustifyH("CENTER")
                else
                    row[j]:SetJustifyH("LEFT")
                end
                xOffset = xOffset + columnWidths[j] + 5
            end

            rowFrame:ClearAllPoints()
            rowFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
            rowFrame:SetSize(frameWidth - 20, ROW_HEIGHT)

            for _, cell in ipairs(row) do cell:Show() end
            rowFrame:Show()
        else
            for _, cell in ipairs(row) do cell:Hide() end
            highlight:Hide()
            rowFrame:Hide()
        end
    end

    GuildWeave:UpdateDeathlog()
end

function GuildWeave:CreateDeathlog()
    if self.DeathlogFrame then return end

    local frame = Deathlog

    local savedWidth = MIN_WIDTH
    local savedHeight = MIN_HEIGHT
    if GuildWeaveDB and GuildWeaveDB["deathlog_size"] then
        savedWidth = GuildWeaveDB["deathlog_size"].width or MIN_WIDTH
        savedHeight = GuildWeaveDB["deathlog_size"].height or MIN_HEIGHT
    end
    frame:SetSize(savedWidth, savedHeight)

    GuildWeave:RestoreFramePosition(frame, "deathlog_position", "BOTTOMLEFT", 40, 60)

    frame:SetBackdrop(GuildWeave.Constants.PANEL_BACKDROP)
    frame:SetBackdropColor(0.1, 0, 0, 0.8)
    frame:SetBackdropBorderColor(1, 0.55, 0.73, 1)
    frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        GuildWeave:SaveFramePosition(self, "deathlog_position")
    end)

    -- Smart resize grip: supports vertical and diagonal resizing
    local resizeGrip = DeathlogResizeGrip
    local startMouseX, startMouseY
    resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            startMouseX, startMouseY = GetCursorPosition()
            frame:StartSizing("BOTTOMRIGHT")
            frame:SetScript("OnUpdate", function()
                local currentX, currentY = GetCursorPosition()
                local deltaX = math.abs(currentX - startMouseX)
                local deltaY = math.abs(currentY - startMouseY)
                if deltaY > deltaX * 2 then
                    frame:StopMovingOrSizing()
                    frame:StartSizing("BOTTOM")
                elseif deltaX > 10 or deltaY > 10 then
                    frame:StopMovingOrSizing()
                    frame:StartSizing("BOTTOMRIGHT")
                end
            end)
        end
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        frame:SetScript("OnUpdate", nil)
        frame:StopMovingOrSizing()
        GuildWeaveDB = GuildWeaveDB or {}
        GuildWeaveDB["deathlog_size"] = {
            width = frame:GetWidth(),
            height = frame:GetHeight()
        }
        UpdateDeathlogLayout(frame)
    end)

    -- Icon: set FrameLevel relative to parent and apply circular masks
    local iconFrame = DeathlogIcon
    iconFrame:SetFrameLevel(frame:GetFrameLevel() + 2)

    local iconBorder = DeathlogIconBorder
    local borderMask = iconFrame:CreateMaskTexture()
    borderMask:SetAllPoints(iconBorder)
    borderMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    iconBorder:AddMaskTexture(borderMask)

    local iconBg = DeathlogIconBg
    iconBg:SetTexture(GuildWeave.Constants.MEDIA.MINIMAP_ICON)
    local iconMask = iconFrame:CreateMaskTexture()
    iconMask:SetPoint("CENTER")
    iconMask:SetSize(20, 20)
    iconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    iconBg:AddMaskTexture(iconMask)

    -- Header height (width determined by XML anchors)
    DeathlogHeaderBg:SetHeight(22)

    -- Title text
    DeathlogTitle:SetText(Localization["DEATHLOG_TITLE"])
    DeathlogTitle:SetTextColor(1, 0.85, 0.1)

    -- Column headers from XML globals
    local headers = {"Name", Localization["DEATHLOG_COL_CLASS"], "Level"}
    frame.columnHeaders = {DeathlogColHeader1, DeathlogColHeader2, DeathlogColHeader3}
    for i, header in ipairs(frame.columnHeaders) do
        header:SetText(headers[i])
        header:SetTextColor(1, 0.8, 0.1)
    end

    -- Dynamic rows (created in Lua; count derived from MAX_HEIGHT constants)
    local maxPossibleRows = math.floor((MAX_HEIGHT - HEADER_HEIGHT - 30) / ROW_HEIGHT)
    frame.rows = {}
    frame.rowFrames = {}
    frame.rowHighlights = {}

    for _ = 1, maxPossibleRows do
        local row = {}

        local highlight = frame:CreateTexture(nil, "BACKGROUND")
        highlight:SetHeight(ROW_HEIGHT)
        highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        highlight:Hide()
        table.insert(frame.rowHighlights, highlight)

        local rowFrame = CreateFrame("Frame", nil, frame)
        rowFrame:EnableMouse(true)
        table.insert(frame.rowFrames, rowFrame)

        for _ = 1, #headers do
            local cell = frame:CreateFontString(nil, "OVERLAY", FONT_SMALL)
            cell:SetText("")
            cell:SetJustifyV("MIDDLE")
            table.insert(row, cell)
        end
        table.insert(frame.rows, row)
    end

    self.DeathlogFrame = frame

    UpdateDeathlogLayout(frame)
end

function GuildWeave:UpdateDeathlog()
    if not self.DeathlogFrame then self:CreateDeathlog() end
    local frame = self.DeathlogFrame
    local data = self.DeathLogData or {}

    local maxRows = CalculateMaxRows(frame:GetHeight())

    local localizedToToken = {}
    for token, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do localizedToToken[name] = token end
    for token, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do localizedToToken[name] = token end

    for i = 1, maxRows do
        if i > #frame.rows then break end

        local row = frame.rows[i]
        local rowFrame = frame.rowFrames[i]
        local highlight = frame.rowHighlights[i]
        local entry = data[i]

        if entry and rowFrame:IsShown() then
            local classToken = localizedToToken[entry.class]
            local color = classToken and RAID_CLASS_COLORS[classToken]
            local safeName = GuildWeave:SanitizeText(entry.name) or "?"
            local safeClass = GuildWeave:SanitizeText(entry.class) or "?"
            local safeZone = GuildWeave:SanitizeText(entry.zone)

            row[1]:SetText(safeName)
            row[2]:SetText(color and string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, safeClass) or safeClass)
            row[3]:SetText(entry.level or "?")

            rowFrame:SetScript("OnEnter", function()
                highlight:Show()
                GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
                GameTooltip:ClearLines()
                if entry.discordHandle then
                    local safeHandle = GuildWeave:SanitizeText(entry.discordHandle)
                    GameTooltip:AddDoubleLine("Discord:", safeHandle, 0.8, 0.8, 0.8, 0.45, 0.63, 0.82)
                end
                GameTooltip:AddDoubleLine(Localization["DEATHLOG_TIP_CLASS"], safeClass, 0.8, 0.8, 0.8, 1, 1, 1)
                GameTooltip:AddDoubleLine("Level:", tostring(entry.level or "?"), 0.8, 0.8, 0.8, 1, 1, 1)
                if safeZone then
                    GameTooltip:AddDoubleLine("Zone:", safeZone, 0.8, 0.8, 0.8, 1, 1, 1)
                end
                if entry.cause then
                    local safeCause = GuildWeave:SanitizeText(entry.cause)
                    GameTooltip:AddDoubleLine(Localization["DEATHLOG_TIP_CAUSE"], safeCause, 0.8, 0.8, 0.8, 1, 0.3, 0.3)
                end
                if entry.lastWords then
                    local safeLastWords = GuildWeave:SanitizeText(entry.lastWords)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(Localization["DEATHLOG_TIP_LASTWORDS"], 0.8, 0.8, 0.8)
                    GameTooltip:AddLine('"' .. safeLastWords .. '"', 1, 0.85, 0.1, true)
                end
                GameTooltip:Show()
            end)
            rowFrame:SetScript("OnLeave", function()
                highlight:Hide()
                GameTooltip:Hide()
            end)

            for _, cell in ipairs(row) do
                if i % 2 == 0 then
                    cell:SetTextColor(0.9, 0.9, 0.9)
                else
                    cell:SetTextColor(0.8, 0.8, 0.8)
                end
            end
        elseif rowFrame:IsShown() then
            rowFrame:SetScript("OnEnter", nil)
            rowFrame:SetScript("OnLeave", nil)
            highlight:Hide()
            for _, cell in ipairs(row) do cell:SetText("") end
        end
    end
end

function GuildWeave:ToggleDeathlog()
    if not self.DeathlogFrame then
        self:CreateDeathlog()
        self:UpdateDeathlog()
        self.DeathlogFrame:Show()
    elseif self.DeathlogFrame:IsShown() then
        self.DeathlogFrame:Hide()
    else
        self:UpdateDeathlog()
        self.DeathlogFrame:Show()
    end
end
