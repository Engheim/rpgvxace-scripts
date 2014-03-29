#==============================================================================
# ** Victor Engine - Control Codes
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Aditional Credit :
#   - CCOA   (For the U.M.S that was used as font for code ideas)
#   - Yanfly (For the YEA - MS that was used as font for code ideas)
#
# Version History:
#  v 1.00 - 2012.01.11 > First release
#  v 1.01 - 2012.01.15 > Fixed the Regular Expressions problem with "" and “”
#  v 1.02 - 2012.03.15 > Compatibility with ENG version/VXAce_SP1
#  v 1.03 - 2012.08.07 > Fixed issues with icon codes
#------------------------------------------------------------------------------
#  This script adds new Control Codes (such as \c[x], \n[x]...) to be used
# whitin the texts. By default they can be used only on Message and
# Help Window, they can be used everywhere when used together with the script
# 'Victor Engine - Control Text'
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.09 or higher
#   If used with 'Victor Engine - Control Text' place this bellow it.
# 
# * Alias methods (Default)
#   class Game_Temp
#     def initialize
#
#   class Window_Base < Window
#     def obtain_escape_code(text)
#     def convert_escape_characters(text)
#     def reset_font_settings
#
#   class Window_Base < Window
#     def obtain_escape_code(text)
#     def convert_escape_characters(text)
#     def process_escape_character(code, text, pos)
#     def reset_font_settings
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Text within strings on the script editor using double quotation (""), like
#  the ones on the Vocab module, needs two backslashes to use the codes.
#  E.g.:
#    Emerge = "%s \\c[1]emerged!\\c[0]"
#
#  The text will not stretch to fit the window if it's the text width is
#  larget than the window width.
#
#  Color Codes:
#  \c[x]         : change color to one of the windowskin colors
#  \c[#rrggbbaa] : change color using hexadecimal values (00-FF) the
#                  aplha (aa) is opitional
#  \c[r,g,b,a]   : change color using RGB values (0-255), the alpha (a) is
#                  optional
#
#  Gold Codes:
#  \g  : display currency unit
#  \tg : display total gold
# 
#  Font Codes:
#  \fn[x]  : change font name ("fontname")
#  \fs[x]  : change font size
#  \fd     : make font disabled (translucent)
#  \fb     : toggle font bold
#  \fi     : toggle font italtic
#  \fo     : toggle font outline
#  \fs     : toggle font shadow
#  \foc[x] : change outline color, can be hexadecimal or rgb value
#            (0 = default color)
#  \foa[x] : change outline alpha
# 
#  Actor Codes:
#  \an[x]    : display actor nickname   (actor ID)
#  \ac[x]    : display actor class name (actor ID)
#  \al[x]    : display actor level      (actor ID)
#  \ap[x, y] : display actor paramenter (actor ID, parameter ID)
#  
#  Icon Coldes:
#  \ii[x] : Display item icon   (Item ID)
#  \iw[x] : Display weapon icon (Weapon ID)
#  \ia[x] : Display armor icon  (Armor ID)
#  \is[x] : Display skill icon  (Skill ID)
#  \it[x] : Display state icon  (State ID)
# 
#  Name Codes:
#  \nc[x]  : display class name  (Class ID)
#  \ni[x]  : display item name   (Item ID)
#  \nw[x]  : display weapon name (Weapon ID)
#  \na[x]  : display armor name  (Armor ID)
#  \ns[x]  : display skill name  (Skill ID)
#  \nt[x]  : display state name  (State ID)
#  \np[x]  : display parameter name (Parameter ID)
#  \nsw[x] : display switch name    (Switch ID)
#  \nvr[x] : display variable name  (Variable ID)
#  \nev[x] : display event name     (Event ID)
#  \nen[x] : display enemy name     (Enemy ID)
#  \nel[x] : display element name   (Element ID)
#  \nwt[x] : display weapon type name (Weapon Type ID)
#  \nat[x] : display armor type name  (Armor Type ID)
#  \nst[x] : display skill type name  (Skill Type ID)
#  \nmp[x] : display map name (Map ID, 0 = current map)
#
#  Misc Codes:
#  \n  : break line
#  \cr : code recplace, replace the code with whatever is stored on
#        the global variable $game_temp.control_code. It can be used to store 
#        long codes and use them on message windows.
#        Ex.: make a script call before the message with:
#             $game_temp.control_code = "\c[#FF0000]\foc[1]\foa[120]"
#             and call \cr to use the code "\c[#FF0000]\foc[1]\foa[120]"
#  \ev"x" : evalute the code on x.
#           Ex.:\ev"$game_sytem.step_count"
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_control_code] = 1.01
Victor_Engine.required(:ve_control_code, :ve_basic_module, 1.09, :above)

