require 'iuplua'
require 'iupluacontrols'

testbutton = iup.button{title = "push me to show item", fontsize = "20"}
content = iup.hbox{testbutton}
mainwindow = iup.dialog{content}

function testbutton:action()
  print(iup.MainLoopLevel())
  reallybutton = iup.button{title="push me to delete this item", fontsize="20"}
  pane = iup.hbox{reallybutton}
  pop = iup.dialog{pane; parentdialog = mainwindow}

  function reallybutton:action()
    print(iup.MainLoopLevel())
    anotherbutton = iup.button{title="ok", fontsize="20"}
    cancelbutton = iup.button{title="cancel", fontsize="20"}
    panel = iup.hbox{anotherbutton, cancelbutton}
    pop2 = iup.dialog{panel; parentdialog = pop}

    function anotherbutton:action()
      pop2:destroy()
      pop:destroy()
      print(iup.ExitLoop())
    end

    function cancelbutton:action()
      pop2:destroy()
    end

    pop2:popup()
  end

  pop:popup()

end

mainwindow:showxy()

if(iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
