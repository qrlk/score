script_name("SCORE")
script_version("01.06.2020")
script_author("qrlk")
script_description("textdraw that shows damage, kills, deaths, K/D")

local events = require 'lib.samp.events'
local inicfg = require 'inicfg'
local key = require("vkeys")

local settings = inicfg.load({
  score =
  {
    posX = 23,
    posY = 426,
    size1 = 0.4,
    size2 = 2,
    key1 = 49,
    key2 = 50,
    enable = true,
    key3 = 51,
    key4 = 52,
    key5 = 53,
  },
  stats =
  {
    dmg = 0,
    kills = 0,
    deaths = 0,
  },
}, 'score2')

count = 0
given = 0
k_given = 0
kills = 0
sendtype = 0
k_kills = 0
deaths = 0
mode = false

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end

  -- ������ ���, ���� ������ ��������� �������� ����������
  update("http://qrlk.me/dev/moonloader/score/stats.php", '['..string.upper(thisScript().name)..']: ', "http://vk.com/qrlk.mods", "scorechangelog")
  openchangelog("scorechangelog", "http://qrlk.me/changelog/score")
  -- ������ ���, ���� ������ ��������� �������� ����������
  
  sampRegisterChatCommand("score", function() lua_thread.create(function() updateMenu() submenus_show(mod_submenus_sa, '{348cb2}SCORE v.'..thisScript().version, '�������', '�������', '�����') end) end)
  sampAddChatMessage("SCORE v"..thisScript().version.." loaded! /score - ���������. <> by qrlk.", 0x348cb2)
  score()
  wait(-1)
end

function events.onSendGiveDamage(playerID, damage, weaponID, bodypart)
  if sampIsPlayerConnected(playerID) then
    result, handle2 = sampGetCharHandleBySampPlayerId(playerID)
    if result then
      health = sampGetPlayerHealth(playerID)
      if health < damage or health == 0 then
        kills = kills + 1
        k_kills = k_kills + 1
        settings.stats.kills = settings.stats.kills + 1
        inicfg.save(settings, "score2")
      end
    end
    k_given = k_given + damage
    given = given + damage
    settings.stats.dmg = settings.stats.dmg + damage
    inicfg.save(settings, "score2")
  end
end

function events.onSendTakeDamage(playerID, damage, weaponID, bodypart)
  if sampIsPlayerConnected(playerID) then
    killer = sampGetPlayerNickname(playerID)
    killer_id = playerID
    killer_w = weaponID
    killer_b = bodypart
  end
end

function score()
  if settings.score.enable then
    sampTextdrawCreate(440, "0", settings.score.posX, settings.score.posY)
    sampTextdrawSetStyle(440, 3)
    sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
    sampTextdrawSetOutlineColor(440, 1, - 16777216)

    lua_thread.create(
      function()
        while true do
          wait(200)
          if settings.score.enable and isCharDead(PLAYER_PED) then
            if killer ~= nil and killer_id ~= nil and killer_w ~= nil and killer_b ~= nil and k_given ~= nil and k_kills ~= nil then
              sampAddChatMessage("{7ef3fa}[SCORE]:{ef3226} "..killer.."{808080}["..killer_id.."]{ffffff} ���� ��� �� {ef3226}"..getweaponname(killer_w).."{ffffff} ����� � {ef3226}"..getbodypart(killer_b)..".", - 1)
              sampAddChatMessage("{7ef3fa}[SCORE]: {ffffff}�� ����� �� ������� {ef3226}"..math.floor(k_given).."{ffffff} �����, � ��� {ef3226}"..k_kills.."{ffffff} "..getending(k_kills)..".", - 1)
            end
            k_given = 0
            k_kills = 0
            deaths = deaths + 1
            settings.stats.deaths = settings.stats.deaths + 1
            inicfg.save(settings, "score2")
            while isCharDead(PLAYER_PED) ~= false do
              wait(200)
            end
          end
        end
      end
    )
    while true do
      wait(10)
      if isKeyDown(settings.score.key1) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("%2.1f", settings.stats.dmg))
        else
          sampTextdrawSetString(440, string.format("%2.1f", given))
        end
      elseif isKeyDown(settings.score.key2) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("K:%d", settings.stats.kills))
        else
          sampTextdrawSetString(440, string.format("K:%d", kills))
        end
      elseif isKeyDown(settings.score.key3) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("D:%d", settings.stats.deaths))
        else
          sampTextdrawSetString(440, string.format("D:%d", deaths))
        end
      elseif isKeyDown(settings.score.key4) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        if mode then
          sampTextdrawSetString(440, string.format("K/D:%2.1f", settings.stats.kills / settings.stats.deaths))
        else
          sampTextdrawSetString(440, string.format("K/D:%2.1f", kills / deaths))
        end
      elseif wasKeyPressed(settings.score.key5) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
        mode = not mode
        addOneOffSound(0.0, 0.0, 0.0, 1052)
        if mode then
          sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 65536)
        else
          sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
        end
      else
        if mode then
          sampTextdrawSetString(440, string.format("%2.1f", k_given))
        else
          sampTextdrawSetString(440, string.format("%2.1f", k_given))
        end
      end
    end
  end
