#==============================================================================
# ** Victor Engine - Leap Attack
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.12.30 > First relase
#  v 1.01 - 2013.01.07 > Added notetag <leap start: x>
#  v 1.02 - 2013.02.13 > Compatibility with Cooperation Skills
#------------------------------------------------------------------------------
#  This script is an add-on for the 'Victor Engine - Animated Battle' script.
# It allows to implement "Leap Attacks", this attacks allows the battler to
# stay outside of battle for some time, then return making a powerful attack.
# Similar to the "Jump" from the Final Fantasy series.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.33 or higher
#   Requires the script 'Victor Engine - Animated Battle' v 1.17 or higher
#   Requires the script 'Victor Engine - Actors Battlers' v 1.08 or higher
#   If used with 'Victor Engine - Active Time Battle' place this bellow it.
#   If used with 'Victor Engine - Automatic Battlers' place this bellow it.
#
# * Overwrite methods
#   class Game_Action
#     def targets_for_opponents
#     def targets_for_friends
#
#   class Game_Unit
#     def random_target
#     def smooth_target(index)
#
# * Alias methods
#   class Game_BattlerBase
#     def inputable?
#
#   class Game_Battler < Game_BattlerBase
#     def regenerate_all
#     def set_pose_setting(value)
#     def atb_freeze?
#     def atb_freeze_result
#     def update_atb
#
#   class Game_Actor < Game_Battler
#     def make_actions
#
#   class Game_Enemy < Game_Battler
#     def make_actions
#
#   class Sprite_Battler < Sprite_Base
#     def update_position
#
#   class Scene_Battle < Scene_Base
#     def use_item
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes.
# 
#  <leap turn: x>
#   Setup how many turns the battler will stay outside of battle. This tag
#   enables the leap attack, but remember to add the leap action pose tag also.
#     x : number of turns
# 
#  <leap start: x>
#   Setup a custom pose for the leap start animation.
#     x : pose sequence name
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors, States, Skills and Items note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors, States,
#   Skills and Items note boxes.
#
#  <leap time: x%>
#   Available only if using the script 'Victor Engine - Active Time Battle'
#   this allows to change the leap wait time by a certain rate. Values
#   lower than 100 make it slower, values above 100 make it faster.
#     x : rate value (100 = no change)
#
#------------------------------------------------------------------------------
# Additional instructions:
#
# To setup an action as a Leap Attack you need to add at last 2 note tags on it:
#  <leap turn: x>
#  <action pose: leap attack>
#
# The tag <action pose: leap attack> can be replaced with any custom action
# pose you want *AS LONG IT CONTAIN THE COMMAND "leap: oof;"* If you add an
# action without this command the battler will not return to the battle.
#
# The leap attack actions are available for the Default, Charset and Kaduki
# templates, if you're using any custom template you must add the leap action
# sequence manually.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Default Template Leap Action
  #--------------------------------------------------------------------------
  VE_DEFAULT_LEAP = "
  
    <action: leap start, reset>
    wait: targets, movement;
    pose: self, row advance, all frames, wait 4, loop;
    move: self, step forward, speed 6;
    wait: self, movement;
    move: self, x -32, y -400, speed 25;
    wait: self, movement;
    leap: self, on;
    wait: 1;
    move: self, retreat, teleport;
    wait: self, movement;
    </action>

    # Pose for physical attacks
    <action: leap attack, reset>
    direction: self, subjects;
    move: self, move to, x -32, y -400, teleport;
    wait: self, movement;
    leap: self, off;
    move: self, move to, x -32, y -2, speed 30;
    wait: self, movement;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    direction: self, subjects;
    </action> 
  
    "
  
  #--------------------------------------------------------------------------
  # * Charset Template Leap Action
  #--------------------------------------------------------------------------
  VE_CHARSET_LEAP = "
  
    <action: leap start, reset>
    wait: targets, movement;
    wait: self, animation;
    pose: self, row direction, all frames, return, wait 4, loop;
    move: self, step forward, speed 6;
    wait: self, movement;
    pose: self, row direction, frame 1;
    move: self, x -32, y -400, speed 25;
    wait: self, movement;
    leap: self, on;
    wait: 1;
    move: self, retreat, teleport;
    wait: self, movement;
    </action>

    # Pose for physical attacks
    <action: leap attack, reset>
    move: self, move to, x -32, y -400, teleport;
    wait: self, movement;
    direction: self, down;
    leap: self, off;
    move: self, move to, x -32, y -2, speed 30;
    icon: self, weapon, angle 45, x -6, y +16, above;
    pose: self, row 1, frame 1;
    wait: self, movement;
    icon: self, delete;
    pose: self, row 1, frame 2;
    anim: self, targets, weapon;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    direction: self, subjects;
    </action>
  
    "

  #--------------------------------------------------------------------------
  # * Kaduki Template Leap Action
  #--------------------------------------------------------------------------
  VE_KADUKI_LEAP = "
  
    <action: leap start, reset>
    wait: targets, movement;
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    move: self, step forward, speed 6;
    wait: self, movement;
    pose: self, row 2, frame 3, sufix _2;
    move: self, x -16, y -400, speed 25;
    wait: self, movement;
    leap: self, on;
    wait: 1;
    move: self, retreat, teleport;
    wait: self, movement;
    </action>

    # Pose for physical attacks
    <action: leap attack, reset>
    move: self, move to, x -32, y -400, teleport;
    wait: self, movement;
    direction: self, down;
    leap: self, off;
    move: self, move to, x -32, y -2, speed 30;
    icon: self, weapon, angle 45, x -4, y +16, above;
    pose: self, row 2, frame 2, sufix _2;
    wait: self, movement;
    icon: self, delete;
    pose: self, row 2, sufix _2, all frames, wait 4;
    move: self, y 64, speed 6;
    jump: self, move;
    pose: self, row 1, all frames, sufix _1, return, wait 12, loop;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets, 100%;
    wait: self, movement;
    wait: 20;
    direction: self, subjects;
    </action>
    
    "
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  if $imported[:ve_animated_battle]
    VE_DEFAULT_ACTION += VE_DEFAULT_LEAP
    VE_ACTION_SETTINGS[:charset] += VE_CHARSET_LEAP if VE_ACTION_SETTINGS[:charset]
    VE_ACTION_SETTINGS[:kaduki]  += VE_KADUKI_LEAP  if VE_ACTION_SETTINGS[:kaduki]
  end
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
$imported[:ve_leap_attack] = 1.02
Victor_Engine.required(:ve_leap_attack, :ve_basic_module, 1.33, :above)
Victor_Engine.required(:ve_leap_attack, :ve_animated_battle, 1.17, :above)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: leap?
  #--------------------------------------------------------------------------
  def leap?
    leap_turn
  end
  #--------------------------------------------------------------------------
  # * New method: leap_turn
  #--------------------------------------------------------------------------
  def leap_turn
    note =~ /<LEAP TURN: (\d+)>/i ? $1.to_i : nil
  end
  #--------------------------------------------------------------------------
  # * New method: leap_time
  #--------------------------------------------------------------------------
  def leap_time
    note =~ /<LEAP TIME: (\d+)%?>/i ? $1.to_f / 100.0 : 1
  end
  #--------------------------------------------------------------------------
  # * New method: leap_start
  #--------------------------------------------------------------------------
  def leap_start
    note =~ /<LEAP START: ([\w\s]+)>/i ? make_symbol($1) : :leap_start
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * New method: setup_leap_action
  #--------------------------------------------------------------------------
  def setup_leap_action(battler)
    battler.turn_count += 1 if !battler.actor?
    battler.make_actions
    @input_battlers.delete(battler)
    @active_members.push(battler)
    turn_start
  end
