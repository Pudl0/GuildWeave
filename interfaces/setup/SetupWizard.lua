-- SetupWizard.lua
-- Unified first-login setup wizard.
-- Static frame defined in SetupWizard.xml; steps built dynamically at show time.

local steps       = {}   -- array of {id, render, onNext} tables
local currentStep = 1
local Localization = GuildWeave.Localization

-- ── Helpers ──────────────────────────────────────────────────────────────────

local FRAME_W = 460
local DOT_SIZE    = 12
local DOT_SPACING = 20

-- Orphaned content widgets are reparented here so they stop rendering
-- (SetParent(nil) can crash in some Classic builds).
local trashFrame = CreateFrame("Frame")
trashFrame:Hide()

local function ClearContent(frame)
    if frame.contentChildren then
        for _, child in ipairs(frame.contentChildren) do
            child:Hide()
            child:SetParent(trashFrame)
        end
    end
    frame.contentChildren = {}
end

local function TrackChild(frame, child)
    frame.contentChildren = frame.contentChildren or {}
    table.insert(frame.contentChildren, child)
end

-- ── Progress bar ─────────────────────────────────────────────────────────────

local function UpdateProgress(frame)
    local total = #steps
    frame.dotContainer:SetSize((total - 1) * DOT_SPACING + DOT_SIZE, DOT_SIZE)
    for i, dot in ipairs(frame.dots) do
        if i <= total then
            dot:Show()
            if i < currentStep then
                dot:SetColorTexture(0.3, 0.8, 0.3, 1)
            elseif i == currentStep then
                dot:SetColorTexture(1, 0.82, 0, 1)
            else
                dot:SetColorTexture(0.3, 0.3, 0.3, 1)
            end
        else
            dot:Hide()
        end
    end
    frame.stepLabel:SetText(string.format(Localization["WIZARD_STEP_LABEL"], currentStep, total))
end

-- ── Navigation ───────────────────────────────────────────────────────────────

local function ShowStep(frame, index)
    currentStep = index
    ClearContent(frame)

    local step = steps[index]
    if step then step.render(frame) end

    UpdateProgress(frame)

    if index > 1 then
        frame.backBtn:Enable()
        frame.backBtn:SetAlpha(1)
    else
        frame.backBtn:Disable()
        frame.backBtn:SetAlpha(0.4)
    end

    if index == #steps then
        frame.nextBtn:SetText(Localization["WIZARD_BTN_DONE"])
    else
        frame.nextBtn:SetText(Localization["WIZARD_BTN_NEXT"])
    end
end

local function NextStep(frame)
    local step = steps[currentStep]
    local ok = true
    if step and step.onNext then ok = step.onNext(frame) end
    if not ok then return end

    if currentStep < #steps then
        ShowStep(frame, currentStep + 1)
    else
        frame:Hide()
        GuildWeave.GuildProfiles:Broadcast()
    end
end

local function PrevStep(frame)
    if currentStep > 1 then ShowStep(frame, currentStep - 1) end
end

-- ── Frame wiring (XML frame + Lua behaviour) ──────────────────────────────────

local WizardFrame = GuildWeaveSetupWizard

local function WireFrame()
    local frame = WizardFrame

    frame:SetBackdrop(GuildWeave.Constants.BACKDROP)
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)

    local title = _G["GuildWeaveSetupWizardTitle"]
    title:SetText(GuildWeave.displayName .. " Setup")
    title:SetTextColor(1, 0.82, 0, 1)

    frame.dotContainer = _G["GuildWeaveSetupWizardDotContainer"]
    frame.dots = {}
    for i = 1, 5 do
        frame.dots[i] = _G["GuildWeaveSetupWizardDotContainerDot" .. i]
    end

    frame.stepLabel = _G["GuildWeaveSetupWizardStepLabel"]
    frame.stepLabel:SetPoint("TOP", frame.dotContainer, "BOTTOM", 0, -4)
    frame.stepLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    local divTop = _G["GuildWeaveSetupWizardDivTop"]
    divTop:SetPoint("TOP", frame.stepLabel, "BOTTOM", 0, -8)

    frame.contentAnchor = _G["GuildWeaveSetupWizardContentAnchor"]
    frame.contentAnchor:SetPoint("TOPLEFT", divTop, "BOTTOMLEFT", 0, 0)

    frame.backBtn = _G["GuildWeaveSetupWizardBackBtn"]
    frame.backBtn:SetText(Localization["WIZARD_BTN_BACK"])
    frame.backBtn:SetScript("OnClick", function() PrevStep(frame) end)

    frame.nextBtn = _G["GuildWeaveSetupWizardNextBtn"]
    frame.nextBtn:SetText(Localization["WIZARD_BTN_NEXT"])
    frame.nextBtn:SetScript("OnClick", function() NextStep(frame) end)
end

WireFrame()

-- ── Step renderers ────────────────────────────────────────────────────────────