end

function getending(count)
  count = count % 10
  if count == 0 then
    return "�������"
  elseif count == 1 then
    return "��������"
  elseif count == 2 or count == 3 or count == 4 then
    return "��������"
  elseif count >= 5 then
    return "�������"
  end
end

function resetscore()
  settings.stats.dmg = 0
  settings.stats.kills = 0
  settings.stats.deaths = 0
  k_given = 0
  given = 0
  kills = 0
  k_kills = 0
  deaths = 0
  addOneOffSound(0.0, 0.0, 0.0, 1052)
  inicfg.save(settings, "score2")
end

function changepos()
  local bckpX1 = settings.score.posX
  local bckpY1 = settings.score.posY
  local bckpS1 = settings.score.size1
  local bckpS2 = settings.score.size2
  sampShowDialog(3838, "��������� ��������� � �������.", "{ffcc00}��������� ��������� textdraw.\n{ffffff}�������� ��������� ����� � ������� ������� �����.\n\n{ffcc00}��������� ������� textdraw.\n{ffffff}�������� ������ ��������������� ����� � ������� {00ccff}'-'{ffffff} � {00ccff}'+'{ffffff}.\n{ffffff}�������� ������ �� ����������� ����� � ������� {00ccff}'9'{ffffff} � {00ccff}'0'{ffffff}.\n{ffffff}�������� ������ �� ��������� ����� � ������� {00ccff}'7'{ffffff} � {00ccff}'8'{ffffff}.\n\n{ffcc00}��� ������� ���������?\n{ffffff}������� \"Enter\", ����� ������� ���������.\n������� ������, ����� �������� ���������.\n� ���� ����� ������������ ������.", "� �����")
  while sampIsDialogActive(3838) == true do wait(100) end
  while true do
    wait(0)
    if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
      wait(0)
      if isKeyDown(40) and bckpY1 + 1 < 480 then bckpY1 = bckpY1 + 1 end
      if isKeyDown(38) and bckpY1 - 1 > 0 then bckpY1 = bckpY1 - 1 end
      if isKeyDown(37) and bckpX1 - 1 > 0 then bckpX1 = bckpX1 - 1 end
      if isKeyDown(39) and bckpX1 + 1 < 640 then bckpX1 = bckpX1 + 1 end
      if isKeyJustPressed(57) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
        end
      end
      if isKeyJustPressed(48) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
        end
      end
      if isKeyJustPressed(55) then
        if bckpS2 - 0.1 > 0 then
          bckpS2 = bckpS2 - 0.1
        end
      end
      if isKeyJustPressed(56) then
        if bckpS2 + 0.1 > 0 then
          bckpS2 = bckpS2 + 0.1
        end
      end
      if isKeyJustPressed(57) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
        end
      end
      if isKeyJustPressed(48) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
        end
      end
      if isKeyJustPressed(55) then
        if bckpS2 - 0.1 > 0 then
          bckpS2 = bckpS2 - 0.1
        end
      end
      if isKeyJustPressed(56) then
        if bckpS2 + 0.1 > 0 then
          bckpS2 = bckpS2 + 0.1
        end
      end
      if isKeyJustPressed(189) then
        if bckpS1 - 0.1 > 0 then
          bckpS1 = bckpS1 - 0.1
          bckpS2 = bckpS1 * 5
        end
      end
      if isKeyJustPressed(187) then
        if bckpS1 + 0.1 > 0 then
          bckpS1 = bckpS1 + 0.1
          bckpS2 = bckpS1 * 5
        end
      end
      sampTextdrawCreate(422, "999", bckpX1, bckpY1)
      sampTextdrawSetStyle(422, 3)
      sampTextdrawSetLetterSizeAndColor(422, bckpS1, bckpS2, - 1)
      sampTextdrawSetOutlineColor(422, 1, - 16777216)
      if isKeyJustPressed(13) then
        sampTextdrawDelete(422)
        settings.score.posX = bckpX1
        settings.score.posY = bckpY1
        settings.score.size1 = bckpS1
        settings.score.size2 = bckpS2
        addOneOffSound(0.0, 0.0, 0.0, 1052)
        inicfg.save(settings, "score2")
        sampTextdrawSetPos(440, settings.score.posX, settings.score.posY)
        sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
        break
      end
      if isKeyJustPressed(32) then
        sampTextdrawDelete(422)
        addOneOffSound(0.0, 0.0, 0.0, 1053)
        break
      end
    end
  end