end

#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * Overwrite method: targets_for_opponents
  #--------------------------------------------------------------------------
  def targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.targetable_members
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: targets_for_friends
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.targetable_members
      end
    end
  end
end

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: inputable?
  #--------------------------------------------------------------------------
  alias :inputable_ve_leap_attack? :inputable?
  def inputable?
    inputable_ve_leap_attack? && !leap
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :leap_turn
  attr_accessor :leap_time
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_all
  #--------------------------------------------------------------------------
  alias :regenerate_all_ve_leap_attack :regenerate_all
  def regenerate_all
    return if leap
    regenerate_all_ve_leap_attack
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_all
  #--------------------------------------------------------------------------
  alias :on_battle_start_all_ve_leap_attack :on_battle_start
  def on_battle_start
    on_battle_start_all_ve_leap_attack
    leap_off
    poses.leap = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: atb_freeze?
  #--------------------------------------------------------------------------
  alias :atb_freeze_ve_leap_attack? :atb_freeze? if $imported[:ve_active_time_battle]
  def atb_freeze?
    atb_freeze_ve_leap_attack? || leap
  end
  #--------------------------------------------------------------------------
  # * Alias method: atb_freeze_result
  #--------------------------------------------------------------------------
  alias :atb_freeze_result_ve_leap_attack :atb_freeze_result if $imported[:ve_active_time_battle]
  def atb_freeze_result
    update_leap_turn
    BattleManager.setup_leap_action(self) if leap_ready?
    atb_freeze_result_ve_leap_attack
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_atb
  #--------------------------------------------------------------------------
  alias :update_atb_ve_leap_attack :update_atb if $imported[:ve_active_time_battle]
  def update_atb
    adjust = (leap && @leap_time) ? @leap_time  : 1
    update_atb_ve_leap_attack * adjust
  end
  #--------------------------------------------------------------------------
  # * Alias method: cast_action?
  #--------------------------------------------------------------------------
  alias :cast_action_ve_leap_attack? :cast_action? if $imported[:ve_active_time_battle]
  def cast_action?
    cast_action_ve_leap_attack? || leap
  end
  #--------------------------------------------------------------------------
  # * New method: leap_speed
  #--------------------------------------------------------------------------
  def leap_speed
    regexp = /<LEAP TIME: (\d+)%?>/i
    get_all_notes.scan(regexp).inject(1.0) {|r| r *= $1.to_f / 100 }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_leap_action
  #--------------------------------------------------------------------------
  def setup_leap_action
    clear_actions
    @actions = poses.leap_action.dup
  end
  #--------------------------------------------------------------------------
  # * New method: leap_off
  #--------------------------------------------------------------------------
  def leap_off
    poses.leap_action = nil
    @leap_turn        = nil
  end
  #--------------------------------------------------------------------------
  # * New method: update_leap_turn
  #--------------------------------------------------------------------------
  def update_leap_turn
    @leap_turn -= 1 if @leap_turn && @leap_turn > 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_leap_time
  #--------------------------------------------------------------------------
  def update_leap_time
    @leap_time -= 1 if @leap_time && @leap_time > 0
  end
  #--------------------------------------------------------------------------
  # * New method: leap_ready?
  #--------------------------------------------------------------------------
  def leap_ready?
    @leap_turn && @leap_turn == 0
  end
  #--------------------------------------------------------------------------
  # * New method: leap
  #--------------------------------------------------------------------------
  def leap
    poses.leap
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: make_actions
  #--------------------------------------------------------------------------
  alias :make_actions_ve_leap_attack :make_actions
  def make_actions
    update_leap_turn if !$imported[:ve_active_time_battle]
    (leap && leap_ready?) ? setup_leap_action : make_actions_ve_leap_attack
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: make_actions
  #--------------------------------------------------------------------------
  alias :make_actions_ve_leap_attack :make_actions
  def make_actions
    update_leap_turn if !$imported[:ve_active_time_battle]
    if leap && !leap_ready?
      clear_actions
    elsif leap && leap_ready?
      setup_leap_action 
    else
      make_actions_ve_leap_attack
    end
  end
