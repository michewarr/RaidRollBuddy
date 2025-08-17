﻿local weird_vibes_mode = true
local frame_height = 140
local textArea_height = 100

local function rrb_print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function tsize(t)
  c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  if c > 0 then return c else return nil end
end

local discover = CreateFrame("GameTooltip", "CustomTooltip1", UIParent, "GameTooltipTemplate")

local function CheckItem(link)
  discover:SetOwner(UIParent, "ANCHOR_PRESERVE")
  discover:SetHyperlink(link)

  if discoverTextLeft1 and discoverTooltipTextLeft1:IsVisible() then
    local name = discoverTooltipTextLeft1:GetText()
    discoverTooltip:Hide()

    if name == (RETRIEVING_ITEM_INFO or "") then
      return false
    else
      return true
    end
  end
  return false
end

local function CreateCloseButton(frame)
  -- Add a close button
  local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeButton:SetWidth(25) -- Button size
  closeButton:SetHeight(25) -- Button size
  closeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2) -- Position at the top right

  -- Set textures if you want to customize the appearance
  closeButton:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
  closeButton:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
  closeButton:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")

  -- Hide the frame when the button is clicked
  closeButton:SetScript("OnClick", function()
      frame:Hide()
  end)
end

local function buttonProperties(button)
  button:SetWidth(35) -- Button size
  button:SetHeight(22) -- Button size
  button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
  button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
  button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
end

local function CreateRollButtons(frame)
  -- Add a MS button
  local RollMSButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  buttonProperties(RollMSButton)
  -- Add a OS button
  local RollOSButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  buttonProperties(RollOSButton)
  -- Add a SR button
  local RollSRButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  buttonProperties(RollSRButton)

  -- MS Button
  RollMSButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -6) -- Position at the top right
  RollMSButton:SetText("MS")
  RollMSButton:SetScript("OnClick", function()
    RandomRoll(1, 100)
  end)
  
  -- OS Button
  RollOSButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -27) -- Position at the top right
  RollOSButton:SetText("OS")
  RollOSButton:SetScript("OnClick", function()
    RandomRoll(1, 99)
  end)

  -- SR Button
  RollSRButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -48) -- Position at the top right
  RollSRButton:SetText("TM")
  RollSRButton:SetScript("OnClick", function()
    RandomRoll(1, 98)
  end)
end

local function CreateMainFrame()
  local frame = CreateFrame("Frame", "ItemRollFrame", UIParent)
  frame:SetWidth(145) -- Adjust size as needed
  frame:SetHeight(frame_height)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Position at center of the parent frame
  frame:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  frame:SetBackdropColor(0, 0, 0, 1) -- Black background with full opacity

  frame:SetMovable(true)
  frame:EnableMouse(true)

  frame:RegisterForDrag("LeftButton") -- Only start dragging with the left mouse button
  frame:SetScript("OnDragStart", function() frame:StartMoving() end)
  frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

  -- Create additional buttons
  CreateCloseButton(frame)
  CreateRollButtons(frame)
  frame:Hide()

  return frame
end



local itemRollFrame = CreateMainFrame()

