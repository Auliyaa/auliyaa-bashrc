require 'cairo'
json = require ('dkjson')
require('lfs')
require('math')

-- =====================================
-- configuration variables
-- =====================================
-- palette generated from background image using https://www.canva.com/colors/color-palette-generator/
color_0='#21252B'
color_1='#A7A9A9'
color_2='#7E7763'
color_3='#6B7C61'

-- default font
font='Noto Sans Light'

-- current y position (drawing is done from top to bottom)
yy=0

-- weather data
owm_key='642f2fb760774183f5d8f3147d493deb'
owm_query='Toulouse,FR'

-- current loop index for weather data fetching
owm_loop_idx=0
owm_fetch_frequency=300

-- owm icons
owm_icons_font="Font Awesome 5 Pro Light"

owm_icons = {}
owm_icons["50n"]=""
owm_icons["50d"]=""
owm_icons["13n"]=""
owm_icons["13d"]=""
owm_icons["11n"]=""
owm_icons["11d"]=""
owm_icons["10n"]=""
owm_icons["10d"]=""
owm_icons["09n"]=""
owm_icons["09d"]=""
owm_icons["04n"]=""
owm_icons["04d"]=""
owm_icons["03n"]=""
owm_icons["03d"]=""
owm_icons["02n"]=""
owm_icons["02d"]=""
owm_icons["01n"]=""
owm_icons["01d"]=""
owm_icons_notfound=""

-- =====================================
-- check if a directory exists
-- =====================================
function dir_exists(path)
  return (lfs.attributes(path, "mode") == "directory")
end

-- =====================================
-- check if a file exists
-- =====================================
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- =====================================
-- Path to current script
-- =====================================
function lua_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or './'
end

-- =====================================
-- path to python scripts folder
-- =====================================
function py_path()
   return string.format('%s%s',lua_path(),'../py/')
end

-- =====================================
-- path to icons folder
-- =====================================
function icons_path()
   return string.format('%s%s',lua_path(),'../icons/')
end

-- =====================================
-- convert hex strings to rgb
-- =====================================
function hex2rgb(hex)
	if hex == nil then
		hex = "#404047"
	end

	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2))/255,
		   tonumber("0x"..hex:sub(3,4))/255,
		   tonumber("0x"..hex:sub(5,6))/255
end

-- =====================================
-- return conky window dimensions
-- =====================================
function conky_wh()
	return conky_window.width,conky_window.height
end

-- =====================================
-- set current font for cairo
-- =====================================
function text_set_font(cr, font, font_size, font_slant, font_weight)
	font_slant = font_slant or CAIRO_FONT_SLANT_NORMAL
	font_weight = font_weight or CAIRO_FONT_WEIGHT_NORMAL
	cairo_select_font_face (cr, font, font_slant, font_weight)
	cairo_set_font_size(cr, font_size)
end

-- =====================================
-- get text bounding box dimensions
-- =====================================
function text_dimensions(cr, text, font, font_size)
	local ct = cairo_text_extents_t:create()
	cairo_text_extents(cr,text,ct)
	return ct.width, ct.height
end

-- =====================================
-- draw text using cairo
-- =====================================
function text_draw(cr, text, x, y, hsv, a)
	local r,g,b = hex2rgb(hsv)
	cairo_set_source_rgba(cr, r, g, b, a)
	cairo_move_to(cr, x, y)
	cairo_show_text(cr, text)
end

-- =====================================
-- (step) draw background
-- =====================================
function draw_bg(cr)
	local r,g,b = hex2rgb(color_0)

	cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
	cairo_set_source_rgba(cr, r, g, b, 0.9)
	cairo_move_to(cr, 0, 0)
	cairo_rel_line_to(cr, w, 0)
	cairo_rel_line_to(cr, 0, h)
	cairo_rel_line_to(cr, -w, 0)
	cairo_close_path(cr)
	cairo_fill(cr)
end

-- =====================================
-- (step) draw date & time
-- =====================================
function draw_clock(cr)
	local datestr = conky_parse('${exec date +"%A %d %B %Y"}')
	local timestr = conky_parse('${exec date +"%H:%M:%S"}')

	-- draw time
  text_set_font(cr, font, 42, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)

	local time_tw,time_th = text_dimensions(cr, timestr)
	yy = yy + time_th + 20
	text_draw(cr, timestr, 25, yy, color_1, 1)

 	-- draw date
	text_set_font(cr, font, 16)
  local date_tw,date_th = text_dimensions(cr, datestr)

  yy = yy + date_th + 15
	text_draw(cr, datestr, 25, yy, color_1, 1)

	-- draw bottom line
	yy = yy+20
	cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
	local r,g,b = hex2rgb(color_1)
	cairo_set_source_rgba(cr, r, g, b, 0.5)
	cairo_move_to(cr, 20, yy)
	cairo_rel_line_to(cr, w-40, 0)
	cairo_rel_line_to(cr, 0, 2)
	cairo_rel_line_to(cr, -w+40, 0)
	cairo_close_path(cr)
	cairo_fill(cr)
