#==============================================================================
# ** Victor Engine - Character Control
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.04 > First release
#  v 1.01 - 2012.01.07 > Added Compatibility with Visual Equipment
#  v 1.02 - 2012.01.14 > Fixed the positive sign on some Regular Expressions
#  v 1.03 - 2012.01.15 > Fixed the Regular Expressions problem with "" and “”
#  v 1.04 - 2012.07.25 > Fixed Compatibility with Visual Equipment and
#                      > Diagonal Movement
#  v 1.05 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to control character chaset animations. You can set
# different graphis for walking, dashing and jumping, also you can display
# pose animations with simple comment call. This allows to animate characters
# on the map without the need of long Move Route event commands.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   If used with 'Victor Engine - Multi Frames' place this bellow it.
#   If used with 'Victor Engine - Visual Equip' place this bellow it.
#   If used with 'Victor Engine - Diagonal Movement' place this bellow it.
#
# * Overwrite methods
#   class Game_CharacterBase
#     def update_animation
#
# * Alias methods
#   class Game_CharacterBase
#     def update_animation
#     def init_public_members
#     def init_private_members
#     def update_anime_count
#     def update_anime_pattern
#     def move_straight(d, turn_ok = true)
#     def move_diagonal(horz, vert)
#     def update_move
#     def update_jump
#     def update_stop
#
#   class Game_Interpreter
#     def comment_call
#
#   class Sprite_Character < Sprite_Base
#     def graphic_changed?
#     def update_character_info
#     def set_bitmap_name
#     def set_bitmap_position
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <actor change pose>      <event change pose>
#  settings                 settings    
#  </actor change pose>     </event change pose>
#   Display a custom pose, the pose overide any other pose being currently
#   played, add the following values to the settings. The ID must be added, 
#   other values are optional. 
#     id: x     : actor index or event ID
#     name: "x" : pose sufix name. ("sufix")
#     loop      : pose animation loop, if added the pose will repeat.
#     lock      : position lock, can't move while playing the pose.
#     walk      : walking pose, if not set the pose will stop if walk.
#     speed: x  : pose animation speed, higher values makes the animation slow.
#     frame: x  : number of frams, can't exceed the max frames of the charset.
#
#  <actor add pose>      <event add pose>
#  settings              settings    
#  </actor add pose>     </event add pose>
#   Display a custom pose, the pose won't be displayed immediately, if there is
#   another pose being displayed, it will wait it finish before, you can
#   add multiple poses at once to make a long animation, add the following
#   values to the settings. The ID must be added, other values are optional. 
#     id: x     : actor index or event ID
#     name: "x" : pose sufix name. ("sufix")
#     loop      : pose animation loop, if added the pose will repeat.
#     lock      : position lock, can't move while playing the pose.
#     walk      : walking pose, if not set the pose will stop if walk.
#     speed: x  : pose animation speed, higher values makes the animation slow.
#     frame: x  : number of frams, can't exceed the max frames of the charset.
#
#  <actor idle stance i: "x">   <event idle stance i: "x">
#  <actor walk stance i: "x">   <event walk stance i: "x">
#  <actor dash stance i: "x">   <event dash stance i: "x">
#  <actor jump stance i: "x">   <event jump stance i: "x">
#   Change the stance for one of the default pose for the actor or event.
#     i : actor index or event ID
#     x : pose sufix name ("sufix")
#
#  <actor clear stances: i>   <event clear stances: i>
#   Clear all changed stances for the actor or event
#     i : actor index or event ID
#
#  <actor clear pose: i>   <event clear pose: i>
#   Clear halts the current pose exhibition and clear all pose waiting to be
#   played.
#     i : actor index or event ID
#
#------------------------------------------------------------------------------
# Additional instructions:
#  
#  To properly display the poses you will need a character with the poses.
#  You will need to make a new charset, with the same filename + the sufix.
#
#  So if you have a chaset named "Actor1", you will need a charset named
#  "Actor1[wlk]" (or whatever you set as the Walk sufix) if you want
#  a custom walking pose.
#
#  If a pose graphic don't exist, it will use the default graphic.
# 
#  If you make a pose loops, it will be displayed continuously until something
#  force it to stop. It may be a movement (only if the settings doesn't include
#  the 'walk' option), a pose change, or clear pose.
#
#  Due to the animated frame, the charset may be off the tile center, you
#  can solve that by adding [x*] or [y*] to the filename, where * is a number
#  positive or negative,that way the position will be adjusted. it must be
#  added before any other sufix
#
#  if used with 'Victor Engine - Diagonal Movement' the diagonal movement
#  sufix must come before the pose sufix.
#
#  The general order for the sufixes is: filename[x*][y*][diag][pose]
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Default waling pose sufix
  #--------------------------------------------------------------------------
  VE_DEFAULT_WALK_SUFIX = "[wlk]"
  #--------------------------------------------------------------------------
  # * Default dashing pose sufix
  #--------------------------------------------------------------------------
  VE_DEFAULT_DASH_SUFIX = "[dsh]"
  #--------------------------------------------------------------------------
  # * Default jumping pose sufix
  #--------------------------------------------------------------------------
  VE_DEFAULT_JUMP_SUFIX = "[jmp]"
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
$imported[:ve_character_control] = 1.05
Victor_Engine.required(:ve_character_control, :ve_basic_module, 1.27, :above)

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
  attr_reader   :pose_sufix
  attr_accessor :pose_list
  attr_accessor :idle_stance
  attr_accessor :walk_stance
  attr_accessor :dash_stance
  attr_accessor :jump_stance
  #--------------------------------------------------------------------------
  # * Overwrite method: update_animation
  #--------------------------------------------------------------------------
  def update_animation
    update_anime_count
    if (@pose_speed != 0 && @anime_count > @pose_speed) ||
       (@pose_speed == 0 && @anime_count > 18 - real_move_speed * 2)
      update_anime_pattern
      @anime_count = 0
      change_pose(idle_stance) if @pattern == 0 && @playing_pose && !@pose_loop
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_public_members
  #--------------------------------------------------------------------------
  alias :init_public_members_ve_character_control :init_public_members
  def init_public_members
    init_public_members_ve_character_control
    @pose_list  = []
    @pose_sufix = ""
    clear_stances
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_private_members
  #--------------------------------------------------------------------------
  alias :init_private_members_ve_character_control :init_private_members
  def init_private_members
    init_private_members_ve_character_control
    change_pose(idle_stance)
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_anime_count
  #--------------------------------------------------------------------------
  alias :update_anime_count_ve_character_control :update_anime_count
  def update_anime_count
    if @playing_pose
      @anime_count += 1.5
    else
      update_anime_count_ve_character_control
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_anime_pattern
  #--------------------------------------------------------------------------
  alias :update_anime_pattern_ve_character_control :update_anime_pattern
  def update_anime_pattern
    if @playing_pose
      @pattern = (@pattern + 1) % [frames, @pose_frame].min
    else
      update_anime_pattern_ve_character_control
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_straight
  #--------------------------------------------------------------------------
  alias :move_straight_ve_character_control :move_straight
  def move_straight(d, turn_ok = true)
    return if @pose_lock
    move_straight_ve_character_control(d, turn_ok)
    set_fixed_direction if @pose_direction
  end
  #--------------------------------------------------------------------------
  # * Alias method: move_diagonal
  #--------------------------------------------------------------------------
  alias :move_diagonal_ve_character_control :move_diagonal
  def move_diagonal(horz, vert)
    return if @pose_lock
    move_diagonal_ve_character_control(horz, vert)
    set_fixed_direction if @pose_direction
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_move
  #--------------------------------------------------------------------------
  alias :update_move_ve_character_control :update_move
  def update_move
    moving_pose
    update_move_ve_character_control
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_jump
  #--------------------------------------------------------------------------
  alias :update_jump_ve_character_control :update_jump
  def update_jump
    jumping_pose
    update_jump_ve_character_control
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_stop
  #--------------------------------------------------------------------------
  alias :update_stop_ve_character_control :update_stop
  def update_stop
    update_stop_ve_character_control
    resting_pose
  end
  #--------------------------------------------------------------------------
  # * New method: resting_pose
  #--------------------------------------------------------------------------
  def resting_pose
    return if @stop_count <= 1 || @playing_pose
    change_pose(idle_stance) if pose_sufix != idle_stance
  end
  #--------------------------------------------------------------------------
  # * New method: jumping_pose
  #--------------------------------------------------------------------------
  def jumping_pose
    return if @pose_lock || @pose_walk
    change_pose(jump_stance) if pose_sufix != jump_stance
  end
  #--------------------------------------------------------------------------
  # * New method: moving_pose
  #--------------------------------------------------------------------------
  def moving_pose
    return if @pose_lock || @pose_walk
    @pose_list.clear
    change_pose(walk_stance) if pose_sufix != walk_stance && !dash?
    change_pose(dash_stance) if pose_sufix != dash_stance && dash?
  end
  #--------------------------------------------------------------------------
  # * New method: change_pose
  #--------------------------------------------------------------------------
  def change_pose(sufix)
    @playing_pose = false 
    reset_fixed_pose if @pose_direction
    value = {sufix: sufix, anim: 0, speed: 0, frame: frames}
    update_pose(value)
  end
  #--------------------------------------------------------------------------
  # * New method: reset_pose_index
  #--------------------------------------------------------------------------
  def reset_pose_index
    @character_index = @real_index
    @pose_index = nil
  end
  #--------------------------------------------------------------------------
  # * New method: reset_fixed_pose
  #--------------------------------------------------------------------------
  def reset_fixed_pose
    @direction = @real_direction
    @diagonal  = @real_diagonal if $imported[:ve_diagonal_move]
    @current_direction = @direction - 2 if $imported[:ve_roatation_turn]
    @final_direction   = @direction - 2 if $imported[:ve_roatation_turn]
    update_direction if $imported[:ve_roatation_turn]
    @pose_direction = nil
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose(pose = default_pose.dup)
    pose = get_next_pose(pose)
    @pose_sufix = pose[:sufix]
    @pose_speed = pose[:speed]
    @pose_frame = pose[:frame]
    @pose_walk  = pose[:walk]
    @pose_loop  = pose[:loop]
    @pose_lock  = pose[:lock] && @playing_pose
    @pose_direction = pose[:line] * 2 if pose[:line]
    @real_direction = @direction
    @real_diagonal  = @diagonal if $imported[:ve_diagonal_move]
    @anime_count    = 0 unless move_pose?
    @pattern        = @playing_pose ? 0 : @original_pattern
    set_fixed_direction if @pose_direction
  end
  #--------------------------------------------------------------------------
  # * New method: set_fixed_direction
  #--------------------------------------------------------------------------
  def set_fixed_direction
    @direction = @pose_direction
    @diagonal  = 0 if $imported[:ve_diagonal_move]
    @current_direction = @direction - 2 if $imported[:ve_roatation_turn]
    @final_direction   = @direction - 2 if $imported[:ve_roatation_turn]
  end
  #--------------------------------------------------------------------------
  # * New method: get_next_pose
  #--------------------------------------------------------------------------
  def get_next_pose(pose)
    if pose == default_pose && !@pose_list.empty?
      pose = @pose_list.shift
      @playing_pose = true
    end
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: move_pose?
  #--------------------------------------------------------------------------
  def move_pose?
    [walk_stance, dash_stance, jump_stance].include?(pose_sufix)
  end
  #--------------------------------------------------------------------------
  # * New method: default_pose
  #--------------------------------------------------------------------------
  def default_pose
    {sufix: @idle_stance, anim: 0, speed: 0, frame: frames}
  end
  #--------------------------------------------------------------------------
  # * New method: start_pose
  #--------------------------------------------------------------------------
  def start_pose(pose)
    clear_poses
    @pose_list.push(pose)
    update_pose
  end 
  #--------------------------------------------------------------------------
  # * New method: add_pose
  #--------------------------------------------------------------------------
  def add_pose(pose)
    @pose_list.push(pose)
    update_pose unless @playing_pose
  end
  #--------------------------------------------------------------------------
  # * New method: clear_poses
  #--------------------------------------------------------------------------
  def clear_poses
    @pose_list.clear
    change_pose(idle_stance)
  end
  #--------------------------------------------------------------------------
  # * New method: clear_stances
  #--------------------------------------------------------------------------
  def clear_stances
    @idle_stance = ""
    @walk_stance = VE_DEFAULT_WALK_SUFIX
    @dash_stance = VE_DEFAULT_DASH_SUFIX
    @jump_stance = VE_DEFAULT_JUMP_SUFIX
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
  alias :comment_call_ve_character_control :comment_call
  def comment_call
    call_clear_pose("EVENT")
    call_clear_pose("ACTOR")
    call_change_stance("EVENT")
    call_change_stance("ACTOR")
    call_change_pose("EVENT", "ADD POSE")
    call_change_pose("ACTOR", "ADD POSE")
    call_change_pose("EVENT", "CHANGE POSE")
    call_change_pose("ACTOR", "CHANGE POSE")
    comment_call_ve_character_control
  end
  #--------------------------------------------------------------------------
  # * New method: call_clear_pose
  #--------------------------------------------------------------------------
  def call_clear_pose(type)
    note.scan(/<#{type} CLEAR POSE: (\d+)>/i) do
      subject = $game_map.events[$1.to_i] if type == "EVENT"
      subject = $game_map.actors[$1.to_i] if type == "ACTOR"
      next unless subject
      subject.clear_poses
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_clear_stances
  #--------------------------------------------------------------------------
  def call_clear_stances(type)
    note.scan(/<#{type} CLEAR STANCES: (\d+)>/i) do
      subject = $game_map.events[$1.to_i] if type == "EVENT"
      subject = $game_map.actors[$1.to_i] if type == "ACTOR"
      next unless subject
      subject.clear_stances
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_change_stance
  #--------------------------------------------------------------------------
  def call_change_stance(type)
    regexp = /<#{type} (\w+) STANCE (\d+): #{get_filename}>/i
    note.scan(regexp) do |move, id, value|
      subject = $game_map.events[id.to_i] if type == "EVENT"
      subject = $game_map.actors[id.to_i] if type == "ACTOR"
      next unless subject
      subject.idle_stance = value if move.upcase == "IDLE"
      subject.walk_stance = value if move.upcase == "WALK"
      subject.dash_stance = value if move.upcase == "DASH"
      subject.jump_stance = value if move.upcase == "JUMP"
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_change_pose
  #--------------------------------------------------------------------------
  def call_change_pose(type, add)
    note.scan(get_all_values("#{type} #{add}")) do
      value = $1.dup
      if value =~ /ID: (\d+)/i
        subject = $game_map.events[$1.to_i] if type == "EVENT"
        subject = $game_map.actors[$1.to_i] if type == "ACTOR"
        next unless subject
        stance = subject.idle_stance
        pose   = {}
        pose[:sufix] = value =~ /NAME: #{get_filename}/i ? $1 : stance
        pose[:loop]  = value =~ /LOOP/i
        pose[:lock]  = value =~ /LOCK/i
        pose[:walk]  = value =~ /WALK/i
        pose[:speed] = value =~ /SPEED: (\d+)/i   ? $1.to_i : 0
        pose[:line]  = value =~ /LINE: ([1234])/i ? $1.to_i : nil
        pose[:frame] = value =~ /FRAMES: (\d+)/i  ? $1.to_i : subject.frames
        subject.start_pose(pose) if add.upcase == "CHANGE POSE"
        subject.add_pose(pose)   if add.upcase == "ADD POSE"
      end
    end
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
  alias :graphic_changed_ve_character_control? :graphic_changed?
  def graphic_changed?
    graphic_changed_ve_character_control? ||
    @pose_sufix != @character.pose_sufix
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_character_info
  #--------------------------------------------------------------------------
  alias :update_character_info_ve_character_control :update_character_info
  def update_character_info
    update_character_info_ve_character_control
    @pose_sufix = @character.pose_sufix
  end
  #--------------------------------------------------------------------------
  # * Alias method: set_bitmap_name
  #--------------------------------------------------------------------------
  alias :set_bitmap_name_ve_character_control :set_bitmap_name
  def set_bitmap_name
    sufix = ($imported[:ve_diagonal_move] ? diagonal_sufix : "") + @pose_sufix
    if $imported[:ve_visual_equip]
      return set_bitmap_name_ve_character_control
    elsif character_exist?(@character_name + sufix)
      return @character_name + sufix
    elsif character_exist?(@character_name + @pose_sufix)
      return @character_name + @pose_sufix
    else
      return set_bitmap_name_ve_character_control
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: set_bitmap_position
  #--------------------------------------------------------------------------
  alias :set_bitmap_position_ve_character_control :set_bitmap_position
  def set_bitmap_position
    set_bitmap_position_ve_character_control
    self.ox -= (@character_name[/\[x([+-]?\d+)\]/i] ? $1.to_i : 0)
    self.oy -= (@character_name[/\[y([+-]?\d+)\]/i] ? $1.to_i : 0)
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: draw_character
  #--------------------------------------------------------------------------
  alias :draw_character_ve_character_control :draw_character
  def draw_character(character_name, character_index, x, y, parts = nil)
    return unless character_name
    x += (character_name[/\[x([+-]?\d+)\]/i] ? $1.to_i : 0)
    y += (character_name[/\[y([+-]?\d+)\]/i] ? $1.to_i : 0)
    args = [character_name, character_index, x, y]
    args.push(parts) if $imported[:ve_visual_equip]
    draw_character_ve_character_control(*args)
  end
end