local function InitItemInfo(frame)
  -- Create the texture for the item icon
  local icon = frame:CreateTexture()
  icon:SetWidth(50) -- Size of the icon
  icon:SetHeight(50) -- Size of the icon
  icon:SetPoint("TOP", frame, "TOP", 0, -10)

  -- Create a button for mouse interaction
  local iconButton = CreateFrame("Button", nil, frame)
  iconButton:SetWidth(50) -- Size of the icon
  iconButton:SetHeight(50) -- Size of the icon
  iconButton:SetPoint("TOP", frame, "TOP", 0, -10)

  -- Create a FontString for the frame hide timer
  local timerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  timerText:SetPoint("CENTER", frame, "TOPLEFT", 25, -34)
  timerText:SetFont(timerText:GetFont(), 20)

  -- Create a FontString for the item name
  local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  name:SetPoint("TOP", icon, "BOTTOM", 0, -10)

  frame.icon = icon
  frame.iconButton = iconButton
  frame.timerText = timerText
  frame.name = name
  frame.itemLink = ""

  local tt = CreateFrame("GameTooltip", "CustomTooltip2", UIParent, "GameTooltipTemplate")

  -- Set up tooltip
  iconButton:SetScript("OnEnter", function()
    tt:SetOwner(iconButton, "ANCHOR_RIGHT")
    tt:SetHyperlink(frame.itemLink)
    tt:Show()
  end)
  iconButton:SetScript("OnLeave", function()
    tt:Hide()
  end)
  iconButton:SetScript("OnClick", function()
    if ( IsControlKeyDown() ) then
      DressUpItemLink(frame.itemLink);
    elseif ( IsShiftKeyDown() and ChatFrameEditBox:IsVisible() ) then
      local itemName, itemLink, itemQuality, _, _, _, _, _, itemIcon = GetItemInfo(frame.itemLink)
      ChatFrameEditBox:Insert(ITEM_QUALITY_COLORS[itemQuality].hex.."\124H"..itemLink.."\124h["..itemName.."]\124h"..FONT_COLOR_CODE_CLOSE);
    end
  end)
end

-- Function to return colored text based on item quality
local function GetColoredTextByQuality(text, qualityIndex)
  -- Get the color associated with the item quality
  local r, g, b, hex = GetItemQualityColor(qualityIndex)
  -- Return the text wrapped in WoW's color formatting
  return string.format("%s%s|r", hex, text)
end

local function SetItemInfo(frame, itemLinkArg)
  local itemName, itemLink, itemQuality, _, _, _, _, _, itemIcon = GetItemInfo(itemLinkArg)
  if not frame.icon then InitItemInfo(frame) end

  -- if we know the item, and the quality isn't green+, don't show it
  if itemName and itemQuality < 2 then return false end
  if not itemIcon then
    frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.name:SetText("Unknown item, attempting to query...")
    -- could be an item we want to see, try to show it
    return true
  end

  frame.icon:SetTexture(itemIcon)
  frame.iconButton:SetNormalTexture(itemIcon)  -- Sets the same texture as the icon

  frame.name:SetText(GetColoredTextByQuality(itemName,itemQuality))

  frame.itemLink = itemLink
  return true
end

local time_elapsed = 0
local item_query = 0.5
local times = 5
local function ShowFrame(frame,duration,item)
  frame:SetScript("OnUpdate", function()
    time_elapsed = time_elapsed + arg1
    item_query = item_query - arg1
    if frame.timerText then frame.timerText:SetText(format("%.0f", duration - time_elapsed)) end
    if time_elapsed >= duration then
      frame:Hide()
      frame:SetScript("OnUpdate", nil)
      time_elapsed = 0
      item_query = 1.5
      times = 3
    end
    if times > 0 and item_query < 0 and not CheckItem(item) then
      times = times - 1
    else
      -- try to set item info, if it's not a valid item or too low quality, hide
      if not SetItemInfo(itemRollFrame,item) then frame:Hide() end
      times = 5
    end
  end)
  if frame.textArea then
    frame.textArea:SetHeight(textArea_height)
  end
  frame:SetHeight(frame_height)
  frame:Show()
end

local function CreateTextArea(frame)
  local textArea = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  textArea:SetHeight(textArea_height) -- Size of the icon
  textArea:SetPoint("TOP", frame, "TOP", 0, -95)
  textArea:SetJustifyH("LEFT")
  textArea:SetJustifyV("TOP")

  return textArea
end

local rollMessages = {}
local function UpdateTextArea(frame)
  if not frame.textArea then
    frame.textArea = CreateTextArea(frame)
  end
  -- Adapt rollMessage sorting
  table.sort(rollMessages, function(a, b)
    -- first sort maxRoll desc.
    if a.maxRoll ~= b.maxRoll then
      return a.maxRoll > b.maxRoll
    end
    -- if maxRoll is the same, sort roll desc.
    return a.roll > b.roll
  end)
  
  -- frame.textArea:SetTeClear()  -- Clear the existing messages
  local text = ""
  local count = 0
  for i, message in ipairs(rollMessages) do
      --if count >= 7 then break end
      text = text .. message.msg .. "\n"
      count = count + 1
  end
  if count >= 4 then
    frame.textArea:SetHeight(frame.textArea:GetHeight()+12)
    frame:SetHeight(frame:GetHeight() + 12) 
  end
  frame.textArea:SetText(text)
