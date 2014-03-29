#==============================================================================
# ** Victor Engine - Control Text
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.02 > First release
#  v 1.01 - 2012.01.04 > Added break line (\n)
#  v 1.02 - 2012.01.07 > Added constant to set the usage of control codes
#                      > Added manual control text code
#                      > Removed the new control codes, they're going to be
#                        added with a separated script.
#                      > Added text replace constant for small text box
#  v 1.03 - 2012.01.10 > Added compatibility with Control Codes
#  v 1.04 - 2012.01.15 > Added compatibility with Target Arrow
#  v 1.05 - 2012.03.15 > Compatibility with ENG version/VXAce_SP1
#  v 1.06 - 2012.08.18 > Fixed issue with some characters
#------------------------------------------------------------------------------
#  This script allows the use to use Control Codes (\c[x], \n[x] and such)
# in every text in a window. By default, only the message box and help text
# have this feature. But with this script you can use it in any window.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.07
# 
# * Overwrite methods (Default)
#   class Window_Base < Window
#     def process_normal_character(c, pos)
#
# * Alias methods (Default)
#   class Window_Base < Window
#     def draw_text(*args)
#     def convert_escape_characters(text)
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
#  Text with codes have a slow process, slower than the default draw text
#  (wich is very slow by itself). Also, text with codes won't stretch to
#  fit the text width. So you can set if all text will automatically use codes
#  or if only specified text will do.
#  If VE_AUTOMATIC_TEXT_CODE = true, all text will automatically use codes,
#  if false you will need to add the code \# at the start of any text
#  you might want to use control codes.
#
#  Some of the database boxes have limited space, and would be hard to add
#  some codes on them, so you can have the script to replace these text
#  by using the code \r[code], this will make the text be replaced with the
#  text set on the script setting VE_TEXT_REPLACE.
#
#  Text within strings on the script editor using double quotation (""), like
#  the ones on the Vocab module, needs two backslashes to use the codes.
#  E.g.:
#    Emerge = "%s \\c[1]emerged!\\c[0]"
#
#  The text will not stretch to fit the window if it's the text width is
#  larger than the text width.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the automatic text control codes
  #   when false, it's needed to add \# on the start of the text to use
  #   control codes
  #--------------------------------------------------------------------------
  VE_AUTOMATIC_TEXT_CODE = false
  #--------------------------------------------------------------------------
  # * Set the automatic text raplace
  #   The text here will replace the code when you use the code \r[code]
  #   The code must be downcase and have no white space.
  #--------------------------------------------------------------------------
  VE_TEXT_REPLACE = {
    new:  "\\#\\i[125]\\c[4]New Game\\c[0]",
    load: "\\#\\i[126]\\c[3]Continue\\c[0]",
    shut: "\\#\\i[127]\\c[2]Shutdown\\c[0]",
  } # Don't remove
  VE_TEXT_REPLACE.default("")
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
$imported[:ve_control_text] = 1.06
Victor_Engine.required(:ve_control_text, :ve_basic_module, 1.07, :above)
Victor_Engine.required(:ve_control_text, :ve_control_code, 1.00, :bellow)

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Overwrite method: process_normal_character
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    return unless c >= ' '
    w = text_size(c).width
    draw_text_ve_control_text(pos[:x], pos[:y], w * 2, pos[:height], c)
    pos[:x] += w
  end  
  #--------------------------------------------------------------------------
  # * Alias method: obtain_escape_code
  #--------------------------------------------------------------------------
  alias :obtain_escape_code_ve_control_text :obtain_escape_code
  def obtain_escape_code(text)
    text =~ /^#/i ? text.slice!(/^#/i) : 
    obtain_escape_code_ve_control_text(text)
  end
  #--------------------------------------------------------------------------
  # * Alias method: draw_text
  #--------------------------------------------------------------------------
  alias :draw_text_ve_control_text :draw_text
  def draw_text(*args)
    text = args[0].is_a?(Rect) ? args[1].to_s : args[4].to_s
    if VE_AUTOMATIC_TEXT_CODE || text =~ /\\[#]/i
      draw_code_text(*args)
    else
      draw_text_ve_control_text(*args)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: convert_escape_characters
  #--------------------------------------------------------------------------
  alias :convert_escape_characters_ve_control_text :convert_escape_characters
  def convert_escape_characters(text)
    result = text.to_s.clone
    begin
      result = text_replace(result)
      result = convert_escape_characters_ve_control_text(result)
    end until !result.include?("\\")
    result.gsub!(/\a/) { "\\" }
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: draw_code_text
  #--------------------------------------------------------------------------
  def draw_code_text(*args)
    is_rect = args[0].is_a?(Rect)
    x = is_rect ? args[0].x      : args[0]
    y = is_rect ? args[0].y      : args[1]
    w = is_rect ? args[0].width  : args[2]
    h = is_rect ? args[0].height : args[3]
    t = is_rect ? args[1].to_s   : args[4].to_s
    a = is_rect ? args[2]        : args[5]
    @text_align  = a
    @text_width  = w
    @text_height = h
    @original_text = t.dup
    draw_text_ve(x, y, t)
  end
  #--------------------------------------------------------------------------
  # * Alias method: text_replace
  #--------------------------------------------------------------------------
  alias :text_replace_ve_control_text :text_replace
  def text_replace(result)
    result = text_replace_ve_control_text(result)
    result.gsub!(/\e\e/) { "\a" }
    result.gsub!(/\e\#/) { "" }
    result.gsub!(/\eR\[(\w+)\]/i) { VE_TEXT_REPLACE[$1.downcase.to_sym] }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: reset_font_settings_ve
  #--------------------------------------------------------------------------
  def reset_font_settings_ve
    contents.font.bold      = Font.default_bold
    contents.font.italic    = Font.default_italic
    contents.font.shadow    = Font.default_shadow
    contents.font.outline   = Font.default_outline
    contents.font.out_color = Font.default_out_color
  end
  #--------------------------------------------------------------------------
  # * New method: process_character_ve
  #--------------------------------------------------------------------------
  def process_character_ve(c, t, p)
    case c
    when "\n" then process_new_line_ve(t, p)
    when "\f" then process_new_page(t, p)
    when "\e" then process_escape_character(obtain_escape_code(t), t, p)
    else process_normal_character(c, p)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: process_new_line_ve
  #--------------------------------------------------------------------------
  def process_new_line_ve(text, pos)
    pos[:x] = get_x(pos[:new_x])
    pos[:y] += pos[:height]
    pos[:height] = calc_line_height(text)
  end
  #--------------------------------------------------------------------------
  # * New method: draw_text_ve
  #--------------------------------------------------------------------------
  def draw_text_ve(x, y, text)
    reset_font_settings_ve
    text = convert_escape_characters(text)
    pos  = {x: get_x(x), y: y, new_x: x, height: @text_height}
    process_character_ve(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: get_x
  #--------------------------------------------------------------------------
  def get_x(x)
    pos = 0
    begin
      c = @original_text.slice!(0, 1)
      text_width = text_size(c).width
      pos += text_width unless ["\n", "\f", "\e", "\a"].include?(c)
    end until c == "\n" || @original_text.empty?
    case @text_align
    when 1 then x + (@text_width - pos) / 2
    when 2 then x + (@text_width - pos)
    else x
    end
  end
end