#==============================================================================
# ** Victor Engine - SFont
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Aditional Credit :
#   - RubyGame  (Original Concept)
#   - Trickster (RubyGame SFont conversion to RPG Maker)
#
# Version History:
#  v 1.00 - 2011.12.21 > First release
#  v 1.01 - 2011.12.21 > Change on the configuration module
#------------------------------------------------------------------------------
#  This script allows the use of SFonts. SFonts is a image file that replaces
# the normal font.
# 
# What are SFonts? (from http://rubygame.org/docs/)
# SFont is a type of bitmapped font, which is loaded from an image file with
# a meaningful top row of pixels, and the font itself below that. The top row
# provides information about what parts of of the lower area contains font
# data, and which parts are empty. The image file should contain all of the 
# glyphs on one row, with the colorkey color at the bottom-left pixel and the
# "skip" color at the top-left pixel.
#
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
# 
# * Alias methods (Default)
#   class Bitmap
#     def draw_text
#     def text_size(str)
#
#   class << DataManager
#     def create_game_objects
#
#   class Sprite_Timer < Sprite
#     def create_bitmap
#
#   class Window_Base < Window
#     def create_contents
#     def text_color(n)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section on bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#  The SFonts must be placed on the folder "Graphics/SFonts". Create a folder
#  named "SFonts" on the Graphics folder.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   On the SFont, the first pixel on the top left corner is considered the
#   "skip color", so, anywhere that this color appears on the first row
#   the part will be skiped, so use it to define the limit from each
#   character. At first it might be hard to get how it work.
#
#   If the constant ALL_SFONT is true, all fonts in all windows will be
#   replaced with SFonts, if false, you will need to add them manually
#   in the code (not recomended for begginers).
#
#   The method "text_color(n)" from Window_Base can be used to change
#   the SFont, where n is the SFont index on the SFONT_NAMES hash.
#   Text on independent bitmaps (outside windows) will need to be changed
#   manually on the code.
#
#   The system fonts can be changed on the Window_Base class, on the
#   following methods. Replace the number in text_color(x) with the index
#   of the color SFont on the SFONT_NAMES hash.
#    def normal_color;      text_color(0);   end;
#    def system_color;      text_color(16);  end;
#    def crisis_color;      text_color(17);  end;
#    def knockout_color;    text_color(18);  end;
#    def mp_cost_color;     text_color(23);  end;
#    def power_up_color;    text_color(24);  end;
#    def power_down_color;  text_color(25);  end;
#    def tp_cost_color;     text_color(29);  end;
#   If you don't feel like changing the default scripts, just create a new
#   script on the Materials section for the class Window_Base, add these
#   medthods, and change the numeric values according to the ones
#   set on SFONT_NAMES hash.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the use of SFonts for all windows
  #    If true all windows will use SFonts automatically, if false
  #    you must set them manually
  #--------------------------------------------------------------------------
  VE_ALL_SFONT = true
  #--------------------------------------------------------------------------
  # * Set SFonts
  #    Set here the index and name of the SFonts that will be used, add how
  #    many SFont names you want. Refer to the SFont bitmap with $sfont[index]
  #    VE_SFONT_NAMES = { index => name, index => name, ... }
  #--------------------------------------------------------------------------
  VE_SFONT_NAMES = { 1 => "Arial White", 2 => "Arial Red", 3 => "Arial Blue",
    4 => "Arial Green", 5 => "Arial Yellow", 6 => "Arial Gray" }
  #--------------------------------------------------------------------------
  # * Set the digit list
  #    The order of the digits here define the order of of the digits on
  #    the image file, make sure to follow the same order or the text
  #    in game might be totally screwed.
  #    You can add how many characters you want, even complex character.
  #    the character here doesn't need to be exactly the same from the
  #    image file so you can use special characters to show icons and such.
  #--------------------------------------------------------------------------
  VE_SFONT_DIGITS = ["!",'"',"#","$","%","&","'","(",")","*","+",",","-",".",
  "/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A",
  "B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T",
  "U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g",
  "h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
  "{","|","}","~"]
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
$imported[:ve_sfonts] = 1.01
Victor_Engine.required(:ve_sfonts, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads each of graphics, creates a Bitmap object, and retains it.
# To speed up load times and conserve memory, this module holds the created
# Bitmap object in the internal hash, allowing the program to return
# preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * New method: sfont
  #--------------------------------------------------------------------------
  def self.sfont(filename, hue = 0)
    self.load_bitmap("Graphics/SFonts/", filename, hue)
  end
end

#==============================================================================
# ** Bitmap
#------------------------------------------------------------------------------
#  This class handles and draws the bitmaps
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :sfont
  #--------------------------------------------------------------------------
  # * Alias method: draw_text
  #--------------------------------------------------------------------------
  alias :draw_text_ve_sfont :draw_text
  def draw_text(*args)
    sfont ? draw_sfont_text(*args) : draw_text_ve_sfont(*args)
  end
  #--------------------------------------------------------------------------
  # * Alias method: draw_sfont_text
  #--------------------------------------------------------------------------
  def draw_sfont_text(*args)
    is_rect = args[0].is_a?(Rect)
    x      = is_rect ? args[0].x      : args[0]
    y      = is_rect ? args[0].y      : args[1]
    width  = is_rect ? args[0].width  : args[2]
    height = is_rect ? args[0].height : args[3]
    text   = is_rect ? args[1].to_s   : args[4].to_s
    align  = is_rect ? args[2]        : args[5]
    bitmap = sfont.draw_text(text)
    x += width - bitmap.width       if align == 2
    x += (width - bitmap.width) / 2 if align == 1
    y += (height - bitmap.height) / 2 - 4
    blt(x, y, bitmap, bitmap.rect)
  end
  #--------------------------------------------------------------------------
  # * Alias method: text_size
  #--------------------------------------------------------------------------
  alias :text_size_ve_sfont :text_size
  def text_size(text)
    sfont ? sfont.text_size(text) : text_size_ve_sfont(text)
  end
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module handles the game and database objects used in game.
# Almost all global variables are initialized on this module
#==============================================================================

class << DataManager
  #--------------------------------------------------------------------------
  # * Alias method: create_game_objects
  #--------------------------------------------------------------------------
  alias :create_game_objects_ve_sfont :create_game_objects
  def create_game_objects
    create_game_objects_ve_sfont
    create_sfonts
  end
  #--------------------------------------------------------------------------
  # * New method: create_sfonts
  #--------------------------------------------------------------------------
  def create_sfonts
    $sfont = {}
    VE_SFONT_NAMES.keys.each {|i| $sfont[i] = SFont.new(VE_SFONT_NAMES[i]) }
    $sfont.default = $sfont[$sfont.keys.sort.first]
  end
end

#==============================================================================
# ** Sprite_Timer
#------------------------------------------------------------------------------
#  This sprite is used to display the timer. It observes the $game_system
# and automatically changes sprite conditions.
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # * Alias method: create_bitmap
  #--------------------------------------------------------------------------
  alias :create_bitmap_ve_sfont :create_bitmap
  def create_bitmap
    create_bitmap_ve_sfont
    self.bitmap.sfont = $sfont[0] if VE_ALL_SFONT
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: create_contents
  #--------------------------------------------------------------------------
  alias :create_contents_ve_sfont :create_contents
  def create_contents
    create_contents_ve_sfont
    contents.sfont = $sfont[0] if VE_ALL_SFONT
  end
  #--------------------------------------------------------------------------
  # * Alias method: text_color
  #--------------------------------------------------------------------------
  alias :text_color_ve_sfont :text_color
  def text_color(n)
    sfont(n)
    text_color_ve_sfont(n)
  end
  #--------------------------------------------------------------------------
  # * Alias method: change_color
  #--------------------------------------------------------------------------
  alias :change_color_ve_sfont :change_color
  def change_color(color, enabled = true)
    change_color_ve_sfont(color, enabled)
    contents.sfont.alpha = enabled ? 255 : translucent_alpha
  end
  #--------------------------------------------------------------------------
  # * New method: sfont
  #--------------------------------------------------------------------------
  def sfont(n)
    return if !contents.sfont
    contents.sfont = $sfont[n]
  end
end

#==============================================================================
# ** SFont
#------------------------------------------------------------------------------
#  This class handles the SFonts
#==============================================================================

class SFont
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :bitmap
  attr_accessor :alpha
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(name)
    @bitmap = Cache.sfont(name)
    @height = @bitmap.height + 4
    @skip   = @bitmap.get_pixel(0, 0)
    @digits = VE_SFONT_DIGITS
    @alpha  = 255
    @values = {}
    @values[" "] = Rect.new(-12, 0, 12, @height)
    setup_digits
    @values.default = @values[" "]
  end
  #--------------------------------------------------------------------------
  # * setup_digits
  #--------------------------------------------------------------------------
  def setup_digits
    x1 = x2 = 0
    @digits.each do |digit|
      x1 += 1 while @bitmap.get_pixel(x1, 0) == @skip && x1 < @bitmap.width
      x2 = x1    
      x2 += 1 while @bitmap.get_pixel(x2, 0) != @skip && x2 < @bitmap.width
      @values[digit] = Rect.new(x1, 0, x2 - x1, @height)
      x1 = x2
    end
  end
  #--------------------------------------------------------------------------
  # * text_size
  #--------------------------------------------------------------------------
  def text_size(text)
    size = 0
    text.split("").each {|i| size += @values[i].width}
    rect = Rect.new(0, 0, size, @height)
    rect
  end
  #--------------------------------------------------------------------------
  # * draw_text
  #--------------------------------------------------------------------------
  def draw_text(text)
    width = [text_size(text).width, 1].max
    bitmap = Bitmap.new(width, @height)
    x = 0
    text.split("").each do |i|
      bitmap.blt(x, 4, @bitmap, @values[i], @alpha)
      x += @values[i].width
    end
    bitmap
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
    return if !@bitmap || @bitmap.disposed?
    @bitmap.dispose
  end
end