end

local function ExtractItemLinksFromMessage(message)
  local itemLinks = {}
  -- This pattern matches the standard item link structure in WoW
  for link in string.gfind(message, "|c.-|H(item:.-)|h.-|h|r") do
    -- rrb_print(link)
    table.insert(itemLinks, link)
  end
  return itemLinks
end

-- no good, seems like masterLooterRaidID always nil?
local function IsUnitMasterLooter(unit)
  local lootMethod, masterLooterPartyID, masterLooterRaidID = GetLootMethod()
  
  if lootMethod == "master" then
      if IsInRaid() then
          -- In a raid, use the raid ID to check
          return UnitIsUnit(unit, "raid" .. masterLooterRaidID)
      elseif IsInGroup() then
          -- In a party, use the party ID to check
          return UnitIsUnit(unit, "party" .. masterLooterPartyID)
      end
  end
  
  return false
end

local function HandleChatMessage(event, message, from)
  if event == "CHAT_MSG_SYSTEM" and itemRollFrame:IsShown() then
    if string.find(message, "rolls") and string.find(message, "(%d+)") then
      -- Add the new message to the rollMessages table
      -- table.insert(rollMessages, message)
      -- Optionally, update the display immediately
      -- UpdateScrollArea(itemRollFrame)
      local _,_,roller, roll, minRoll, maxRoll = string.find(message, "(%S+) rolls (%d+) %((%d+)%-(%d+)%)")
      -- rrb_print(roller .. " " .. roll .. " " .. minRoll .. " " .. maxRoll)
      if roller and roll then
          roll = tonumber(roll) -- Convert roll to a number
          maxRoll = tonumber(maxRoll)
          table.insert(rollMessages, { roller = roller, roll = roll, maxRoll = maxRoll, msg = message })
          time_elapsed = 0
          UpdateTextArea(itemRollFrame)
      end
    end
  elseif event == "CHAT_MSG_RAID_WARNING" then
    local lootMethod, _ = GetLootMethod()
    if lootMethod == "master" then -- check if there is a loot master
      local links = ExtractItemLinksFromMessage(message)
      if tsize(links) == 1 then
        if string.find(message, "^No one has need:") or
           string.find(message,"has been sent to") or
           string.find(message, " received ") then
          itemRollFrame:Hide()
          return
        elseif string.find(message,"Rolling Cancelled") or -- usually a cancel is accidental in my experience
               string.find(message,"seconds left to roll") or
               string.find(message,"Rolling is now Closed") then
          return
        end
        rollMessages = {}
        UpdateTextArea(itemRollFrame)
        time_elapsed = 0
        ShowFrame(itemRollFrame,FrameShownDuration,links[1])

        -- SetItemInfo(itemRollFrame,links[1])
      end
    end
  elseif event == "ADDON_LOADED" and arg1 == "RaidRollBuddy" then
    if not FrameShownDuration then FrameShownDuration = 10 end
  end
end

itemRollFrame:RegisterEvent("ADDON_LOADED")
itemRollFrame:RegisterEvent("CHAT_MSG_SYSTEM")
itemRollFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
itemRollFrame:SetScript("OnEvent", function () HandleChatMessage(event,arg1,arg2) end)

-- Register the slash command
SLASH_RAIDROLLBUDDY1 = '/rrb'

-- Command handler
SlashCmdList["RAIDROLLBUDDY"] = function(msg)
    local newDuration = tonumber(msg)
    if newDuration then
      if newDuration > 0 then
        FrameShownDuration = newDuration
        rrb_print("Frame shown duration set to " .. newDuration .. " seconds.")
      else
        rrb_print("Invalid duration. Please enter a number greater than 0.")
      end
    else
      ShowFrame(itemRollFrame,FrameShownDuration,"item:15723")
    end
end
