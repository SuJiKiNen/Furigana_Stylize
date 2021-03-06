﻿local tr = aegisub.gettext

script_name = tr"Furigana Stylize"
script_description = tr"Generate independent style datas for every syllable and furigana from Aegisub karaskel furigana work"
script_author = "SuJiKiNen"
script_version = "2.0"

require "karaskel"
require "json"

furi_styles = {}
appeared_furi_styles = {}
main_styles = {}
cover_styles = {}
furi_lines = {}

 -- settings
local generate_furigana = true
local use_config = true
local file_path="?user"
local config_filename = "furiganaStylizeConfig.json"

configs= {
	["furiganaScale"] = 0.5,
	["maintextVerticalPositionFixed"] = 0,
	["maintextHorizontalPositionFixed"] = 0,
	["furiganaVerticalPositionFixed"] = 3,
	["furiganaHorizontalPositionFixed"] = -1,
	["furiganaSpacing"] = 0,
	["noBlankSyl"] = true,
	["noBlankFuri"] = true,
	["generateLine"] = true,
	["generateFuriLine"] = true,
	["generateSylLine"] = false,
	["sylTimeMode"] = "line",
	["furiTimeMode"] = "line",
	["fieldTextMode"] = "clean",
	["positionMode"] = "inner",
}

karaskel.furigana_scale = 0.5

--[[
maintext_vertical_position_fixed = 0
maintext_horizontal_position_fixed = 0
furigana_vertical_position_fixed = 3
furigana_horizontal_position_fixed = -1
furigana_spacing = 0
no_blank_syl = true
no_blank_furi = true
generate_furi_line = true
generate_syl_line = false
syl_time_mode = "syl";
]]
--	settings

