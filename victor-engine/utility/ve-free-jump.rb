#==============================================================================
# ** Victor Engine - Free Jump
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.24 > First release
#  v 1.01 - 2013.01.07 > Fixed issue with Terrain States and Moving Platform
#------------------------------------------------------------------------------
#  This script adds a jumping system to the game, you can have the character
# to jump when the key set is pressed. While jumping, the character will
# not trigger events and terrain damage.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.25 or higher
#   Requires the script 'Victor Engine - Pixel Movement' v 1.04 or higher
#   If used with 'Victor Engine - Moving Platform' place this bellow it.
#   If used with 'Victor Engine - Terrain States' place this bellow it.
#
# * Overwrite methods
#   class Game_CharacterBase
#     def screen_y
#
# * Alias methods
#   class Game_Player < Game_Character
#     def start_map_event(x, y, triggers, normal)
#     def clear_transfer_info
#     def dash?
#     def update
#     def move_by_input
#     def update_nonmoving(last_moving)
#     def on_damage_floor?
#     def on_state_floor?
#
#   class Sprite_Character < Sprite_Base
#     def set_tile_bitmap
#     def update_position
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <enable jump>
#   Enable the free jump
#
#  <disable jump>
#   Disable the free jump
#
#------------------------------------------------------------------------------
# Additional instructions:
#  
#  Free Jump start DISABLED. Use the comment call to enable jump once you want
#  it to be enabled.
#
#  IMPORTANT: This mechanic was developed for single player porpouse only.
#   It WILL NOT WORK WITH THE FOLLOWERS. Disable the followers visibility on
#   where jumping is allowed. I will not make this system works with followers,
#   simply don't ask anything about it.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Jump key
  #   Setup the key that makes the player jump when pressed
  #    :A >> keyboard Shift  :B >> keyboard X      :C >> keyboard Z
  #    :X >> keyboard A      :Y >> keyboard S      :Z >> keyboard D
  #    :L >> keyboard Q      :R >> keyboard W
  #--------------------------------------------------------------------------
  VE_JUMP_KEY = :X
  #--------------------------------------------------------------------------
  # * Setup moving during jumps
  #   If true you can control the movement while jumping, if false
  #   the direction will not change when the jump start.
  #--------------------------------------------------------------------------
  VE_FREE_MOVE = true
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
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_free_jump] = 1.00
Victor_Engine.required(:ve_free_jump, :ve_basic_module, 1.25, :above)
Victor_Engine.required(:ve_free_jump, :ve_pixel_movement, 1.04, :above)

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Overwrite method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@real_y) * 32 + 32 - shift_y
  end
  #--------------------------------------------------------------------------
  # * New method: position_adjust
  #--------------------------------------------------------------------------
  def position_adjust
    jump_height
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :jump_enabled
  #--------------------------------------------------------------------------
  # * Alias method: clear_transfer_info
  #--------------------------------------------------------------------------
  alias :start_map_event_ve_free_jump :start_map_event
  def start_map_event(x, y, triggers, normal)
    return if jumping?
    start_map_event_ve_free_jump(x, y, triggers, normal)
  end
  #--------------------------------------------------------------------------
  # * Alias method: clear_transfer_info
  #--------------------------------------------------------------------------
  alias :clear_transfer_info_ve_free_jump :clear_transfer_info
  def clear_transfer_info
    clear_transfer_info_ve_free_jump
    @dash_count = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: dash?
  #--------------------------------------------------------------------------
  alias :dash_ve_free_jump? :dash?
  def dash?
    result = dash_ve_free_jump?
    result = @jump_dash if jumping?
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_free_jump :update
  def update
    update_ve_free_jump
    free_jump if Input.trigger?(VE_JUMP_KEY) && jump_enabled
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_by_input
  #--------------------------------------------------------------------------
  alias :move_by_input_ve_free_jump :move_by_input
  def move_by_input
    return update_jump_move if !VE_FREE_MOVE && jumping?
    move_by_input_ve_free_jump
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_nonmoving
  #--------------------------------------------------------------------------
  alias :update_nonmoving_ve_free_jump :update_nonmoving
  def update_nonmoving(last_moving)
    @dash_count += ((dash? && (last_moving || @moved)) ? 1 : -1)
    @dash_count  = [[@dash_count, 6].min, 0].max
    update_nonmoving_ve_free_jump(last_moving)
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_damage_floor?
  #--------------------------------------------------------------------------
  alias :on_damage_floor_ve_free_jump? :on_damage_floor?
  def on_damage_floor?
    on_damage_floor_ve_free_jump? && !jumping?
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_state_floor?
  #--------------------------------------------------------------------------
  alias :on_state_floor_ve_free_jump? :on_state_floor? if $imported[:ve_terrain_states]
  def on_state_floor?
    on_state_floor_ve_free_jump? && !jumping?
  end
  #--------------------------------------------------------------------------
  # * New method: update_jump
  #--------------------------------------------------------------------------
  def update_jump
    @free_jump ? update_free_jump : super
  end
  #--------------------------------------------------------------------------
  # * New method: position_adjust
  #--------------------------------------------------------------------------
  def free_jump
    return if $game_map.interpreter.running? || jumping?
    diag = $imported[:ve_roatation_turn] && diagonal_enabled? && diagonal?
    @jump_peak  = 3
    @jump_count = @jump_peak * 2
    @stop_count = 0
    @run_jump   = true
    @free_jump  = true
    @end_press  = false
    @jump_dash  = @dash_count == 6
    @jump_move  = Input.press?(Input.dir4)
    rotation    = $imported[:ve_roatation_turn]
    @jump_dir   = rotation ? get_final_direction[0] : @direction
    @jump_diag  = rotation ? get_final_direction[1] : @diagonal
    straighten
  end
  #--------------------------------------------------------------------------
  # * New method: position_adjust
  #--------------------------------------------------------------------------
  def update_free_jump
    @end_press   = true if !Input.press?(VE_JUMP_KEY)
    jump_pressed = Input.press?(VE_JUMP_KEY) && !@end_press && @jump_peak < 8
    @jump_count += 2 if jump_pressed
    @jump_peak  += 1 if jump_pressed
    @jump_count = [@jump_count - 0.8, 0].max
    update_move
    update_bush_depth
    straighten
    @free_jump = false if @jump_count == 0
    @jump_dash = false if @jump_count == 0
  end
  #--------------------------------------------------------------------------
  # * New method: position_adjust
  #--------------------------------------------------------------------------
  def update_jump_move
    return if moving? || !@jump_move
    if !@jump_diag || @jump_diag == 0
      move_straight(@jump_dir)
    elsif @jump_diag && @jump_diag != 0
      diagonal_movement(@jump_diag)
    end
  end
end


#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_free_jump :comment_call
  def comment_call
    call_jump_enable
    comment_call_ve_free_jump
  end
  #--------------------------------------------------------------------------
  # * New method: call_jump_enable
  #--------------------------------------------------------------------------
  def call_jump_enable
    $game_player.jump_enabled = true  if note =~ /<ENABLE JUMP>/i 
    $game_player.jump_enabled = false if note =~ /<DISABLE JUMP>/i 
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
  # * Alias method: set_tile_bitmap
  #--------------------------------------------------------------------------
  alias :set_tile_bitmap_ve_free_jump :set_tile_bitmap
  def set_tile_bitmap
    set_tile_bitmap_ve_free_jump
    @cw = 16
    @ch = 32
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_position
  #--------------------------------------------------------------------------
  alias :update_position_ve_free_jump :update_position
  def update_position
    update_position_ve_free_jump
    self.oy = @ch + @character.position_adjust
  end
end