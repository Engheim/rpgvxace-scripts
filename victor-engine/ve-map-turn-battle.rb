#==============================================================================
# ** Victor Engine - Map Turn Battle
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.20 > First relase
#  v 1.01 - 2012.07.21 > Compatibility with Fog and Overlay and Light Effects
#                      > Fixed Map Pictures not showing during battle
#  v 1.02 - 2012.05.29 > Compatibility with Pixel Movement
#  v 1.03 - 2012.07.24 > Compatibility with Basic Module 1.25
#  v 1.04 - 2012.08.02 > Compatibility with Basic Module 1.27
#  v 1.05 - 2012.08.03 > Compatibility with Anti Lag
#  v 1.06 - 2012.08.03 > Fixed issue with Anti Lag
#                      > Fixed issue with Pixel Movement
#  v 1.07 - 2012.11.03 > Fixed issue with random battle positions
#  v 1.08 - 2012.12.13 > Fixed issue with battle pictures
#                      > Added instructions for troop id for map battles
#  v 1.09 - 2013.02.13 > Compatibility with Animated Battle 1.21
#------------------------------------------------------------------------------
#  This script is an add-on for the 'Victor Engine - Animated Battle', it
# allows to make battles to occur the current map, instead of using a
# transition to another scene, like int the game Chrono Trigger. It doesn't
# make any change on the turn mechanic of the battle and anything else.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   Requires the script 'Victor Engine - Animated Battle' v 1.05 or higher
#   Requires the script 'Victor Engine - Actors Battlers' v 1.06 or higher
#   If used with 'Victor Engine - Light Effects' place this bellow it.
#   If used with 'Victor Engine - Pixel Movement' place this bellow it.
#
# * Alias methods 
#   class << BattleManager
#     def process_escape_pose
#     def battle_end(result)
#
#   class Game_Party < Game_Unit
#     def initialize
#
#   class Game_Player < Game_Character
#     def update_scroll(last_real_x, last_real_y)
#     def add_move_update(dir)
#
#   class Game_Follower < Game_Character
#     def initialize(member_index, preceding_character)
#     def chase_preceding_character
#     def add_move_update(dir)
#
#   class Scene_Map < Scene_Base
#     def pre_battle_scene
#     def perform_battle_transition
#     def perform_transition
#
#   class Scene_Battle < Scene_Base
#     def create_spriteset
#     def perform_transition
#     def pre_terminate
#
#   class Game_Interpreter
#     def comment_call
#
#
#   class Game_Follower < Game_Character
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic' and the script
# 
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <call map battle>
#  start: [x, y]; end: [x, y]; escape: [x, y]; defeat: [x, y];
#  actors: [x, y], [x, y], [x, y];
#  enemies: [event, enemy, switch],  [event, enemy];
#  can escape; can lose; skip return; troop: x;
#  </call map battle>
#   This call is used to call battles on maps, using the normal event battle
#   call will end on a normal battle with transition.
#     start: [x, y];
#       position of the screen at the battle start
#     end: [x, y];
#        position of the party at battle end, in case of victory
#     escape: [x, y];
#        position of the party at battle end, in case of escape
#     defeat: [x, y];
#        position of the party at battle end, in case of defeat (only if the
#        battle is set up to continue after defeat)
#     actors: [x, y], [x, y], [x, y];
#        position of each actor during the battle, you must add a value [x, y]
#        for every actor in the party, so always add an ammount equal the
#        max number of party members to avoid errors.
#     enemies: [event, enemy, switch], [event, enemy];
#        enemies info
#        event is the Event ID of the event that represents the enemye
#        enemy is the Enemy ID on the database.
#        switch is an opitional value that represents the switch that will
#         be turned on when the enemy dies, it can be a numeric value, or the
#         the letters A, B, C or D. If numeric, it turn on a switch, if it's a
#         letter, it turn on the switch local with that letter. If omited
#         it don't turn on any switch using an erase event instead.
#     can escape;
#        optional value that must be added to allow escaping from battles
#     can lose;
#        optional value that must be added to avoid game over after a defeat
#     skip return;
#        optional value that makes the actors not return to their positions
#        after the battle end, can be used for after battle cutscenes, remember
#        that you must make a call manually to gather the party before allowing
#        the player to control them.
#     troop: x;
#         setup the troop id, this can be used for in battle events, the
#         battle called with this command will use the event list of the
#         troop id X. Other troop settings are ignored.
#
#------------------------------------------------------------------------------
# Additional instructions:
#   All the positions are *MAP COORDINATES*, so to know the positions just
#   check the tile position on the editor.
#
#   If using sprites, you need to have 5 different graphics for them:
#   The default and one for each direction.
#   You must add an extra sufix on them for each direction they're facing:
#   [up] [left] [right] [down]
#
#   So if you have a battler named "Actor" and use VE_SPRITE_SUFIX = "[anim]"
#   you will need the files to be named like this:
#   Actor[anim][up]
#   Actor[anim][left]
#   Actor[anim][right]
#   Actor[anim][down]
#   
#   Charsets battlers don't need any extra setup.
#
#   When using the script 'Victor Engine - Animated Battle' the lights do NOT
#   follow the actors and enemies during battles, even if there was a light on
#   the event/actor on the map.
#
#------------------------------------------------------------------------------
# Examples:
#
#   <call map battle>
#   start: [12, 15]; end: [12, 15]; escape: [12, 21];
#   actors: [7, 14], [14, 17], [17, 14], [10, 17];
#   enemies: [1, 1, A],  [2, 1, A],  [3, 1, A];
#   can escape;
#   </call map battle>
# 
#    This call will make the screen center at the coodinate x:12 y:15 of the
#    map, the battle end position will be the same, for escape the position
#    is the coordinate x:12, y:21
#
#    The actor will be placed on the following positions: first actor on
#    x:7, y:14; second actor on x:14, y:17, third actor on x:17, y:14;
#    and the last actor on x:10, y:17
#
#    The events ID 1, 2 and 3 will become enemies. They will become the enemy
#    ID 1, and will turn on the switch local A for each event.
#
#    The battle can be escaped.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Change the behavior of default template to work with 4 directions
  #   sprites
  #--------------------------------------------------------------------------
  VE_DEFAULT_ACTION = "

    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row idle, all frames, wait 12, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row dead, all frames, wait 16, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row danger, all frames, wait 12, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    pose: self, row guard, all frames, wait 24, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row intro, all frames, wait 16, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row victory, all frames, wait 16, sufix [direction];
    wait: self, pose;
    </action>
    
    # Pose displayed when escaping (for ATB)
    <action: escaping, loop>
    pose: self, row retreat, all frames, wait 4, loop, sufix [direction];
    wait: self, pose;
    </action>
  
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row ready, frame 1, sufix [direction];
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row itemcast, frame 1, sufix [direction];
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row skillcast, frame 1, sufix [direction];
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row magiccast, frame 1, sufix [direction];
    wait: self, pose;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    </action>
    
    # Pose displayed when recive damage
    <action: hurt, reset>
    action: self, hurt pose;
    wait: 16;
    </action>
    
    # Pose displayed when hurt
    <action: hurt pose, reset>
    pose: self, row hurt, all frames, wait 4, sufix [direction];
    </action>

    # Pose displayed when evading attacks
    <action: evade, reset>
    pose: self, row evade, all frames, wait 4, sufix [direction];
    wait: 16;
    </action>
  
    # Pose displayed when a attack miss
    <action: miss, reset>
    </action>
  
    # Pose displayed when reviving
    <action: revive, reset>
    </action>
  
    # Pose displayed when dying
    <action: die, reset>
    </action>
  
    # Make the target inactive (important, avoid change)
    <action: inactive>
    countered;
    wait: self, countered;
    inactive;
    </action>
  
    # Finish offensive action (important, avoid change)
    <action: finish>
    finish;
    </action>
    
    # Reset to idle after action (important, avoid change)
    <action: clear, reset>
    </action>

    # Pose displayed during move reset (important, avoid change)
    <action: reset, reset>
    pose: self, row idle, all frames, wait 8, loop, sufix [direction];
    </action>
    
    # Pose for counter attack preparation (important, avoid change)
    <action: prepare counter, reset>
    wait: self, action;
    wait: targets, counter;
    </action>

    # Pose for counter attack activation (important, avoid change)
    <action: counter on, reset>
    counter: self, on;
    </action>
    
    # Pose for counter attack deactivation (important, avoid change)
    <action: counter off, reset>
    counter: targets, off;
    </action>
    
    # Pose for magic reflection (important, avoid change)
    <action: reflection, reset>
    wait: self, animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: self, animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset>
    pose: self, row advance, all frames, wait 4, loop, sufix [direction];
    move: self, substitution, move over;
    wait: self, movement;
    </action>
    
    # Pose for substitution deactivation (important, avoid change)
    <action: substitution off, reset>
    pose: self, row advance, all frames, wait 4, loop, sufix [direction];
    move: self, retreat, move over;
    wait: self, movement;
    </action>
    
    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: self, action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    move: self, move to;
    direction: self, subjects;
    jump: self, move, height 7;
    pose: self, row advance, all frames, wait 4, loop, sufix [direction];
    wait: self, movement;
    </action>
    
    # Step forward movement
    <action: step forward, reset>
    wait: targets, movement;
    move: self, step forward, speed 6;
    pose: self, row advance, all frames, wait 4, loop, sufix [direction];
    wait: self, movement;
    </action>
    
    # Step backward movement
    <action: step backward, reset>
    move: self, step backward, speed 6;
    pose: self, row retreat, all frames, wait 4, invert, loop, sufix [direction];
    wait: self, movement;
    </action>

    # Return to original spot
    <action: retreat, reset>
    move: self, retreat;
    pose: self, row retreat, all frames, wait 4, loop, sufix [direction];
    jump: self, move, height 7;
    wait: self, movement;
    direction: self, default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row retreat, all frames, wait 4, invert, loop, sufix [direction];
    wait: self, movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row guard, all frames, wait 8, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, weapon 1;
    wait: 8;
    effect: self, targets 75%, weapon 1;
    wait: targets, animation;
    pose: self, row skill, all frames, wait 4, sufix [direction];
    wait: 8;
    anim: targets, weapon 2;
    wait: 8;
    effect: self, targets 75%, weapon 2;
    wait: 20;
    </action>
        
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    pose: self, row item, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>

    # Pose for item use 
    <action: item, reset>
    wait: targets, movement;
    pose: self, row item, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>

    # Pose for the skill 'Dual Attack'
    <action: double attack skill, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets 75%;
    wait: targets, animation;
    pose: self, row skill, all frames, wait 4, sufix [direction];
    wait: 8;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets 75%;
    wait: 20;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Mana Drain'
    <action: drain, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: targets, user drain;
    wait: targets, action;
    </action>

    # Pose for the targets of the skills 'Life Drain' and 'Manda Drain'
    <action: user drain, reset>
    throw: self, user, icon 187, return, revert, init y -12, end y -12;
    wait: self, throw;
    drain: active;
    </action>    
    
    # Pose for the sample skill 'Throw Weapon'
    <action: throw weapon, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    action: targets, target throw;
    wait: targets, action;
    wait: 20;
    </action>
    
    # Pose for the targets of the sample skill 'Throw Weapon'
    <action: target throw, reset>
    throw: self, user, weapon, arc 12, spin +45, init y -12, end y -12;
    wait: self, throw;
    throw: self, user, weapon, arc 12, spin +45, return, revert, init y -12, end y -12;
    anim: self, weapon;
    wait: 8;
    effect: active, targets, 100%, clear;
    wait: self, throw;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 5 times>
    direction: self, subjects;
    clear: targets, damage;
    move: targets, retreat, teleport;
    pose: self, row attack, frame 1, all frames, wait 2, sufix [direction];
    move: self, x -48, speed 50;
    anim: targets, effect;
    effect: self, targets 30%;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 4, sufix [direction];
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Tempest', white, high priority;
    tone: clear, high priority, duration 20;
    wait: 15;
    anim: targets, effect;
    flash: screen, duration 10; 
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for the sample skill 'Meteor'
    <action: meteor, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 4, sufix [direction];
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Meteor';
    tone: clear, high priority, duration 20;
    anim: targets, effect;
    wait: 20;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    action: targets, arrow;
    wait: targets, action;
    wait: 20;
    </action>
    
    # Pose for the targets of 'Bow' attack
    <action: arrow, reset>
    throw: self, user, image 'Arrow', arc 10, angle 45, init x -6, init y -12;
    wait: self, throw;
    anim: self, weapon;
    wait: 8;
    effect: active, targets, 100%;
    </action>

    # Pose for the skill 'Multi Attack'
    <action: multi attack, opponents_unit.targetable_members.size times>
    wait: next;
    move: self, move to front;
    pose: self, row advance, all frames, wait 4, loop, sufix [direction];
    wait: self, movement;
    direction: self, subjects;
    pose: self, row attack, all frames, wait 4, sufix [direction];
    wait: 4;
    anim: last, effect, clear;
    wait: 8;
    effect: self, last, 100%;
    wait: 20;
    </action>
    
    # Pose for the skill 'Aura Spell'
    <action: aura spell, reset>
    wait: targets, movement;
    action: self, step forward;
    direction: self, subjects;
    pose: self, row magic, all frames, wait 4, sufix [direction];
    action: aura effect;
    wait: action
    action: self, step backward;
    </action>

    <action: aura effect, friends_unit.targetable_members.size times>
    wait: next;
    anim: last, effect;
    wait: 4;
    effect: self, last, 100%;
    wait: last, animation;
    </action>
    
    "
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
$imported[:ve_map_battle] = 1.09
Victor_Engine.required(:ve_map_battle, :ve_basic_module, 1.27, :above)
Victor_Engine.required(:ve_map_battle, :ve_animated_battle, 1.05, :above)
Victor_Engine.required(:ve_map_battle, :ve_actor_battlers, 1.06, :above)

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Alias method: process_escape_pose
  #--------------------------------------------------------------------------
  alias :process_escape_pose_ve_map_battle :process_escape_pose
  def process_escape_pose
    if $game_party.map_battle
      SceneManager.scene.wait(5)
      SceneManager.scene.close_window
      Graphics.freeze
    else
      process_escape_pose_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_end
  #--------------------------------------------------------------------------
  alias :battle_end_ve_map_battle :battle_end
  def battle_end(result)
    battle_end_ve_map_battle(result)
    map_battle = $game_party.map_battle
    if map_battle
      $game_system.intro_fade = $game_temp.old_intro_fade
      $game_battle_fogs       = $game_temp.old_battle_fog
      map_battle[:result] = :end    if result == 0 && map_battle
      map_battle[:result] = :escape if result == 1 && map_battle
      map_battle[:result] = :defeat if result == 2 && map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_map_battle
  #--------------------------------------------------------------------------
  def setup_map_battle
    init_members
    $game_troop.setup_map_battle($game_party.map_battle)
    @can_escape = $game_party.map_battle[:can_run]
    @can_lose   = $game_party.map_battle[:can_lose]
    $game_temp.old_intro_fade = $game_system.intro_fade
    $game_temp.old_battle_fog = $game_battle_fogs
    $game_battle_fogs         = true
    $game_system.intro_fade   = false
    make_escape_ratio
  end