dialog_config=
{
	["mainTextLabel"]							={class="label",												x=0,y=0,width=1,height=1,config=false,label="Main Text:"},
	["maintextVerticalPositionFixedLabel"]		={class="label",												x=0,y=1,width=1,height=1,config=false,label="Vertical Position Fixed:"},
	["maintextVerticalPositionFixed"]			={class="floatedit",name ="maintextVerticalPositionFixed",		x=1,y=1,width=1,height=1,config=true,value=0},
	["maintextHorizontalPositionFixedLabel"]	={class="label",												x=0,y=2,width=1,height=1,config=false,label="Horizontal Position Fixed:"},
	["maintextHorizontalPositionFixed"]			={class="floatedit",name="maintextHorizontalPositionFixed",		x=1,y=2,width=1,height=1,config=true,value=0},
	
	["furiganaLabel"]							={class="label",												x=0,y=4,width=1,height=1,config=false,label="Furigana Text:"},
	["furiganaScaleLabel"]						={class="label",												x=0,y=5,width=1,height=1,config=false,label="Furigana Scale:"},
	["furiganaScale"]							={class="floatedit",name="furiganaScale",						x=1,y=5,width=1,height=1,config=true ,value=0.5},
	["furiganaSpacingLabel"]					={class="label",												x=0,y=6,width=1,height=1,config=false,label="Furigana Spacing:"},
	["furiganaSpacing"]							={class="floatedit",name="furiganaSpacing",						x=1,y=6,width=1,height=1,config=true ,value=0},
	["furiganaVerticalPositionFixedLabel"]		={class="label",												x=0,y=7,width=1,height=1,config=false,label="Vertical Position Fixed:"},
	["furiganaVerticalPositionFixed"]			={class="floatedit",name="furiganaVerticalPositionFixed",		x=1,y=7,width=1,height=1,config=true,value=3.0},
	["furiganaHorizontalPositionFixedLabel"]	={class="label",												x=0,y=8,width=1,height=1,config=false,label="Horizontal Position Fixed:"},
	["furiganaHorizontalPositionFixed"]			={class="floatedit",name="furiganaHorizontalPositionFixed",		x=1,y=8,width=1,height=1,config=true,value=-1},
	
	["othersLabel"]								={class="label",												x=0,y=10,width=1,height=1,config=false,label="Others:"},
	["noBlankSylLabel"]							={class="label",												x=0,y=11,width=1,height=1,config=false,label="No Blank Syl:"},
	["noBlankSyl"]								={class="dropdown",name="noBlankSyl",							x=1,y=11,width=1,height=1,config=true,items={"true","false"},value="true"},
	["noBlankFuriLabel"]						={class="label",												x=0,y=12,width=1,height=1,config=false,label="No Blank Furi:"},
	["noBlankFuri"]								={class="dropdown",name="noBlankFuri",							x=1,y=12,width=1,height=1,config=true,items={"true","false"},value="true"},
	["generateLineLabel"]						={class="label",												x=0,y=13,width=1,height=1,config=false,label="Generate Line:"},
	["generateLine"]							={class="dropdown",name="generateLine",							x=1,y=13,width=1,height=1,config=true,items={"true","false"},value="true"},
	["generateSylLineLabel"]					={class="label",												x=0,y=14,width=1,height=1,config=false,label="Generate Syl Line:"},
	["generateSylLine"]							={class="dropdown",name="generateSylLine",						x=1,y=14,width=1,height=1,config=true,items={"true","false"},value="true"},
	["generateFuriLineLabel"]					={class="label",												x=0,y=15,width=1,height=1,config=false,label="Generate Furi Line:"},
	["generateFuriLine"]						={class="dropdown",name="generateFuriLine",						x=1,y=15,width=1,height=1,config=true,items={"true","false"},value="true"},
	["sylTimeModeLabel"]						={class="label",												x=0,y=16,width=1,height=1,config=false,label="Syl Time Mode:"},
	["sylTimeMode"]								={class="dropdown",name="sylTimeMode",							x=1,y=16,width=1,height=1,config=true,items={"line","syl"},value="line"},
	["furiTimeModeLabel"]						={class="label",												x=0,y=17,width=1,height=1,config=false,label="Furi Time Mode:"},
	["furiTimeMode"]							={class="dropdown",name="furiTimeMode",							x=1,y=17,width=1,height=1,config=true,items={"line","syl","furi"},value="line"},
	["fieldTextModeLabel"]						={class="label",												x=0,y=18,width=1,height=1,config=false,label="Actor Field Text Mode:"},
	["fieldTextMode"]							={class="dropdown",name="fieldTextMode",						x=1,y=18,width=1,height=1,config=true,items={"clean","rich"},value="clean"},
	["positionModeLabel"]						={class="label",												x=0,y=19,width=1,height=1,config=false,label="Furi Position Mode:"},
	["positionMode"]							={class="dropdown",name="positionMode",							x=1,y=19,width=1,height=1,config=true,items={"inner","outer"},value="inner"},
	}

function remove_furiganas(subs) 
	local i = 1
	while i <= #subs do
		local l = subs[i]
		i = i + 1
		if l.class == "dialogue" and l.effect == "furigana" then
			i = i - 1
			subs.delete(i)
		end
	end
end

function remove_karaskel_furigana_styles(subs)
	local i = 1
	while i <= #subs do
		local l = subs[i]
		i = i + 1
		if l.class == "style" and l.name:match("furigana") then
			i = i - 1
			subs.delete(i)
		end
	end
end

function set_furigana_spacing(styles)
	for i=1, #styles do
	  local style = styles[i]
	  if style.name:match("furigana") then
			style.spacing = dialog_config["furiganaSpacing"].value
	  end
   end
end

function read_config()
	local filename = aegisub.decode_path(file_path.."\\"..config_filename)
	local filehandle = io.open(filename,"r")
	if filehandle then
		local raw_text = filehandle:read("*all")
		local parsedConfig = json.decode(raw_text)
		for entryName,entryValue in pairs(parsedConfig) do
			configs[ entryName ] = entryValue
			if type(entryValue) == "boolean" then
				if entryValue then
					dialog_config[ entryName ].value = "true"
				else
					dialog_config[ entryName ].value = "false"
				end
			else
					dialog_config[ entryName ].value = entryValue
			end
		end
		filehandle:close()
	else
		aegisub.debug.out("file not found!write default!\n")
		write_config()
	end
	karaskel.furigana_scale = tonumber(configs["furiganaScale"])
end