end

-- =====================================
-- draw weather icon & data
-- =====================================
function draw_weather(cr)
  -- refresh weather str at given frequency
	if (owm_loop_idx%owm_fetch_frequency == 0) then
		local weatherstr = conky_parse(string.format('${exec python3 %s%s --key %s --query %s}',py_path(),'owm.py',owm_key,owm_query))
    owm_decode_obj, owm_decode_pos, owm_decode_err = json.decode(weatherstr, 1, nil)
  end

  if not owm_decode_err then
    local main = owm_decode_obj.main
    local weather = owm_decode_obj.weather[1]
    local icon_text = owm_icons[weather.icon] or owm_icons_notfound
    local degree_text = string.format('%s°C',math.floor(main.temp),math.floor(main.feels_like))
    local sub_text1 = string.format('%s,%s',owm_decode_obj.name,owm_decode_obj.sys.country)
    local sub_text2 = string.format('%s%% hum.',main.humidity)

    -- draw icon
    text_set_font(cr, owm_icons_font, 40)
    local icon_tw,icon_th = text_dimensions(cr, icon_text)
  	text_draw(cr, icon_text, w-icon_tw-20, icon_th+10, color_1, 1)

    -- draw degrees
    text_set_font(cr, font, 28)
    local degree_tw,degree_th = text_dimensions(cr, degree_text)
    text_draw(cr, degree_text, w-icon_tw-20-degree_tw-15, degree_th+icon_th/3, color_1, 1)

    -- draw subtext1
    text_set_font(cr, font, 16, CAIRO_FONT_SLANT_ITALIC, CAIRO_FONT_WEIGHT_NORMAL)
    local subtext1_tw,subtext1_th = text_dimensions(cr, sub_text1)
    text_draw(cr, sub_text1, w-subtext1_tw-20, icon_th+subtext1_th+30, color_1, 1)

    -- draw subtext2
    text_set_font(cr, font, 16, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    local subtext2_tw,subtext2_th = text_dimensions(cr, sub_text2)
    text_draw(cr, sub_text2, w-icon_tw-20-subtext2_tw-15, subtext2_th+icon_th+5, color_1, 1)

  end

	owm_loop_idx = (owm_loop_idx+1)%owm_fetch_frequency
end

-- =====================================
-- draw bar
-- =====================================
function draw_bar(cr, bx, by, bw, bh, bval, bmax)

  cairo_set_operator(cr, CAIRO_OPERATOR_OVER)



  -- local r1,g1,b1 = hex2rgb(color_1)
  -- cairo_set_line_width (cr, 1.0);
  -- cairo_move_to(cr, bx, by)
  -- cairo_rel_line_to(cr, bw, 0)
  -- cairo_rel_line_to(cr, 0, bh)
  -- cairo_rel_line_to(cr, -bw, 0)
  -- cairo_close_path(cr)
  --
  -- cairo_stroke(cr)
end

-- =====================================
-- CPU temps
-- =====================================
function draw_cpu_temps(cr)
  yy=yy+10

  -- title
  text_set_font(cr, font, 20, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
  local text="CPU temps"
  local tw,th=text_dimensions(cr,text)

  cairo_set_source_rgba(cr, r1, g1, b1, 1)
  text_draw(cr, text, (w/2.) - (tw/2.), yy+th, color_1, 1)

  yy=yy+th+5
  draw_bar(cr, 30, yy, w-60, 20, 50, 100)
end

-- =====================================
-- conky entrypoint
-- =====================================
function conky_start_widgets()
	if conky_window == nil then
		return end

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cr = cairo_create(cs)

	w,h = conky_wh()
	if (w ~= 0 and h ~= 0) then
		-- restart from top
		yy=0
		draw_bg(cr)
    draw_weather(cr)
		draw_clock(cr)
    draw_cpu_temps(cr)

		-- CPU temp
		-- CPU frequency
		-- CPU usage
		-- disk usage
		-- ram usage
		-- local git status
	end

	cairo_surface_destroy(cs)
	cairo_destroy(cr)
end
