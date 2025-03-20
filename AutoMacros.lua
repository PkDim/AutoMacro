

local textFields = {};
local ReplaceWords = {"party1","party2", "party3","arena1","arena2","arena3"};
local MacrosList = {};


local ResultRoleSearch = {};


--combat check
local function IsInCombat()
    return UnitAffectingCombat("player")
end

--role search
local function PartyIdSearch()
    ResultRoleSearch[1] = "party1"
    ResultRoleSearch[2] = "party1"
    ResultRoleSearch[3] = "arena1"
 
   
    for N=1,2 do
        local gUnit = "party"..N;
        local rawRole; 
        rawRole = UnitGroupRolesAssigned(gUnit);
        if string.find(rawRole,"HEALER")  or string.find(rawRole,"TANK") then
            ResultRoleSearch[1] = "party"..N;
        end
        if string.find(rawRole,"DAMAGER") then
            ResultRoleSearch[2] = "party"..N;
        end       
    end

             
    
    for i = 1, GetNumArenaOpponentSpecs() do
        local specID = GetArenaOpponentSpec(i)
        if specID and specID > 0 then
            local _, _, _, _, roleType = GetSpecializationInfoByID(specID)
            if string.find(roleType,"HEALER") or string.find(roleType,"TANK") then
                if i ~= "" and i ~= nil then
                    ResultRoleSearch[3] = "arena"..i
                    break
                end
            end
        end
    end
    
    
    
    
end


-- Change one macro 
local function ChangeMacros(NameOfMacro,ValueOfChange)
    local TextMacro;
    local EditOfMacro;
    TextMacro = GetMacroBody(NameOfMacro);
    for _, word in ipairs(ReplaceWords) do
        TextMacro = TextMacro:gsub(word, ValueOfChange)
    end
    local macroIndex = GetMacroIndexByName(NameOfMacro);
    if not UnitAffectingCombat("player") then
        EditMacro(macroIndex, nil, nil, TextMacro);
    end
end

--Recording found roles in the macro list
local function ReplacePartyMacros(macrosList, rolesList)
    local sortedKeys = {}

  
    for key in pairs(macrosList) do
        table.insert(sortedKeys, key)
    end

   
    table.sort(sortedKeys)

   
    local index = 1
    for _, key in ipairs(sortedKeys) do
        local values = macrosList[key]
        local secondValue = rolesList[index]
        if secondValue then
            for _, value in ipairs(values) do
                if value ~= "" and value ~= nil then
                    ChangeMacros(value, secondValue)
                end
            end
            index = index + 1
            
        end
    end
end
    
   

--Save params in WTF AutoMacros
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "AutoMacros" then
            if not AutoMacros then
                AutoMacros = {};
                AutoMacros["1_AlliedHeal"] = {};
                AutoMacros["2_AlliedDamager"] = {};
                AutoMacros["3_EnemyArenaHeal"] = {};
            end
            -- Загрузка сохранённых данных
            MacrosList = AutoMacros

           
            

            -- Отслеживание выхода из игры для сохранения данных
            self:RegisterEvent("PLAYER_LOGOUT")
        end
    elseif event == "PLAYER_LOGOUT" then
       
        AutoMacros = AutoMacros
    end
end

--Interface

