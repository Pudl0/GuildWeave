-- MemberContextMenu.lua
-- Officer-only right-click menu on Members-tab roster rows.

local Localization = GuildWeave.Localization

StaticPopupDialogs["GUILDWEAVE_DEATHSET_SET"] = {
    text = Localization["DEATHSET_DIALOG_TEXT"],
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 6,
    OnShow = function(self)
        self.EditBox:SetText("")
        self.EditBox:SetFocus()
    end,
    OnAccept = function(self)
        GuildWeave.Death:SetRemote(self.data, self.EditBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
        local dialog = self:GetParent()
        if not dialog then return end
        local button1 = (dialog.GetName and _G[dialog:GetName() .. "Button1"]) or dialog.button1
        if button1 and button1.Click then
            button1:Click()
        end
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local contextMenu = CreateFrame("Frame", "GuildWeaveMemberContextMenu", UIParent, "UIDropDownMenuTemplate")
local contextMenuTarget = nil

GuildWeave:RegisterDropdownAutoClose(contextMenu, function() contextMenuTarget = nil end)

UIDropDownMenu_Initialize(contextMenu, function(self, level)
    if not contextMenuTarget then return end
    local targetName = contextMenuTarget

    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.text = Localization["CONTEXTMENU_SET_DEATHSET"]
    info.func = function()
        CloseDropDownMenus()
        StaticPopup_Show("GUILDWEAVE_DEATHSET_SET", targetName, nil, targetName)
    end
    UIDropDownMenu_AddButton(info, level)
end, "MENU")

-- Public API
function GuildWeave.OfficerPanel:ShowMemberContextMenu(targetName)
    if not targetName or targetName == "" then return end
    contextMenuTarget = targetName
    ToggleDropDownMenu(1, nil, contextMenu, "cursor", 0, 0)
end