end

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
  attr_accessor :old_intro_fade
  attr_accessor :old_battle_fog
  attr_accessor :old_custom_positions
  attr_accessor :old_custom_formation
  attr_accessor :old_position_adjust
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * New method: finished_movement?
  #--------------------------------------------------------------------------
  def finished_movement?
    actors.all? {|actor| actor.finished_movement? }
  end  
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :map_battle
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_map_battle :initialize
  def initialize
    initialize_ve_map_battle
    @map_battle = nil
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * New method: setup_map_battle
  #--------------------------------------------------------------------------
  def setup_map_battle(value)
    clear
    @troop_id = value[:troop_id]
    @enemies  = []
    value[:enemies].each do |info|
      next if !$data_enemies[info[:id]] || erased_event(info)
      enemy = Game_Enemy.new(@enemies.size, info[:id])
      event = $game_map.events[info[:event]]
      enemy.screen_x = event.screen_x
      enemy.screen_y = event.screen_y
      enemy.switch   = info[:switch]
      enemy.event_id = info[:event]
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # * New method: erased_event
  #--------------------------------------------------------------------------
  def erased_event(info)
    if info[:switch].string?
      $game_self_switches[[$game_map.map_id, info[:event], info[:switch]]]
    elsif info[:switch].numeric?
      $game_switches[info[:switch]]
    else
      $game_map.events[info[:event]].erased?
    end
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :switch
  attr_accessor :event_id
  #--------------------------------------------------------------------------
  # * New method: setup_dead_event
  #--------------------------------------------------------------------------
  def setup_dead_event
    return if !dead?
    if switch.string?
      $game_self_switches[[$game_map.map_id, event_id, switch]] = true
    elsif switch.numeric?
      $game_switches[switch] = true
    else
      $game_map.events[event_id].erase
    end
  end