function write_config()
	for entryName,configEntry in pairs (dialog_config) do
		if configEntry.config then
			if( configEntry.value=="true" or configEntry.value=="false" ) then
				if(configEntry.value=="true") then
						configs[ entryName ] = true
				else
						configs[ entryName ] = false
				end
			else
				configs[ entryName ] = configEntry.value
			end
		end
	end
	local serializedConfig = json.encode(configs)
	local filename = aegisub.decode_path(file_path.."\\"..config_filename)
	local filehandle = io.open(filename,"w")
	if filehandle then
		filehandle:write(serializedConfig)
		filehandle:close()
	else
	end
	karaskel.furigana_scale =  tonumber(dialog_config["furiganaScale"].value)
end

function set_config(subs)
	read_config()
	button, config = aegisub.dialog.display(dialog_config,{"Save","Save&&Apply","Cancel"})
	if button=="Save" or button =="Save&&Apply" then
		for entryName,configEntry in pairs(config) do
			dialog_config[ entryName ].value = tostring(configEntry)
		end
		write_config()
	end
	
	if button=="Save&&Apply" then
		stylize(subs)
	end
	
	if button == "Cancel" then
		aegisub.cancel()
	end
end

function stylize(subs)
	remove_karaskel_furigana_styles(subs)
	remove_furiganas(subs)
	meta,styles = karaskel.collect_head(subs,generate_furigana)
	set_furigana_spacing(styles)
	read_config()
	
	local style_start_i = nil
	local style_end_i = nil
	local dialog_start_i = nil
	local dialog_end_i = nil
	dialog_start_i,dialog_end_i = get_dialogs_range(subs)
	for i=dialog_start_i,dialog_end_i do
		aegisub.progress.set( (i-dialog_start_i) * 100 / (dialog_end_i-dialog_start_i) )
		aegisub.progress.task(string.format("Processing %%%d",(i-dialog_start_i) * 100 / (dialog_end_i-dialog_start_i)))
		local line = subs[i]
		karaskel.preproc_line_text(meta,styles,line)
		karaskel.preproc_line_size(meta,styles,line)
		karaskel.preproc_line_pos(meta,styles,line)
		
		if configs["generateLine"] and line.comment == true then
			local nline = table.copy(line)
			nline.text = nline.text_stripped
			nline.comment = false
			nline.effect = "furigana"
			subs.append(nline)
		end
		
		local syl_count = 0
		for k=1,#line.kara do 
			local syl = line.kara[k]
			--if (not (no_blank_syl and is_syl_blank(syl))) and generate_syl_line then
			if (not (configs["noBlankSyl"] and is_syl_blank(syl))) and configs["generateSylLine"] and line.comment==true then
				syl_count = syl_count + 1
				local syl_line = table.copy(line)
				syl_line.text =	 syl.text_stripped
				syl_line.effect = "furigana"
				syl_line.comment = false
				
				if configs["positionMode"] == "inner" then
					syl_line.style = string.format("line_%d_syl_%d",i-dialog_start_i+1,syl_count)
				else
					syl_line.style = line.style
				end
				
				if configs["fieldTextMode"] == "rich" then
					syl_line.actor = string.format("{syl_%d_%d_%d}",syl.start_time,syl.end_time,syl.duration)
				end
				
				syl_line.layer = syl_count
				if configs["sylTimeMode"] == "syl" then
					syl_line.start_time = line.start_time +syl.start_time
					syl_line.end_time = line.start_time + syl.end_time
				end
				
				if configs["sylTimeMode"] == "line" then
					syl_line.start_time = line.start_time
					syl_line.end_time = line.end_time
				end
				
				local syl_style = table.copy(line.styleref)
				syl_style.name = syl_line.style
				if configs["positionMode"] == "inner" then
					syl_style.margin_l = line.left+syl.left+ configs["maintextHorizontalPositionFixed"] --maintext_horizontal_position_fixed
					syl_style.margin_r = 0
					syl_style.align = ( (line.styleref.align <4) and 1) or 7
					syl_style.margin_t = line.eff_margin_t + configs["maintextVerticalPositionFixed"]	--maintext_vertical_position_fixed
					syl_style.margin_b = line.eff_margin_b + configs["maintextVerticalPositionFixed"]	--maintext_vertical_position_fixed
					syl_style.margin_v = line.eff_margin_v + configs["maintextVerticalPositionFixed"]	--maintext_vertical_position_fixed
				end
				
				if configs["positionMode"]=="outer" then
					syl_line.margin_l = line.left+syl.left+ configs["maintextHorizontalPositionFixed"]
					syl_line.margin_r = 0
					syl_line.halign = "left"
					syl_line.margin_t = line.eff_margin_t + configs["maintextVerticalPositionFixed"]
					syl_line.margin_b = line.eff_margin_b + configs["maintextVerticalPositionFixed"]
					syl_line.margin_v = line.eff_margin_v + configs["maintextVerticalPositionFixed"]
				end
				if not styles[ syl_style.name ] then 
						table.insert(main_styles,syl_style)
				else
					cover_styles[ syl_style.name ] = syl_style
				end
				subs.append(syl_line)
			end
		end
		
		local furi_count = 0
		for j=1,line.furi.n do
			local furi = line.furi[j]
			--if (not (no_blank_furi and is_furi_blank(furi))) and generate_furi_line then
			if (not (configs["noBlankFuri"] and is_furi_blank(furi))) and configs["generateFuriLine"] and line.comment ==true then
				furi_count = furi_count +1
				local furi_line = table.copy(line)
				furi_line.text = furi.text
				furi_line.effect = "furigana"
				furi_line.comment = false
				furi_line.layer = furi_count
				
				if configs["positionMode"] =="inner" then
					furi_line.style = string.format("line_%d_furi_%d",i-dialog_start_i+1,furi_count)
				else
					furi_line.style = line.style.."-furi"
				end
				
				if configs["fieldTextMode"] == "rich" then
					furi_line.actor = string.format("{furi_%d_%d_%d}",furi.start_time,furi.end_time,furi.duration)
				end
				furi_line.layer = furi_count
				local furi_style = table.copy(line.styleref)
				furi_style.name = furi_line.style
				furi_style.margin_l = line.left+furi.left+ configs["furiganaHorizontalPositionFixed"] --furigana_horizontal_position_fixed
				furi_style.margin_r = 0
				furi_style.align = ( (line.styleref.align <4) and 1) or 7
				furi_style.fontsize = furi_style.fontsize*karaskel.furigana_scale
				furi_style.outline	= furi_style.outline *karaskel.furigana_scale
				furi_style.shadow	= furi_style.shadow	 *karaskel.furigana_scale
				if configs["positionMode"] == "inner" then
					furi_style.margin_t = line.eff_margin_t + line.height + configs["furiganaVerticalPositionFixed"] --furigana_vertical_position_fixed
					furi_style.margin_b = line.eff_margin_b + line.height + configs["furiganaVerticalPositionFixed"] --furigana_vertical_position_fixed
					furi_style.margin_v = line.eff_margin_v + line.height + configs["furiganaVerticalPositionFixed"] --furigana_vertical_position_fixed 
				end
				if configs["furiTimeMode"] == "line" then
					furi_line.start_time = line.start_time
					furi_line.end_time = line.end_time
				end
				
				if configs["furiTimeMode"] == "syl" then
					furi_line.start_time = furi.syl.start_time + line.start_time
					furi_line.end_time = furi.syl.end_time	 + line.start_time
				end
				
				if configs["furiTimeMode"] == "furi" then
					furi_line.start_time = furi.start_time + line.start_time
					furi_line.end_time = furi.end_time + line.start_time
				end
				
				if configs["positionMode"] == "outer" then
					furi_line.margin_l = line.left+furi.left+ configs["furiganaHorizontalPositionFixed"]
					furi_line.margin_r = 0
					furi_line.halign = "left"
					furi_line.margin_t = line.eff_margin_t + line.height + configs["furiganaVerticalPositionFixed"]
					furi_line.margin_b = line.eff_margin_b + line.height + configs["furiganaVerticalPositionFixed"]
					furi_line.margin_v = line.eff_margin_v + line.height + configs["furiganaVerticalPositionFixed"]
				end
				if not styles[ furi_style.name ] then
					if not appeared_furi_styles[ furi_style.name ] then
						appeared_furi_styles[ furi_style.name ] = true
						table.insert(furi_styles,furi_style)
					end
				else
					cover_styles[ furi_style.name ] = furi_style
				end
				subs.append(furi_line)
			end
		end
	end
	style_start_i,style_end_i=get_styles_range(subs)
	for i=style_start_i,style_end_i do
		local style = subs[i]
		if cover_styles[ style.name ] then
		   subs[ i ] = cover_styles[ style.name ]
		end
	end
   
	for i=1,#main_styles do
		subs[ -style_start_i ] = main_styles[i]
	end
	
	for i=1,#furi_styles do
		subs[ -style_start_i ] = furi_styles[i]
	end
	remove_karaskel_furigana_styles(subs)
