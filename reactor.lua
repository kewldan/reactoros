--Made by Avenger#1818
--Reactor OS with grafical interface

--Возможности:
--  Остановить реактор при перегреве;

--Настройки:
local _FreqOfUpdate = 0.1 --Частота обновления (Рекомендуется <= 0.5)
local _FreqOfSoundOfOverHeating = 500 -- Частота пищалки при перегреве
local _local = "ru" --Язык, доступные значения - ru, en
--/////////

--Перевод:
local localZ = {
    ["ru"] = {
        ["FatalError"] = "КРИТИЧЕСКАЯ ОШИБКА: ",
        ["reactorNotFound"] = "КОМПОНЕНТ РЕАКТОРА НЕ НАЙДЕН",
        ["redstoneNotFound"] = "РЕДСТОУН НЕ НАЙДЕН",
        ["MFSUNotFound"] = "MFSU НЕ НАЙДЕН",
        ["overheating"] = "ПЕРЕГРЕВ",
        ["reactor1"] = "РЕАКТОР АКТИВЕН",
        ["reactor2"] = "РЕАКТОР ЗАГЛУШЕН",
        ["Cheat"] = "Текущее тепло: ",
        ["OE"] = "Выход EU: ",
        ["MFSU"] = "MFSU: "
    },
    ["en"] = {
        ["FatalError"] = "FATAL ERROR: ",
        ["reactorNotFound"] = "REACTOR NOT FOUND",
        ["redstoneNotFound"] = "REDSTONE NOT FOUND",
        ["MFSUNotFound"] = "MFSU NOT FOUND",
        ["overheating"] = "OVERHEATING",
        ["reactor1"] = "REACTOR ENABLE",
        ["reactor2"] = "REACTOR DISABLE",
        ["Cheat"] = "Current heat: ",
        ["OE"] = "Output EU: ",
        ["MFSU"] = "MFSU: "
   }
}
--///////

local lang = localZ[_local]

local com = require("component")
local error = ""
 
if #com.list("reactor_chamber")() == 0 then
  error = lang["FatalError"]..lang["reactorNotFound"]
else
  reactor = com.proxy(com.list("reactor_chamber")())
end
 
if #com.list("ic2_te_mfsu")() == 0 then
  error = lang["FatalError"]..lang["MFSUNotFound"]
else
  storage = com.proxy(com.list("ic2_te_mfsu")())
end
 
if #com.list("redstone")() == 0 then
  error = lang["FatalError"]..lang["redstoneNotFound"]
else
  redstone = com.redstone
end
 
local gpu = com.gpu
local e = require("event")
local w, h = gpu.getResolution()
require("term").clear()

function round(num)
  return math.floor(x*100)/100
end
 
function drawScreen() --Рисуем линии
  gpu.fill(1, 1, 1, h, "|")
  gpu.fill(w, 1, 1, h, "|")
  gpu.fill(1, 1, w, 1, "–")
  gpu.fill(1, h, w, 1, "–")
end
 
function redstoneChange(st) --Во всех сторонах ставим значения для Redstone контроллера
  redstone.setOutput(0, st)
  redstone.setOutput(1, st)
  redstone.setOutput(2, st)
  redstone.setOutput(3, st)
  redstone.setOutput(4, st)
  redstone.setOutput(5, st)
end
 
function update() --Обновление экрана
  drawScreen() --Рисуем линии
  if 100/(reactor.getMaxHeat()/reactor.getHeat()) >= 50 then
    redstoneChange(0)
    require("computer").beep(_FreqOfSoundOfOverHeating, _FreqOfUpdate/2)
    _fg = gpu.getForeground()
    gpu.setForeground(0xff0000)
    gpu.set(3, 7, "!!! - "..lang["overheating"].." - !!!")
    gpu.setForeground(_fg)
  else
    redstoneChange(1)
    gpu.fill(3, 7, 3, h - 1, " ")
  end
 
  if reactor.producesEnergy() then
    gpu.set(3, 3, lang["reactor1"])
  else
    gpu.set(3, 3, lang["reactor2"])
  end
  gpu.fill(3, 4, w-1, h-1, " ")
  gpu.set(3, 4, lang["Cheat"]..tostring(round(100/(reactor.getMaxHeat()/reactor.getHeat()))).."%")
  gpu.set(3, 5, lang["OE"]..tostring(reactor.getReactorEUOutput()))
  gpu.set(3, 6, lang["MFSU"]..tostring(round(100/(storage.getCapacity()/storage.getEnergy()))).."%")
end
 
function exit(...)
  tb = {...}
  redstoneChange(0)
  require("computer").shutdown(true)
end
 
e.listen("touch", exit)
if error == "" then
  while true do
    update()
    os.sleep(_FreqOfUpdate)
  end
else
  print(error)
end