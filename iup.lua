--GUI interface for luaCAM
--written by Jesse Meade-Clift

require 'iuplua'
require 'iupluacontrols'
require 'lib'

local sqlite3 = require("lsqlite3")
--figure out scintilla library
--todo: make macros reload on action to update when new one is made

local input_f
local macro_name
local output_f
local input_str
local number
local input_filename
local save
local macro_ext = "/media/usb/FDD_USB/DISK00/0101"
local savename = "uicam.cfg"
local savetxt = "./macros/test.lua\n100\n"
local current_table = "ms24"
local vars = ""
local datamax = 0

local database = assert(sqlite3.open("ms24.db"), "database load error")
function datacount(qu)
  local tmp
  for k in database:urows("select count(*) from (" .. qu .. ")") do
    tmp = k
  end
  print(tmp)
  return tmp 
end
datamax = datacount("ms24")



function savefile()
	local msg --is this kosher?
	save, msg = io.open(savename, "r")
	if not save then
		local f = io.open(savename, "w")
		f.write(f, savetxt)
		f.close(f)
		save = io.open(savename, "r")
	end
	input_filename = save.read(save,"*line")
	number = trim(extract_number(save.read(save,"*line")))
	save.close(save)
end

function get_vals(macro)
	local inp = "./macros/"..macro
	input_f, msg = io.open(inp, "r")
	if input_f then
		input_filename = inp
	end
	input_str = input_f.read(input_f, "*all")
	if input_f and (inp ~= "closed file") then
		input_f.close(input_f)
	end
	local out = linenumbers(
							headers(number,  _, input_filename) ..
							comment_vars(input_str) ..
							preproc(input_str)
						)
	vars = pull_vars(input_str)

	return input_str, out
end


savefile()

local t = scandir("macros")
list = iup.list { value = 4, visiblelines=8,expand = "HORIZONTAL", fontsize="12"}   
for i,v  in ipairs(t) do
	list[i] = v
	if string.find(input_filename, list[i]) then
    --TODO would like to scrollto position here but doesn't work with
    --editbox = no
		list.value = i
	end
end
macro_name = list[list.value]
local inp_val, out_val = get_vals(list[list.value])

savebutton = iup.button{title = "Save", fontsize="20"}

input = iup.multiline{value = inp_val, expand = "YES", visiblecolumns=30, readonly="yes"}
output = iup.multiline{value = out_val, expand = "YES", visiblecolumns=30, readonly="yes"}
variables = iup.multiline{value = vars, expand = "YES", visiblecolumns=20, visiblelines=10}

prog = iup.text{value = (number or "none"),expand = "HORIZONTAL", fontsize="20"}

function prog:killfocus_cb(t, i, v)
	number = prog.value
	local newinput = write_vars(input.value, variables.value)
	output.value = linenumbers(
							headers(number,  _, input_filename) ..
							comment_vars(newinput) ..
							preproc(newinput)
						)
end

function savedef()
	local writesave, msg = io.open(savename, "w")
	writesave.write(writesave, macro_name .. "\n")
	writesave.write(writesave, number .. "\n")
	writesave.close(writesave)
end

function variables:killfocus_cb(t, i, v)
	local newinput = write_vars(input.value, variables.value)
	output.value = linenumbers(
							headers(number,  _, input_filename) ..
							comment_vars(newinput) ..
							preproc(newinput)
						)
end

function list:action(t, i, v)
	input.value, output.value = get_vals(t)
	variables.value = vars

	--iup.Redraw(frm_vars, 10)
	macro_name = t
end

function savebutton:action()
	savedlg = iup.filedlg{dialogtype = "SAVE", title = "Save G-Code", filter = "*.eia", filterinfo = "EIA G-code files", directory = macro_ext, file = number..".eia"}
	savedlg:popup(iup.CENTER,iup.CENTER)
	local status = savedlg.status
	if status == "1" then 
		--new
		local output_f = assert(io.open(savedlg.value, "w"))
		output_f.write(output_f, output.value)
		if output_f then
			output_f.close(output_f)
		end
		print(savedlg.value)
		savedef()
	elseif status == "0" then
		local output_f = assert(io.open(savedlg.value, "w"))
		print(output_f)
		print(output.value)
		output_f.write(output_f, output.value)
		if output_f then
			output_f.close(output_f)
		end
		savedef()
		print("must overwrite")
		print(savedlg.value)
	elseif status == "-1" then
		print("cancelled")
	end