end

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
  attr_accessor :battle_positions
  #--------------------------------------------------------------------------
  # * New method: finished_movement?
  #--------------------------------------------------------------------------
  def finished_movement?
    @battle_positions[:x].ceil == @x.ceil &&
    @battle_positions[:y].ceil == @y.ceil && !moving?
  end
  #--------------------------------------------------------------------------
  # * New method: move_to_position
  #--------------------------------------------------------------------------
  def move_to_position
    return if moving? || finished_movement?
    return if $imported[:ve_pixel_movement] && @move_list.size > 0
    position = @battle_positions
    move_toward_position(position[:x], position[:y])
  end
  #--------------------------------------------------------------------------
  # * New method: turn_to_position
  #--------------------------------------------------------------------------
  def turn_to_position
    return if moving? || !finished_movement?
    position = $game_party.map_battle[:start]
    turn_toward_position(position[:x], position[:y])
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
  # * Alias method: update_scroll
  #--------------------------------------------------------------------------
  alias :update_scroll_ve_map_battle :update_scroll
  def update_scroll(last_real_x, last_real_y)
    return if @battle_positions
    update_scroll_ve_map_battle(last_real_x, last_real_y)
  end
  #--------------------------------------------------------------------------
  # * Alias method: add_move_update
  #--------------------------------------------------------------------------
  alias :add_move_update_ve_map_battle :add_move_update if $imported[:ve_followers_options]
  def add_move_update(dir)
    return if @battle_positions
    add_move_update_ve_map_battle(dir)
  end
  #--------------------------------------------------------------------------
  # *
  #--------------------------------------------------------------------------
  alias :step_times_ve_map_battle :step_times if $imported[:ve_pixel_movement]
  def step_times
    $game_party.map_battle ? super : step_times_ve_map_battle
  end
  #--------------------------------------------------------------------------
  # * New method: update_battle_scroll
  #--------------------------------------------------------------------------
  def update_battle_scroll(type)
    position = get_screen_postion($game_party.map_battle[type])
    ax1 = $game_map.display_x
    ay1 = $game_map.display_y
    ax2 = $game_map.round_x(position[:x])
    ay2 = $game_map.round_y(position[:y])
    $game_map.scroll_down (1.0 / 16) if ay2 > ay1
    $game_map.scroll_left (1.0 / 16) if ax2 < ax1
    $game_map.scroll_right(1.0 / 16) if ax2 > ax1
    $game_map.scroll_up   (1.0 / 16) if ay2 < ay1
  end
  #--------------------------------------------------------------------------
  # * New method: get_screen_postion
  #--------------------------------------------------------------------------
  def get_screen_postion(position)
    max_x = ($game_map.width  - $game_map.screen_tile_x)
    max_y = ($game_map.height - $game_map.screen_tile_y)
    pos_x = [0, [position[:x] - center_x, max_x].min].max
    pos_y = [0, [position[:y] - center_y, max_y].min].max
    {x: pos_x, y: pos_y}
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
  # * Alias method: chase_preceding_character
  #--------------------------------------------------------------------------
  alias :chase_preceding_character_ve_map_battle :chase_preceding_character
  def chase_preceding_character
    return if @battle_positions
    chase_preceding_character_ve_map_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: add_move_update
  #--------------------------------------------------------------------------
  alias :add_move_update_ve_map_battle :add_move_update if $imported[:ve_followers_options]
  def add_move_update(dir)
    return if @battle_positions
    add_move_update_ve_map_battle(dir)
  end
  #--------------------------------------------------------------------------
  # * Alias method: step_times
  #--------------------------------------------------------------------------
  alias :step_times_ve_map_battle :step_times if $imported[:ve_pixel_movement]
  def step_times
    $game_party.map_battle ? super : step_times_ve_map_battle
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
  # * New method: is_in_battle?
  #--------------------------------------------------------------------------
  def is_in_battle?
    list = $game_party.map_battle[:enemies].collect {|event| event[:event] }
    list.include?(@id)
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
  # * Alias method: screen
  #--------------------------------------------------------------------------
  alias :screen_ve_map_battle :screen
  def screen
    $game_party.map_battle ? $game_map.screen : screen_ve_map_battle
  end  
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_map_battle :comment_call
  def comment_call
    call_map_battle_comments
    comment_call_ve_map_battle
  end
  #--------------------------------------------------------------------------
  # * New method: call_map_battle_comments
  #--------------------------------------------------------------------------
  def call_map_battle_comments
    regexp = get_all_values("CALL MAP BATTLE")
    if note =~ regexp
      info  = $1.dup
      value = {}
      value[:can_run]  = info =~ /CAN ESCAPE/i   ? true : false
      value[:can_lose] = info =~ /CAN LOSE/i     ? true : false
      value[:skip]     = info =~ /SKIP RETURN/i  ? true : false
      value[:troop_id] = info =~ /TROOP: (\d+)/i ? $1.to_i : 1
      value[:start]    = get_position('START' , info)
      value[:end]      = get_position('END'   , info)
      value[:escape]   = get_position('ESCAPE', info)
      value[:defeat]   = get_position('DEFEAT', info)
      value[:enemies]  = setup_enemies(info)
      return if no_available_enemies(value)
      setup_actors(info)
      $game_party.map_battle = value
      SceneManager.call(Scene_Battle)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_position
  #--------------------------------------------------------------------------
  def get_position(value, info)
    regexp = /#{value}: *\[(\d+), *(\d+)\]/i
    info   =~ regexp ? {x: $1.to_i, y: $2.to_i} : {x: 0, y: 0}
  end
  #--------------------------------------------------------------------------
  # * New method: setup_actors
  #--------------------------------------------------------------------------
  def setup_actors(info)
    list = get_actor_info(info)  
    $game_map.actors.each_with_index do |actor, index|
      actor.battle_positions = {x: list[index][:x], y: list[index][:y]}
      actor.clear_move if actor.follower? && $imported[:ve_followers_options]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_actor_info
  #--------------------------------------------------------------------------
  def get_actor_info(info)
    value = info =~ /ACTORS: ((?: *\[\d+, *\d+\],?)*)/i ? $1 : ""
    value.scan(/\[(\d+) *, *(\d+)\]/i).collect {|x, y| {x: x.to_i, y: y.to_i} }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_enemies
  #--------------------------------------------------------------------------
  def setup_enemies(info)
    regexp = /ENEMIES: ((?: *\[\d+ *, *\d+(?: *, *\w+)?\],*)*)/i 
    value  = info =~ regexp ? $1 : ""
    value.scan(/\[(\d+) *, *(\d+)(?: *, *(\w+))?\]/i).collect do |x, y, z| 
      result = ["A","B","C","D"].include?(z.upcase) ? z.upcase : z.to_i if z
      {event: x.to_i, id: y.to_i, switch: result} 
    end
  end
  #--------------------------------------------------------------------------
  # * New method: no_available_enemies
  #--------------------------------------------------------------------------
  def no_available_enemies(info)
    info[:enemies].all? {|enemy| erased_event(enemy) }
  end
  #--------------------------------------------------------------------------
  # * New method: erased_event
  #--------------------------------------------------------------------------
  def erased_event(info)
    if info[:switch].string?
      $game_self_switches[[$game_map.map_id, info[:event], info[:switch]]]
    elsif info[:switch].numeric?
      $game_switches[info[:switch]]
    else
      $game_map.events[info[:event]].erased?
    end
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: pre_battle_scene
  #--------------------------------------------------------------------------
  alias :pre_battle_scene_ve_map_battle :pre_battle_scene
  def pre_battle_scene
    if $game_party.map_battle
      prepare_map_battle
      Graphics.freeze
      @spriteset.dispose_characters
      BattleManager.save_bgm_and_bgs
      BattleManager.play_battle_bgm
    else
      pre_battle_scene_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: perform_battle_transition
  #--------------------------------------------------------------------------
  alias :perform_battle_transition_ve_map_battle :perform_battle_transition
  def perform_battle_transition
    perform_battle_transition_ve_map_battle if !$game_party.map_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: perform_transition
  #--------------------------------------------------------------------------
  alias :perform_transition_ve_map_battle :perform_transition
  def perform_transition
    if $game_party.map_battle
      Graphics.transition(0)
      end_map_battle
    else
      perform_transition_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * New method: prepare_map_battle
  #--------------------------------------------------------------------------
  def prepare_map_battle
    setup_battle_position
    Graphics.update
  end
  #--------------------------------------------------------------------------
  # * New method: setup_battle_position
  #--------------------------------------------------------------------------
  def setup_battle_position
    update_screen_position(:start)
    upate_battle_position
    setup_actors_position
    BattleManager.setup_map_battle
  end
  #--------------------------------------------------------------------------
  # * New method: update_screen_position
  #--------------------------------------------------------------------------
  def update_screen_position(type)
    while !$game_map.finished_movement? || 
           display_position != start_position(type)
      upate_battle_position
      update_actor_position
      $game_player.update_battle_scroll(type)
    end
    $game_map.actors.each {|actor| actor.straighten }
    $game_map.actors.each {|actor| actor.turn_to_position }
  end
  #--------------------------------------------------------------------------
  # * New method: display_position
  #--------------------------------------------------------------------------
  def display_position
    {x: $game_map.display_x, y:  $game_map.display_y}
  end
  #--------------------------------------------------------------------------
  # * New method: start_position
  #--------------------------------------------------------------------------
  def start_position(type)
    position = $game_player.get_screen_postion($game_party.map_battle[type])
    {x: position[:x], y: position[:y]}
  end
  #--------------------------------------------------------------------------
  # * New method: update_actor_position
  #--------------------------------------------------------------------------
  def update_actor_position
    $game_map.actors.each {|actor| actor.move_to_position }
    $game_map.actors.each {|actor| actor.turn_to_position }
  end
  #--------------------------------------------------------------------------
  # * New method: upate_battle_position
  #--------------------------------------------------------------------------
  def upate_battle_position
    update_basic
    $game_map.update(false)
    $game_player.update
    $game_timer.update
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # * New method: setup_actors_position
  #--------------------------------------------------------------------------
  def setup_actors_position
    $game_temp.old_custom_positions = $game_custom_positions.dup
    $game_temp.old_custom_formation = $game_custom_formation
    $game_custom_formation = :custom
    $game_map.actors.each do |character|
      index = character.actor.index + 1
      $game_custom_positions[index][:x] = character.screen_x
      $game_custom_positions[index][:y] = character.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # * New method: end_map_battle
  #--------------------------------------------------------------------------
  def end_map_battle
    unless $game_party.map_battle[:skip]
      setup_return_position($game_party.map_battle[:result])
      update_screen_position($game_party.map_battle[:result])
      upate_battle_position
    end
    clear_battle_values
  end
  #--------------------------------------------------------------------------
  # * New method: setup_return_position
  #--------------------------------------------------------------------------
  def setup_return_position(result)
    position = $game_party.map_battle[result]
    $game_map.actors.each do |actor|
      actor.battle_positions = {x: position[:x], y: position[:y]}
    end
  end
  #--------------------------------------------------------------------------
  # * New method: clear_battle_values
  #--------------------------------------------------------------------------
  def clear_battle_values
    $game_party.map_battle = nil
    $game_map.actors.each {|actor| actor.battle_positions = nil }
    $game_custom_positions = $game_temp.old_custom_positions.dup
    $game_custom_formation = $game_temp.old_custom_formation
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: create_spriteset
  #--------------------------------------------------------------------------
  alias :create_spriteset_ve_map_battle :create_spriteset
  def create_spriteset
    if $game_party.map_battle
      @spriteset = Spriteset_MapBattle.new
      setup_spriteset
    else
      create_spriteset_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: perform_transition
  #--------------------------------------------------------------------------
  alias :perform_transition_ve_map_battle :perform_transition
  def perform_transition
    if $game_party.map_battle
      Graphics.transition(0)
    else
      perform_transition_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: pre_terminate
  #--------------------------------------------------------------------------
  alias :pre_terminate_ve_map_battle :pre_terminate
  def pre_terminate
    if $game_party.map_battle && SceneManager.scene_is?(Scene_Map)
      clear_enemies
      super
    else
      pre_terminate_ve_map_battle
    end
  end
  #--------------------------------------------------------------------------
  # * New method: clear_enemies
  #--------------------------------------------------------------------------
  def clear_enemies
    $game_troop.members.each {|enemy| enemy.setup_dead_event }
  end