local function RenderDiscord(frame)
    local f = frame.contentAnchor

    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -20)
    lbl:SetWidth(FRAME_W - 40)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(Localization["WIZARD_DISCORD_PROMPT"])
    TrackChild(frame, lbl)

    local eb = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    eb:SetSize(FRAME_W - 140, 28)
    eb:SetPoint("TOP", lbl, "BOTTOM", 0, -14)
    eb:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    eb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(8, 8, 0, 0)
    eb:SetAutoFocus(true)
    eb:SetMaxLetters(50)
    eb:SetText(DiscordHandle or "")
    eb:SetScript("OnEnterPressed", function() NextStep(frame) end)
    TrackChild(frame, eb)

    frame._discordEditBox = eb
end

local function OnNextDiscord(frame)
    local eb = frame._discordEditBox
    if not eb then return true end
    local handle = eb:GetText():match("^%s*(.-)%s*$")
    if handle == "" then
        GuildWeave:Print(GuildWeave.Constants.COLORS.WARNING ..
            Localization["WIZARD_DISCORD_REQUIRED"] .. "|r")
        return false
    end
    DiscordHandle = handle
    return true
end

local function RenderPronouns(frame)
    local f = frame.contentAnchor

    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -20)
    lbl:SetWidth(FRAME_W - 40)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(Localization["WIZARD_PRONOUNS_PROMPT"])
    TrackChild(frame, lbl)

    local eb = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    eb:SetSize(FRAME_W - 140, 28)
    eb:SetPoint("TOP", lbl, "BOTTOM", 0, -14)
    eb:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    eb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(8, 8, 0, 0)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(30)
    eb:SetText(Pronouns or "")
    eb:SetScript("OnEnterPressed", function() NextStep(frame) end)
    TrackChild(frame, eb)

    frame._pronounsEditBox = eb
end

local function OnNextPronouns(frame)
    local eb = frame._pronounsEditBox
    if eb then
        local val = eb:GetText():match("^%s*(.-)%s*$")
        Pronouns = val
    end
    return true
end

local function RenderRole(frame)
    local f = frame.contentAnchor

    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -24)
    lbl:SetWidth(FRAME_W - 40)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(Localization["WIZARD_ROLE_PROMPT"])
    TrackChild(frame, lbl)

    local roles = GuildWeave.Constants.ROLES
    local btnW   = 90
    local totalW = btnW * #roles + 10 * (#roles - 1)
    local startX = -(totalW / 2) + btnW / 2

    frame._selectedRoles = {}
    if GuildWeaveOwnProfile and GuildWeaveOwnProfile.role then
        for part in GuildWeaveOwnProfile.role:gmatch("[^/]+") do
            frame._selectedRoles[part] = true
        end
    end
    frame._roleBtns = {}

    local function RefreshRoleButtons()
        for _, entry in ipairs(frame._roleBtns) do
            if frame._selectedRoles[entry.name] then
                entry.btn:SetNormalFontObject(GameFontHighlight)
            else
                entry.btn:SetNormalFontObject(GameFontNormal)
            end
        end
    end

    for i, roleName in ipairs(roles) do
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(btnW, 30)
        btn:SetPoint("TOP", lbl, "BOTTOM", startX + (i - 1) * (btnW + 10), -20)
        btn:SetText(roleName)
        TrackChild(frame, btn)
        table.insert(frame._roleBtns, { name = roleName, btn = btn })

        btn:SetScript("OnClick", function()
            if frame._selectedRoles[roleName] then
                frame._selectedRoles[roleName] = nil
            else
                frame._selectedRoles[roleName] = true
            end
            RefreshRoleButtons()
        end)
    end

    RefreshRoleButtons()
end

local function OnNextRole(frame)
    local parts = {}
    for _, roleName in ipairs(GuildWeave.Constants.ROLES) do
        if frame._selectedRoles[roleName] then
            table.insert(parts, roleName)
        end
    end
    if #parts == 0 then
        GuildWeave:Print(GuildWeave.Constants.COLORS.WARNING ..
            Localization["WIZARD_ROLE_REQUIRED"] .. "|r")
        return false
    end
    GuildWeaveOwnProfile = GuildWeaveOwnProfile or {}
    GuildWeaveOwnProfile.role = table.concat(parts, "/")
    return true
end