end

function get_styles_range(subs)
	local style_start_i = nil
	local style_end_i = nil
	for i = 1, #subs do
	  local line = subs[i];
	  
	  if not style_start_i and line.class == "style" then
		  style_start_i = i
	  end
	  if line.class == "style" then
		  style_end_i = i
	  end
	end
	return style_start_i,style_end_i
end

function get_dialogs_range(subs)
	local dialog_start_i = nil
	local dialog_end_i = nil
		for i = 1, #subs do
		local line = subs[i];
	
		if not dialog_start_i and line.class == "dialogue" then
			dialog_start_i = i
		end
		if line.class == "dialogue" then
			dialog_end_i = i
		end
	end
	return dialog_start_i,dialog_end_i
end

function is_furi_blank(furi)
	if furi.duration <= 0 then
		return true
	end
	local t = furi.text_stripped
	if t:len() <= 0 then return true end
	t = t:gsub("[ \t\n\r]", "") -- regular ASCII space characters
	t = t:gsub("　", "") -- fullwidth space
	return t:len() <= 0
end

function is_syl_blank(syl)
	if syl.duration <= 0 then
		return true
	end
	local t = syl.text_stripped
	if t:len() <= 0 then return true end
	t = t:gsub("[ \t\n\r]", "") 
	t = t:gsub("　", "")
	return t:len() <= 0