end

function changehotkey(mode)
  local modes =
    {
      [1] = " ��� ������ �� �� �����",
      [2] = " ��� �������",
      [3] = " ��� �������",
      [4] = " ��� k/d",
      [5] = " ��� ����� ������ �����/�� �����"
    }
  if tonumber(mode) == nil or tonumber(mode) < 1 or tonumber(mode) > 5 then
    sampAddChatMessage("1) ���������� ����� �� �����: "..key.id_to_name(settings.score.key1)..". 2) ���������� ��������: "..key.id_to_name(settings.score.key2)..". 3) ���������� ������: "..key.id_to_name(settings.score.key3)..". 4) k/d: "..key.id_to_name(settings.score.key4)..". 5) �����/�� �����: "..key.id_to_name(settings.score.key5)..".", - 1)
    sampAddChatMessage("��������: /scorekey [1|2|3|4|5]", - 1)
  else
    mode = tonumber(mode)
    sampShowDialog(989, "��������� ������� �������"..modes[mode], "������� \"����\", ����� ���� ������� ������ �������.\n��������� ����� ��������.", "����", "�������")
    while sampIsDialogActive(989) do wait(100) end
    local resultMain, buttonMain, typ = sampHasDialogRespond(988)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 1 then
              settings.score.key1 = i
            end
            if mode == 2 then
              settings.score.key2 = i
            end
            if mode == 3 then
              settings.score.key3 = i
            end
            if mode == 4 then
              settings.score.key4 = i
            end
            if mode == 5 then
              settings.score.key5 = i
            end
            print(i)
            sampAddChatMessage("����������� ����� ������� ������� - "..key.id_to_name(i), - 1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "score2")
            ke1y = 1
            break
          end
        end
      end
    end
    ke1y = nil
  end
end

function getbodypart(part)
  local names = {
    [3] = "����",
    [4] = "����",
    [5] = "����� ����",
    [6] = "������ ����",
    [7] = "����� ����",
    [8] = "������ ����",
    [9] = "������"
  }
  return names[part]
end

