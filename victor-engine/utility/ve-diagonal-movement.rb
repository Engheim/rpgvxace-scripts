#==============================================================================
# ** Victor Engine - Diagonal Movement
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.23 > First release
#  v 1.01 - 2011.12.30 > Fixed sync with vehicle
#  v 1.02 - 2012.01.01 > New comment tags
#  v 1.03 - 2012.01.04 > Compatibility with Character Control
#  v 1.04 - 2012.01.04 > Compatibility with Follower Control
#  v 1.05 - 2012.05.29 > Compatibility with Pixel Movement
#  v 1.06 - 2012.07.25 > Fixed Compatibility with Visual Equip and
#                      > Character Control
#  v 1.07 - 2012.07.30 > Fixed diagonal movement speed
#  v 1.08 - 2012.08.04 > Added option for fixing blocked movement
#  v 1.09 - 2013.01.24 > Fixed issue with pixel movement and VE_DIAGONAL_FIX
#------------------------------------------------------------------------------
#  This script allows to set diagonal movement for the player and events.
# This feature is opitional for events. It's possible to have different
# graphic for the diagonal movement
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.16 or higher
#   If used with 'Victor Engine - Multi Frames' place this bellow it.
#   If used with 'Victor Engine - Pixel Movement' place this bellow it.
#   If used with 'Victor Engine - Visual Equip' place this bellow it.
# 
# * Alias methods (Default)
#   class Game_CharacterBase
#     def init_public_members
#     def move_straight(d, turn_ok = true)
#     def move_diagonal(horz, vert)
#
#   class Game_Character < Game_CharacterBase
#     def move_random
#     def move_toward_character(character)
#     def move_away_from_character(character)
#     def turn_toward_character(character)
#     def turn_away_from_character(character)
#     def move_forward
#
#   class Game_Event < Game_Character
#     def clear_page_settings
#     def setup_page_settings
#
#   class Game_Player < Game_Character
#     def initialize
#     def move_by_input
#
#   class Game_Vehicle < Game_Character
#     def sync_with_player
#
#   class Sprite_Character < Sprite_Base
#     def graphic_changed?
#     def update_src_rect
#
# * Alias methods (Basic Module)
#   class Game_Character < Game_CharacterBase
#     def move_toward_position(x, y)
#
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the scripts 'Victor Engine - Basic' and 
#  'Victor Engine - Multi Frames'.
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <actor diagonal on> 
#  <actor diagonal off>
#   These tags allows to turn the diagonal on or off for the player.
#
#  <event i diagonal on> 
#  <event i diagonal off>
#   These tags allows to turn the diagonal on or off for events.
#     i : event ID
#
#------------------------------------------------------------------------------
# Comment boxes note tags:
#   Tags to be used on events Comment boxes. They're different from the
#   comment call, they're called always the even refresh.
#
#  <diagonal move>
#    This tag allows the diagonal move for events if VE_DIAGONAL_EVENTS = false
#    It enables the diagonal move only for the page where the comment
#    is located
#
#  <block diagonal>
#    This tag disable the diagonal move for events if VE_DIAGONAL_EVENTS = true
#    It disable the diagonal move only for the page where the comment
#    is located
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  To add custom graphic for diagonal movement, you must have a graphic
#  with the sufix set on VE_DIAGONAL_SUFIX added to it's name, by default
#  this sufix is "[diag]", so you must have a file named "CharName[diag]"
#  for a chaset named "CharName". If the diagonal file doesn't exist, it 
#  will use the normal graphic.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Diagonal graphic sufix
  #    Sufix added to the names of diagonal movement graphics.
  #--------------------------------------------------------------------------
  VE_DIAGONAL_SUFIX = "[diag]"
  #--------------------------------------------------------------------------
  # * Set diagonal movement for events
  #    If true, automatically all events will have diagonal movement
  #    If false, you must add the diagonal movement manually by adding the
  #    comment tag for diagonal move on it.
  #--------------------------------------------------------------------------
  VE_DIAGONAL_EVENTS = false 
  #--------------------------------------------------------------------------
  # * Fix blocked diagonal movement
  #   If true, when the diagonal movement is blocked, then the character
  #   moves straight to the direction not blocked.
  #--------------------------------------------------------------------------
  VE_DIAGONAL_FIX = false
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
$imported[:ve_diagonal_move] = 1.09
Victor_Engine.required(:ve_diagonal_move, :ve_basic_module, 1.16, :above)
Victor_Engine.required(:ve_diagonal_move, :ve_character_control, 1.10, :bellow)

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :diagonal
  #--------------------------------------------------------------------------
  # * Alias method: init_public_members
  #--------------------------------------------------------------------------
  alias :init_public_members_ve_diagonal_move :init_public_members
  def init_public_members
    init_public_members_ve_diagonal_move
    @diagonal = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_straight
  #--------------------------------------------------------------------------
  alias :move_straight_ve_diagonal_move :move_straight
  def move_straight(d, turn_ok = true)
    @diagonal = 0
    move_straight_ve_diagonal_move(d, turn_ok)
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_diagonal
  #--------------------------------------------------------------------------
  alias :move_diagonal_ve_diagonal_move :move_diagonal
  def move_diagonal(horz, vert)
    @diagonal = 1 if diagonal_enabled? && horz == 4 && vert == 2
    @diagonal = 3 if diagonal_enabled? && horz == 6 && vert == 2
    @diagonal = 7 if diagonal_enabled? && horz == 4 && vert == 8
    @diagonal = 9 if diagonal_enabled? && horz == 6 && vert == 8
    move_diagonal_ve_diagonal_move(horz, vert)
    diagonal_direction if diagonal_enabled?
  end
  #--------------------------------------------------------------------------
  # * Alias method: distance_per_frame
  #--------------------------------------------------------------------------
  alias :distance_per_frame_ve_diagonal_move :distance_per_frame
  def distance_per_frame
    distance = distance_per_frame_ve_diagonal_move
    diagonal? ? distance / Math.sqrt(2) : distance
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_enabled?
  #--------------------------------------------------------------------------
  def diagonal_enabled?
    @diagonal_enabled
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal?
  #--------------------------------------------------------------------------
  def diagonal?
    @diagonal && @diagonal != 0 
  end
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Alias method: move_random
  #--------------------------------------------------------------------------
  alias :move_random_ve_diagonal_move :move_random
  def move_random
    if diagonal_enabled? && rand(2) == 0
      horz = [4, 6].random
      vert = [2, 8].random
      move_diagonal(horz, vert)
    else
      move_random_ve_diagonal_move
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_toward_character
  #--------------------------------------------------------------------------
  alias :move_toward_character_ve_diagonal_move :move_toward_character
  def move_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    horz = sx > 0 ? 4 : 6
    vert = sy > 0 ? 8 : 2
    if diagonal_enabled? && sx != 0 && sy != 0 && 
       diagonal_passable?(x, y, horz, vert)
      move_diagonal(horz, vert)
    else
      move_toward_character_ve_diagonal_move(character)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: move_toward_position
  #--------------------------------------------------------------------------
  alias :move_toward_position_ve_diagonal_move :move_toward_position
  def move_toward_position(x, y)
    sx = distance_x_from(x)
    sy = distance_y_from(y)
    horz = sx > 0 ? 4 : 6
    vert = sy > 0 ? 8 : 2
    if diagonal_enabled? && sx != 0 && sy != 0 && 
       diagonal_passable?(x, y, horz, vert)
      move_diagonal(horz, vert)
    else
      move_toward_position_ve_diagonal_move(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_away_from_character
  #--------------------------------------------------------------------------
  alias :move_away_from_character_ve_diagonal_move :move_away_from_character
  def move_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    horz = sx > 0 ? 6 : 4
    vert = sy > 0 ? 2 : 8
    if diagonal_enabled? && sx != 0 && sy != 0 && 
       diagonal_passable?(x, y, horz, vert)
      move_diagonal(horz, vert)
    else
      move_away_from_character_ve_diagonal_move(character)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: turn_toward_character
  #--------------------------------------------------------------------------
  alias :turn_toward_character_ve_diagonal_move :turn_toward_character
  def turn_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if diagonal_enabled? && sx != 0 && sy != 0
      @diagonal = 1 if sx > 0 && sy < 0
      @diagonal = 3 if sx < 0 && sy < 0
      @diagonal = 7 if sx > 0 && sy > 0
      @diagonal = 9 if sx < 0 && sy > 0
      diagonal_direction
    else
      @diagonal = 0
      turn_toward_character_ve_diagonal_move(character)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: turn_away_from_character
  #--------------------------------------------------------------------------
  alias :turn_away_from_character_ve_diagonal_move :turn_away_from_character
  def turn_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if diagonal_enabled? && sx != 0 && sy != 0
      @diagonal = 1 if sx < 0 && sy > 0
      @diagonal = 3 if sx > 0 && sy > 0
      @diagonal = 7 if sx < 0 && sy < 0
      @diagonal = 9 if sx > 0 && sy < 0
      diagonal_direction
    else
      @diagonal = 0
      turn_away_from_character_ve_diagonal_move(character)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_move_straight
  #--------------------------------------------------------------------------
  alias :update_move_straight_ve_diagonal_move :update_move_straight if $imported[:ve_pixel_movement]
  def update_move_straight
    update_move_straight_ve_diagonal_move
    diagonal_move_fix_pixel(@move_value[:d].first) if player? && @move_value
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_move_diagonal
  #--------------------------------------------------------------------------
  alias :update_move_diagonal_ve_diagonal_move :update_move_diagonal if $imported[:ve_pixel_movement]
  def update_move_diagonal
    update_move_diagonal_ve_diagonal_move
    if player? && @move_value
      d = 1 if @move_value[:d] == [4, 2]
      d = 3 if @move_value[:d] == [6, 2]
      d = 7 if @move_value[:d] == [4, 8]
      d = 9 if @move_value[:d] == [6, 8]
      diagonal_move_fix_pixel(d)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_forward
  #--------------------------------------------------------------------------
  alias :move_forward_ve_diagonal_move :move_forward
  def move_forward
    if diagonal?
      diagonal_movement(@diagonal)
      diagonal_move_fix(@diagonal) if need_fix?
    else
      move_forward_ve_diagonal_move
    end
  end
  #--------------------------------------------------------------------------
  # * New method: need_fix?
  #--------------------------------------------------------------------------
  def need_fix?
    (!moving? && !$imported[:ve_pixel_movement]) && VE_DIAGONAL_FIX
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_movement
  #--------------------------------------------------------------------------
  def diagonal_movement(d)
    case d
    when 1 then move_diagonal(4, 2)
    when 3 then move_diagonal(6, 2)
    when 7 then move_diagonal(4, 8)
    when 9 then move_diagonal(6, 8)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_move_fix
  #--------------------------------------------------------------------------
  def diagonal_move_fix(d)
    @diagonal = nil
    case d
    when 1 then move_straight(4);  move_straight(2) if !moving?
    when 3 then move_straight(6);  move_straight(2) if !moving?
    when 7 then move_straight(4);  move_straight(8) if !moving?
    when 9 then move_straight(6);  move_straight(8) if !moving?
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_diagonal_direction
  #--------------------------------------------------------------------------
  def diagonal_direction
    set_direction(2) if @diagonal == 1
    set_direction(4) if @diagonal == 7
    set_direction(6) if @diagonal == 3
    set_direction(8) if @diagonal == 9
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_move_fix
  #--------------------------------------------------------------------------
  def diagonal_move_fix_pixel(d)
    case d
    when 1 then perform_move_fix_pixel(4, 2)
    when 3 then perform_move_fix_pixel(6, 2)
    when 7 then perform_move_fix_pixel(4, 8)
    when 9 then perform_move_fix_pixel(6, 8)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_move_fix
  #--------------------------------------------------------------------------
  def perform_move_fix_pixel(horz, vert)
    return if @moved || moving?
    @move_value = nil
    @diagonal   = nil
    set_direction(horz)       if passable?(@x, @y, horz) && !@moved
    move_straight_pixel(horz) if passable?(@x, @y, horz) && !@moved
    set_direction(vert)       if passable?(@x, @y, vert) && !@moved
    move_straight_pixel(vert) if passable?(@x, @y, vert) && !@moved
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
  alias :clear_page_settings_ve_diagonal_move :clear_page_settings
  def clear_page_settings
    clear_page_settings_ve_diagonal_move
    @diagonal_enabled = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_page_settings
  #--------------------------------------------------------------------------
  alias :setup_page_settings_ve_diagonal_move :setup_page_settings
  def setup_page_settings
    setup_page_settings_ve_diagonal_move
    @diagonal_enabled =  VE_DIAGONAL_EVENTS || note =~ /<DIAGONAL MOVE>/i
    @diagonal_enabled =  false if note =~ /<BLOCK DIAGONAL>/i
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
  alias :initialize_ve_diagonal_move :initialize
  def initialize
    initialize_ve_diagonal_move
    diagonal_on
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_by_input
  #--------------------------------------------------------------------------
  alias :move_by_input_ve_diagonal_move :move_by_input
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    if diagonal_enabled? && Input.dir8 > 0 && Input.dir8 % 2 != 0
      diagonal_movement(Input.dir8) 
      diagonal_move_fix(Input.dir8) if need_fix?
    else
      move_by_input_ve_diagonal_move
    end
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_on
  #--------------------------------------------------------------------------
  def diagonal_on
    @diagonal_enabled = true
    @followers.diagonal_on
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_off
  #--------------------------------------------------------------------------
  def diagonal_off
    @diagonal_enabled = false
    @followers.diagonal_off
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
  # * Alias method: distance_per_frame
  #--------------------------------------------------------------------------
  alias :distance_per_frame_ve_diagonal_move :distance_per_frame
  def distance_per_frame
    distance = 2 ** real_move_speed / 256.0
    $game_player.diagonal? ? distance / Math.sqrt(2) : distance
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_on
  #--------------------------------------------------------------------------
  def diagonal_on
    @diagonal_enabled = true
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_off
  #--------------------------------------------------------------------------
  def diagonal_off
    @diagonal_enabled = false
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
  # * New method: diagonal_on
  #--------------------------------------------------------------------------
  def diagonal_on
    each {|follower| follower.diagonal_on }
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_off
  #--------------------------------------------------------------------------
  def diagonal_off
    each {|follower| follower.diagonal_off }
  end
end

#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  Esta classe gerencia veículos. Se não houver veículos no mapa atual, a
# coordenada é definida como (-1,-1).
# Esta classe é usada internamente pela classe Game_Map. 
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: sync_with_player
  #--------------------------------------------------------------------------
  alias :sync_with_player_ve_diagonal_move :sync_with_player
  def sync_with_player
    sync_with_player_ve_diagonal_move
    @diagonal = $game_player.diagonal
    diagonal_direction
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
  # * Alias method: graphic_changed?
  #--------------------------------------------------------------------------
  alias :graphic_changed_ve_diagonal_move :graphic_changed?
  def graphic_changed?
    graphic_changed_ve_diagonal_move ||
    @diagonal != @character.diagonal
  end
  #--------------------------------------------------------------------------
  # * New method: update_character_info
  #--------------------------------------------------------------------------
  alias :update_character_info_ve_diagonal_move :update_character_info
  def update_character_info
    update_character_info_ve_diagonal_move
    @diagonal = @character.diagonal
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_src_rect
  #--------------------------------------------------------------------------
  alias :update_src_rect_ve_diagonal_move :update_src_rect
  def update_src_rect
    if @tile_id == 0 && @character.diagonal?
      update_diagonal_src_rect
    else
      update_src_rect_ve_diagonal_move
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: set_character_diagonal_bitmap
  #--------------------------------------------------------------------------
  alias :set_bitmap_name_ve_diagonal_move :set_bitmap_name
  def set_bitmap_name
    name = @character_name + ($imported[:ve_visual_equip] ? "" : diagonal_sufix)
    character_exist?(name) ? name : set_bitmap_name_ve_diagonal_move
  end
  #--------------------------------------------------------------------------
  # * New method: diagonal_sufix
  #--------------------------------------------------------------------------
  def diagonal_sufix
    @character.diagonal? ? VE_DIAGONAL_SUFIX : ""
  end
  #--------------------------------------------------------------------------
  # * New method: update_diagonal_src_rect
  #--------------------------------------------------------------------------
  def update_diagonal_src_rect
    dir = 0 if @diagonal == 1
    dir = 1 if @diagonal == 7
    dir = 2 if @diagonal == 3
    dir = 3 if @diagonal == 9
    index = @character.character_index
    if $imported[:ve_multi_frames] && @character_name[/\[F(\d+)\]/i]
      pattern = @character.pattern
    else
      pattern = @character.pattern < 3 ? @character.pattern : 1
    end
    sx = (index % 4 * @character.frames + pattern) * @cw
    sy = (index / 4 * 4 + dir) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
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
  alias :comment_call_ve_diagonal_move :comment_call
  def comment_call
    call_change_actor_diagonal
    call_change_event_diagonal
    comment_call_ve_diagonal_move
  end  
  #--------------------------------------------------------------------------
  # * New method: call_change_actor_diagonal
  #--------------------------------------------------------------------------
  def call_change_actor_diagonal
    if note =~ /<ACTOR DIAGONAL (ON|OFF)>/i
      $game_player.diagonal_off if $1.upcase == "OFF"
      $game_player.diagonal_on  if $1.upcase == "ON"
    end
  end 
  #--------------------------------------------------------------------------
  # * New method: call_change_event_diagonal
  #--------------------------------------------------------------------------
  def call_change_event_diagonal
    if note =~ /<EVENT (\d+) DIAGONAL (ON|OFF)>/i
      $game_map.events[$1.to_i].diagonal_off if $2.upcase == "OFF"
      $game_map.events[$1.to_i].diagonal_on  if $2.upcase == "ON"
    end
  end
end