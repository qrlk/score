--01.07.19
script_name("SCORE")
script_version("0.1")
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
    key3 = 51,
    key4 = 52,
  },
  stats =
  {
    dmg = 0,
    kills = 0,
    deaths = 0,
  },
}, 'score')

given = 0
kills = 0
deaths = 0
last_id = -1
mode = false
last_time = -1
function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  sampAddChatMessage("SCORE v"..thisScript().version.." loaded! /scorepos - change pos. /scorekey - change hotkey. /scorereset - reset stats. <> by qrlk.", 0x348cb2)
  sampAddChatMessage("1) Хоткей убийств: "..key.id_to_name(settings.score.key1)..". 2) Хоткей смертей: "..key.id_to_name(settings.score.key2)..". 3) Хоткей k/d: "..key.id_to_name(settings.score.key3)..". 4) Смена режима: "..key.id_to_name(settings.score.key4)..".", 0x348cb2)
  sampRegisterChatCommand("scorepos", function() lua_thread.create(changepos) end)
  sampRegisterChatCommand("scorereset", function() lua_thread.create(resetscore) end)
  sampRegisterChatCommand("scorekey", function(param) lua_thread.create(changehotkey, param) end)
  sampTextdrawCreate(440, "0", settings.score.posX, settings.score.posY)
  sampTextdrawSetStyle(440, 3)
  sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
  sampTextdrawSetOutlineColor(440, 1, - 16777216)
  lua_thread.create(function() while true do wait(200) if isCharDead(PLAYER_PED) then deaths = deaths + 1 settings.stats.deaths = settings.stats.deaths + 1 inicfg.save(settings, "score") while isCharDead(PLAYER_PED) ~= false do wait(200) end end end end)

  while true do
    wait(10)
    local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if res and last_id ~= nil and last_time ~= nil and sampIsPlayerConnected(last_id) and os.clock() - last_time < sampGetPlayerPing(id) / 220 then
      local a, b = sampGetCharHandleBySampPlayerId(last_id)
      if a and isCharDead(b) then
        last_id = nil
        last_time = nil
        kills = kills + 1
        settings.stats.kills = settings.stats.kills + 1
        inicfg.save(settings, "score")
      end
    end

    if isKeyDown(settings.score.key1) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
      if mode then
        sampTextdrawSetString(440, string.format("K:%d", settings.stats.kills))
      else
        sampTextdrawSetString(440, string.format("K:%d", kills))
      end
    elseif isKeyDown(settings.score.key2) then
      if mode then
        sampTextdrawSetString(440, string.format("D:%d", settings.stats.deaths))
      else
        sampTextdrawSetString(440, string.format("D:%d", deaths))
      end
    elseif isKeyDown(settings.score.key3) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
      if mode then
        sampTextdrawSetString(440, string.format("K/D:%2.1f", settings.stats.kills / settings.stats.deaths))
      else
        sampTextdrawSetString(440, string.format("K/D:%2.1f", kills / deaths))
      end
    elseif wasKeyPressed(settings.score.key4) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
      mode = not mode
      addOneOffSound(0.0, 0.0, 0.0, 1052)
      if mode then
        sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 65536)
      else
        sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, - 1)
      end
    else
      if mode then
        sampTextdrawSetString(440, string.format("%2.1f", settings.stats.dmg))
      else
        sampTextdrawSetString(440, string.format("%2.1f", given))
      end
    end
  end
end

function events.onSendGiveDamage(playerID, damage, weaponID, bodypart)
  if sampIsPlayerConnected(playerID) then
    last_id = playerID
    last_time = os.clock()
    given = given + damage
    settings.stats.dmg = settings.stats.dmg + damage
    inicfg.save(settings, "score")
  end
end

function events.onPlayerDeathNotification(er, ed)
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)

end

function resetscore()
  settings.stats.dmg = 0
  settings.stats.kills = 0
  settings.stats.deaths = 0
	given = 0
	kills = 0
	deaths = 0
  addOneOffSound(0.0, 0.0, 0.0, 1052)
  inicfg.save(settings, "score")
end

function changepos()
  local bckpX1 = settings.score.posX
  local bckpY1 = settings.score.posY
  local bckpS1 = settings.score.size1
  local bckpS2 = settings.score.size2
  sampShowDialog(3838, "Изменение положения и размера.", "{ffcc00}Изменение положения textdraw.\n{ffffff}Изменить положение можно с помощью стрелок клавы.\n\n{ffcc00}Изменение размера textdraw.\n{ffffff}Изменить размер ПРОПОРЦИОНАЛЬНО можно с помощью {00ccff}'-'{ffffff} и {00ccff}'+'{ffffff}.\n{ffffff}Изменить размер по горизонтали можно с помощью {00ccff}'9'{ffffff} и {00ccff}'0'{ffffff}.\n{ffffff}Изменить размер по вертикали можно с помощью {00ccff}'7'{ffffff} и {00ccff}'8'{ffffff}.\n\n{ffcc00}Как принять изменения?\n{ffffff}Нажмите \"Enter\", чтобы принять изменения.\nНажмите пробел, чтобы отменить изменения.\nВ меню можно восстановить дефолт.", "Я понял")
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
        inicfg.save(settings, "score")
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
    [1] = " для убийств",
    [2] = " для смертей",
    [3] = " для k/d",
    [4] = " для смены режима сеанс/всё время"
  }
  if tonumber(mode) == nil or tonumber(mode) < 1 or tonumber(mode) > 4 then
    sampAddChatMessage("1) Хоткей убийств: "..key.id_to_name(settings.score.key1)..". 2) Хоткей смертей: "..key.id_to_name(settings.score.key2)..". 3) Хоткей k/d: "..key.id_to_name(settings.score.key3)..". 4) Смена режима: "..key.id_to_name(settings.score.key4)..". Изменить: /scorekey [1|2|3|4]", - 1)
  else
    mode = tonumber(mode)
    sampShowDialog(989, "Изменение горячей клавиши"..modes[mode], "Нажмите \"Окей\", после чего нажмите нужную клавишу.\nНастройки будут изменены.", "Окей", "Закрыть")
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
            sampAddChatMessage("Установлена новая горячая клавиша - "..key.id_to_name(i), - 1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "score")
            ke1y = 1
            break
          end
        end
      end
    end
    ke1y = nil
  end
end