local function RenderProfessions(frame)
    local f = frame.contentAnchor

    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 20, -16)
    lbl:SetWidth(FRAME_W - 40)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(Localization["WIZARD_PROF_PROMPT"])
    TrackChild(frame, lbl)

    local detected = GuildWeave.GuildProfiles:DetectProfessions()
    frame._profFields = {}
    local SKILL_X = 240

    for slot = 1, 2 do
        local d = detected[slot]
        local yOff = -20 - (slot - 1) * 68

        local nameLbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, yOff)
        nameLbl:SetText(string.format(Localization["WIZARD_PROF_LABEL"], slot))
        nameLbl:SetTextColor(0.8, 0.8, 0.8, 1)
        TrackChild(frame, nameLbl)

        local skillLbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        skillLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", SKILL_X, yOff)
        skillLbl:SetText("Skill:")
        skillLbl:SetTextColor(0.8, 0.8, 0.8, 1)
        TrackChild(frame, skillLbl)

        local nameEb = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
        nameEb:SetSize(225, 24)
        nameEb:SetPoint("TOPLEFT", nameLbl, "BOTTOMLEFT", 0, -4)
        nameEb:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
        nameEb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        nameEb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        nameEb:SetFontObject("GameFontHighlight")
        nameEb:SetTextInsets(6, 6, 0, 0)
        nameEb:SetAutoFocus(false)
        nameEb:SetMaxLetters(40)
        nameEb:SetText(d and d.name or
            (GuildWeaveOwnProfile and GuildWeaveOwnProfile["prof"..slot] or ""))
        TrackChild(frame, nameEb)

        local skillEb = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
        skillEb:SetSize(100, 24)
        skillEb:SetPoint("TOPLEFT", skillLbl, "BOTTOMLEFT", 0, -4)
        skillEb:SetBackdrop(GuildWeave.Constants.POPUPBACKDROP)
        skillEb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        skillEb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        skillEb:SetFontObject("GameFontHighlight")
        skillEb:SetTextInsets(6, 6, 0, 0)
        skillEb:SetAutoFocus(false)
        skillEb:SetMaxLetters(7)
        if d then
            skillEb:SetText(d.rank .. "/" .. d.maxRank)
        else
            local cached = GuildWeaveOwnProfile and GuildWeaveOwnProfile["prof"..slot.."rank"]
            skillEb:SetText(cached and tostring(cached) or "")
        end
        TrackChild(frame, skillEb)

        frame._profFields[slot] = { nameEb = nameEb, skillEb = skillEb }
    end

    local skipBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    skipBtn:SetSize(130, 26)
    skipBtn:SetPoint("TOP", frame._profFields[2].nameEb, "BOTTOM", 0, -16)
    skipBtn:SetText(Localization["WIZARD_PROF_SKIP"])
    skipBtn:SetScript("OnClick", function()
        GuildWeaveOwnProfile = GuildWeaveOwnProfile or {}
        GuildWeaveOwnProfile.skipProfessions = true
        NextStep(frame)
    end)
    TrackChild(frame, skipBtn)
end

local function OnNextProfessions(frame)
    GuildWeaveOwnProfile = GuildWeaveOwnProfile or {}
    for slot = 1, 2 do
        local fields = frame._profFields and frame._profFields[slot]
        if fields then
            local name = fields.nameEb:GetText():match("^%s*(.-)%s*$")
            local skillRaw = fields.skillEb:GetText():match("^%s*(.-)%s*$")
            local rank = tonumber(skillRaw:match("^(%d+)")) or nil
            GuildWeaveOwnProfile["prof"..slot]         = (name ~= "") and name or nil
            GuildWeaveOwnProfile["prof"..slot.."rank"] = rank
        end
    end
    return true
end

-- ── Public API ────────────────────────────────────────────────────────────────

function GuildWeave:BuildWizardSteps(forceAll)
    steps = {}

    if forceAll or not DiscordHandle or DiscordHandle == "" then
        table.insert(steps, { id = "discord",     render = RenderDiscord,     onNext = OnNextDiscord })
    end
    if forceAll or Pronouns == nil then
        table.insert(steps, { id = "pronouns",    render = RenderPronouns,    onNext = OnNextPronouns })
    end
    if forceAll or not GuildWeaveOwnProfile or not GuildWeaveOwnProfile.role then
        table.insert(steps, { id = "role",        render = RenderRole,        onNext = OnNextRole })
    end
    if forceAll or (not (GuildWeaveOwnProfile and GuildWeaveOwnProfile.skipProfessions)
        and (not GuildWeaveOwnProfile or not GuildWeaveOwnProfile.prof1)) then
        table.insert(steps, { id = "professions", render = RenderProfessions, onNext = OnNextProfessions })
    end
end

function GuildWeave:ShowSetupWizard(forceAll)
    GuildWeave:BuildWizardSteps(forceAll)
    if #steps == 0 then return end

    currentStep = 1
    ShowStep(WizardFrame, 1)
    WizardFrame:Show()
end

function GuildWeave:InitializeSetupWizard()
    GuildWeave.EventManager:RegisterHandler("PLAYER_ENTERING_WORLD",
        function()
            C_Timer.After(6, function()
                GuildWeave:MigrateFromGuildNoteIfNeeded()
                C_Timer.After(0.5, function()
                    GuildWeave:ShowSetupWizard(false)
                end)
            end)
        end, 0, "SetupWizardInit")

    SLASH_SETUPWIZARD1 = '/gwsetup'
    SlashCmdList["SETUPWIZARD"] = function()
        GuildWeave:ShowSetupWizard(true)
    end
end