function getweaponname(weapon) -- getweaponname by FYP
  local names = {
    [0] = "������",
    [1] = "�������",
    [2] = "������ ��� ������",
    [3] = "����������� �������",
    [4] = "����",
    [5] = "����",
    [6] = "������",
    [7] = "���",
    [8] = "������",
    [9] = "���������",
    [10] = "�������� �����",
    [11] = "�����",
    [12] = "���������",
    [13] = "������������ ���������",
    [14] = "������",
    [15] = "������",
    [16] = "�������",
    [17] = "������������� ����",
    [18] = "�������� ��������",
    [22] = "���������",
    [23] = "��������� � ����������",
    [24] = "Deagle",
    [25] = "Shotgun",
    [26] = "������",
    [27] = "������� ���������",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "��������",
    [34] = "����������� ��������",
    [35] = "���",
    [36] = "HS Rocket",
    [37] = "�������",
    [38] = "��������",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "�������� ���������",
    [42] = "������������",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute" }
return names[weapon]
end
--------------------------------------------------------------------------------
-------------------------------------MENU---------------------------------------
--------------------------------------------------------------------------------
function updateMenu()
  mod_submenus_sa = {
    {
      title = '���������� � �������',
      onclick = function()
        sampShowDialog(0, "{7ef3fa}/edith v."..thisScript().version.." - ���������� � ������� {00ff66}\"SCORE\"", "{00ff66}SCORE{ffffff}\n������� ������� �����, ������ � ����, �������� � ���������������� ����� ������.\n��� ������ ���������, �� ������� �� ��������� ���������� ���� ���� �� �����.\n\n������� {7ef3fa}"..key.id_to_name(settings.score.key1).."{ffffff}, ����� �������� ���� ����.\n������� {7ef3fa}"..key.id_to_name(settings.score.key2).."{ffffff}, ����� �������� ��������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key3).."{ffffff}, ����� �������� ������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key4).."{ffffff}, ����� �������� ����������� ������� � �������.\n������� {7ef3fa}"..key.id_to_name(settings.score.key5).."{ffffff}, ����� ������� �����: �� ����� (�����) ��� �� �� ����� (�������).", "����")
      end
    },
    {
      title = '���������� ����������',
      onclick = function()
        sampShowDialog(0, "{7ef3fa}���� ����������", "{00ff66}�� �����:{ffffff}\n����: "..tostring(k_given).."\n�������: "..tostring(k_kills).."\n{00ff66}�� �����:{ffffff}\n����: "..tostring(given).."\n�������: "..tostring(kills).."\n�������: "..tostring(deaths).."\n"..string.format("K/D: %2.1f", kills / deaths).."\n{00ff66}�� �� �����:{ffffff}\n����: "..string.format("%2.1f", settings.stats.dmg).."\n�������: "..tostring(settings.stats.kills).."\n�������: "..tostring(settings.stats.deaths).."\n"..string.format("K/D: %2.1f", settings.stats.kills / settings.stats.deaths), "����")
      end
    },
    {
      title = ' '
    },
    {
      title = '���/���� ������: '..tostring(settings.score.enable),
      onclick = function()
        settings.score.enable = not settings.score.enable
        if not settings.score.enable then
          sampTextdrawDelete(440)
        else
          thisScript():reload()
        end
        inicfg.save(settings, "score2")
      end
    },
    {
      title = ' '
    },
    {
      title = '�������� �������',
      onclick = function()
        lua_thread.create(resetscore)
      end
    },
    {
      title = ' '
    },
    {
      title = '�������� ������� � ������',
      onclick = function()
        lua_thread.create(changepos)
      end
    },
    {
      title = '�������� ������� ���������',
      submenu = {
        {
          title = '�������� ���� ���� - {7ef3fa}'..key.id_to_name(settings.score.key1),
          onclick = function()
            lua_thread.create(changehotkey, 1)
          end
        },
        {
          title = '�������� �������� - {7ef3fa}'..key.id_to_name(settings.score.key2),
          onclick = function()
            lua_thread.create(changehotkey, 2)
          end
        },
        {
          title = '�������� ������ - {7ef3fa}'..key.id_to_name(settings.score.key3),
          onclick = function()
            lua_thread.create(changehotkey, 3)
          end
        },
        {
          title = '�������� K/D - {7ef3fa}'..key.id_to_name(settings.score.key4),
          onclick = function()
            lua_thread.create(changehotkey, 4)
          end
        },
        {
          title = '����� ������ (����� - �����, ������� - �� �����) - {7ef3fa}'..key.id_to_name(settings.score.key5),
          onclick = function()
            lua_thread.create(changehotkey, 5)
          end
        },
      },
    }
  }