end

#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  This class handles units. It's used as a superclass of the Game_Party and
# Game_Troop classes.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * Overwrite method: random_target
  #--------------------------------------------------------------------------
  def random_target
    tgr_rand = rand * tgr_sum
    members  = targetable_members
    members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    members[0]
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: smooth_target
  #--------------------------------------------------------------------------
  def smooth_target(index)
    member = members[index]
    (member && member.alive? && !member.leap) ? member : targetable_members[0]
  end
  #--------------------------------------------------------------------------
  # * New method: targetable_members
  #--------------------------------------------------------------------------
  def targetable_members
    alive_members.select {|member| !member.leap }
  end
end

#==============================================================================
# ** Game_BattlerPose
#------------------------------------------------------------------------------
#  This class deals with battlers poses.
#==============================================================================

class Game_BattlerPose
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :leap
  attr_accessor :leap_action
  #--------------------------------------------------------------------------
  # * New method: leap_pose
  #--------------------------------------------------------------------------
  def leap_pose(item)
    activate
    @battler.leap_turn = item.leap_turn
    @battler.leap_time = item.leap_time * @battler.leap_speed
    @current_item      = item
    @leap_action       = @battler.actions.collect {|action| action.clone }
    clear_loop
    call_pose(item.leap_start)
    call_pose(:inactive)
  end