end

#==============================================================================
# ** Spriteset_MapBattle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites and Map sprites. 
# It's used within the Scene_Battle class.
#==============================================================================

class Spriteset_MapBattle < Spriteset_Battle
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize
    super
    create_characters
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_weather
    update
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_shadow
    dispose_weather
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
    update_tileset    if @tileset
    update_tilemap    if @tilemap
    update_parallax   if @parallax
    update_characters if @character_sprites
    update_shadow     if @shadow_sprite
    update_weather    if @weather
  end
  #--------------------------------------------------------------------------
  # * create_battleback1
  #--------------------------------------------------------------------------
  def create_battleback1
  end
  #--------------------------------------------------------------------------
  # * create_battleback2
  #--------------------------------------------------------------------------
  def create_battleback2
  end
  #--------------------------------------------------------------------------
  # * dispose_battleback1
  #--------------------------------------------------------------------------
  def dispose_battleback1
  end
  #--------------------------------------------------------------------------
  # * dispose_battleback2
  #--------------------------------------------------------------------------
  def dispose_battleback2
  end
  #--------------------------------------------------------------------------
  # * update_battleback1
  #--------------------------------------------------------------------------
  def update_battleback1
  end
  #--------------------------------------------------------------------------
  # * update_battleback2
  #--------------------------------------------------------------------------
  def update_battleback2
  end  
  #--------------------------------------------------------------------------
  # * create_tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.map_data = $game_map.data
    load_tileset
  end
  #--------------------------------------------------------------------------
  # * load_tileset
  #--------------------------------------------------------------------------
  def load_tileset
    @tileset = $game_map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      @tilemap.bitmaps[i] = Cache.tileset(name)
    end
    @tilemap.flags = @tileset.flags
  end
  #--------------------------------------------------------------------------
  # * create_parallax
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #--------------------------------------------------------------------------
  # * create_characters
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    $game_map.events.values.each do |event|
      next if event.is_in_battle?
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    $game_map.vehicles.each do |vehicle|
      @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
    end
    @map_id = $game_map.map_id
    refresh_characters_sprites if $imported[:ve_anti_lag]
  end
  #--------------------------------------------------------------------------
  # * create_shadow
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # * create_weather
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * dispose_tilemap
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # * dispose_parallax
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.bitmap.dispose if @parallax.bitmap
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # * dispose_characters
  #--------------------------------------------------------------------------
  def dispose_characters
    @character_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * dispose_shadow
  #--------------------------------------------------------------------------
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * dispose_weather
  #--------------------------------------------------------------------------
  def dispose_weather
    @weather.dispose
  end
  #--------------------------------------------------------------------------
  # * refresh_characters
  #--------------------------------------------------------------------------
  def refresh_characters
    dispose_characters
    create_characters
  end
  #--------------------------------------------------------------------------
  # * refresh_characters_sprites
  #--------------------------------------------------------------------------
  def refresh_characters_sprites
    @screen_sprites = []
    @character_sprites.each do |sprite|
      sprite.update
      @screen_sprites.push(sprite) if sprite.character.on_screen?
    end
  end
  #--------------------------------------------------------------------------
  # * refresh_sprites
  #--------------------------------------------------------------------------
  def refresh_sprites
    refresh_characters_sprites
    $game_map.refresh_event_list
    $game_map.refresh_screen_position
  end
  #--------------------------------------------------------------------------
  # * update_tileset
  #--------------------------------------------------------------------------
  def update_tileset
    if @tileset != $game_map.tileset
      load_tileset
      refresh_characters
    end
  end
  #--------------------------------------------------------------------------
  # * update_tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.map_data = $game_map.data
    @tilemap.ox = $game_map.display_x * 32
    @tilemap.oy = $game_map.display_y * 32
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # * update_parallax
  #--------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      @parallax.bitmap.dispose if @parallax.bitmap
      @parallax.bitmap = Cache.parallax(@parallax_name)
      Graphics.frame_reset
    end
    @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
    @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
  end
  #--------------------------------------------------------------------------
  # * update_characters
  #--------------------------------------------------------------------------
  def update_characters
    refresh_characters if @map_id != $game_map.map_id
    refresh_sprites    if $imported[:ve_anti_lag] && $game_map.screen_moved?
    if $imported[:ve_anti_lag]
      @screen_sprites.each {|sprite| sprite.update }
    else
      @character_sprites.each {|sprite| sprite.update }
    end
  end
  #--------------------------------------------------------------------------
  # * update_shadow
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # * update_weather
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type  = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  #--------------------------------------------------------------------------
  # * update_pictures
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
end

