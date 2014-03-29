#==============================================================================
# ** Victor Engine - Multi Frames
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.21 > First release
#  v 1.01 - 2011.12.22 > Compatibility with Diagonal Movement
#  v 1.02 - 2012.01.02 > Added character bitmap positions
#  v 1.03 - 2012.01.04 > Compatibility with Character Control
#------------------------------------------------------------------------------
#  This script allows to use charset graphics with a number of frames different
# from 3.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.05 or higher
#   If used with 'Victor Engine - Followers Options' place this bellow it.
#   If used with 'Victor Engine - Visual Equip' place this bellow it.
#
# * Overwrite methods (Default)
#   class Window_Base < Window
#     def draw_character
#
# * Alias methods (Default)
#   class Game_CharacterBase
#     def update_anime_pattern
#     def straighten
#     def set_graphic(character_name, character_index)
#
#   class Sprite_Character < Sprite_Base
#     def set_character_bitmap
#     def update_src_rect
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
#   To change the number of frames of a charset graphic, add [f*] to it's
#   name, where * is the number of frames.
#   It's possible to use individual charsets or 8 characters charsets.
#   If using the 8 characters charset, all of them must have the same number
#   of frames.
#   When changing the number of frames, the animation behavior also changes.
#   Upon reaching the last frame it will return to the first, differently
#   from the default RPG Maker VX Ace pattern, that repate the second frame
#   after displaying the third.
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
$imported[:ve_multi_frames] = 1.03
Victor_Engine.required(:ve_multi_frames, :ve_basic_module, 1.05, :above)
Victor_Engine.required(:ve_multi_frames, :ve_diagonal_move, 1.00, :bellow)
Victor_Engine.required(:ve_multi_frames, :ve_roatation_turn, 1.00, :bellow)
Victor_Engine.required(:ve_multi_frames, :ve_character_control, 1.00, :bellow)

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Alias method: update_anime_pattern
  #--------------------------------------------------------------------------
  alias :update_anime_pattern_ve_multi_frames :update_anime_pattern
  def update_anime_pattern
    if @character_name[/\[F(\d+)\]/i] && !(@stop_count > 0 && !@step_anime)
      @pattern = (@pattern + 1) % frames
    else
      update_anime_pattern_ve_multi_frames
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: straighten
  #--------------------------------------------------------------------------
  alias :straighten_ve_multi_frames :straighten
  def straighten
    if @character_name[/\[F(\d+)\]/i]
      @pattern = 0 if @walk_anime || @step_anime
      @anime_count = 0
    else
      straighten_ve_multi_frames
    end
  end  
  #--------------------------------------------------------------------------
  # * Alias method: set_graphic
  #--------------------------------------------------------------------------
  alias :set_graphic_ve_multi_frames :set_graphic
  def set_graphic(character_name, character_index)
    set_graphic_ve_multi_frames(character_name, character_index)
    @original_pattern = 0 if @character_name[/\[F(\d+)\]/i]
  end  
  #--------------------------------------------------------------------------
  # * New method: frames
  #--------------------------------------------------------------------------
  def frames
    @character_name[/\[F(\d+)\]/i] ? $1.to_i : 3
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player.
# The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_multi_frames :refresh
  def refresh
    refresh_ve_multi_frames
    @original_pattern = @character_name[/\[F(\d+)\]/i] ? 0 : 1
  end
end

#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles the followers. Followers are the actors of the party
# that follows the leader in a line. It's used within the Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_multi_frames :refresh
  def refresh
    refresh_ve_multi_frames
    @original_pattern = @character_name[/\[F(\d+)\]/i] ? 0 : 1
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: update_src_rect
  #--------------------------------------------------------------------------
  alias :update_src_rect_ve_multi_frames :update_src_rect
  def update_src_rect
    if @tile_id == 0 && @character_name[/\[F(\d+)\]/i]
      update_multi_frames_src_rect
    else
      update_src_rect_ve_multi_frames
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_multi_frames_src_rect
  #--------------------------------------------------------------------------
  def update_multi_frames_src_rect
    index = @character.character_index
    sx = (index % 4 * @character.frames + @character.pattern) * @cw
    sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Overwrite method: draw_character
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign   = character_name[/^[\!\$]./]
    frames = character_name[/\[F(\d+)\]/i] ? $1.to_i : 3
    if sign && sign.include?('$')
      cw = bitmap.width / frames
      ch = bitmap.height / 4
    else
      cw = bitmap.width / (frames * 4)
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n % 4* 3 + 1) * cw, (n / 4 * 4) * ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
end