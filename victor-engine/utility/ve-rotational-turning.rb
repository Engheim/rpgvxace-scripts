#==============================================================================
# ** Victor Engine - Rotational Turning
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.23 > First release
#  v 1.01 - 2011.12.30 > Fixed get on and off vehicle glitch
#  v 1.02 - 2012.01.01 > Fixed initial event direction and added new tags
#  v 1.03 - 2012.01.04 > Compatibility with Character Control
#  v 1.04 - 2012.05.30 > Compatibility with Pixel Movement
#  v 1.05 - 2012.07.24 > Compatibility with Moving Platforms
#  v 1.06 - 2012.11.03 > Fixed issue with direction ladders
#                      > Fixed issue with direction after map transfer
#------------------------------------------------------------------------------
#  This scripts allows to set a different movement when the character changes
# the direction he is facing, instead of facing directly the new direction
# the character tunrs smoothly with a rotational movement.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.05 or higher
#   If used with 'Victor Engine - Multi Frames' place this bellow it.
# 
# * Overwrite methods
#   class Game_CharacterBase
#     def set_direction(d)
#
# * Alias methods
#   class Game_CharacterBase
#     def init_private_members
#     def update
#
#   class Game_Event < Game_Character
#     def clear_page_settings
#     def setup_page_settings
#
#   class Game_Player < Game_Character
#     def initialize
#
#   class Game_Interpreter
#     def comment_call
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
#  <actor rotation on> 
#  <actor rotation off>
#   These tags allows to turn the rotation move on or off for the player.
#
#  <event i rotation on> 
#  <event i rotation off>
#   These tags allows to turn the rotation move on or off for events.
#     i : event ID
#
#------------------------------------------------------------------------------
# Comment boxes note tags:
#   Tags to be used on events Comment boxes. They're different from the
#   comment call, they're called always the even refresh.
#
#  <rotation move>
#    This tag allows the rotation move for events if VE_ROTATE_EVENTS = false
#    It enables the rotation move only for the page where the comment
#    is located
#
#  <block rotation>
#    This tag disable the rotation move for events if VE_ROTATE_EVENTS = true
#    It disable the rotation move only for the page where the comment
#    is located
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set rotational turning for events
  #    If true, automatically all events will have rotational turning.
  #    If false, you must add the rotational turning manually by adding the
  #    comment tag for rotational turn on it.
  #--------------------------------------------------------------------------
  VE_ROTATE_EVENTS = true
  #--------------------------------------------------------------------------
  # * Set wait time between the frame change during rotation
  #--------------------------------------------------------------------------
  VE_ROTATION_WAIT = 2
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
$imported[:ve_roatation_turn] = 1.06
Victor_Engine.required(:ve_roatation_turn, :ve_basic_module, 1.05, :above)

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Overwrite method: set_direction
  #--------------------------------------------------------------------------
  def set_direction(d)
    @stop_count = 0
    return if @direction_fix || d == 0 || rotating? || (ladder_down? && d == 2)
    set_final_direction(d)
    @rotation_wait  = VE_ROTATION_WAIT
    @clock_rotation = rotation_direction
    @current_direction = @final_direction if !rotation_enabled? || tranfering?
    update_direction if tranfering?
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_private_members
  #--------------------------------------------------------------------------
  alias :init_private_members_ve_roatation_turn :init_private_members
  def init_private_members
    init_private_members_ve_roatation_turn
    @final_direction   = 0
    @current_direction = 0
    @rotation_wait     = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_roatation_turn :update
  def update
    update_rotation if rotating?
    update_ve_roatation_turn
    update_direction
  end
  #--------------------------------------------------------------------------
  # * New method: set_final_direction
  #--------------------------------------------------------------------------
  def set_final_direction(d)
    diag = $imported[:ve_diagonal_move] && diagonal_enabled? && diagonal?
    case d
    when 2 then @final_direction = diag ? 1 : 0
    when 4 then @final_direction = diag ? 3 : 2
    when 6 then @final_direction = diag ? 7 : 6
    when 8 then @final_direction = diag ? 5 : 4
    end
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_direction
  #--------------------------------------------------------------------------
  def rotation_direction
    clock = 0
    nclock = 8
    clock  += 1 while @final_direction != (@current_direction + clock) % 8
    nclock -= 1 while @final_direction != (@current_direction + nclock) % 8
    clock < (8 - nclock)
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_enabled?
  #--------------------------------------------------------------------------
  def rotation_enabled?
    @rotation_enabled
  end
  #--------------------------------------------------------------------------
  # * New method: rotating?
  #--------------------------------------------------------------------------
  def rotating?
    @final_direction != @current_direction
  end
  #--------------------------------------------------------------------------
  # * New method: update_rotation
  #--------------------------------------------------------------------------
  def update_rotation
    @pattern = @original_pattern
    return @rotation_wait -= 1 if @rotation_wait > 0
    @rotation_wait = VE_ROTATION_WAIT
    add = $imported[:ve_diagonal_move] ? 1 : 2
    dir = @current_direction
    dir = (dir + add) % 8 if @clock_rotation
    dir = dir - add if !@clock_rotation
    dir = $imported[:ve_diagonal_move] ? 7 : 6 if dir < 0
    @current_direction = dir
  end
  #--------------------------------------------------------------------------
  # * New method: update_direction
  #--------------------------------------------------------------------------
  def update_direction
    case @current_direction
    when 0 then @direction = 2; @diagonal = 0
    when 1 then @direction = 2; @diagonal = 1
    when 2 then @direction = 4; @diagonal = 0
    when 3 then @direction = 4; @diagonal = 7
    when 4 then @direction = 8; @diagonal = 0
    when 5 then @direction = 8; @diagonal = 9
    when 6 then @direction = 6; @diagonal = 0
    when 7 then @direction = 4; @diagonal = 3
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_clear_direction
  #--------------------------------------------------------------------------
  def update_clear_direction
    case @direction
    when 2 then @current_direction = @final_direction = 0
    when 4 then @current_direction = @final_direction = 2
    when 6 then @current_direction = @final_direction = 6
    when 8 then @current_direction = @final_direction = 4
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_final_direction
  #--------------------------------------------------------------------------
  def get_final_direction
    case @final_direction
    when 0 then [2, 0]
    when 1 then [2, 1]
    when 2 then [4, 0]
    when 3 then [4, 7]
    when 4 then [8, 0]
    when 5 then [8, 9]
    when 6 then [6, 0]
    when 7 then [4, 3]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: ladder_down?
  #--------------------------------------------------------------------------
  def ladder_down?
    $game_map.ladder?(@x, @y + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: transfer?
  #--------------------------------------------------------------------------
  def tranfering?
    $game_player.transfer? && (player? || follower?)
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: clear_page_settings
  #--------------------------------------------------------------------------
  alias :clear_page_settings_ve_roatation_turn :clear_page_settings
  def clear_page_settings
    clear_page_settings_ve_roatation_turn
    @rotation_enabled = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_page_settings
  #--------------------------------------------------------------------------
  alias :setup_page_settings_ve_roatation_turn :setup_page_settings
  def setup_page_settings
    setup_page_settings_ve_roatation_turn
    @rotation_enabled  = VE_ROTATE_EVENTS || note =~ /<ROTATION MOVE>/i
    @rotation_enabled  = false if note =~ /<BLOCK ROTATION>/i
    set_final_direction(@direction)
    @current_direction = @final_direction
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_on
  #--------------------------------------------------------------------------
  def rotation_on
    @rotation_enabled = true
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_off
  #--------------------------------------------------------------------------
  def rotation_off
    @rotation_enabled = false
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_roatation_turn :initialize
  def initialize
    initialize_ve_roatation_turn
    rotation_on
  end
  #--------------------------------------------------------------------------
  # * Alias method: get_on_off_vehicle
  #--------------------------------------------------------------------------
  alias :get_on_off_vehicle_ve_roatation_turn :get_on_off_vehicle
  def get_on_off_vehicle
    return if rotating?
    get_on_off_vehicle_ve_roatation_turn
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_private_members
  #--------------------------------------------------------------------------
  alias :clear_transfer_info_ve_roatation_turn :clear_transfer_info
  def clear_transfer_info
    clear_transfer_info_ve_roatation_turn
    update_clear_direction
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_on
  #--------------------------------------------------------------------------
  def rotation_on
    @rotation_enabled = true
    @followers.rotation_on
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_off
  #--------------------------------------------------------------------------
  def rotation_off
    @rotation_enabled = false
    @followers.rotation_off
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
  # * New method: rotation_on
  #--------------------------------------------------------------------------
  def rotation_on
    @rotation_enabled = true
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_off
  #--------------------------------------------------------------------------
  def rotation_off
    @rotation_enabled = false
  end
end

#==============================================================================
# ** Game_Followers
#------------------------------------------------------------------------------
#  This class handles the followers. It's a wrapper for the built-in class
# "Array." It's used within the Game_Player class.
#==============================================================================

class Game_Followers
  #--------------------------------------------------------------------------
  # * New method: rotation_on
  #--------------------------------------------------------------------------
  def rotation_on
    each {|follower| follower.rotation_on }
  end
  #--------------------------------------------------------------------------
  # * New method: rotation_off
  #--------------------------------------------------------------------------
  def rotation_off
    each {|follower| follower.rotation_off }
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
  alias :comment_call_ve_roatation_turn :comment_call
  def comment_call
    call_change_actor_rotation
    call_change_event_rotation
    comment_call_ve_roatation_turn
  end  
  #--------------------------------------------------------------------------
  # * New method: call_change_actor_rotation
  #--------------------------------------------------------------------------
  def call_change_actor_rotation
    if note =~ /<ACTOR ROTATION (ON|OFF)>/i
      $game_player.rotation_off if $1.upcase == "OFF"
      $game_player.rotation_on  if $1.upcase == "ON"
    end
  end 
  #--------------------------------------------------------------------------
  # * New method: call_change_event_rotation
  #--------------------------------------------------------------------------
  def call_change_event_rotation
    if note =~ /<EVENT (\d+) ROTATION (ON|OFF)>/i
      $game_map.events[$1.to_i].rotation_off if $2.upcase == "OFF"
      $game_map.events[$1.to_i].rotation_on  if $2.upcase == "ON"
    end
  end
end