#==============================================================================
# ** VE - Map Battle X VE - Light Effects
#------------------------------------------------------------------------------
#  Compatibility Patch for VE - Map Battle and VE - Light Effects
#==============================================================================

if $imported[:ve_light_effects]
  #==============================================================================
  # ** Spriteset_MapBattle
  #------------------------------------------------------------------------------
  #  This class brings together battle screen sprites and Map sprites. 
  # It's used within the Scene_Battle class.
  #==============================================================================

  class Spriteset_MapBattle < Spriteset_Battle
    #--------------------------------------------------------------------------
    # * Alias method: initialize
    #--------------------------------------------------------------------------
    alias :initialize_ve_map_battle :initialize
    def initialize
      initialize_ve_map_battle
      2.times { update_light(true) }
    end
    #--------------------------------------------------------------------------
    # * Alias method: update
    #--------------------------------------------------------------------------
    alias :update_ve_map_battle :update
    def update
      update_ve_map_battle
      update_light
    end
    #--------------------------------------------------------------------------
    # * Alias method: dispose
    #--------------------------------------------------------------------------
    alias :dispose_ve_map_battle :dispose
    def dispose
      dispose_ve_map_battle
      dispose_light unless SceneManager.scene_is?(Scene_Map)
    end
    #--------------------------------------------------------------------------
    # * New method: update_light
    #--------------------------------------------------------------------------
    def update_light(forced = false)
      return unless Graphics.frame_count % 2 == 0 || forced
      update_shade
      update_effects
    end
    #--------------------------------------------------------------------------
    # * New method: dispose_light
    #--------------------------------------------------------------------------
    def dispose_light
      if @light_effect
        @light_effect.dispose
        @light_effect = nil
        @screen_shade = nil
      end
    end
    #--------------------------------------------------------------------------
    # * New method: update_shade
    #--------------------------------------------------------------------------
    def update_shade
      if !@light_effect && $game_map.screen.shade.visible
        refresh_lights
      elsif $game_map.screen.shade.visible && @light_effect
        @light_effect.update
      elsif @light_effect && !$game_map.screen.shade.visible
        dispose_light
      end
    end
    #--------------------------------------------------------------------------
    # * New method: refresh_lights
    #--------------------------------------------------------------------------
    def refresh_lights
      @light_effect.dispose if @light_effect
      @screen_shade = $game_map.screen.shade
      @light_effect = Sprite_Light.new(@screen_shade, @viewport2)
      $game_map.event_list.each {|ev| ev.refresh_lights }
      @light_effect.update
    end  
    #--------------------------------------------------------------------------
    # * New method: update_effects
    #--------------------------------------------------------------------------
    def update_effects
      return if !@light_effect || $game_map.screen.lights.empty?
      $game_map.screen.lights.keys.each {|key| create_light(key) }
      $game_map.screen.remove_light.clear
    end
    #--------------------------------------------------------------------------
    # * New method: create_light
    #--------------------------------------------------------------------------
    def create_light(key)
      effect = @light_effect.lights[key]
      return if remove_light(key)
      return if effect && effect.light == $game_map.screen.lights[key]
      @light_effect.create_light($game_map.screen.lights[key])
    end
    #--------------------------------------------------------------------------
    # * New method: remove_light
    #--------------------------------------------------------------------------
    def remove_light(key)
      return false if !$game_map.screen.remove_light.include?(key) 
      @light_effect.remove_light(key)
      $game_map.screen.lights.delete(key)
      return true
    end
  end
end