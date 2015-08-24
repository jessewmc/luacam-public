require 'iuplua'
require 'iupluacontrols'

contenttable={}
for i = 1, 10 do
  local exec = [[
    button]] .. i .. [[=iup.button{title="button]]..i..[["}
    table.insert(contenttable, button]].. i ..[[)
    function button]]..i..[[:action()
      print("button]]..i..[[ pressed")
    end
    ]]

  print(exec)
  --loadstring can only access globals afaik. what a mess
  assert(loadstring(exec))()
end
testbutton = iup.button{title = "pushme", fontsize="20"}
table.insert(contenttable, testbutton)
content = iup.hbox(contenttable)
mainwindow = iup.dialog{content}

mainwindow:showxy()

if(iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