end
--var_labels IS A TABLE! thats why it doesn't work when you muck around
vars_horiz = iup.hbox {variables; fontsize="12", margin="0x0", expand="YES"}
frm_out = iup.frame {output ; title = "Output"}
frm_inp = iup.frame {input ; title = "Raw Macro"}
frm_macro = iup.frame {list ; title = "Macro"}
save_box = iup.hbox {prog, savebutton, margin="0x0"}
frm_prog = iup.frame {save_box; title = "Prog. No."}
--frm_save = iup.frame {savebutton}
frm_vars = iup.frame {vars_horiz ; title = "Variables", size = "SIXx"}



vert_sub = iup.vbox {frm_prog, frm_macro, frm_vars, margin="0x0"}
horiz = iup.hbox {vert_sub, iup.vbox{frm_inp; margin="10x0"}, iup.vbox{frm_out; margin="0x0"}}
horiz.tabtitle = "Custom Cycles"


--angleoffset stuff

cent_x_label = iup.label{title = " centre x "}
cent_y_label = iup.label{title = " centre y "}
bolt_x_label = iup.label{title = " bolt x "}
bolt_y_label = iup.label{title = " bolt y "}

local txtsize = "EIGHTx"

centre_x = iup.text{size = txtsize, value = "0"}
centre_y = iup.text{size = txtsize, value = "0"}
bolt_x = iup.text{size = txtsize, value = "0"}
bolt_y = iup.text{size = txtsize, value = "0"}

cent_x_h = iup.hbox {cent_x_label, centre_x}
cent_y_h = iup.hbox {cent_y_label, centre_y}
bolt_x_h = iup.hbox {bolt_x_label, bolt_x}
bolt_y_h = iup.hbox {bolt_y_label, bolt_y}

left = iup.vbox {cent_x_h, cent_y_h}
right = iup.vbox {bolt_x_h, bolt_y_h}

top = iup.hbox {left, right}

calc = iup.button {title = "calculate"}

alpha_txt = iup.label{title = " angle from positive x axis "}
bcd_txt = iup.label{title = " approx bolt circle dia. "}

--this seemed to get clobbered by some other global when called alpha
--not sure if built in or one of mine
--ed. : It gets clobbered by vars in macros. Shit
alpha1 = iup.text{size = txtsize, readonly = "yes", value = "0"}
bcd = iup.text{size = txtsize, readonly = "yes", value = "0"}

texts = iup.vbox {alpha_txt, bcd_txt}
outs = iup.vbox {alpha1, bcd}
hh = iup.hbox {texts, outs}
bottom = iup.hbox {calc, hh}
alla = iup.vbox {top, bottom, fontsize = "20"}
frm_ang = iup.frame {alla ; title = "Angle Offset"}
all = iup.hbox {frm_ang, margin="10x10"}
all.tabtitle = "Calculations"

function calc:action()
	local angle_offset = 0
	local boltx = tonumber(bolt_x.value)
	local bolty = tonumber(bolt_y.value)
	local centx = tonumber(centre_x.value)
	local centy = tonumber(centre_y.value)
	alpha1.value = string.format("%.3f", 
		math.deg(math.atan2(
			bolty - centy,
			boltx - centx) + angle_offset))
	bcd.value = string.format("%.4f",
		2*math.sqrt((bolty - centy)*
			(bolty - centy) + (boltx - centx)*
			(boltx - centx)))
end

--end angleoffset stuff


--start ms24

namesearch = iup.text{fontsize="20", visiblecolumns = "20", nc = "30"}
numsearch = iup.text{fontsize="20", nc = "8"}
numfound = iup.text{fontsize="20", bgcolor = "192 192 192", readonly = "YES", value = datacount("select * from ms24")}

function numsearch:valuechanged_cb()
  searchchange(numsearch.value, "prog_no")
  namesearch.value = ""
end

function namesearch:valuechanged_cb()
  searchchange(namesearch.value, "name")
  numsearch.value = ""
end