SLASH_HELLOWORLD1 = '/am'; 
function SlashCmdList.HELLOWORLD(msg, editbox)
    local MyAddon = {}
    MyAddon.groups = {}
    MyAddon.frame = CreateFrame("Frame", "MyAddonFrame", UIParent, "BasicFrameTemplateWithInset")
    MyAddon.frame:SetSize(400, 600)
    MyAddon.frame:SetPoint("CENTER")
    MyAddon.frame:SetMovable(true)
    MyAddon.frame:EnableMouse(true)
    MyAddon.frame:RegisterForDrag("LeftButton")
    MyAddon.frame:SetScript("OnDragStart", MyAddon.frame.StartMoving)
    MyAddon.frame:SetScript("OnDragStop", MyAddon.frame.StopMovingOrSizing)

    MyAddon.frame.title = MyAddon.frame:CreateFontString(nil, "OVERLAY")
    MyAddon.frame.title:SetFontObject("GameFontHighlight")
    MyAddon.frame.title:SetPoint("LEFT", MyAddon.frame.TitleBg, "LEFT", 5, 0)
    MyAddon.frame.title:SetText("Auto Macros")

    MyAddon.scrollFrame = CreateFrame("ScrollFrame", "MyAddonScrollFrame", MyAddon.frame, "UIPanelScrollFrameTemplate")
    MyAddon.scrollFrame:SetSize(380, 500)
    MyAddon.scrollFrame:SetPoint("TOPLEFT", MyAddon.frame, "TOPLEFT", 10, -30)

    MyAddon.scrollChild = CreateFrame("Frame", "MyAddonScrollChild", MyAddon.scrollFrame)
    MyAddon.scrollChild:SetSize(380, 1000)
    MyAddon.scrollFrame:SetScrollChild(MyAddon.scrollChild)

    MyAddon.data = MacrosList

    local function createDropdown(parent, items, width)
        local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", -16, -5)
        UIDropDownMenu_SetWidth(dropdown, width)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            if items and #items > 0 then
                for _, item in ipairs(items) do
                    info.text = item
                    info.func = function()
                        UIDropDownMenu_SetSelectedName(dropdown, item)
                    end
                    UIDropDownMenu_AddButton(info)
                end
            else
                info.text = "NULL"
                info.func = function()
                    UIDropDownMenu_SetSelectedName(dropdown, "NULL")
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        return dropdown
    end

    local function createGroup(parent, groupName, macros, index)
        local groupFrame = CreateFrame("Frame", nil, parent)
        groupFrame:SetSize(360, 150)

        groupFrame.title = groupFrame:CreateFontString(nil, "OVERLAY")
        groupFrame.title:SetFontObject("GameFontNormalLarge")
        groupFrame.title:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 10, -10)
        groupFrame.title:SetText(groupName)

        groupFrame.dropdown = createDropdown(groupFrame, macros, 140)
        groupFrame.dropdown:SetPoint("TOPLEFT", groupFrame.title, "BOTTOMLEFT", -10, -20)

        groupFrame.inputBox = CreateFrame("EditBox", nil, groupFrame, "InputBoxTemplate")
        groupFrame.inputBox:SetSize(140, 30)
        groupFrame.inputBox:SetPoint("TOPLEFT", groupFrame.dropdown, "TOPRIGHT", 30, -7)
        groupFrame.inputBox:SetAutoFocus(false)
        groupFrame.inputBox:SetText("Macro name")

        groupFrame.submitButton = CreateFrame("Button", nil, groupFrame, "GameMenuButtonTemplate")
        groupFrame.submitButton:SetSize(150, 30)
        groupFrame.submitButton:SetPoint("TOPLEFT", groupFrame.dropdown, "BOTTOMLEFT", 16, -10)
        groupFrame.submitButton:SetText("Remove from group")
        groupFrame.submitButton:SetNormalFontObject("GameFontNormal")
        groupFrame.submitButton:SetHighlightFontObject("GameFontHighlight")

        groupFrame.inputSubmitButton = CreateFrame("Button", nil, groupFrame, "GameMenuButtonTemplate")
        groupFrame.inputSubmitButton:SetSize(100, 30)
        groupFrame.inputSubmitButton:SetPoint("TOPLEFT", groupFrame.inputBox, "BOTTOMLEFT", 0, -10)
        groupFrame.inputSubmitButton:SetText("Add")
        groupFrame.inputSubmitButton:SetNormalFontObject("GameFontNormal")
        groupFrame.inputSubmitButton:SetHighlightFontObject("GameFontHighlight")

        if index == 1 then
            groupFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
        else
            groupFrame:SetPoint("TOPLEFT", MyAddon.groups[index-1], "BOTTOMLEFT", 0, -20)
        end

        --Interface ends

        -- delete macro from drop down
        groupFrame.submitButton:SetScript("OnClick", function()
            local selectedValue = UIDropDownMenu_GetSelectedName(groupFrame.dropdown)
            local macrosname = "";
            --selectedValue groupName
            for key, val in pairs(MacrosList) do
                if key == groupName then
                    for i, macroname in pairs(MacrosList[key]) do 
                        if macroname == selectedValue then
                            table.remove(MacrosList[groupName],i)
                            macrosname = macroname
                        end
                    end
                end
            end
            
            print("Your macros --"..macrosname.."-- removed from group!")
        end)

        -- add new macro
        groupFrame.inputSubmitButton:SetScript("OnClick", function()
            local inputText = groupFrame.inputBox:GetText()
            --groupName inputText
            local checkflag = 0
            if inputText ~= "" and inputText ~= nil then
                for key, val in pairs(MacrosList) do
                   
                    for i, macroname in pairs(MacrosList[key]) do 
                        if macroname == inputText then
                            checkflag = 1
                            print("You already have --"..macroname.."-- in >"..key.."< group!")
                        end
                    end
                    
                end
                if checkflag == 0 then
                    for key, val in pairs(MacrosList) do
                        if key == groupName then
                            table.insert(MacrosList[key],inputText)
                        end
                    end
                    groupFrame.inputBox:SetText("Saved")
                end
            end
        end)
        return groupFrame
    end

    local function createAllGroups()
        local sortedKeys = {}
    
        
        for groupName in pairs(MyAddon.data) do
            table.insert(sortedKeys, groupName)
        end
    
        
        table.sort(sortedKeys)
    
       
        local index = 1
        for _, groupName in ipairs(sortedKeys) do
            local macros = MyAddon.data[groupName]
            local groupFrame = createGroup(MyAddon.scrollChild, groupName, macros, index)
            table.insert(MyAddon.groups, groupFrame)
            index = index + 1
        end
    end

    createAllGroups()
end


-- Updates on events, lame trggered multy times
local frameCheck = CreateFrame("Frame")
frameCheck:RegisterEvent("ARENA_OPPONENT_UPDATE")
frameCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
frameCheck:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
frameCheck:SetScript("OnEvent", function(self, event, ...)
    
   if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" or event == "GROUP_ROSTER_UPDATE") and not IsInCombat() then
        local inInstance, instanceType = IsInInstance()
            if inInstance and instanceType == "arena" then
            PartyIdSearch()
            ReplacePartyMacros(MacrosList,ResultRoleSearch);
        end
    end
    
end)




--Frame for save params in WTF
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)