end

function edit_ruby_line(subs,sel)
	if #sel <=0 then
		aegisub.debug.out("you must select a line to edit!")
	end
	--aegisub.debug.out(tostring(#sel))
	
	local line = subs[ sel[1] ]
	meta,styles = karaskel.collect_head(subs,generate_furigana)
	karaskel.preproc_line_text(meta,styles,line)
	local maintext = {}
	local furitext = {}
	for k=1,#line.kara do
		local syl = line.kara[k]
		maintext[k] = syl.text
		furitext[k] = ""
		if syl.text:find("|") then
			maintext[k], furitext[k] = syl.text:match("^(.-)|(.-)$")
		end
		--aegisub.debug.out(maintext[k]..furitext[k].."\n")
	end
	
	local ruby_dialog ={}
	for i=1,#maintext do
		local labeltext = tostring(i)..","..maintext[i]..":"
		table.insert(ruby_dialog, {class = "label",label =labeltext,x=0,y=i-1,width=1,height=1})
		if furitext[i]~= "" then
			table.insert(ruby_dialog, {class = "edit",name=maintext[i],value=furitext[i],x=1,y=i-1,width=1,height=1})
		end
	end
	button, results = aegisub.dialog.display(ruby_dialog, {"OK","Cancel"})
	if button=="OK" then
		local newtext = ""
		for i=1,#maintext do
			newtext = newtext.."{\\k1}"..maintext[i]
			if furitext[i]~="" then
				newtext = newtext.."|"..results[ maintext[i] ]
			end
		end
		line.text = newtext
		subs[ sel[1] ] = line
	else
		aegisub.cancel()
	end
end

aegisub.register_macro(script_name.."/Settings", script_description, set_config)
aegisub.register_macro(script_name.."/Edit Ruby", script_description, edit_ruby_line)
aegisub.register_macro(script_name.."/Generate", script_description, stylize)