end
--------------------------------------------------------------------------------
------------------------------------UPDATE--------------------------------------
--------------------------------------------------------------------------------
function update(php, prefix, url, komanda)
  komandaA=komanda
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  local ffi = require 'ffi'
  ffi.cdef[[
	int __stdcall GetVolumeInformationA(
			const char* lpRootPathName,
			char* lpVolumeNameBuffer,
			uint32_t nVolumeNameSize,
			uint32_t* lpVolumeSerialNumber,
			uint32_t* lpMaximumComponentLength,
			uint32_t* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			uint32_t nFileSystemNameSize
	);
	]]
  local serial = ffi.new("unsigned long[1]", 0)
  ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
  serial = serial[0]
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)
  if thisScript().name == "ADBLOCK" then
    if mode == nil then mode = "unsupported" end
    php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&m='..mode..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  else
    php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  end
  downloadUrlToFile(php, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            if info.changelog ~= nil then
              changelogurl = info.changelog
            end
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix, komanda)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('��������� %d �� %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('�������� ���������� ���������.')
                      if komandaA ~= nil then
                        sampAddChatMessage((prefix..'���������� ���������! ��������� �� ���������� - /'..komandaA..'.'), color)
                      end
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'���������� ������ ��������. �������� ���������� ������..'), color)
                        update = false
                      end
                    end
                  end
                )
              end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': ���������� �� ���������.')
            end
          end
        else
          print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function openchangelog(komanda, url)
  sampRegisterChatCommand(komanda,
    function()
      lua_thread.create(
        function()
          if changelogurl == nil then
            changelogurl = url
          end
          sampShowDialog(222228, "{ff0000}���������� �� ����������", "{ffffff}"..thisScript().name.." {ffe600}���������� ������� ���� changelog ��� ���.\n���� �� ������� {ffffff}�������{ffe600}, ������ ���������� ������� ������:\n        {ffffff}"..changelogurl.."\n{ffe600}���� ���� ���� ���������, �� ������ ������� ��� ������ ����.", "�������", "��������")
          while sampIsDialogActive() do wait(100) end
          local result, button, list, input = sampHasDialogRespond(222228)
          if button == 1 then
            os.execute('explorer "'..changelogurl..'"')
          end
        end
      )
    end
  )
end
--------------------------------------------------------------------------------
--------------------------------------3RD---------------------------------------
--------------------------------------------------------------------------------
-- made by FYP
function submenus_show(menu, caption, select_button, close_button, back_button)
  select_button, close_button, back_button = select_button or 'Select', close_button or 'Close', back_button or 'Back'
  prev_menus = {}
  function display(menu, id, caption)
    local string_list = {}
    for i, v in ipairs(menu) do
      table.insert(string_list, type(v.submenu) == 'table' and v.title .. '  >>' or v.title)
    end
    sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, 4)
    repeat
      wait(0)
      local result, button, list = sampHasDialogRespond(id)
      if result then
        if button == 1 and list ~= -1 then
          local item = menu[list + 1]
          if type(item.submenu) == 'table' then -- submenu
            table.insert(prev_menus, {menu = menu, caption = caption})
            if type(item.onclick) == 'function' then
              item.onclick(menu, list + 1, item.submenu)
            end
            return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
          elseif type(item.onclick) == 'function' then
            local result = item.onclick(menu, list + 1)
            if not result then return result end
            return display(menu, id, caption)
          end
        else -- if button == 0
          if #prev_menus > 0 then
            local prev_menu = prev_menus[#prev_menus]
            prev_menus[#prev_menus] = nil
            return display(prev_menu.menu, id - 1, prev_menu.caption)
        end
        return false
        end
      end
    until result
  end
  return display(menu, 31337, caption or menu.title)
end