#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :control_code
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_control_code :initialize
  def initialize
    initialize_ve_control_code
    @control_code = ""
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: obtain_escape_code
  #--------------------------------------------------------------------------
  alias :obtain_escape_code_ve_control_code :obtain_escape_code
  def obtain_escape_code(text)
    list = "OC|OA|N|Z|D|B|I|O|S"
    text =~ /^F(?:#{list})/i ? text.slice!(/^F(?:#{list})/i) : 
    obtain_escape_code_ve_control_code(text)
  end
  #--------------------------------------------------------------------------
  # * Alias method: convert_escape_characters
  #--------------------------------------------------------------------------
  alias :convert_escape_characters_ve_control_code :convert_escape_characters
  def convert_escape_characters(text)
    result = text.to_s.clone
    result = text_replace(result) unless $imported[:ve_control_text]
    result = convert_escape_characters_ve_control_code(result)
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: reset_font_settings
  #--------------------------------------------------------------------------
  alias :reset_font_settings_ve_control_code :reset_font_settings
  def reset_font_settings
    reset_font_settings_ve_control_code
    contents.font.shadow  = Font.default_shadow
    contents.font.outline = Font.default_outline
    contents.font.out_color = Font.default_out_color
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_escape_character
  #--------------------------------------------------------------------------
  alias :process_escape_character_ve_control_code :process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(precess_text_color(text))
    when 'FN', 'FZ', 'FD', 'FB', 'FI', 'FO', 'FS', 'FOC', 'FOA'
      precess_font_settings(code, text)
    when 'II', 'IW', 'IA', 'IS', 'IT'
      process_icon_setting(code, pos)
    else
      process_escape_character_ve_control_code(code, text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: text_replace
  #--------------------------------------------------------------------------
  alias :text_replace_ve_control_code :text_replace
  def text_replace(result)
    result.gsub!(/\\CR/i) { $game_temp.contro_code.to_s }
    result = text_replace_ve_control_code(result)
    result = replace_misc_values(result)
    result = replace_actor_values(result)
    result = replace_name_values(result)
    result
  end
  #--------------------------------------------------------------------------
  # * New method: replace_misc_values
  #--------------------------------------------------------------------------
  def replace_misc_values(result)
    result.gsub!(/\eTG/i) { $game_party.gold.to_s }
    result.gsub!(/\eEV#{get_filename}/i) { eval($1).to_s }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: replace_actor_values
  #--------------------------------------------------------------------------
  def replace_actor_values(result)
    result.gsub!(/\eAN\[(\d+)\]/i) { actor_nickname($1.to_i) }
    result.gsub!(/\eAC\[(\d+)\]/i) { actor_class($1.to_i) }
    result.gsub!(/\eAL\[(\d+)\]/i) { actor_level($1.to_i) }
    result.gsub!(/\eAP\[(\d+) *, *(\d+)\]/i) { actor_param($1.to_i, $2.to_i) }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: replace_name_values
  #--------------------------------------------------------------------------
  def replace_name_values(result)
    result.gsub!(/\eNC\[(\d+)\]/i)  { class_name($1.to_i) }
    result.gsub!(/\eNI\[(\d+)\]/i)  { item_name($1.to_i) }
    result.gsub!(/\eNW\[(\d+)\]/i)  { weapon_name($1.to_i) }
    result.gsub!(/\eNA\[(\d+)\]/i)  { armor_name($1.to_i) }
    result.gsub!(/\eNS\[(\d+)\]/i)  { skill_name($1.to_i) }
    result.gsub!(/\eNT\[(\d+)\]/i)  { state_name($1.to_i) }
    result.gsub!(/\eNP\[(\d+)\]/i)  { param_name($1.to_i) }
    result.gsub!(/\eNEV\[(\d+)\]/i) { event_name($1.to_i) }
    result.gsub!(/\eNEN\[(\d+)\]/i) { enemy_name($1.to_i) }
    result.gsub!(/\eNSW\[(\d+)\]/i) { switch_name($1.to_i) }
    result.gsub!(/\eNVR\[(\d+)\]/i) { variable_name($1.to_i) }
    result.gsub!(/\eNEL\[(\d+)\]/i) { element_name($1.to_i) }
    result.gsub!(/\eNWT\[(\d+)\]/i) { weapon_type_name($1.to_i) }
    result.gsub!(/\eNAT\[(\d+)\]/i) { armor_type_name($1.to_i) }
    result.gsub!(/\eNST\[(\d+)\]/i) { skill_type_name($1.to_i) }
    result.gsub!(/\eNMP\[(\d+)\]/i) { map_name($1.to_i) }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: actor_nickname
  #--------------------------------------------------------------------------
  def actor_nickname(n)
    $game_actors[n] ? $game_actors[n].nickname : ""
  end
  #--------------------------------------------------------------------------
  # * New method: actor_class
  #--------------------------------------------------------------------------
  def actor_class(n)
    $game_actors[n] ? $game_actors[n].class.name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: actor_level
  #--------------------------------------------------------------------------
  def actor_level(n)
    $game_actors[n] ? $game_actors[n].level.to_s : ""
  end
  #--------------------------------------------------------------------------
  # * New method: actor_param
  #--------------------------------------------------------------------------
  def actor_param(n, i)
    $game_actors[n] ? $game_actors[n].param(i).to_s : ""
  end
  #--------------------------------------------------------------------------
  # * New method: class_name
  #--------------------------------------------------------------------------
  def class_name(n)
    $data_classes[n] ? $data_classes[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: item_name
  #--------------------------------------------------------------------------
  def item_name(n)
    $data_items[n] ? $data_items[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: weapon_name
  #--------------------------------------------------------------------------
  def weapon_name(n)
    $data_weapons[n] ? $data_weapons[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: armor_name
  #--------------------------------------------------------------------------
  def armor_name(n)
    $data_armors[n] ? $data_armors[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: skill_name
  #--------------------------------------------------------------------------
  def skill_name(n)
    $data_skills[n] ? $data_skills[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: state_name
  #--------------------------------------------------------------------------
  def state_name(n)
    $data_states[n] ? $data_states[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: param_name
  #--------------------------------------------------------------------------
  def param_name(n)
    $data_system.terms.params[n] ? $data_system.terms.params[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: event_name
  #--------------------------------------------------------------------------
  def event_name(n)
    $game_map.events[n] ? $game_map.events[n].name  : ""
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_name
  #--------------------------------------------------------------------------
  def enemy_name(n)
    $data_enemies[n] ? $data_enemies[n].name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: switch_name
  #--------------------------------------------------------------------------
  def switch_name(n)
    $data_system.switches[n] ? $data_system.switches[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: ariable_name
  #--------------------------------------------------------------------------
  def variable_name(n)
    $data_system.variables[n] ? $data_system.variables[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: element_name
  #--------------------------------------------------------------------------
  def element_name(n)
    $data_system.elements[n] ? $data_system.elements[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: weapon_type_name
  #--------------------------------------------------------------------------
  def weapon_type_name(n)
    $data_system.variables[n] ? $data_system.variables[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: armor_type_name
  #--------------------------------------------------------------------------
  def armor_type_name(n)
    $data_system.armor_types[n] ? $data_system.armor_types[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: skill_type_name
  #--------------------------------------------------------------------------
  def skill_type_name(n)
    $data_system.skill_types[n] ? $data_system.skill_types[n] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: map_name
  #--------------------------------------------------------------------------
  def map_name(n)
    n == 0 ? current_map_name : get_map_name(n)
  end
  #--------------------------------------------------------------------------
  # * New method: current_map_name
  #--------------------------------------------------------------------------
  def current_map_name
    $game_map.display_name ? $game_map.display_name : ""
  end
  #--------------------------------------------------------------------------
  # * New method: get_map_name
  #--------------------------------------------------------------------------
  def get_map_name(n)
    map = load_data(sprintf("Data/Map%03d.rvdata2", n))
    map ? map.display_name ? map.display_name : "" : ""
  end
  #--------------------------------------------------------------------------
  # * New method: precess_text_color
  #--------------------------------------------------------------------------
  def precess_text_color(text, default = nil)
    param = obtain_escape_param(text)
    param = obtain_rgb_color(text)  if param == 0
    param = obtain_hex_color(text)  if param == 0
    color = text_color(param)       if param.numeric?
    color = default                 if param == 0 && default
    color = change_rgb_color(param) if param =~ /(?: *,? *\d+){3,4}/i
    color = change_hex_color(param) if param =~ /\#[ABCDEF\d]{6,8}/i
    color
  end
  #--------------------------------------------------------------------------
  # * New method: obtain_rgb_color
  #--------------------------------------------------------------------------
  def obtain_rgb_color(text)
    text.slice!(/^\[(?: *,? *\d+){3,4}\]/)[/(?: *,? *\d+){3,4}/] rescue 0
  end
  #--------------------------------------------------------------------------
  # * New method: obtain_hex_color
  #--------------------------------------------------------------------------
  def obtain_hex_color(text)
    text.slice!(/^\[\#[ABCDEF\d]{6,8}\]/i)[/\#[ABCDEF\d]{6,8}/i] rescue 0
  end
  #--------------------------------------------------------------------------
  # * New method: change_rgb_color
  #--------------------------------------------------------------------------
  def change_rgb_color(param)
    if param =~ /(\d+) *, *(\d+) *, *(\d+) *,? *(\d+)?/
      color = Color.new($1.to_i, $2.to_i, $3.to_i, $4 ? $4.to_i : 255)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: change_hex_color
  #--------------------------------------------------------------------------
  def change_hex_color(param)
    if param =~ /\#(.{2})(.{2})(.{2})(.{2})?/i
      color = Color.new($1.hex, $2.hex, $3.hex, $4 ? $4.hex : 255)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: precess_font_settings
  #--------------------------------------------------------------------------
  def precess_font_settings(code, text)
    case code.upcase
    when 'FN'  then contents.font.name = obtain_escape_text(text)
    when 'FZ'  then contents.font.size = obtain_escape_param(text)
    when 'FD'  then contents.font.color.alpha = translucent_alpha
    when 'FB'  then contents.font.bold    = !contents.font.bold
    when 'FI'  then contents.font.italic  = !contents.font.italic
    when 'FO'  then contents.font.outline = !contents.font.outline
    when 'FS'  then contents.font.shadow  = !contents.font.shadow
    when 'FOC' then contents.font.out_color = precess_ouline_color(text)
    when 'FOA' then contents.font.out_color.alpha = obtain_escape_param(text)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: precess_ouline_color
  #--------------------------------------------------------------------------
  def precess_ouline_color(text)
    precess_text_color(text, Font.default_out_color)
  end
  #--------------------------------------------------------------------------
  # * New method: obtain_escape_text
  #--------------------------------------------------------------------------
  def obtain_escape_text(text)
    text.slice!(/^\[[ \w\d]*\]/)[/[ \w\d]*/].to_s rescue Font.default_name
  end
  #--------------------------------------------------------------------------
  # * New method: process_icon_settings
  #--------------------------------------------------------------------------
  def process_icon_settings(code, text)
    case code.upcase
    when 'II'
      icon = object_icon_index($data_items, obtain_escape_param(text))
      process_draw_icon(icon, pos)
    when 'IW'
      icon = object_icon_index($data_weapons, obtain_escape_param(text))
      process_draw_icon(icon, pos)
    when 'IA'
      icon = object_icon_index($data_armors, obtain_escape_param(text))
      process_draw_icon(icon, pos)
    when 'IS'
      icon = object_icon_index($data_skills, obtain_escape_param(text))
      process_draw_icon(icon, pos)
    when 'IT'
      icon = object_icon_index($data_states, obtain_escape_param(text))
      process_draw_icon(icon, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: object_icon_index
  #--------------------------------------------------------------------------
  def object_icon_index(object, index)
    object[index].icon_index rescue 0
  end
end