function searchchange(searchstring, property)
  local words = {}
  -- %w is all alpha chars, %" matches quote mark, \ escapes. One or more matched
  for w in string.gmatch(searchstring, "[%w%\"]+") do
    words[#words +1] = w
  end

  local query = "select * from ("
  local query2 = ") where " .. property .. " like '%"
  local yreuq = "%'"
  local q = "ms24"


  for _,v in ipairs(words) do
    print(v)
    q = query .. q .. query2 .. v .. yreuq 
  end

  if q == "ms24" then
    q = "select * from ms24"
  end
  print(q)
  dbinit()
  --dear god call datacount much? Save the damn value
  db_show.numlin = datacount(q)
  print("datacount")
  print("datacount currently: ".. datacount(q))
  numfound.value = datacount(q)
  --need max number in db currently to zero other cells properly
  j = 1
  for row in database:nrows(q) do
    db_show:setcell(j,0, row.prog_no)
    db_show:setcell(j,1, row.name)
    j = j + 1
  end
  db_show.redraw = "ALL"
end

newentry = iup.button{title = "New Entry", fontsize = 20}
backup = iup.button{title = "Backup Database", fontsize = 20, alignment = "ARIGHT:ACENTER"}

function backup:action()
	backdlg = iup.filedlg{dialogtype = "SAVE", title = "Save Database Backup", filter = "*.csv", filterinfo = "CSV files", directory = macro_ext, file = current_table..".csv"}
	backdlg:popup(iup.CENTER,iup.CENTER)
  local backstatus = backdlg.status
  if status == "1" then

  elseif status == "0" then

  elseif status == "-1" then

  end
end

function newentry:action()
  local num = iup.text{expand="yes", fontsize="12"}
  local numl = iup.label{title = "Prog. No."}
  local namel = iup.label{title = "Prog. Name"}
  local name = iup.text{expand="yes", fontsize="12"}
  local desc = iup.multiline{visiblecolumns = 50, visiblelines = 20, wordwrap = "yes"}
  local clspop = iup.button{title = "Cancel", fontsize="20"}
  local newsave = iup.button{title = "Save", fontsize="20"}
  local butts = iup.hbox{newsave, clspop}
  local panel = iup.vbox{iup.hbox{iup.vbox{numl,namel}, iup.vbox{num,name}},desc, butts, margin ="10x10"}
  function clspop:action()
    pip:destroy()
  end
  function newsave:action()
    local execstring = "insert into ms24 (prog_no, name, desc) values (" .. num.value .. ", '" .. name.value .. "', '" .. desc.value .. "')"
    print(execstring)
    database:exec(execstring)

    --this works nicely for refreshing current search
    if (numsearch.value ~= "" or nil) then
      searchchange(numsearch.value, "prog_no")
    else
      searchchange(namesearch.value, "name")
    end
    print("set cells")

    pip:destroy()
    --redraw works funny if not put after destroying popup.
    --I suspect force top is to blame
    db_show.redraw = "ALL"
    print("supposed to redraw ".. tostring(db_show) .. " here")
  end

  pip = iup.dialog{panel;parentdialog = dlg, menubox="NO",resize="NO",maxbox="NO",minbox="NO",title=NULL}
  pip:popup(iup.CENTER, iup.CENTER)

end

numsearchbutton = iup.frame{numsearch;title = "Search Number"}
searchbutton = iup.frame{namesearch; title = "Search Name"}
numfoundframe = iup.frame{numfound; title = "Entry Count"}
db_show = iup.matrix {fontsize=12,numcol = 1, numlin=datamax, numcol_visible=1, numlin_visible=10, border="YES", resizematrix="YES", yautohide="NO"}

function dbinit()
  db_show:setcell(0,0, "Prog. No.")
  db_show:setcell(0,1, "Prog. Name")
  local i = 1
  for row in database:nrows("select * from ms24") do
    db_show:setcell(i,0, nil)
    db_show:setcell(i,1, nil)
    i = i + 1
  end
end

db_show.WIDTH1 = "430"
db_show.ALIGNMENT1 = "ALEFT"
db_show.READONLY = "YES"

dbinit()
local i = 1

for row in database:nrows("select * from ms24") do
  db_show:setcell(i,0, row.prog_no)
  db_show:setcell(i,1, row.name)
  i = i + 1
end


ms24 = iup.vbox{iup.hbox{newentry, backup, gap = "505"},iup.hbox {searchbutton, numsearchbutton, numfoundframe}, iup.hbox{db_show, expand="NO"}}
ms24.tabtitle = "MS-24"
ms13 = iup.vbox{}
ms13.tabtitle = "MS-13"
db_tab = iup.tabs { ms24, ms13; tabtype = "LEFT"}
db = iup.hbox {db_tab}

db.tabtitle = "Program Databases"

--end ms24

tabbing = iup.tabs { db, horiz, all }

final = iup.hbox {tabbing; margin="10x10"}

dlg = iup.dialog {final
      ; title = "LuaCAM"}
dlg.shrink="YES"

function dlg:resize_cb(w, h)
  iup.Refresh(dlg)
  db_show.RASTERWIDTH1 = nil
  db_show.FITTOSIZE = "COLUMNS"
  return iup.DEFAULT
end


dlg:showxy(iup.CENTER, iup.CENTER)

function dlg:close_cb()
  for row in database:nrows("select * from ms24") do
    print(row.prog_no, row.name)
  end
  local ret = database:close()
  print("closing database... code: " .. ret)
end


function db_show:click_cb(ln, column, sts)
  if ln == 0 then return end;
  local num = iup.text{value = self:getcell(ln, 0), expand="yes", fontsize="12"}
  local numl = iup.label{title = "Prog. No."}
  local namel = iup.label{title = "Prog. Name"}
  local name = iup.text{value = self:getcell(ln, 1), expand="yes", fontsize="12"}
  sublinktable = {gap="5"}
  suplinktable = {gap="5"}
  local i = 1
  for z in database:nrows("select * from subs where prog_id = " .. num.value) do
    local exec = [[
      link]]..i..[[=iup.link{title="]].. z.sub_id ..[["}
      table.insert(sublinktable, link]]..i..[[)
      function link]]..i..[[:action()
        print("link ]].. i ..[[pressed")
      end
      ]]
    i= i+1
    print(exec)
    assert(loadstring(exec))()
  end
  local j = 1
  for y in database:nrows("select * from subs where sub_id = " .. num.value) do
    local exec = [[
      slink]]..j..[[=iup.link{title="]].. y.prog_id..[["}
      table.insert(suplinktable,slink]]..j..[[)
      function slink]]..j..[[:action()
        print("slink ]] .. j.. [[ pressed")
      end
      ]]
    j=j+1
    print(exec)
    assert(loadstring(exec))()
  end

  if i==1 then table.insert(sublinktable, iup.label{title="None             "}) end
  if j==1 then table.insert(suplinktable, iup.label{title="None             "}) end

  local addsub = iup.button{title="+"}
  local remsub = iup.button{title="-"}
  local addsup = iup.button{title="+"}
  local remsup = iup.button{title="-"}

  function addsub:action()
  end
    

  table.insert(sublinktable, addsub)
  table.insert(sublinktable, remsub)
  table.insert(suplinktable, addsup)
  table.insert(suplinktable, remsup)

  local subframe = iup.frame{title="Sub Programs", minsize="120x"; iup.hbox(sublinktable)}
  local supframe = iup.frame{title="Calling Programs", minsize="120x"; iup.hbox(suplinktable)}
  --manually calling iterator once, only want one row
  local desc_text = ""
  --nrows grabs a row in a table with named params corresponding to columns
  for x in database:nrows("select * from ms24 where prog_no = " .. num.value) do
    desc_text = x.desc
  end
  local desc = iup.multiline{value = desc_text, visiblecolumns = 50, visiblelines = 20, wordwrap = "yes"}
  local clspop = iup.button{title = "Cancel", fontsize="20"}
  local delbutton = iup.button{title = "Delete", fontsize="20"}
  local saveagain = iup.button{title = "Save", fontsize="20"}
  local butts = iup.hbox{saveagain, delbutton, clspop}
  local panel = iup.vbox{iup.hbox{iup.vbox{numl,namel}, iup.vbox{num,name}},iup.hbox{subframe,supframe},desc, butts, margin ="10x10"}
  function clspop:action()
    pp:destroy()
  end
  function saveagain:action()
    local execstring = "update ms24 set prog_no = " .. num.value .. ", name = '" .. name.value .. "', desc = '" .. desc.value .. "' where prog_no = " .. db_show:getcell(ln, 0)
    print(execstring)
    database:exec(execstring)

    --these need to be done before popup destroyed, obviously
    db_show:setcell(ln, 0, num.value)
    db_show:setcell(ln, 1, name.value)

    pp:destroy()
    --redraw works funny if not put after destroying popup.
    --I suspect force top is to blame
    db_show.redraw = "ALL"
    print("supposed to redraw ".. tostring(db_show) .. " here")
  end
  
  function delbutton:action()
    local okbut = iup.button{title = "OK", fontsize="20"}
    local cancelbut = iup.button{title = "Cancel", fontsize = "20"}
    local textlabel = iup.label{title = "Are you sure you want to delete program " .. num.value .."?"}
    local pane = iup.vbox{textlabel, iup.hbox{okbut,cancelbut}}
    function cancelbut:action()
      --destroying pp as well. related to iup.close?
      usure:destroy()
    end
    function okbut:action()
      delcall = "delete from ms24 where prog_no = " .. num.value
      print(delcall)
      database:exec(delcall)
      searchchange(namesearch.value, "name")

      usure:destroy()
      pp:destroy()
      db_show.redraw = "ALL"
      --this one seems unnecessary
      return iup.CLOSE
    end
    usure = iup.dialog{pane;parentdialog=pp, menubox="NO", resize="NO", maxbox="NO", minbox="NO", title=NULL}
    usure:popup(iup.CENTER, iup.CENTER)
    --this one fixes old hang issue, but also causes pp to close
    return iup.CLOSE

  end

  pp = iup.dialog{panel;parentdialog=dlg, menubox="NO",resize="NO",maxbox="NO",minbox="NO",title=NULL}
  pp:popup(iup.CENTER, iup.CENTER)
end



if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