end

#==============================================================================
# ** Game_PoseValue
#------------------------------------------------------------------------------
#  This class deals with battlers pose values.
#==============================================================================

class Game_PoseValue
  #--------------------------------------------------------------------------
  # * Alias method: setup_pose
  #--------------------------------------------------------------------------
  alias :setup_pose_ve_leap_attack :setup_pose
  def setup_pose(value)
    setup_pose_ve_leap_attack(value)
    set_leap(value) if @name == :leap
  end
  #--------------------------------------------------------------------------
  # * New method: set_leap
  #--------------------------------------------------------------------------
  def set_leap(value)
    @data[:leap] = value =~ /ON/i ? true : false
  end
end

#==============================================================================
# ** Game_PoseAction
#------------------------------------------------------------------------------
#  This class deals with battlers pose actions.
#==============================================================================

class Game_PoseAction
  #--------------------------------------------------------------------------
  # * New method: update_pose_leap
  #--------------------------------------------------------------------------
  def update_pose_leap
    get_subjects.each do |subject|
      subject.poses.leap = @pose[:leap]
      subject.leap_off if !@pose[:leap]
    end
  end
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: update_position
  #--------------------------------------------------------------------------
  alias :update_position_ve_leap_attack :update_position
  def update_position
    update_position_ve_leap_attack
    update_leap_opacity
  end
  #--------------------------------------------------------------------------
  # * New method: update_leap_opacity
  #--------------------------------------------------------------------------
  def update_leap_opacity
    if @battler.poses.leap && !@leap_opacity
      @leap_opacity = self.opacity
      self.opacity  = 0
    elsif @leap_opacity && !@battler.poses.leap
      self.opacity  = @leap_opacity
      @leap_opacity = nil
    end
  end
end

#==============================================================================
# ** Window_BattleActor
#------------------------------------------------------------------------------
#  This window display a list of actors on the battle screen.
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # * New method: enable?
  #--------------------------------------------------------------------------
  def enable?(index)
    $game_party.members[index] && !$game_party.members[index].leap
  end
  #--------------------------------------------------------------------------
  # * New method: current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(index)
  end
end

#==============================================================================
# ** Window_BattleEnemy
#------------------------------------------------------------------------------
#  This window display a list of enemies on the battle screen.
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # * New method: enable?
  #--------------------------------------------------------------------------
  def enable?(index)
    $game_troop.members[index] && !$game_troop.members[index].leap
  end
  #--------------------------------------------------------------------------
  # * New method: current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(index)
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: use_item
  #--------------------------------------------------------------------------
  alias :use_item_ve_leap_attack :use_item
  def use_item
    item = @subject.current_action.item
    return @subject.deactivate if item.leap? && no_leap_target?
    (item.leap? && !@subject.leap) ? leap_start : use_item_ve_leap_attack
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_leap
  #--------------------------------------------------------------------------
  def no_leap_target?
    @subject.poses.action_targets.all? {|target| target.dead? || target.leap } ||
    @subject.poses.action_targets.empty? 
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_leap
  #--------------------------------------------------------------------------
  def leap_start
    item = @subject.current_action.item
    @subject.poses.leap_pose(item)
    @subject.use_item(item)
    refresh_status
  end
end