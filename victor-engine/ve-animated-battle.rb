#==============================================================================
# ** Victor Engine - Animated Battle
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Aditional Credit :
#   - Fomar0153 (Help with icons placement)
#
# Version History:
#  v beta - 2012.01.28 > Beta release
#  v 1.00 - 2012.03.08 > Full release
#  v 1.01 - 2012.03.11 > Better automatic facing direction handling
#                      > Added tags to control intro and victory poses
#                      > Added tags to assign equipment icons for enemies
#  v 1.02 - 2012.03.15 > Fixed enemies turing back when unmovable
#                      > Better active battler handling
#  v 1.03 - 2012.03.19 > Fixed last text error on fast damage skill
#                      > Fixed bug if number of members exceeds battle members
#  v 1.04 - 2012.03.21 > Fixed pose freeze error
#  v 1.05 - 2012.05.20 > Compatibility with Map Turn Battle
#  v 1.06 - 2012.05.22 > Compatibility with Passive States
#  v 1.07 - 2012.05.24 > Compatibility with State Auto Apply
#                      > Added note tags for cast poses
#  v 1.08 - 2012.05.25 > Fixed Counter and Reflect endless loop
#                      > Fixed freeze at the battle end
#  v 1.09 - 2012.07.17 > Fixed throw wait and effect animation
#                      > Fixed icons placement (Thanks to Fomar0153)
#                      > Fixed directions of actions
#                      > Fixed battle log showing too fast
#                      > Fixed freeze when escaping
#                      > Improved Dual Wielding options
#  v 1.10 - 2012.07.18 > Compatibility with Retaliation Damage
#                      > Improved direction handling
#                      > Improved animation wait time handling
#                      > Fixed throw animation skip if targets are near
#                      > Fixed shield icon flashing after defending
#                      > Fixed some log messages not showing
#                      > Fixed typo with move forward (replace all 'foward'
#                        text with 'forward')
#  v 1.11 - 2012.07.24 > Fixed game closing when cause death state on targets
#                      > Fixed issue with animation wait
#                      > Added "last" target tag for actions, this tag will
#                        use for the action the same target from the previous
#                        action.
#  v 1.12 - 2012.08.01 > Compatibility with State Aura
#  v 1.13 - 2012.08.02 > Compatibility with Custom Slip Effect
#                      > Compatibility with Basic Module 1.27
#  v 1.14 - 2012.08.17 > Compatibility with Custom Hit Formula
#  v 1.15 - 2012.11.03 > Added "frame size" value for pose settings, allowing
#                        to setup different frame sizes for each pose. Needed
#                        to use CCOA styled battlers.
#                      > Fixed issue with freeze when battlers enters the
#                        battle with events.
#                      > Fixed small jump during actions without movement.
#                      > Fixed issue with notetags priority.
#                      > Fixed issue with collapse time on battle end.
#  v 1.16 - 2012.12.13 > Compatibility with State Graphics
#  v 1.17 - 2012.12.24 > Compatibility with Active Time Battle
#                      > Compatibility with Counter Options
#  v 1.18 - 2012.12.30 > Compatibility with Leap Attack
#  v 1.19 - 2013.01.07 > Improved frame setup precision
#                      > Added target setting "next" that allows the sequence
#                        to select the "next" valid target
#                      > Added possibility to use script codes to setup the
#                        number of actions repeats, any valid game battler
#                        method that returns numeric values can be used.
#  v 1.20 - 2013.01.24 > Improved frame setup precision.
#  v 1.21 - 2013.01.13 > Major changes on various setups. More deatais at thr
#                        Additional Instructions.
#                      > Added new sprite settings: ox: and oy:. It can be used
#                        to adjust the positon of some battle graphics.
#                      > Added values: "condition", "script", "afterimage",
#                        "transform", "appear", "target". More information
#                        about those on the user manual.
#                      > Fixed issue with zoomed icons position.
#------------------------------------------------------------------------------
#  This script provides a totally customized animated battle system.
# This script allows a full customization of actions sequences, spritesheet
# and many things related to in battle display.
# This script ins't newbie friendly, be *VERY CAREFUL* with the settings.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#   If used with 'Victor Engine - Custom Slip Effect' place this bellow it.
#   If used with 'Victor Engine - Custom Hit Formula' place this bellow it.
#
#
# * Overwrite methods
#   class Game_BattlerBase
#     def refresh
#
#   class Game_Battler < Game_BattlerBase
#     def dead?
#
#   class Game_Actor < Game_Battler
#     def perform_collapse_effect
#     def perform_damage_effect
#
#   class Game_Enemy < Game_Battler
#     def perform_damage_effect
#
#   class Sprite_Battler < Sprite_Base
#     def update_bitmap
#     def init_visibility
#     def update_origin
#
#   class Spriteset_Battle
#     def create_actors
#
#   class Window_BattleLog < Window_Selectable
#     def wait_and_clear
#     def wait
#     def back_to(line_number)
#     def display_added_states(target)
#
#   class Scene_Battle < Scene_Base
#     def abs_wait_short
#     def process_action
#     def apply_item_effects(target, item)
#     def execute_action
#     def use_item
#     def show_animation(targets, animation_id)
#     def invoke_counter_attack(target, item)
#     def invoke_magic_reflection(target, item)
#     def apply_substitute(target, item)
#
# * Alias methods
#   class << BattleManager
#     def init_members
#     def battle_end(result)
#     def process_victory
#     def process_escape
#     def process_abort
#
#   class Game_Screen
#     def clear_tone
#     def update
#
#   class Game_Battler < Game_BattlerBase
#     def initialize
#     def item_apply(user, item)
#     def make_damage_value(user, item)
#     def regenerate_hp
#     def die
#     def revive
#
#   class Game_Actor < Game_Battler
#     def param_plus(param_id)
# 
#   class Game_Enemy < Game_Battler
#     def perform_collapse_effect
#
#   class Sprite_Battler < Sprite_Base
#     def initialize(viewport, battler = nil)
#     def update_effect
#     def revert_to_normal
#     def setup_new_effect
#
#   class Spriteset_Battle
#     def initialize
#     def update
#     def dispose
#     def create_pictures
#     def create_viewports
#     def update_viewports
#
#   class Window_BattleLog < Window_Selectable
#     def add_text(text)
#
#   class Scene_Battle < Scene_Base
#     def create_spriteset
#     def update_basic
#     def turn_end
#     def next_command
#     def prior_command
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'.
#  This script requires a very heavy user setup, refer to the User Manual
#  at http://victorscripts.wordpress.com/ for more information.
#------------------------------------------------------------------------------
# Weapons note tags:
#   Tags to be used on Weapons note boxes. 
#
#  <attack pose: action>
#   Changes the normal attack pose when using a weapon with this tag
#     action : action name
#
#  <dual pose: action>
#   Changes the double attack pose when using a weapon with this tag
#     action : action name
#
#  <skill pose: action>
#   Changes the physical skill pose when using a weapon with this tag
#     action : action name
#
#  <magic pose: action>
#   Changes the magical skill pose when using a weapon with this tag
#     action : action name
#
#  <item pose: action>
#   Changes the item pose when using a weapon with this tag
#     action : action name
#
#  <advance pose: action>
#   Changes the movement for actions when using a weapon with this tag
#   this change the movement of all actions that have movement (by default
#   only normal attacks and physical skills)
#     action : movement type name
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes. 
#
#  <action pose: action>
#   Changes the pose of the skill or item with this tag
#     action : action name
# 
#  <action movement>
#   By default, only physical skills have movement. So, if you want to add
#   movement to non-physical skills and items, add this tag.
#
#  <allow dual attack>
#   By default, skills and items do a single hit even if the character is
#   dual wielding, adding this tag to the skill will allow the actor to
#   attack twice when dual wielding. This only if the action don't use a
#   custom pose.
#
#------------------------------------------------------------------------------
# Actors note tags:
#   Tags to be used on Actors note boxes.
#
#  <no intro>
#   This tag will make the actor display no intro pose at the battle start.
#   By default, all actor display intro pose
#
#  <no victory>
#   This tag will make the actor display no victory pose at the battle start.
#   By default, all actors display victory pose
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on Enemies note boxes.
#
#  <intro pose>
#   This tag will make the enemy display intro pose at the battle start.
#   By default, no enemy display intro pose
#
#  <victory pose>
#   This tag will make the enemy display victory pose at the battle start.
#   By default, no enemy display victory pose
#
#  <weapon x: y>
#   This allows to display weapons for enemies when using the pose value
#   'icon: weapon *'.
#     x : the slot index of the weapon (1: right hand, 2: left hand)
#     y : the incon index
#
#  <armor x: y>
#   This allows to display armors for enemies when using the pose value
#   'icon: armor *'.
#     x : the slot index of the armor (1: shield, 2: helm, 3: armor, 4: acc)
#     y : the incon index
#
#------------------------------------------------------------------------------
# Actors, Enemies, Classes, States, Weapons and Armors note tags:
#   Tags to be used on Actors, Enemies, Classes, States, Weapons and Armors
#   note boxes.
#
#  <unmovable> 
#   This tag allows to make a totally unmovable battler. The battler will not
#   move to attack, neither be can forced to move by any action.
#  
#  <use dual attack>
#   By default, the attack when dual wielding calls the action sequence from
#   the equiped weapons. Adding this tag will make the actor use the custom
#   dual attack sequence <action: dual attack, reset>
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
# 
#  <no intro>
#   When called, the next battle will have no intro pose.
#
#  <no victory>
#   When called, the next battle will have no victory pose.
#
#------------------------------------------------------------------------------
# Additional Instructions:
#
#  More detailed info about the settings can be found on the User Manual at:
#   http://victorscripts.wordpress.com/
#
#  From version 1.09 and later the dual attack pose is opitional, if not set
#  the actor will use the default attack for each weapon instead (wich
#  allows to use weapons with totally different poses), also it's possible 
#  to setup skills to inherit the double attack effect. So you can make
#  you physical single hit skills to deal 2 strikes if dual wielding.
#
#  From version 1.21 and later the "effect:" and "throw:" values have been
#  changed. Now you must refer two targets values.
#  For the "effect" value, the first is the user of the action, the second the
#  targets. 
#  For the "throw:" value, the first is the target of the throw, the second 
#  battler throwing.
#  Actions sequences made before this update might need to be ajusted to these
#  new settings if not working properly. So if a custom action made before
#  this update shows problems, update those actions before asking for help.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Initialize Variables
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS = {} # Don't remove or change
  #--------------------------------------------------------------------------
  # * Animated battler sufix
  #   When using sprites, add this to the animated sprite sheet of the battler,
  #   that way you can keep the original battler a single sprite and make 
  #   easier to setup their position on the troop
  #--------------------------------------------------------------------------
  VE_SPRITE_SUFIX = "[anim]"
  #--------------------------------------------------------------------------
  # * Intro fade
  #   When true, there will be a small fade effect on the battlers during
  #   the battle start (like RMXP default battle)
  #--------------------------------------------------------------------------
  VE_BATTLE_INTRO_FADE = true
  #--------------------------------------------------------------------------
  # * Default sprite settings
  #   This is the settings for all battler graphics that doesn't have
  #   their own custom setting
  #--------------------------------------------------------------------------
  VE_DEFAULT_SPRITE = {
  # Basic Settings
  # name:   value,
    frames: 4,        # Number of frames
    rows:   14,       # Number of rows
    ox:     0,        # Adjust sprite X position
    oy:     0,        # Adjust sprite Y position
    mirror: true,     # Mirror battler when facing right
    invert: false,    # Invert the battler graphic
    mode:   :sprite,  # Graphic style (:sprite or :chasert)
    action: :default, # Action settings
    # IMPORTANT: using the ox: and oy: value will make the battle animation to
    # be moved also, if you want to adjust the battler position without
    # changing the position of the animation, use the script 
    # 'VE - Animations Settings' together with the batte.
    
  # Main Poses
  # name:       row,
    idle:      1,   # Idle pose
    guard:     2,   # Guard pose
    evade:     2,   # Evade pose
    danger:    3,   # Low HP pose
    hurt:      4,   # Damage pose
    attack:    5,   # Physical attack pose
    use:       6,   # No type use pose
    item:      6,   # Item use pose
    skill:     7,   # Skill use pose
    magic:     8,   # Magic use pose
    advance:   9,   # Advance pose
    retreat:   10,  # Retreat pose
    escape:    10,  # Escape pose
    victory:   11,  # Victory pose
    intro:     12,  # Battle start pose
    dead:      13,  # Incapacited pose
    ready:     nil, # Ready pose
    itemcast:  nil, # Item cast pose
    skillcast: nil, # Skill cast pose
    magiccast: nil, # Magic cast pose
    command:   nil, # Command pose
    input:     nil, # Input pose
    cancel:    nil, # Cancel pose
    # You can add other pose names and call them within the action settings
    # use only lowcase letters
    # IMPORTANT: the ready, itemcast, skillcast, magiccast, command, input and
    # cancel poses are skiped if nil, no matter what you setup on the pose
    # setting, so even using charset mode you need to setup a value to turn
    # on these poses.
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Custom sprite settings
  #   Theses settings are set individually based on the battler graphic
  #   filename (even if using the charset mode, the setting will be based
  #   on the battler name, so it's suggested to use the same name for
  #   the battler and charset graphic when using charset mode)
  #   Any value from the default setting can be used, if a value is not set
  #   it's automatically uses the value from basic setting
  #--------------------------------------------------------------------------
  VE_SPRITE_SETTINGS = {
  # 'Filename' => {settings},
  #
  # 'Sample 1' => {frames: 4, rows: 14, mirror: true, mode: :sprite,
  #                action: :default},
  # 'Sample 2' => {frames: 3, rows: 4, mirror: true, invert: false,
  #                mode: :charset, action: :charset},
  # 'Sample 3' => {frames: 3, rows: 4, mirror: false, invert: false,
  #                mode: :charset, action: :kaduki},
  # 'Sample 1' => {frames: 4, rows: 14, mirror: true, mode: :sprite,
  #                action: :default, oy: 20, evade: 1, skill: 4},
    'Holder'   => {frames: 4, rows: 14, mirror: true, mode: :sprite,
                   action: :default},
    'Charset'  => {frames: 3, rows: 4, mirror: false, invert: false,
                   mode: :charset, action: :charset},
    'Kaduki'   => {frames: 3, rows: 4, mirror: true, invert: false,
                   mode: :charset, action: :kaduki},
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Settings Used For all battlers that doesn't have specific settings
  #--------------------------------------------------------------------------
  VE_DEFAULT_ACTION = "

    # Pose displayed for skip actions
    <action: do nothing, reset>
    </action>

    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row idle, all frames, wait 12;
    wait: self, pose;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row dead, all frames, wait 16;
    wait: self, pose;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row danger, all frames, wait 12;
    wait: self, pose;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    pose: self, row guard, all frames, wait 24;
    wait: self, pose;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row intro, all frames, wait 16;
    wait: self, pose;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row victory, all frames, wait 16;
    wait: self, pose;
    </action>
    
    # Pose displayed when escaping (for ATB)
    <action: escaping, loop>
    pose: self, row retreat, all frames, wait 4, loop;
    wait: self, pose;
    </action>
  
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row ready, frame 1;
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row itemcast, frame 1;
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row skillcast, frame 1;
    wait: self, pose;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row magiccast, frame 1;
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
    pose: self, row hurt, all frames, wait 4;
    </action>

    # Pose displayed when evading attacks
    <action: evade, reset>
    pose: self, row evade, all frames, wait 4;
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
    pose: self, row idle, all frames, wait 8, loop;
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
    pose: self, row advance, all frames, wait 4, loop;
    move: self, substitution, move over;
    wait: self, movement;
    </action>
    
    # Pose for substitution deactivation (important, avoid change)
    <action: substitution off, reset>
    pose: self, row advance, all frames, wait 4, loop;
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
    pose: self, row advance, all frames, wait 4, loop;
    wait: self, movement;
    </action>
    
    # Step forward movement
    <action: step forward, reset>
    wait: targets, movement;
    move: self, step forward, speed 6;
    pose: self, row advance, all frames, wait 4, loop;
    wait: self, movement;
    </action>
    
    # Step backward movement
    <action: step backward, reset>
    move: self, step backward, speed 6;
    pose: self, row retreat, all frames, wait 4, invert, loop;
    wait: self, movement;
    </action>

    # Return to original spot
    <action: retreat, reset>
    move: self, retreat;
    pose: self, row retreat, all frames, wait 4, loop;
    jump: self, move, height 7;
    wait: self, movement;
    direction: self, default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row retreat, all frames, wait 4, invert, loop;
    wait: self, movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row guard, all frames, wait 8;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, y +1;
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, y +1;
    wait: 4;
    anim: targets, weapon 1;
    wait: 8;
    effect: self, targets 75%, weapon 1;
    wait: targets, animation;
    pose: self, row skill, all frames, wait 4, y +1;
    wait: 8;
    anim: targets, weapon 2;
    wait: 8;
    effect: self, targets 75%, weapon 2;
    wait: 20;
    </action>
        
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    pose: self, row item, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>

    # Pose for item use 
    <action: item, reset>
    wait: targets, movement;
    pose: self, row item, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    </action>

    # Pose for the skill 'Dual Attack'
    <action: double attack skill, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4, y +1;
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets 75%;
    wait: targets, animation;
    pose: self, row skill, all frames, wait 4, y +1;
    wait: 8;
    anim: targets, weapon;
    wait: 8;
    effect: self, targets 75%;
    wait: 20;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Manda Drain'
    <action: drain, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4;
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
    pose: self, row attack, all frames, wait 4;
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
    pose: self, row attack, frame 1, all frames, wait 2;
    move: self, x -48, speed 50;
    anim: targets, effect;
    effect: self, targets 30%;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 4;
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
    pose: self, row magic, all frames, wait 4;
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
    pose: self, row attack, all frames, wait 4;
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
    pose: self, row advance, all frames, wait 4, loop;
    wait: self, movement;
    direction: self, subjects;
    pose: self, row attack, all frames, wait 4;
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
    pose: self, row magic, all frames, wait 4;
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
  # * Sample settings used for battlers tagged as 'charset'
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS[:charset] = "

    # Pose displayed for skip actions
    <action: do nothing, reset>
    </action>

    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row direction, frame 2;
    wait: pose;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row 4, frame 2, angle -90, x -16, y -12;
    wait: pose;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row direction, frame 2;
    wait: pose;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    icon: self, shield, y +8, above;
    pose: self, row direction, frame 1;
    wait: 16;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row direction, frame 2;
    wait: 64;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row 2, frame 2;
    wait: 2;
    pose: self, row 4, frame 2;
    wait: 2;
    pose: self, row 3, frame 2;
    wait: 2;
    pose: self, row 1, frame 2;
    wait: 2;
    pose: self, row 2, frame 2;
    wait: 2;
    pose: self, row 4, frame 2;
    wait: 2;
    pose: self, row 3, frame 2;
    wait: 2;
    pose: self, row 1, frame 2;
    wait: 2;
    jump: self, height 8, speed 8;
    wait: 10
    </action>
  
    # Pose displayed when escaping (for ATB)
    <action: escaping, loop>
    pose: self, row direction, all frames, return, wait 4, loop, invert;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    action: self, step forward;
    wait: action;
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    action: self, step backward;
    wait: action;
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    action: self, step backward;
    wait: action;
    </action>
    
    # Pose displayed when recive damage
    <action: hurt, reset>
    direction: self, active;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step backward, speed 4;
    wait: self, movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step forward, speed 5;
    wait: self, movement;
    direction: self, default;
    </action>
    
    # Pose displayed when hurt
    <action: hurt pose, reset>
    pose: self, row direction, frame 1;
    </action>
    
    # Pose displayed when evading attacks
    <action: evade, reset>
    direction: self, active;
    pose: self, row 1, frame 2;
    move: self, step backward, speed 4;
    jump: self, move;
    wait: self, movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step forward, speed 5;
    wait: self, movement;
    direction: self, default;
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
    pose: self, row direction, frame 2, loop;
    </action>
    
    # Pose for counter attack preparation (important, avoid change)
    <action: prepare counter, reset>
    wait: self, action;
    </action>

    # Pose for counter attack deactivation (important, avoid change)
    <action: counter on, reset>
    counter: self, on;
    wait: counter;
    </action>

    # Pose for counter attack activation (important, avoid change)
    <action: counter off, reset>
    counter: targets, off;
    </action>

    # Pose for magic reflection (important, avoid change)
    <action: reflection, reset>
    wait: animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset>
    pose: self, row direction, all frames, return, wait 4, loop;
    move: self, substitution, move over;
    wait: self, movement;
    </action>
    
    # Pose for substitution deactivation (important, avoid change)
    <action: substitution off, reset>
    pose: self, row direction, all frames, return, wait 4, loop;
    move: self, retreat, move over;
    wait: self, movement;
    </action>

    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    move: self, move to;
    direction: self, subjects;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    </action>
    
    # Step forward movement
    <action: step forward, reset>
    wait: targets, movement;
    move: self, step forward, speed 6;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    </action>

    # Step backward movement
    <action: step backward, reset>
    move: self, step backward, speed 6;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    </action>

    # Return to original spot
    <action: retreat, reset>
    direction: self, return;
    move: self, retreat;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    direction: self, default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row direction, all frames, wait 2, y +1;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: self, targets, 100%;
    wait: 20;
    wait: pose;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets 75%, weapon;
    wait: targets, animation;
    icon: self, delete;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, revert, y +1;
    icon: self, weapon 2, angle -90, x +12, y -16;
    icon: self, weapon 2, angle -45, x +6, y -16;
    icon: self, weapon 2, angle 0;
    anim: targets, weapon;
    icon: self, weapon 2, angle 45, x -6, y +8;
    effect: self, targets 75%, weapon 2;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    action: self, step forward;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: self, action;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for item use
    <action: item, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: self, action;
    wait: 10;
    pose: self, row direction, frame 1;
    icon: action, x -8, above;
    wait: 4;
    pose: self, row direction, frame 2;
    icon: action, x -4, y -4, above;
    wait: 4;
    pose: self, row direction, frame 3;
    icon: action, y -8, above;
    wait: 4;
    pose: self, row direction, frame 2;
    icon: action, y -8, x +4, above;
    wait: 12;
    icon: self, delete;
    pose: self, row direction, frame 1;
    throw: targets, self, action, arc 10, init y -8;
    wait: targets, throw;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>

    # Pose for the skill 'Dual Attack'
    <action: dual attack skill, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets, 100%;
    wait: targets, animation;
    icon: self, delete;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, revert, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -6, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Mana Drain'
    <action: drain, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: targets, user drain;
    wait: targets, action;
    </action>

    # Pose for the targets of the skills 'Life Drain' and 'Mana Drain
    <action: user drain, reset>
    throw: self, user, icon 187, return, revert, init y -12, end y -12;
    wait: self, throw;
    drain: active;
    </action>    
    
    # Pose for the sample skill 'Throw Weapon'
    <action: throw weapon, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, frame 1;
    pose: self, row direction, frame 2;
    action: targets, target throw;
    pose: self, row direction, frame 3;
    wait: targets, action;
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
    wait: animation;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 5 times>
    direction: self, subjects;
    clear: targets, damage;
    move: targets, retreat, teleport;
    pose: self, row direction, frame 3, y +1;
    move: self, x -48, speed 50;
    icon: self, weapon, angle 45, x -12, y +8;
    anim: targets, effect;
    effect: self, targets 30%;
    icon: self, delete;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row direction, all frames, wait 4;
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
    wait: animation;
    pose: self, row direction, all frames, wait 4;
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
    
    # Pose for 'Claw' type weapons
    <action: claw, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 3, y +1;
    icon: self, weapon, angle -45, x +16, y -16;
    icon: self, weapon, angle -30, x +10, y -16;
    icon: self, weapon, angle -15, x -2;
    anim: targets, weapon;
    icon: self, weapon, angle 0, x -6, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Spear' type weapons
    <action: spear, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 3, y +1;
    icon: self, weapon, angle 45, x +12, y +8;
    icon: self, weapon, angle 45, x +12, y +8;
    icon: self, weapon, angle 45, x 0, y +8;
    anim: targets, weapon;
    icon: self, weapon, angle 45, x -12, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Gun' type weapons
    <action: gun, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 3;
    icon: self, weapon, angle -135, x +12, y -16;
    icon: self, weapon, angle -105, x +6, y -10;
    icon: self, weapon, angle -75, x 0, y -2;
    icon: self, weapon, angle -45, x -6, y +4;
    wait: 30;
    sound: name 'Gun1';
    pose: self, row direction, frame 3;
    icon: self, weapon, angle -75, x 0, y -2;
    pose: self, row direction, frame 2;
    icon: self, weapon, angle -105, x +6, y -10;
    pose: self, row direction, frame 1;
    anim: targets, weapon;
    icon: self, weapon, angle -135, x +12, y -16;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 2, all frames, sufix _3, wait 4;
    icon: self, image 'Bow1', x +6, above;
    icon: self, image 'Bow2', x +6, above;
    icon: self, image 'Bow3', x +6, above;
    wait: 10;
    action: targets, arrow;
    icon: self, image 'Bow2', x +6, above;
    icon: self, image 'Bow1', x +6, above;
    wait: self, action;
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
    target: next;
    move: self, move to front;
    pose: self, row direction, all frames, return, wait 4, loop;
    wait: self, movement;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: last, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, last, 100%, clear;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for the skill 'Aura Spell'
    <action: aura spell, reset>
    wait: targets, movement;
    wait: animation;
    action: self, step forward;
    wait: self, action;
    direction: self, subjects;
    pose: self, row direction, all frames, wait 4;
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
  # * Sample settings used for battlers tagged as 'kaduki' style
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS[:kaduki] = "

    # Pose displayed for skip actions
    <action: do nothing, reset>
    </action>

    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row 1, all frames, sufix _1, return, wait 16;
    wait: pose;
    </action>

    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row 4, all frames, sufix _2, return, wait 8;
    wait: pose;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row 3, all frames, sufix _1, return, wait 16;
    wait: pose;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    icon: self, shield, y +8, above;
    pose: self, row 4, frame 3, sufix _1;
    wait: 16;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row 1, frame 2, sufix _1;
    wait: 12;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row 1, all frames, sufix _2, wait 8;
    wait: pose;
    </action>
  
    # Pose displayed when escaping (for ATB)
    <action: escaping, loop>
    pose: self, row 4, all frames, sufix _1, return, loop, wait 8, invert;
    wait: pose;
    </action>

    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: pose;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row 4, all frames, sufix _3, loop, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    action: self, step forward;
    wait: self, action;
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    action: self, step backward;
    wait: self, action;
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    action: self, step backward;
    wait: self, action;
    </action>
        
    # Pose displayed when recive damage
    <action: hurt, reset>
    pose: self, row 2, all frames, sufix _1, wait 4;
    move: self, step backward, speed 4;
    wait: self, movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row 4, all frames, wait 4, return, sufix _1;
    move: self, step forward, speed 5;
    wait: self, movement;
    </action>
     
    # Pose displayed when hurt
    <action: hurt pose, reset>
    pose: self, row 2, frame 1, sufix _1;
    </action>

    # Pose displayed when evading attacks
    <action: evade, reset>
    pose: self, row 2, sufix _2, all frames, wait 4;
    move: self, step backward, speed 4;
    jump: self, move;
    wait: self, movement;
    pose: self, row 1, frame 2, sufix _2;
    wait: 4;
    pose: self, row 4, all frames, wait 4, return, sufix _1;
    move: self, step forward, speed 5;
    wait: self, movement;
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
    wait: self, counter;
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
    pose: self, row 1, all frames, sufix _1, return, wait 16, loop;
    </action>
    
    # Pose for counter attack preparation (important, avoid change)
    <action: prepare counter, reset>
    wait: self, action;
    wait: targets, countered;
    </action>
    
    # Pose for counter attack deactivation (important, avoid change)
    <action: counter off, reset>
    counter: targets;
    </action>
    
    # Pose for magic reflection (important, avoid change)
    <action: reflection, reset>
    wait: animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset>
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    move: self, substitution, move over;
    wait: self, movement;
    </action>
    
    # Pose for substitution deactivation (important, avoid change)
    <action: substitution off, reset>
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    move: self, retreat, move over;
    wait: self, movement;
    </action>
    
    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    wait: animation;
    move: self, move to;
    direction: self, subjects;
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    wait: self, movement;
    </action>
    
    # Step forward movement
    <action: step forward, reset>
    wait: targets, movement;
    move: self, step forward, speed 6;
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    wait: self, movement;
    </action>

    # Step backward movement
    <action: step backward, reset>
    wait: animation;
    move: self, step backward, speed 6;
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    </action>
    
    # Return to original spot
    <action: retreat, reset>
    direction: self, return;
    move: self, retreat;
    pose: self, row 4, all frames, sufix _1, return, loop, wait 8;
    wait: self, movement;
    direction: self, default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row 4, all frames, sufix _1, return, loop, wait 8, invert;
    wait: self, movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row 4, frame 2, sufix _1;
    icon: self, shield, y +8, above;
    pose: self, row 4, frame 3, sufix _1;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: self, targets, 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -180, x +12, y -16;
    icon: self, weapon, angle -135, x +12, y -16;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, weapon 1;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets 75%, weapon 1;
    wait: targets, animation;
    icon: self, delete;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon 2, angle -180, x +12, y -16;
    icon: self, weapon 2, angle -135, x +12, y -16;
    icon: self, weapon 2, angle -90, x +12, y -16;
    icon: self, weapon 2, angle -45, x +6, y -16;
    icon: self, weapon 2, angle 0;
    anim: targets, weapon 2;
    icon: self, weapon 2, angle 45, x -6, y +8;
    effect: self, targets 75%, weapon 2;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: self, action;
    pose: self, row 2, all frames, sufix _3, wait 3;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: self, action;
    direction: self, subjects;
    pose: self, row 3, all frames, sufix _3, wait 3;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>

    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>

    # Pose for item use
    <action: item, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: 10;
    pose: self, row 2, all frames, sufix _3, wait 3;
    icon: self, action, x -8, above;
    wait: 4;
    icon: self, action, x -4, y -4, above;
    wait: 4;
    icon: self, action, y -8, above;
    wait: 4;
    icon: self, action, y -8, x +4, above;
    wait: 12;
    pose: self, row 1, all frames, sufix _3, wait 2;
    icon: self, delete;
    throw: targets, self, action, arc 10, init y -8;
    wait: targets, throw;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: self, step backward;
    </action>

    # Pose for the skill 'Dual Attack'
    <action: dual attack skill, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -180, x +12, y -16;
    icon: self, weapon, angle -135, x +12, y -16;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    wait: targets, animation;
    wait: self, animation;
    icon: self, delete;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -180, x +12, y -16;
    icon: self, weapon, angle -135, x +12, y -16;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0;
    anim: targets, effect;
    icon: self, weapon, angle 45, x -6, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Manda Drain'
    <action: drain, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 3, all frames, sufix _3, wait 3;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: self, targets, 100%;
    wait: 20;
    action: targets, user drain;
    wait: action;
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
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3;
    wait: 4;
    action: targets, target throw;
    wait: targets, action;
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
    wait: self, animation;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 5 times>
    direction: self, subjects;
    clear: targets, damage;
    move: targets, retreat, teleport;
    pose: self, row 1, frame 3, sufix _3, y +1;
    move: self, x -48, speed 50;
    icon: self, weapon, angle 45, x -12, y +8;
    anim: targets, effect;
    effect: self, targets 30%;
    icon: self, delete;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    pose: self, row 3, all frames, sufix _3, wait 3;
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
    pose: self, row 3, all frames, sufix _3, wait 3;
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
    
    # Pose for 'Claw' type weapons
    <action: claw, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -45, x +16, y -16;
    icon: self, weapon, angle -30, x +10, y -16;
    icon: self, weapon, angle -15, x -2;
    anim: targets, weapon;
    icon: self, weapon, angle 0, x -6, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Spear' type weapons
    <action: spear, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle 45, x +12, y +8;
    icon: self, weapon, angle 45, x +12, y +8;
    icon: self, weapon, angle 45, x 0, y +8;
    anim: targets, weapon;
    icon: self, weapon, angle 45, x -12, y +8;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Gun' type weapons
    <action: gun, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3;
    icon: self, weapon, angle -135, x +12, y -16;
    icon: self, weapon, angle -105, x +6, y -10;
    icon: self, weapon, angle -75, x 0, y -2;
    icon: self, weapon, angle -45, x -6, y +4;
    wait: 30;
    sound: name 'Gun1';
    pose: self, row 1, frame 3, sufix _3;
    icon: self, weapon, angle -75, x -6, y -2;
    pose: self, row 1, frame 2, sufix _3;
    icon: self, weapon, angle -105, y -10;
    pose: self, row 1, frame 1, sufix _3;
    anim: targets, effect;
    effect: self, targets, 100%;
    wait: 20;
    icon: self, delete;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: self, subjects;
    pose: self, row 2, all frames, sufix _3, wait 4;
    icon: self, image 'Bow1', x +6, above;
    icon: self, image 'Bow2', x +6, above;
    icon: self, image 'Bow3', x +6, above;
    wait: 10;
    action: targets, arrow;
    icon: self, image 'Bow2', x +6, above;
    icon: self, image 'Bow1', x +6, above;
    wait: targets, action;
    </action>
    
    # Pose for the targets of 'Bow' attack
    <action: arrow, reset>
    throw: self, user, image 'Arrow', arc 10, angle 45, init x -6, init y -12;
    wait: self, throw;
    anim: self, weapon;
    wait: 8;
    effect: active, targets, 100%;
    </action>

    # Movement to target for the skill 'Aura Blade'
    <action: aura blade move to, reset>
    wait: targets, movement;
    wait: self, animation;
    move: self, move to, x +52;
    direction: self, subjects;
    pose: self, row 4, all frames, sufix _1, return, wait 8;
    wait: self, movement;
    </action>
    
    # Pose for the skill 'Aura Blade'
    <action: aura blade, reset>
    wait: targets, movement;
    pose: self, row 4, sufix _3, all frames, wait 8, loop;
    anim: self, id 81;
    wait: self, animation;
    pose: self, row 2, sufix _3, all frames, wait 3, y +1;
    icon: self, weapon, angle 45, x -6, y +6;
    icon: self, weapon, angle 30, x -10, y +0;
    icon: self, weapon, angle 15, x -14, y -6;
    icon: self, weapon, angle 0, x -10, y -10;
    wait: 30;
    anim: self, id 110;
    wait: self, animation;
    wait: 30;
    afterimage: on, red 160, green 160, alpha 128;
    move: self, x -144, speed 15;
    pose: self, row 1, sufix _3, all frames, wait 3, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    icon: self, weapon, angle 45, x -10, y +8;
    anim: targets, effect;
    effect: self, targets, 100%;
    wait: self, movement;
    afterimage: self, off;
    wait: 20;
    icon: self, delete;
    </action>

    # Pose for the skill 'Multi Attack'
    <action: multi attack, opponents_unit.targetable_members.size times>
    target: next;
    afterimage: self, on;
    move: self, move to front;
    pose: self, row 4, all frames, sufix _1, return, wait 8, loop;
    wait: self, movement;
    afterimage: self, off;
    direction: self, subjects;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: self, weapon, angle -90, x +12, y -16;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    anim: last, effect;
    icon: self, weapon, angle 45, x -10, y +8;
    effect: self, last, 100%, clear;
    wait: 20;
    icon: self, delete;
    </action>

    # Pose for the skill 'Aura Spell'
    <action: aura spell, reset>
    wait: targets, movement;
    action: self, step forward;
    wait: self, action;
    pose: self, row 3, all frames, sufix _3, wait 3;
    action: self, aura effect;
    wait: self, action
    action: self, step backward;
    </action>

    <action: aura effect, friends_unit.targetable_members.size times>
    target: next;
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
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_animated_battle] = 1.21
Victor_Engine.required(:ve_animated_battle, :ve_basic_module, 1.35, :above)
Victor_Engine.required(:ve_animated_battle, :ve_actor_battlers, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_animations_settings, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_passive_states, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_map_battle, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_state_cancel, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_tech_points, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_trait_control, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_mp_level, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_automatic_battlers, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_state_auto_apply, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_element_states, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_counter_options, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_state_aura, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_state_graphics, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_active_time_battle, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_damage_popup, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_action_streghten, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_element_strenghten, 1.00, :bellow)

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  This class is the superclass of all other classes.
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * New method: custom_pose
  #--------------------------------------------------------------------------
  def custom_pose(type)
    note =~ /<#{type.upcase} POSE: (\w[\w ]+)>/i ? make_symbol($1) : nil
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :old_tone
  #--------------------------------------------------------------------------
  # * Alias method: init_members
  #--------------------------------------------------------------------------
  alias :init_members_ve_animated_battle :init_members
  def init_members
    $game_party.members.each {|member| member.poses.clear_poses }
    init_members_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_end
  #--------------------------------------------------------------------------
  alias :battle_end_ve_animated_battle :battle_end
  def battle_end(result)
    $game_party.members.each {|member| member.poses.clear_poses }
    $game_system.no_intro   = false
    $game_system.no_victory = false
    battle_end_ve_animated_battle(result)
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_victory
  #--------------------------------------------------------------------------
  alias :process_victory_ve_animated_battle :process_victory
  def process_victory
    @phase = nil
    process_battle_end_pose($game_party)
    process_victory_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_defeat
  #--------------------------------------------------------------------------
  alias :process_defeat_ve_animated_battle :process_defeat
  def process_defeat
    @phase = nil
    process_battle_end_pose($game_troop)
    process_defeat_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_escape
  #--------------------------------------------------------------------------
  alias :process_escape_ve_animated_battle :process_escape
  def process_escape
    @escaping = true
    success   = process_escape_ve_animated_battle
    @escaping = false
    return success
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_abort
  #--------------------------------------------------------------------------
  alias :process_abort_ve_animated_battle :process_abort
  def process_abort
    @phase = nil
    process_escape_pose if @escaping
    process_abort_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: process_battle_end_pose
  #--------------------------------------------------------------------------
  def process_battle_end_pose(party)
    SceneManager.scene.log_window_clear
    SceneManager.scene.update_basic while end_wait?(party)
    SceneManager.scene.update_basic
    party.movable_members.each do |member| 
      next if $game_system.no_victory || !member.victory_pose?
      member.poses.clear_loop
      member.poses.call_pose(:victory)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: end_wait?
  #--------------------------------------------------------------------------
  def end_wait?(party)
    party.not_in_position? || party.active? || processing_collapse?
  end
  #--------------------------------------------------------------------------
  # * New method: processing_collapse?
  #--------------------------------------------------------------------------
  def processing_collapse?
    SceneManager.scene.spriteset.collapse?
  end
  #--------------------------------------------------------------------------
  # * New method: process_escape_pose
  #--------------------------------------------------------------------------
  def process_escape_pose
    $game_party.movable_members.each do |member| 
      member.poses.clear_loop
      member.poses.call_pose(:escape)
    end
    SceneManager.scene.abs_wait(5)
    SceneManager.scene.update_basic while $game_party.moving?
    SceneManager.scene.close_window
    Graphics.fadeout(30)
  end
  #--------------------------------------------------------------------------
  # * New method: clear_active_pose
  #--------------------------------------------------------------------------
  def clear_active_pose
    return unless actor && actor.poses.active_pose
    actor.poses.active_pose = nil
    actor.reset_pose
  end
  #--------------------------------------------------------------------------
  # * New method: active
  #--------------------------------------------------------------------------
  def active
    SceneManager.scene_is?(Scene_Battle) ? SceneManager.scene.active : nil
  end
  #--------------------------------------------------------------------------
  # * New method: targets
  #--------------------------------------------------------------------------
  def targets
    return [] unless active
    active.poses.current_action_targets
  end 
  #--------------------------------------------------------------------------
  # * New method: last_targets
  #--------------------------------------------------------------------------
  def last_targets
    return [] unless active
    active.poses.last_targets
  end
  #--------------------------------------------------------------------------
  # * New method: battler_active?
  #--------------------------------------------------------------------------
  def battler_active?
    return false unless active
    active.poses.active?
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system-related data. Also manages vehicles and BGM, etc.
# The instance of this class is referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :no_intro
  attr_accessor :no_victory
  attr_accessor :intro_fade
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    initialize_ve_animated_battle
    @intro_fade = VE_BATTLE_INTRO_FADE
  end
end

#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
# flashes, etc. It's used within the Game_Map and Game_Troop classes.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :low_tone
  attr_reader   :high_tone
  attr_accessor :old_tone
  attr_accessor :old_low_tone
  attr_accessor :old_high_tone
  #--------------------------------------------------------------------------
  # * Alias method: clear_tone
  #--------------------------------------------------------------------------
  alias :clear_tone_ve_animated_battle :clear_tone
  def clear_tone
    clear_tone_ve_animated_battle
    @low_tone  = Tone.new
    @high_tone = Tone.new
    @low_tone_target  = Tone.new
    @high_tone_target = Tone.new
    @low_tone_duration  = 0
    @high_tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_animated_battle :update
  def update
    update_ve_animated_battle
    low_update_tone
    high_update_tone
  end
  #--------------------------------------------------------------------------
  # * New method: start_low_tone_change
  #--------------------------------------------------------------------------
  def start_low_tone_change(tone, duration)
    @low_tone_target = tone.clone
    @low_tone_duration = duration
    @low_tone = @low_tone_target.clone if @low_tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: start_high_tone_change
  #--------------------------------------------------------------------------
  def start_high_tone_change(tone, duration)
    @high_tone_target = tone.clone
    @high_tone_duration = duration
    @high_tone = @high_tone_target.clone if @high_tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: low_update_tone
  #--------------------------------------------------------------------------
  def low_update_tone
    if @low_tone_duration > 0
      d    = @low_tone_duration
      tone = @low_tone_target
      @low_tone.red   = (@low_tone.red   * (d - 1) + tone.red)   / d
      @low_tone.green = (@low_tone.green * (d - 1) + tone.green) / d
      @low_tone.blue  = (@low_tone.blue  * (d - 1) + tone.blue)  / d
      @low_tone.gray  = (@low_tone.gray  * (d - 1) + tone.gray)  / d
      @low_tone_duration -= 1
    end
  end  
  #--------------------------------------------------------------------------
  # * New method: high_update_tone
  #--------------------------------------------------------------------------
  def high_update_tone
    if @high_tone_duration > 0
      d    = @high_tone_duration
      tone = @high_tone_target
      @high_tone.red   = (@high_tone.red   * (d - 1) + tone.red)   / d
      @high_tone.green = (@high_tone.green * (d - 1) + tone.green) / d
      @high_tone.blue  = (@high_tone.blue  * (d - 1) + tone.blue)  / d
      @high_tone.gray  = (@high_tone.gray  * (d - 1) + tone.gray)  / d
      @high_tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * New method: tone_change?
  #--------------------------------------------------------------------------
  def tone_change?
    @tone_duration > 0 || @low_tone_duration > 0 || @high_tone_duration > 0
  end
end

#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :hurt_pose
  #--------------------------------------------------------------------------
  # * New method: damage_adjust
  #--------------------------------------------------------------------------
  def damage_adjust(value, item)
    return unless value
    @hp_damage *= value
    @mp_damage *= value
    @hp_damage  = @hp_damage.to_i
    @mp_damage  = [@battler.mp, @mp_damage.to_i].min
    @hp_drain   = @hp_damage if item.damage.drain?
    @mp_drain   = @mp_damage if item.damage.drain?
    @hp_drain   = [@battler.hp, @hp_drain].min
  end
  #--------------------------------------------------------------------------
  # * New method: setup_drain
  #--------------------------------------------------------------------------
  def setup_drain(user)
    user.hp_drain += @hp_drain
    user.mp_drain += @mp_drain
    @hp_drain = 0
    @mp_drain = 0
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
  # * Overwrite method: refresh
  #--------------------------------------------------------------------------
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @mp = [[@mp, mmp].min, 0].max
    die if @dying && !immortal?
    return if @dying
    valid = @hp == 0 && !immortal?
    valid ? add_state(death_state_id) : remove_state(death_state_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: element_set
  #--------------------------------------------------------------------------
  alias :element_set_ve_animated_battle :element_set
  def element_set(item)
    element_set  = element_set_ve_animated_battle(item)
    element_set += poses.element_flag
    element_set.compact
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
  attr_accessor :poses
  attr_accessor :hp_drain
  attr_accessor :mp_drain
  #--------------------------------------------------------------------------
  # * Overwrite method: dead?
  #--------------------------------------------------------------------------
  def dead?
    super && !immortal?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_element_rate
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    elements = user.element_set(item)
    elements.empty? ? 1.0 : elements_max_rate(elements)
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    @hp_drain = 0
    @mp_drain = 0
    @poses = Game_BattlerPose.new(self)
    initialize_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_animated_battle :item_apply
  def item_apply(user, item)
    item_apply_ve_animated_battle(user, item)
    poses.call_damage_pose(item, user) if movable?
    poses.substitution     = false
    user.poses.result_flag = @result.hit? ? :hit : :miss
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_animated_battle :make_damage_value
  def make_damage_value(user, item)
    make_damage_value_ve_animated_battle(user, item)
    active_effect_make_damage(user, item)
    clear_elemental_flag(user, item)
    @result.damage_adjust(user.poses.damage_flag, item)
    @result.hurt_pose = !user.poses.no_hurt_flag
    @result.setup_drain(user)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :execute_damage_ve_animated_battle :execute_damage
  def execute_damage(user)
    execute_damage_ve_animated_battle(user)
    poses.clear_immortal if self.hp <= 0 && poses.clear_flag
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_hp
  #--------------------------------------------------------------------------
  alias :regenerate_hp_ve_animated_battle :regenerate_hp
  def regenerate_hp
    regenerate_hp_ve_animated_battle
    if @result.hp_damage > 0 && movable? && $imported[:ve_damage_pop]
      poses.call_pose(:hurt, :clear)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: die
  #--------------------------------------------------------------------------
  alias :die_ve_animated_battle :die
  def die
    return @dying = true if immortal?
    poses.call_pose(:die, :clear)
    @dying = false
    die_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: revive
  #--------------------------------------------------------------------------
  alias :revive_ve_animated_battle :revive
  def revive
    call_pose(:revive, :clear)
    revive_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: get_all_poses
  #--------------------------------------------------------------------------
  def get_all_poses(note = "")
    note + get_all_notes + battler_settings + default_settings
  end
  #--------------------------------------------------------------------------
  # * New method: default_settings
  #--------------------------------------------------------------------------
  def default_settings
    VE_DEFAULT_ACTION
  end
  #--------------------------------------------------------------------------
  # * New method: battler_settings
  #--------------------------------------------------------------------------
  def battler_settings
    VE_ACTION_SETTINGS[battler_mode] ? VE_ACTION_SETTINGS[battler_mode] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: battler_mode
  #--------------------------------------------------------------------------
  def battler_mode
    sprite_value(:action)
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_value
  #--------------------------------------------------------------------------
  def sprite_value(n)
    sprite_settings[n].nil? ? VE_DEFAULT_SPRITE[n] : sprite_settings[n]
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_settings
  #--------------------------------------------------------------------------
  def sprite_settings
    VE_SPRITE_SETTINGS[@battler_name] ? VE_SPRITE_SETTINGS[@battler_name] :
    VE_DEFAULT_SPRITE
  end
  #--------------------------------------------------------------------------
  # * New method: script_processing
  #--------------------------------------------------------------------------
  def script_processing(code)
    eval(code) rescue false
  end
  #--------------------------------------------------------------------------
  # * New method: set_pose_frames
  #--------------------------------------------------------------------------
  def set_pose_frames(value)
    if value =~ /(\d+) FRAMES/i
      [@pose[:frame] + $1.to_i, sprite_value(:frames)].min - 1
    else
      sprite_value(:frames) - 1
    end
  end
  #--------------------------------------------------------------------------
  # * New method: weapon_icon
  #--------------------------------------------------------------------------
  def weapon_icon(index)
    actor? ? actor_weapon_icon(index) : enemy_weapon_icon(index)
  end
  #--------------------------------------------------------------------------
  # * New method: actor_weapon_icon
  #--------------------------------------------------------------------------
  def actor_weapon_icon(index)
    weapons[index - 1] ? weapons[index - 1].icon_index : nil
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_weapon_icon
  #--------------------------------------------------------------------------
  def enemy_weapon_icon(index)
    note =~ /<WEAPON #{index}: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: armor_icon
  #--------------------------------------------------------------------------
  def armor_icon(index)
   actor? ? actor_armor_icon(index) : enemy_armor_icon(index)
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def actor_armor_icon(index)
    slot = equip_slots[index]
    return nil unless slot && slot != 0 && equip_list[slot]
    equip = equip_list[slot]
    equip.object ? equip.object.icon_index : nil
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def enemy_armor_icon(index)
    note =~ /<ARMOR #{index}: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def equip_list
    @equips
  end
  #--------------------------------------------------------------------------
  # * New method: action_icon
  #--------------------------------------------------------------------------
  def action_icon
    poses.current_item ? poses.current_item.icon_index : 0
  end
  #--------------------------------------------------------------------------
  # * New method: current_origin?
  #--------------------------------------------------------------------------
  def current_origin?
    current_x == screen_x && current_y == screen_y
  end
  #--------------------------------------------------------------------------
  # * New method: target_origin?
  #--------------------------------------------------------------------------
  def target_origin?
    target_x == screen_x && target_y == screen_y
  end
  #--------------------------------------------------------------------------
  # * New method: target_current?
  #--------------------------------------------------------------------------
  def target_current?
    current_x == target_x  && current_y == target_y
  end
  #--------------------------------------------------------------------------
  # * New method: not_origin?
  #--------------------------------------------------------------------------
  def not_origin?
    !origin?
  end
  #--------------------------------------------------------------------------
  # * New method: current_x
  #--------------------------------------------------------------------------
  def current_x
    poses.current_position[:x]
  end
  #--------------------------------------------------------------------------
  # * New method: current_y
  #--------------------------------------------------------------------------
  def current_y
    poses.current_position[:y]
  end
  #--------------------------------------------------------------------------
  # * New method: current_h
  #--------------------------------------------------------------------------
  def current_h
    poses.current_position[:h]
  end
  #--------------------------------------------------------------------------
  # * New method: current_j
  #--------------------------------------------------------------------------
  def current_j
    poses.current_position[:j]
  end
  #--------------------------------------------------------------------------
  # * New method: target_x
  #--------------------------------------------------------------------------
  def target_x
    poses.target_position[:x]
  end
  #--------------------------------------------------------------------------
  # * New method: target_y
  #--------------------------------------------------------------------------
  def target_y
    poses.target_position[:y]
  end
  #--------------------------------------------------------------------------
  # * New method: target_h
  #--------------------------------------------------------------------------
  def target_h
    poses.target_position[:h]
  end
  #--------------------------------------------------------------------------
  # * New method: target_j
  #--------------------------------------------------------------------------
  def target_j
    poses.target_position[:j]
  end
  #--------------------------------------------------------------------------
  # * New method: item_attack?
  #--------------------------------------------------------------------------
  def item_attack?(item)
    item.skill? && item.id == attack_skill_id
  end
  #--------------------------------------------------------------------------
  # * New method: item_defend?
  #--------------------------------------------------------------------------
  def item_defend?(item)
    item.skill? && item.id == guard_skill_id
  end
  #--------------------------------------------------------------------------
  # * New method: use_dual_attack?
  #--------------------------------------------------------------------------
  def use_dual_attack?(item)
    get_all_notes =~ /<USE DUAL ATTACK>/i && double_attack?(item)
  end
  # * New method: use_dual_attack?
  #--------------------------------------------------------------------------
  def use_double_attack?(item)
   double_attack?(item) && !use_dual_attack?(item)
  end
  #--------------------------------------------------------------------------
  # * New method: double_attack?
  #--------------------------------------------------------------------------
  def double_attack?(item)
    actor? && dual_wield? && weapons.size > 1 && (item_attack?(item) ||
    (item  && item.note =~ /<ALLOW DUAL ATTACK>/i))
  end
  #--------------------------------------------------------------------------
  # * New method: immortal?
  #--------------------------------------------------------------------------
  def immortal?
    poses.immortal?
  end
  #--------------------------------------------------------------------------
  # * New method: down?
  #--------------------------------------------------------------------------
  def down?
    poses.down?
  end
  #--------------------------------------------------------------------------
  # * New method: left?
  #--------------------------------------------------------------------------
  def left?
    poses.left?
  end
  #--------------------------------------------------------------------------
  # * New method: right?
  #--------------------------------------------------------------------------
  def right?
    poses.right?
  end
  #--------------------------------------------------------------------------
  # * New method: up?
  #--------------------------------------------------------------------------
  def up?
    poses.up?
  end
  #--------------------------------------------------------------------------
  # * New method: unmovable?
  #--------------------------------------------------------------------------
  def unmovable?
    get_all_notes =~ /<UNMOVABLE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: hurt_pose?
  #--------------------------------------------------------------------------
  def hurt_pose?
    @result.hit? && @result.hp_damage > 0 && @result.hurt_pose
  end
  #--------------------------------------------------------------------------
  # * New method: command_pose
  #--------------------------------------------------------------------------
  def command_pose
    poses.call_pose(:command, :clear) if sprite_value(:command)
  end
  #--------------------------------------------------------------------------
  # * New method: input_pose
  #--------------------------------------------------------------------------
  def input_pose
    poses.call_pose(:input, :clear) if sprite_value(:input)
  end
  #--------------------------------------------------------------------------
  # * New method: cancel_pose
  #--------------------------------------------------------------------------
  def cancel_pose
    poses.call_pose(:cancel, :clear) if sprite_value(:cancel)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_counter_targets
  #--------------------------------------------------------------------------
  def setup_counter_targets(target, item)
    [target]
  end
  #--------------------------------------------------------------------------
  # * New method: counter_action
  #--------------------------------------------------------------------------
  def counter_action
    $data_skills[attack_skill_id]
  end
  #--------------------------------------------------------------------------
  # * New method: drain_setup
  #--------------------------------------------------------------------------
  def drain_setup
    self.hp += @hp_drain
    self.mp += @mp_drain
    @result.hp_damage = -@hp_drain
    @result.mp_damage = -@mp_drain
    @hp_drain = 0
    @mp_drain = 0
    @damaged  = true if $imported[:ve_damage_pop]
  end
  #--------------------------------------------------------------------------
  # * New method: perform_damage_effect
  #--------------------------------------------------------------------------
  def perform_fast_collapse
    reset_pose
    @sprite_effect_type = :instant_collapse
  end
  #--------------------------------------------------------------------------
  # * New method: reset_pose
  #--------------------------------------------------------------------------
  def reset_pose
    return unless $game_party.in_battle
    sprite.reset_pose if sprite
  end
  #--------------------------------------------------------------------------
  # * New method: clear_flag=
  #--------------------------------------------------------------------------
  def clear_flag=(n)
    poses.clear_flag = n
  end
  #--------------------------------------------------------------------------
  # * New method: clear_elemental_flag
  #--------------------------------------------------------------------------
  def clear_elemental_flag(user, item)
    user.poses.element_flag.clear
    user.poses.active_effect.each {|member| member.poses.element_flag.clear }
    user.poses.active_effect.clear
  end
  #--------------------------------------------------------------------------
  # * New method: active_effect_make_damage
  #--------------------------------------------------------------------------
  def active_effect_make_damage(user, item)
    return if user.poses.active_effect.empty?
    setup_old_results
    apply_new_results(user, item)
    restore_old_results(item)
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_make_damage
  #--------------------------------------------------------------------------
  def setup_old_results
    @result_critical  = @result.critical
    @result_hp_damage = @result.hp_damage
    @result_mp_damage = @result.mp_damage
    @result_hp_drain  = @result.hp_drain
    @result_mp_drain  = @result.mp_drain
    @result_resist    = @result.resist if $imported[:ve_damage_pop]
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_make_damage
  #--------------------------------------------------------------------------
  def apply_new_results(user, item)
    user.poses.active_effect.each do |battler|
      next if battler == user
      make_damage_value_ve_animated_battle(battler, item)
      @result_critical  |= @result.critical
      @result_hp_damage += @result.hp_damage
      @result_mp_damage += @result.mp_damage
      @result_hp_drain  += @result.hp_drain
      @result_mp_drain  += @result.mp_drain
      @result_success   |= @result.success
      @result_resist    *= @result.resist if $imported[:ve_damage_pop]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_make_damage
  #--------------------------------------------------------------------------
  def restore_old_results(item)
    @result.critical  = @result_critical
    @result.hp_damage = @result_hp_damage
    @result.mp_damage = @result_mp_damage
    @result.hp_drain  = @result_hp_drain
    @result.mp_drain  = @result_mp_drain
    @result.resist    = @result_resist if $imported[:ve_damage_pop]
    @result.success   = item.damage.to_hp? || @result.mp_damage != 0
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
  # * Overwrite method: perform_collapse_effect
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      reset_pose
      case collapse_type
      when 0
        @sprite_effect_type = :collapse
        Sound.play_enemy_collapse
      when 1
        @sprite_effect_type = :boss_collapse
        Sound.play_boss_collapse1
      when 2
        @sprite_effect_type = :instant_collapse
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: perform_damage_effect
  #--------------------------------------------------------------------------
  def perform_damage_effect
    $game_troop.screen.start_shake(5, 5, 10) unless use_sprite?
    Sound.play_actor_damage
  end
  #--------------------------------------------------------------------------
  # * Alias method: param_plus
  #--------------------------------------------------------------------------
  alias :param_plus_ve_animated_battle :param_plus
  def param_plus(param_id)
    if param_id > 1 && @attack_flag
      atk_equips.compact.inject(super) {|r, item| r += item.params[param_id] }
    else
      param_plus_ve_animated_battle(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: atk_feature_objects
  #--------------------------------------------------------------------------
  def atk_feature_objects
    list = @attack_flag ? atk_equips : equips.compact
    states + [actor] + [self.class] + list
  end
  #--------------------------------------------------------------------------
  # * New method: atk_all_features
  #--------------------------------------------------------------------------
  def atk_all_features
    atk_feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_features
  #--------------------------------------------------------------------------
  def atk_features(code)
    atk_all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_features_set
  #--------------------------------------------------------------------------
  def atk_features_set(code)
    atk_features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_elements
  #--------------------------------------------------------------------------
  def atk_elements
    set = atk_features_set(FEATURE_ATK_ELEMENT)
    set |= [1] if weapons.compact.empty?
    return set
  end
  #--------------------------------------------------------------------------
  # * New method: atk_states
  #--------------------------------------------------------------------------
  def atk_states
    atk_features_set(FEATURE_ATK_STATE)
  end
  #--------------------------------------------------------------------------
  # * New method: atk_equips
  #--------------------------------------------------------------------------
  def atk_equips
    ([weapons[@attack_flag - 1]] + armors).collect {|item| item }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: character_hue
  #--------------------------------------------------------------------------
  def character_hue
    hue
  end
  #--------------------------------------------------------------------------
  # * New method: intro_pose?
  #--------------------------------------------------------------------------
  def intro_pose?
    !(note =~ /<NO INTRO>/i)
  end
  #--------------------------------------------------------------------------
  # * New method: victory_pose?
  #--------------------------------------------------------------------------
  def victory_pose?
    !(note =~ /<NO VICTORY>/i)
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
  # * Overwrite method: perform_damage_effect
  #--------------------------------------------------------------------------
  def perform_damage_effect
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # * Alias method: perform_collapse_effect
  #--------------------------------------------------------------------------
  alias :perform_collapse_effect_ve_animated_battle :perform_collapse_effect
  def perform_collapse_effect
    reset_pose
    perform_collapse_effect_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: atk_animation_id1
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: atk_animation_id2
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: character_name
  #--------------------------------------------------------------------------
  def character_name
    @character_name = @battler_name
    @character_name
  end
  #--------------------------------------------------------------------------
  # * New method: character_hue
  #--------------------------------------------------------------------------
  def character_hue
    @character_hue = @battler_hue
    @character_hue
  end
  #--------------------------------------------------------------------------
  # * New method: character_index
  #--------------------------------------------------------------------------
  def character_index
    note =~ /<CHARACTER INDEX: (\d+)>/i ? $1.to_i - 1 : 0
  end
  #--------------------------------------------------------------------------
  # * New method: visual_items
  #--------------------------------------------------------------------------
  def visual_items
    [default_part]
  end
  #--------------------------------------------------------------------------
  # * New method: default_part
  #--------------------------------------------------------------------------
  def default_part
    {name: character_name, index1: character_index, index2: character_index,
     hue: character_hue, priority: 0}
  end
  #--------------------------------------------------------------------------
  # * New method: intro_pose?
  #--------------------------------------------------------------------------
  def intro_pose?
    note =~ /<INTRO POSE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: victory_pose?
  #--------------------------------------------------------------------------
  def victory_pose?
    note =~ /<VICTORY POSE>/i
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
  # * New method: moving?
  #--------------------------------------------------------------------------
  def not_in_position?
    movable_members.any? {|member| member.poses.not_in_position? }
  end
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def moving?
    movable_members.any? {|member| member.poses.moving? }
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?
    movable_members.any? {|member| member.poses.active? }
  end
  #--------------------------------------------------------------------------
  # * New method: targetable_members
  #--------------------------------------------------------------------------  
  def targetable_members
    alive_members
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
  alias :comment_call_ve_animated_battle :comment_call
  def comment_call
    call_animated_battle_comments
    comment_call_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: call_animated_battle_comments
  #--------------------------------------------------------------------------
  def call_animated_battle_comments
    $game_system.no_intro   = true if note =~ /<NO INTRO>/i
    $game_system.no_victory = true if note =~ /<NO VICTORY>/i
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
  attr_accessor :row
  attr_accessor :spin
  attr_accessor :angle
  attr_accessor :sufix
  attr_accessor :frame
  attr_accessor :shake
  attr_accessor :reset
  attr_accessor :x_adj
  attr_accessor :y_adj
  attr_accessor :f_size
  attr_accessor :f_init
  attr_accessor :timing
  attr_accessor :freeze
  attr_accessor :active
  attr_accessor :jumping
  attr_accessor :targets
  attr_accessor :teleport
  attr_accessor :call_end
  attr_accessor :icon_list
  attr_accessor :invisible
  attr_accessor :direction
  attr_accessor :immortals
  attr_accessor :animation
  attr_accessor :countered
  attr_accessor :call_anim
  attr_accessor :dual_flag
  attr_accessor :pose_list
  attr_accessor :move_over
  attr_accessor :pose_loop
  attr_accessor :afterimage
  attr_accessor :move_speed
  attr_accessor :reset_move
  attr_accessor :throw_list
  attr_accessor :clear_flag
  attr_accessor :counter_on
  attr_accessor :call_effect
  attr_accessor :next_target
  attr_accessor :attack_flag
  attr_accessor :damage_flag
  attr_accessor :result_flag
  attr_accessor :active_pose
  attr_accessor :substitution
  attr_accessor :last_targets
  attr_accessor :anim_targets
  attr_accessor :element_flag
  attr_accessor :current_item
  attr_accessor :no_hurt_flag
  attr_accessor :active_effect
  attr_accessor :action_targets
  attr_accessor :counter_target
  attr_accessor :target_position
  attr_accessor :previous_action
  attr_accessor :current_position
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear_poses
  end
  #--------------------------------------------------------------------------
  # * New method: clear_poses
  #--------------------------------------------------------------------------
  def clear_poses
    @sufix = ""
    @row   = 0
    @frame = 0
    @angle = 0
    @spin  = 0
    @x_adj = 0
    @y_adj = 0
    @f_init   = 0
    @hp_drain = 0
    @mp_drain = 0
    @direction  = 2
    @move_speed = 1.0
    @targets    = []
    @immortals  = []
    @throw_list = []
    @icon_list  = {}
    @timing     = {}
    @element_flag   = []
    @active_effect  = []
    @action_targets = []
    @pose_list = Game_PoseList.new(@battler)
    clear_shake
    clear_position
  end
  #--------------------------------------------------------------------------
  # * New method: immortal?
  #--------------------------------------------------------------------------
  def immortal?
    return false unless $game_party.in_battle
    members = BattleManager.all_battle_members
    members.any? {|member| member.poses.immortals.include?(@battler) }
  end
  #--------------------------------------------------------------------------
  # * New method: clear_shake
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # * New method: clear_position
  #--------------------------------------------------------------------------
  def clear_position
    @target_position  = {x: 0, y: 0, h: 0, j: 0}
    @current_position = {x: 0, y: 0, h: 0, j: 0}
    @default_position = {x: 0, y: 0, h: 0, j: 0}
  end
  #--------------------------------------------------------------------------
  # * New method: call_pose
  #--------------------------------------------------------------------------
  def call_pose(pose, insert = nil, item = nil, battler = nil)
    return if insert == :clear && pose_list.include?(pose)
    notes = @battler.get_all_poses(item ? item.note : "")
    setup_pose(pose, notes, make_string(pose), insert, battler)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose(pose, notes, code, insert, battler)
    regexp = get_all_values("ACTION: *#{code}((?: *, *[^>]+)+)?", "ACTION")
    result = []
    if notes.gsub(/\r\n/i, "") =~ regexp
      value = $1
      setup = $2
      time  = value =~ /([^,]+) TIMES/i ? [script_processing($1), 1].max : 1
      last  = value =~ /(\w[\w ]+)/i    ? make_symbol($1) : nil
      layer = insert.numeric? ? insert : 1
      time.times { result.push(setup_value(setup, pose, last, layer, battler)) }
      insert_poses(insert, result)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: script_processing
  #--------------------------------------------------------------------------
  def script_processing(value)
    @battler.script_processing(value)
  end
  #--------------------------------------------------------------------------
  # * New method: insert_poses
  #--------------------------------------------------------------------------
  def insert_poses(insert, next_pose)
    case insert
    when :clear, :insert then @pose_list.insert(1, 0, next_pose)
    when Numeric         then @pose_list.insert(insert, 0, next_pose)
    else @pose_list.insert(1, -1, next_pose)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_value
  #--------------------------------------------------------------------------
  def setup_value(setup, pose, last, layer, battler)
    values = Game_PoseAction.new(pose, last, layer, @battler)
    setup.scan(/(\w+)(?:: *([^;\n\r]+)[;\n\r])?/i) do |name, value|
      value = value ? value : ""
      values.push(Game_PoseValue.new(name, value, @battler, battler, layer))
    end
    values
  end
  #--------------------------------------------------------------------------
  # * New method: pose_name_list
  #--------------------------------------------------------------------------
  def pose_name_list
    pose_list.list[1]
  end
  #--------------------------------------------------------------------------
  # * New method: pose_name
  #--------------------------------------------------------------------------
  def pose_name
    pose_list.name[1]
  end
  #--------------------------------------------------------------------------
  # * New method: clear_loop
  #--------------------------------------------------------------------------
  def clear_loop
    @pose_list.clear_loop
  end
  #--------------------------------------------------------------------------
  # * New method: clear_damage
  #--------------------------------------------------------------------------
  def clear_damage
    @pose_list.clear_damage
  end
  #--------------------------------------------------------------------------
  # * New method: states_pose
  #--------------------------------------------------------------------------
  def states_pose
    $data_states.compact.collect {|state| state.custom_pose("STATE") }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: current_action_targets
  #--------------------------------------------------------------------------
  def current_action_targets
    next_target ? [@action_targets[next_target]] : @action_targets
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?
    @active
  end
  #--------------------------------------------------------------------------
  # * New method: down?
  #--------------------------------------------------------------------------
  def down?
    @direction == 2
  end
  #--------------------------------------------------------------------------
  # * New method: left?
  #--------------------------------------------------------------------------
  def left?
    @direction == 4
  end
  #--------------------------------------------------------------------------
  # * New method: right?
  #--------------------------------------------------------------------------
  def right?
    @direction == 6
  end
  #--------------------------------------------------------------------------
  # * New method: up?
  #--------------------------------------------------------------------------
  def up?
    @direction == 8
  end
  #--------------------------------------------------------------------------
  # * New method: target_direction
  #--------------------------------------------------------------------------
  def target_direction(x, y)
    relative_x = @battler.current_x - x
    relative_y = @battler.current_y - y
    if isometric?
      @direction = 2 if relative_x > 0 && relative_y < 0
      @direction = 4 if relative_x > 0 && relative_y > 0
      @direction = 6 if relative_x < 0 && relative_y < 0
      @direction = 8 if relative_x < 0 && relative_y > 0
    elsif relative_x.abs >= relative_y.abs && !frontview?
      @direction = relative_x < 0 ? 6 : 4
    elsif relative_y.abs >= relative_x.abs && !sideview?
      @direction = relative_y < 0 ? 2 : 8
    end
  end
  #--------------------------------------------------------------------------
  # * New method: action_direction
  #--------------------------------------------------------------------------
  def action_direction(units)
    x = units.collect {|member| member.current_x }.average
    y = units.collect {|member| member.current_y }.average
    target_direction(x, y)
  end
  #--------------------------------------------------------------------------
  # * New method: active_direction
  #--------------------------------------------------------------------------
  def active_direction
    units = BattleManager.all_battle_members
    action_direction(units.select {|member| member.poses.active? })
  end
  #--------------------------------------------------------------------------
  # * New method: default_direction
  #--------------------------------------------------------------------------
  def default_direction
    action_direction(@battler.opponents_unit.members)
  end
  #--------------------------------------------------------------------------
  # * New method: targets_direction
  #--------------------------------------------------------------------------
  def targets_direction
    action_direction(BattleManager.targets)
  end
  #--------------------------------------------------------------------------
  # * New method: origin_direction
  #--------------------------------------------------------------------------
  def origin_direction
    target_direction(@battler.screen_x, @battler.screen_y)
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_position
  #--------------------------------------------------------------------------
  def adjust_position(value)
    if isometric?
      x, y =  value, -value * 0.75 if down?
      x, y =  value,  value * 0.75 if left?
      x, y = -value, -value * 0.75 if right?
      x, y = -value,  value * 0.75 if up?
    else
      x, y = 0, -value if down?
      x, y =  value, 0 if left?
      x, y = -value, 0 if right?
      x, y = 0,  value if up?
    end
    @target_position[:x] += x.to_i
    @target_position[:y] += y.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: sharing_position?
  #--------------------------------------------------------------------------
  def sharing_position?
    sharing_list.size > 1 && !move_over
  end
  #--------------------------------------------------------------------------
  # * New method: sharing_list
  #--------------------------------------------------------------------------
  def sharing_list
    BattleManager.all_battle_members.select {|other| position_overlap?(other) }
  end
  #--------------------------------------------------------------------------
  # * New method: position_overlap?(other)
  #--------------------------------------------------------------------------
  def position_overlap?(other)
    x = target_position[:x] - other.poses.target_position[:x]
    y = target_position[:y] - other.poses.target_position[:y]
    x.abs <= 12 && y.abs <= 12
  end
  #--------------------------------------------------------------------------
  # * New method: position_fix
  #--------------------------------------------------------------------------
  def position_fix
    sharing_list.each do |other|
      next if other == @battler || !position_overlap?(other)
      fix_vert(other) if left?  || right? 
      fix_horz(other) if down?  || up? 
    end
  end
  #--------------------------------------------------------------------------
  # * New method:  fix_vert
  #--------------------------------------------------------------------------
  def fix_vert(other)
    adjust = @battler.current_y > other.current_x ? 4 : -4
    @target_position[:y] += adjust
  end
  #--------------------------------------------------------------------------
  # * New method: fix_horz
  #--------------------------------------------------------------------------
  def fix_horz(other)
    adjust = @battler.current_x > other.current_x ? 4 : -4
    @target_position[:x] += adjust
  end
  #--------------------------------------------------------------------------
  # * New method: fix_position
  #--------------------------------------------------------------------------
  def fix_position
    @target_position = @current_position.dup
  end
  #--------------------------------------------------------------------------
  # * New method: sideview?
  #--------------------------------------------------------------------------
  def sideview?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :side
  end
  #--------------------------------------------------------------------------
  # * New method: frontview?
  #--------------------------------------------------------------------------
  def frontview?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :front
  end
  #--------------------------------------------------------------------------
  # * New method: isometric
  #--------------------------------------------------------------------------
  def isometric?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :iso
  end
  #--------------------------------------------------------------------------
  # * New method: target_distance
  #--------------------------------------------------------------------------
  def target_distance(symbol)
    @target_position[symbol] - @current_position[symbol]
  end
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def moving?
    @current_position != @target_position
  end
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def damage_pose?
    pose_list.damage_pose?
  end
  #--------------------------------------------------------------------------
  # * New method: no_pose?
  #--------------------------------------------------------------------------
  def pose?
    timing[:time]
  end
  #--------------------------------------------------------------------------
  # * New method: state_pose?
  #--------------------------------------------------------------------------
  def state_pose?
    state_pose
  end
  #--------------------------------------------------------------------------
  # * New method: state_pose
  #--------------------------------------------------------------------------
  def state_pose
    @battler.states.collect {|state| state.custom_pose("STATE") }.first
  end
  #--------------------------------------------------------------------------
  # * New method: state_pose
  #--------------------------------------------------------------------------
  def cast_pose
    call_active_pose(@battler.cast_action.item)
  end
  #--------------------------------------------------------------------------
  # * New method: activate
  #--------------------------------------------------------------------------
  def activate
    return unless current_action && current_action.item
    @active         = true
    @active_pose    = nil
    @action_targets = make_action_targets
    setup_immortals
  end
  #--------------------------------------------------------------------------
  # * New method: make_action_targets
  #--------------------------------------------------------------------------
  def make_action_targets
    targets = current_action.make_targets.compact.dup
    return targets.sort {|a, b| b.current_x <=> a.current_x } if frontview?
    return targets.sort {|a, b| b.current_y <=> a.current_y }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_immortals
  #--------------------------------------------------------------------------
  def setup_immortals
    @action_targets.each {|target| @immortals.push(target) unless target.dead? }
    @immortals.uniq!
  end
  #--------------------------------------------------------------------------
  # * New method: deactivate
  #--------------------------------------------------------------------------
  def deactivate
    @active      = false
    @attack_flag = nil
    @result_flag = nil
    @next_target = nil
    @call_end    = true
    clear_immortals
    @action_targets.clear
  end
  #--------------------------------------------------------------------------
  # * New method: clear_immortals
  #--------------------------------------------------------------------------
  def clear_immortals
    members   = BattleManager.all_battle_members
    immortals = members.inject([]) {|r, member| r += member.poses.immortals }
    members.each   {|member| member.poses.immortals.clear }
    immortals.each {|member| member.refresh }
  end
  #--------------------------------------------------------------------------
  # * New method: action_pose
  #--------------------------------------------------------------------------
  def action_pose(item)
    @current_item = item
    call_action_poses
  end
  #--------------------------------------------------------------------------
  # * New method: call_action_poses
  #--------------------------------------------------------------------------
  def call_action_poses
    clear_loop
    set_action_pose
    call_pose(:inactive)
    call_custom_pose("RETREAT", :retreat, @current_item)
    call_pose(:clear)
  end
  #--------------------------------------------------------------------------
  # * New method: set_action_pose
  #--------------------------------------------------------------------------
  def set_action_pose
    set_attack_pose
    set_attack_pose(true) if use_double_attack?
    @attack_flag = use_double_attack? ? 1 : nil
  end
  #--------------------------------------------------------------------------
  # * New method: call_attack_pose
  #--------------------------------------------------------------------------
  def set_attack_pose(dual = false)
    item       = @current_item
    @dual_flag = dual
    call_move_pose("ADVANCE", :advance,   dual) if item && need_move?(item)
    call_pose(setup_pose_type(dual), nil, item) if item
    call_pose(:finish, nil)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose_type
  #--------------------------------------------------------------------------
  def setup_pose_type(dual = false)
    pose = setup_basic_pose(dual)
    pose = :defend if item_defend?
    pose = setup_custom_pose(pose)
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: setup_basic_pose
  #--------------------------------------------------------------------------
  def setup_basic_pose(dual)
    pose = weapons_pose("USE",    :use,    dual)
    pose = weapons_pose("ITEM",   :item,   dual) if @current_item.item?
    pose = weapons_pose("MAGIC",  :magic,  dual) if @current_item.magical?
    pose = weapons_pose("SKILL",  :skill,  dual) if @current_item.physical?
    pose = weapons_pose("ATTACK", :attack, dual) if item_attack?
    pose = weapons_pose("DUAL",   :dual_attack)  if use_dual_attack?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def item_attack?
    @battler.item_attack?(@current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def item_defend?
    @battler.item_defend?(@current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def use_double_attack?
    @battler.use_double_attack?(@current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def use_dual_attack?
    @battler.use_dual_attack?(@current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def current_action
    @battler.current_action
  end
  #--------------------------------------------------------------------------
  # * New method: frames
  #--------------------------------------------------------------------------
  def frames
    @battler.character_name[/\[F(\d+)\]/i] ? $1.to_i : 3
  end
  #--------------------------------------------------------------------------
  # * New method: not_in_position?
  #--------------------------------------------------------------------------
  def not_in_position?
    pose_list.first_name == :retreat
  end
  #--------------------------------------------------------------------------
  # * New method: setup_custom_pose
  #--------------------------------------------------------------------------
  def setup_custom_pose(pose)
    item = @current_item
    pose = battler_pose("ACTION", pose, item)
    pose = battler_pose("ITEM"  , pose, item) if item.item?
    pose = battler_pose("MAGIC" , pose, item) if item.magical?
    pose = battler_pose("SKILL" , pose, item) if item.physical?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: weapons_pose
  #--------------------------------------------------------------------------
  def weapons_pose(type, pose, dual = false)
    valid = @battler.actor? ? @battler.weapons + [@battler] : [@battler]
    list  = valid.collect {|item| item.custom_pose(type) }
    list.shift if dual
    list.empty? || !pose_exist?(list.first) ? pose : list.first
  end
  #--------------------------------------------------------------------------
  # * New method: battler_pose
  #--------------------------------------------------------------------------
  def battler_pose(type, pose, item)
    note   = item ? item.note : ""
    custom = item.custom_pose(type)
    custom && pose_exist?(custom, note) ? custom : pose
  end
  #--------------------------------------------------------------------------
  # * New method: pose_exist?
  #--------------------------------------------------------------------------
  def pose_exist?(pose, note = "")
    value  = "ACTION: #{make_string(pose)}(?:(?: *, *[^>]+)+)?"
    regexp = get_all_values(value, "ACTION")
    @battler.get_all_poses(note) =~ regexp
  end
  #--------------------------------------------------------------------------
  # * New method: call_move_pose
  #--------------------------------------------------------------------------
  def call_move_pose(type, pose, dual)
    pose = weapons_pose(type, pose, dual) 
    pose = battler_pose(type, pose, @current_item)
    call_pose(pose, nil, @current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: call_custom_pose
  #--------------------------------------------------------------------------
  def call_custom_pose(type, pose, item)
    pose = battler_pose(type, pose, item)
    call_pose(pose, nil, item)
  end
  #--------------------------------------------------------------------------
  # * New method: need_move?
  #--------------------------------------------------------------------------
  def need_move?(item)
    return false if @battler.unmovable?
    return true  if item.note =~ /<ACTION MOVEMENT>/i
    return true  if item.skill? && item.physical?
    return true  if item.skill? && item.id == @battler.attack_skill_id
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: call_damage_pose
  #--------------------------------------------------------------------------
  def call_damage_pose(item, user)
    call_pose(:hurt,     :clear, item) if @battler.hurt_pose?
    call_pose(:miss,     :clear, item) if @battler.result.missed
    call_pose(:evade,    :clear, item) if @battler.result.evaded
    call_pose(:critical, :clear, item) if @battler.result.critical
    call_subsititution if @substitution
  end
  #--------------------------------------------------------------------------
  # * New method: call_damage_pose
  #--------------------------------------------------------------------------
  def clear_immortal
    @clear_flag = false
    BattleManager.all_battle_members.select do |member| 
      member.poses.immortals.delete(@battler)
      member.poses.action_targets.delete(@battler)
    end
    @battler.refresh
    @battler.result.added_states.delete(1)
  end
  #--------------------------------------------------------------------------
  # * New method: call_subsititution
  #--------------------------------------------------------------------------
  def call_subsititution
    call_pose(:substitution_on, :insert)
    @battler.sprite.update
  end
  #--------------------------------------------------------------------------
  # * New method: set_active_pose
  #--------------------------------------------------------------------------
  def set_active_pose
    return if !current_item && (!current_action || !current_action.item)
    item = current_action ? current_action.item : current_item
    setup_active_pose(item)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_active_pose
  #--------------------------------------------------------------------------
  def setup_active_pose(item)
    @active_pose = call_active_pose(item)
    @battler.reset_pose if @active_pose
  end
  #--------------------------------------------------------------------------
  # * New method: call_active_pose
  #--------------------------------------------------------------------------
  def call_active_pose(item)
    pose = :ready      if @battler.sprite_value(:ready)
    pose = :item_cast  if item.item?     && @battler.sprite_value(:itemcast)
    pose = :magic_cast if item.magical?  && @battler.sprite_value(:magiccast)
    pose = :skill_cast if item.physical? && @battler.sprite_value(:skillcast)
    pose = battler_pose("ITEM CAST", pose, item)  if pose && item.item?
    pose = battler_pose("MAGIC CAST", pose, item) if pose && item.magical?
    pose = battler_pose("SKILL CAST", pose, item) if pose && item.physical?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: setup_counter
  #--------------------------------------------------------------------------
  def setup_counter(target, item)
    return if @counter_target
    target.poses.counter_on = true
    target.poses.countered  = true
    action          = @battler.counter_action
    @current_item   = action
    @action_targets = make_counter_targets(target, action)
    @counter_target = target
    setup_immortals
    @battler.use_item(action)
    call_pose(:prepare_counter)
    call_action_poses
    call_pose(:counter_off)
  end
  #--------------------------------------------------------------------------
  # * New method: make_counter_targets
  #--------------------------------------------------------------------------
  def make_counter_targets(target, item)
    targets = @battler.setup_counter_targets(target, item)
    return targets.sort {|a, b| b.current_x <=> a.current_x } if frontview?
    return targets.sort {|a, b| b.current_y <=> a.current_y }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_reflect
  #--------------------------------------------------------------------------
  def setup_reflect(item)
    @action_targets = [@battler]
    setup_immortals
    @current_item = item
    call_pose(:reflection, :insert, item)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_substitute
  #--------------------------------------------------------------------------
  def setup_substitute(target)
    @action_targets = [target]
    @substitution   = true
    call_pose(:substitution_off, :insert)
  end
  #--------------------------------------------------------------------------
  # * New method: start_shake
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # * New method: update_shake
  #--------------------------------------------------------------------------
  def update_shake
    return unless shaking?
    delta  = (@shake_power * @shake_speed * @shake_direction) / 10.0
    clear  = @shake_duration <= 1 && @shake * (@shake + delta) < 0
    @shake = clear ? 0 : @shake + delta
    @shake_direction = -1 if @shake > @shake_power * 2
    @shake_direction = 1  if @shake < - @shake_power * 2
    @shake_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: update_freeze
  #--------------------------------------------------------------------------
  def update_freeze
    return if @freeze == 0 || !@freeze.numeric?
    @freeze -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: shaking?
  #--------------------------------------------------------------------------
  def shaking?
    @shake_duration > 0 || @shake != 0
  end
  #--------------------------------------------------------------------------
  # * New method: frozen?
  #--------------------------------------------------------------------------
  def frozen?
    (@freeze.numeric? && @freeze > 0) || @freeze == :lock || @battler.unmovable?
  end
  #--------------------------------------------------------------------------
  # * New method: frozen?
  #--------------------------------------------------------------------------
  def action?(layer)
    @pose_list.layer > layer
  end
  #--------------------------------------------------------------------------
  # * New method: setup_subject
  #--------------------------------------------------------------------------
  def setup_subject(subject)
    @immortals      = subject.poses.immortals.dup
    @current_item   = subject.poses.current_item
    @action_targets = subject.poses.action_targets.dup
  end
end

#==============================================================================
# ** Game_PoseValue
#------------------------------------------------------------------------------
#  This class deals with battlers pose values.
#==============================================================================

class Game_PoseValue
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name
  attr_reader   :data
  attr_reader   :layer
  attr_reader   :battler
  attr_reader   :subjects
  attr_reader   :targets
  attr_reader   :active
  attr_reader   :icon_battler
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(name, value, battler, active, layer)
    @name     = make_symbol(name)
    @layer    = layer
    @battler  = battler
    @active   = active
    @subjects = set_subjects(value)
    @data     = {}
    @targets  = []
    setup_pose(value)
  end
  #--------------------------------------------------------------------------
  # * New method: []
  #--------------------------------------------------------------------------
  def [](value)
    @data[value]
  end
  #--------------------------------------------------------------------------
  # * New method: []=
  #--------------------------------------------------------------------------
  def []=(id, value)
    @data[id] = value
  end
  #--------------------------------------------------------------------------
  # * New method: poses
  #--------------------------------------------------------------------------
  def poses
    battler.poses
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose(value)
    case @name
    when :pose       then set_pose(value)
    when :wait       then set_wait(value)
    when :move       then set_move(value)
    when :jump       then set_jump(value)
    when :anim       then set_anim(value)
    when :icon       then set_icon(value)
    when :loop       then set_loop(value)
    when :tone       then set_tone(value)
    when :hide       then set_hide(value)
    when :throw      then set_throw(value)
    when :sound      then set_sound(value)
    when :plane      then set_plane(value)
    when :flash      then set_flash(value)
    when :shake      then set_shake(value)
    when :movie      then set_movie(value)
    when :count      then set_count(value)
    when :clear      then set_clear(value)
    when :state      then set_state(value)
    when :action     then set_action(value)
    when :freeze     then set_freeze(value)
    when :effect     then set_effect(value)
    when :script     then set_script(value)
    when :picture    then set_picture(value)
    when :counter    then set_counter(value)
    when :direction  then set_direction(value)
    when :condition  then set_condition(value)
    when :transform  then set_transform(value)
    when :afterimage then set_afterimage(value)
    when :transition then set_transition(value)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_pose
  #--------------------------------------------------------------------------
  def set_pose(value)
    @data[:row]   = set_row(value)
    @data[:sufix] = set_sufix(value)
    @data[:frame] = value =~ /FRAME (\d+)/i      ? $1.to_i : 1
    @data[:angle] = value =~ /ANGLE ([+-]?\d+)/i ? $1.to_i : 0
    @data[:spin]  = value =~ /SPIN ([+-]?\d+)/i  ? $1.to_i : 0
    @data[:x]     = value =~ /X ([+-]?\d+)/i     ? $1.to_i : 0
    @data[:y]     = value =~ /Y ([+-]?\d+)/i     ? $1.to_i : 0
    @data[:size]  = value =~ /FRAME SIZE (\d+)/i ? $1.to_i : nil
    @data[:pose]  = setl_all_frames(value)
  end
  #--------------------------------------------------------------------------
  # * New method: set_wait
  #--------------------------------------------------------------------------
  def set_wait(value)
    value.scan(/\w+/i) {|result| set_wait_value(result) }
  end
  #--------------------------------------------------------------------------
  # * New method: set_move
  #--------------------------------------------------------------------------
  def set_move(value)
    @data[:value]    = make_symbol($1) if value =~ /(#{movement_words})/i
    @targets         = active_targets if @data[:value] == :move_to
    @targets         = active_targets if @data[:value] == :move_to_front
    @data[:x]        = value =~ /X ([+-]?\d+)/i ? $1.to_i : 0
    @data[:y]        = value =~ /Y ([+-]?\d+)/i ? $1.to_i : 0
    @data[:h]        = value =~ /HEIGHT (\d+)/i ? $1.to_i : 0
    @data[:speed]    = value =~ /SPEED (\d+)/i  ? $1.to_i / 10.0 : 1.0
    @data[:teleport] = true if value =~ /TELEPORT/i
    @data[:reset]    = true if value =~ /RESET/i
    @data[:over]     = true if value =~ /OVER/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_jump
  #--------------------------------------------------------------------------
  def set_jump(value)
    @data[:move]   = true if value =~ /MOVE/i
    @data[:reset]  = true if value =~ /RESET/i
    @data[:height] = value =~ /HEIGHT (\d+)/i ? [$1.to_i, 1].max : nil
    @data[:speed]  = value =~ /SPEED (\d+)/i  ? [$1.to_i, 1].max : 10
  end
  #--------------------------------------------------------------------------
  # * New method: set_clear
  #--------------------------------------------------------------------------
  def set_clear(value)
    @data[:idle]   = true if value =~ /IDLE/i
    @data[:damage] = true if value =~ /DAMAGE/i
    @data[:pose]   = true if value =~ /POSE/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_state
  #--------------------------------------------------------------------------
  def set_state(value)
    @data[:add]    = get_values(value, "ADD").compact
    @data[:remove] = get_values(value, "REMOVE").compact
  end
  #--------------------------------------------------------------------------
  # * New method: set_action
  #--------------------------------------------------------------------------
  def set_action(value)
    value.scan(/(\w[\w ]+)/) { @data[:action] = make_symbol($1) }
  end
  #--------------------------------------------------------------------------
  # * New method: set_freeze
  #--------------------------------------------------------------------------
  def set_freeze(value)
    @data[:duration] = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 1
  end
  #--------------------------------------------------------------------------
  # * New method: set_sound
  #--------------------------------------------------------------------------
  def set_sound(value)
    @data[:name]   = value =~ /NAME #{get_filename}/i ? $1 : ""
    @data[:volume] = value =~ /VOLUME (\d+)/i ? $1.to_i : 100
    @data[:pitch]  = value =~ /PITCH (\d+)/i  ? $1.to_i : 100
  end
  #--------------------------------------------------------------------------
  # * New method: set_hide
  #--------------------------------------------------------------------------
  def set_hide(value)
    @data[:all_battler] = true if value =~ /ALL BATTLERS/i
    @data[:all_enemies] = true if value =~ /ALL ENEMIES/i
    @data[:all_friends] = true if value =~ /ALL FRIENDS/i
    @data[:all_targets] = true if value =~ /ALL TARGETS/i
    @data[:not_targets] = true if value =~ /NOT TARGETS/i
    @data[:exc_user]    = true if value =~ /EXCLUDE USER/i
    @data[:inc_user]    = true if value =~ /INCLUDE USER/i
    @data[:unhide]      = true if value =~ /UNHIDE/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_anim
  #--------------------------------------------------------------------------
  def set_anim(value)
    @data[:anim] = set_anim_id(value)
  end
  #--------------------------------------------------------------------------
  # * New method: set_icon
  #--------------------------------------------------------------------------
  def set_icon(value)
    @targets       = set_subjects(value, ",")
    @data[:index]  = value =~ /INDEX ([+-]?\d+)/i      ? $1.to_i : 0
    @data[:image]  = value =~ /IMAGE #{get_filename}/i ? $1.to_s : nil
    @data[:delete] = true if value =~ /DELETE/i
    @data[:above]  = true if value =~ /ABOVE/i
    return if @data[:delete]
    set_action_icon(value)
    @data[:x]    = value =~ /X ([+-]?\d+)/i     ? $1.to_i : 0
    @data[:y]    = value =~ /Y ([+-]?\d+)/i     ? $1.to_i : 0
    @data[:a]    = value =~ /ANGLE ([+-]?\d+)/i ? $1.to_i : 0
    @data[:o]    = value =~ /OPACITY (\d+)/i    ? $1.to_i : 255
    @data[:spin] = value =~ /SPIN ([+-]\d+)/i   ? $1.to_i : 0
    @data[:fin]  = value =~ /FADE IN (\d+)/i    ? $1.to_i : 0
    @data[:fout] = value =~ /FADE OUT (\d+)/i   ? $1.to_i : 0
    @data[:izm]  = value =~ /INIT ZOOM (\d+)/i  ? $1.to_i / 100.0 : 1.0
    @data[:ezm]  = value =~ /END ZOOM (\d+)/i   ? $1.to_i / 100.0 : 1.0
    @data[:szm]  = value =~ /ZOOM SPD (\d+)/i   ? $1.to_i / 100.0 : 0.1
  end
  #--------------------------------------------------------------------------
  # * New method: set_picture
  #--------------------------------------------------------------------------
  def set_picture(value)
    @data[:id]     = value =~ /ID (\d+)/i ? [$1.to_i, 1].max : 1
    @data[:delete] = true if value =~ /DELETE/i
    return if @data[:delete]
    nm = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    og = value =~ /CENTER/i            ? 1       : 0
    x  = value =~ /POS X ([+-]?\d+)/i  ? $1.to_i : 0
    y  = value =~ /POS Y ([+-]?\d+)/i  ? $1.to_i : 0
    zx = value =~ /ZOOM X ([+-]?\d+)/i ? $1.to_i : 100.0
    zy = value =~ /ZOOM X ([+-]?\d+)/i ? $1.to_i : 100.0
    op = value =~ /OPACITY (\d+)/i     ? $1.to_i : 255
    bt = value =~ /BLEND ([+-]\d+)/i   ? $1.to_i : 0
    dr = value =~ /DURATION (\d+)/i    ? $1.to_i : 0
    @data[:show] = [n, og, x, y, zx, zy, op, bt]  if value =~ /SHOW/i
    @data[:move] = [og, x, y, zx, zy, op, bt, dr] if value =~ /MOVE/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_plane
  #--------------------------------------------------------------------------
  def set_plane(value)
    @data[:delete]   = value =~ /DELETE/i ? true : false
    @data[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 0
    return if @data[:delete]
    name     = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    x        = value =~ /MOVE X ([+-]?\d+)/i    ? $1.to_i : 0
    y        = value =~ /MOVE Y ([+-]?\d+)/i    ? $1.to_i : 0
    z        = value =~ /Z ([+-]?\d+)/i         ? $1.to_i : 500
    zoom_x   = value =~ /ZOOM X (\d+)/i         ? $1.to_i : 100.0
    zoom_y   = value =~ /ZOOM Y (\d+)/i         ? $1.to_i : 100.0
    opacity  = value =~ /OPACITY (\d+)/i        ? $1.to_i : 160
    blend    = value =~ /BLEND (\d+)/i          ? $1.to_i : 0
    duration = @data[:duration]
    @data[:list] = [name, x, y, z, zoom_x, zoom_y, opacity, blend, duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_throw
  #--------------------------------------------------------------------------
  def set_throw(value)
    @targets       = set_subjects(value, ",")
    @data[:image]  = value =~ /IMAGE #{get_filename}/i ? $1.to_s : nil
    set_action_icon(value)
    @data[:revert] = true if value =~ /REVERT/i
    @data[:return] = true if value =~ /RETURN/i
    @data[:anim]   = value =~ /ANIM (\d+)/i        ? $1.to_i : nil
    @data[:init_x] = value =~ /INIT X ([+-]?\d+)/i ? $1.to_i : 0
    @data[:init_y] = value =~ /INIT Y ([+-]?\d+)/i ? $1.to_i : 0
    @data[:end_x]  = value =~ /END X ([+-]?\d+)/i  ? $1.to_i : 0
    @data[:end_y]  = value =~ /END Y ([+-]?\d+)/i  ? $1.to_i : 0
    @data[:arc]    = value =~ /ARC (\d+)/i         ? $1.to_i : 0
    @data[:spin]   = value =~ /SPIN ([+-]\d+)/i    ? $1.to_i : 0
    @data[:fin]    = value =~ /FADE IN (\d+)/i     ? $1.to_i : 0
    @data[:fout]   = value =~ /FADE OUT (\d+)/i    ? $1.to_i : 0
    @data[:a]      = value =~ /ANGLE (\d+)/i       ? $1.to_i : 0
    @data[:o]      = value =~ /OPACITY (\d+)/i     ? $1.to_i : 255
    @data[:speed]  = value =~ /SPEED (\d+)/i       ? $1.to_i / 10.0  : 1.0
    @data[:izm]    = value =~ /INIT ZOOM (\d+)/i   ? $1.to_i / 100.0 : 1.0
    @data[:ezm]    = value =~ /END ZOOM (\d+)/i    ? $1.to_i / 100.0 : 1.0
    @data[:szm]    = value =~ /ZOOM SPD (\d+)/i    ? $1.to_i / 100.0 : 0.1
  end
  #--------------------------------------------------------------------------
  # * New method: set_shake
  #--------------------------------------------------------------------------
  def set_shake(value)
    @data[:screen] = true if value =~ /SCREEN/i
    power    = value =~ /POWER (\d+)/i    ? [$1.to_i, 2].max : 5
    speed    = value =~ /SPEED (\d+)/i    ? [$1.to_i, 2].max : 5
    duration = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 10
    @data[:shake] = [power / 2.0, speed / 2.0, duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_movie
  #--------------------------------------------------------------------------
  def set_movie(value)
    @data[:name] = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    set_tone(value)
  end
  #--------------------------------------------------------------------------
  # * New method: set_tone
  #--------------------------------------------------------------------------
  def set_tone(value)
    r = value =~ /RED ([+-]?\d+)/i   ? $1.to_i : 0
    g = value =~ /GREEN ([+-]?\d+)/i ? $1.to_i : 0
    b = value =~ /BLUE ([+-]?\d+)/i  ? $1.to_i : 0
    a = value =~ /GRAY ([+-]?\d+)/i  ? $1.to_i : 0
    tone = [r, g, b, a]
    tone = [ 255,  255,  255, 0] if value =~ /WHITE/i
    tone = [-255, -255, -255, 0] if value =~ /BLACK/i
    @data[:tone]     = Tone.new(*tone)
    @data[:clear]    = true if value =~ /CLEAR/i
    @data[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 0
    @data[:priority] = :normal
    @data[:priority] = :high if value =~ /HIGH PRIORITY/i
    @data[:priority] = :low  if value =~ /LOW PRIORITY/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_flash
  #--------------------------------------------------------------------------
  def set_flash(value)
    @data[:screen] = true if value =~ /SCREEN/i
    r = value =~ /RED (\d+)/i   ? $1.to_i : 255
    g = value =~ /GREEN (\d+)/i ? $1.to_i : 255
    b = value =~ /BLUE (\d+)/i  ? $1.to_i : 255
    a = value =~ /ALPHA (\d+)/i ? $1.to_i : 160
    duration = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 10
    @data[:flash] = [Color.new(r, g, b, a), duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_loop
  #--------------------------------------------------------------------------
  def set_loop(value)
    @data[:loop_anim] = value =~ /ANIM (\d+)/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_effect
  #--------------------------------------------------------------------------
  def set_effect(value)
    @targets         = set_subjects(value, ",")
    @data[:damage]   = $1.to_i / 100.0  if value =~ /(\d+)%/i
    @data[:weapon]   = [$1.to_i, 1].max if value =~ /WEAPON (\d+)/i
    @data[:no_pose]  = true if value =~ /NO POSE/i
    @data[:clear]    = true if value =~ /CLEAR/i
    @data[:active]   = true if value =~ /ACTIVE/i
    @data[:elements] = get_values(value, "ELEMENTS").compact
  end
  #--------------------------------------------------------------------------
  # * New method: set_condition
  #--------------------------------------------------------------------------
  def set_condition(value)
    @data[:condition] = value =~ /^END/i ? :end : value.dup
  end
  #--------------------------------------------------------------------------
  # * New method: set_script
  #--------------------------------------------------------------------------
  def set_script(value)
    @data[:script]  = value.dup
  end
  #--------------------------------------------------------------------------
  # * New method: set_counter
  #--------------------------------------------------------------------------
  def set_counter(value)
    @data[:counter] = true  if value =~ /ON/i 
    @data[:counter] = false if value =~ /OFF/i 
  end
  #--------------------------------------------------------------------------
  # * New method: set_direction
  #--------------------------------------------------------------------------
  def set_direction(value)
    @targets          = battler.poses.last_targets if value =~ /SUBJECTS/i
    @data[:targets]   = true if value =~ /SUBJECTS/i
    @data[:active]    = true if value =~ /ACTIVE/i
    @data[:return]    = true if value =~ /RETURN/i
    @data[:default]   = true if value =~ /DEFAULT/i
    @data[:direction] = 2 if value =~ /DOWN/i
    @data[:direction] = 4 if value =~ /LEFT/i
    @data[:direction] = 6 if value =~ /RIGHT/i
    @data[:direction] = 8 if value =~ /UP/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_transition
  #--------------------------------------------------------------------------
  def set_transition(value)
    @data[:prepare]  = true if value =~ /PREPARE/i
    @data[:execute]  = true if value =~ /EXECUTE/i
    @data[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 40
    @data[:name]     = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
  end
  #--------------------------------------------------------------------------
  # * New method: set_transform
  #--------------------------------------------------------------------------
  def set_transform(value)
    @data[:id] = $1.to_i if value =~ /ID (\d+)/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_afterimage
  #--------------------------------------------------------------------------
  def set_afterimage(value)
    @data[:off]     = true if value =~ /OFF/i
    @data[:opacity] = value =~ /OPACITY (\d+)/i ? $1.to_i : 200
    @data[:blend]   = value =~ /BLEND (\d+)/i   ? $1.to_i : 0
    @data[:wait]    = value =~ /WAIT (\d+)/i    ? $1.to_i : 2
    @data[:fade]    = value =~ /FADE (\d+)/i   ? $1.to_i : 10
    r = value =~ /RED (\d+)/i   ? $1.to_i : 0
    g = value =~ /GREEN (\d+)/i ? $1.to_i : 0
    b = value =~ /BLUE (\d+)/i  ? $1.to_i : 0
    a = value =~ /ALPHA (\d+)/i ? $1.to_i : 0
    @data[:color] = [r, g, b, a]
  end
  #--------------------------------------------------------------------------
  # * New method: set_subjects
  #--------------------------------------------------------------------------
  def set_subjects(value, code = "^")
    case value
    when /#{code} *USER/i
      [active ? active : battler]
    when /#{code} *ACTIVE/i
      [BattleManager.active ? BattleManager.active : battler]
    when /#{code} *ACTOR ([^>,;]+)/i
      actor = $game_actors[battler.script_processing($1)]
      $game_party.battle_members.include?(actor) ? [actor] : []
    when /#{code} *FRIEND ([^>,;]+)/i
      [$game_party.battle_members[battler.script_processing($1) - 1]].compact
    when /#{code} *ENEMY ([^>,;]+)/i
      [$game_troop.members[battler.script_processing($1) - 1]].compact
    when /#{code} *RANDOM ENEMY/i
      poses.last_targets = [battler.opponents_unit.members.random]
      poses.last_targets
    when /#{code} *RANDOM FRIEND/i
      poses.last_targets = [battler.friends_unit.members.random]
      poses.last_targets
    when /#{code} *ALL ENEMIES/i
      poses.last_targets = battler.opponents_unit.members
      poses.last_targets
    when /#{code} *ALL FRIENDS/i
      poses.last_targets = battler.friends_unit.members
      poses.last_targets
    when /#{code} *TARGETS/i
      poses.last_targets = poses.action_targets.dup
      poses.last_targets
    when /#{code} *LAST/i
      poses.last_targets
    when /#{code} *NEXT/i
      poses.next_target  += 1 if poses.next_target
      poses.next_target ||= 0
      poses.next_target  %=  poses.action_targets.size
      poses.last_targets  = [poses.current_action_targets.first]
      poses.last_targets
    when /#{code} *PREVIOUS/i
      poses.next_target  -= 1 if battler.next_target
      poses.next_target ||= 0
      poses.next_target  %=  poses.action_targets.size
      poses.last_targets  = [poses.current_action_targets.first]
      poses.last_targets
    else
      [battler]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_row
  #--------------------------------------------------------------------------
  def set_row(value)
    pose = battler.sprite_value(make_symbol($1)) if value =~ /ROW (\w+)/i
    pose = :direction if value =~ /ROW DIRECTION/i
    pose = $1.to_i    if value =~ /ROW (\d+)/i
    pose ? pose : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_sufix
  #--------------------------------------------------------------------------
  def set_sufix(value)
    pose = value =~ /SUFIX ([\[\]\w]+)/i ? $1.to_s : ""
    if pose.downcase == "[direction]"
      pose = case poses.direction
      when 2 then "[down]"
      when 4 then "[left]"
      when 6 then "[right]"
      when 8 then "[up]"
      end
    end
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: set_action_icon
  #--------------------------------------------------------------------------
  def set_action_icon(value)
    id = battler.poses.dual_flag ? 2 : 1
    @icon_battler  = battler if value =~ /ACTIVE/i
    @data[:weapon] = id      if value =~ /WEAPON/i
    @data[:weapon] = $1.to_i if value =~ /WEAPON (\d+)/i
    @data[:armor]  = $1.to_i if value =~ /ARMOR (\d+)/i
    @data[:armor]  = 1       if value =~ /SHIELD/i
    @data[:custom] = $1.to_i if value =~ /ICON (\d+)/i
    @data[:action] = true    if value =~ /ACTION/i
  end
  #--------------------------------------------------------------------------
  # * New method: setl_all_frames
  #--------------------------------------------------------------------------
  def setl_all_frames(value)
    if value =~ /(?:\d+|ALL) FRAMES?/i
      w = value =~ /WAIT (\d+)/i ? [$1.to_i, 1].max : 1
      l = value =~ /LOOP/i   ? true : false
      r = value =~ /RETURN/i ? true : false
      v = value =~ /REVERT/i ? true : false
      i = value =~ /INVERT/i ? true : false
      f = battler.set_pose_frames(value) rescue 0
      {wait: w, time: w, frame: f, loop: l, return: r, revert: v, invert: i}
    else
      {invert: value =~ /INVERT/i ? true : false }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_wait_value
  #--------------------------------------------------------------------------
  def set_wait_value(value)
    case value
    when /(\d+)/i
      @data[:time] = $1.to_i
      @data[:wait] = $1.to_i
    when /(#{wait_words})/i
      @data[:time] = 2
      @data[:wait] = make_symbol($1)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_anim_id
  #--------------------------------------------------------------------------
  def set_anim_id(value)
    item = battler.poses.current_item
    case value
    when /CAST/i
      cast = item && $imported[:ve_cast_animation]
      anim = cast ? battler.cast_animation_id(item) : 0
      anim
    when /EFFECT/i
      item ? item.animation_id : 0
    when /ID (\d+)/i
      $1.to_i
    when /WEAPON(?: *(\d+)?)?/i
      dual = battler.poses.dual_flag || ($1 && $1.to_i == 2)
      dual ? battler.atk_animation_id2 : battler.atk_animation_id1
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_values
  #--------------------------------------------------------------------------
  def get_values(value, code)
    regexp = /#{code} *((?:\d+%?|, *\d+%?)+)/i
    value.scan(regexp).inject([]) do |r, obj| 
      r += obj.first.scan(/\d+%?/i).collect {|i| i[/%/i] ? nil : i.to_i}
    end
  end
  #--------------------------------------------------------------------------
  # * New method: wait_words
  #--------------------------------------------------------------------------
  def wait_words
    words  = 'ANIMATION|ACTIVE|ACTION|MOVEMENT|ORIGIN|COUNTERED|COUNTER|'
    words += 'SUBSTITUTION|TONE|THROW|POSE|FREEZE|LOG'
    words
  end
  #--------------------------------------------------------------------------
  # * New method: movement_words
  #--------------------------------------------------------------------------
  def movement_words
    'MOVE TO(?: FRONT)?|STEP (?:FORWARD|BACKWARD)|RETREAT|ESCAPE|SUBSTITUTION'
  end
  #--------------------------------------------------------------------------
  # * New method: active_targets
  #--------------------------------------------------------------------------
  def active_targets
    battler.poses.current_action_targets
  end
end

#==============================================================================
# ** Game_PoseAction
#------------------------------------------------------------------------------
#  This class deals with battlers pose actions.
#==============================================================================

class Game_PoseAction
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name
  attr_reader   :next
  attr_reader   :data
  attr_reader   :layer
  attr_reader   :battler
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(name, last, layer, battler)
    @name    = name
    @next    = last
    @layer   = layer
    @battler = battler
    @data    = []
    @current = []
  end
  #--------------------------------------------------------------------------
  # * New method: []
  #--------------------------------------------------------------------------
  def [](id)
    @data[id]
  end
  #--------------------------------------------------------------------------
  # * New method: []=
  #--------------------------------------------------------------------------
  def []=(id, value)
    @data[id] = value
  end
  #--------------------------------------------------------------------------
  # * New method: push
  #--------------------------------------------------------------------------
  def push(value)
    @data.push(value)
  end
  #--------------------------------------------------------------------------
  # * New method: empty?
  #--------------------------------------------------------------------------
  def empty?
    @data.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: poses
  #--------------------------------------------------------------------------
  def poses
    @battler.poses
  end
  #--------------------------------------------------------------------------
  # * New method: pose_list
  #--------------------------------------------------------------------------
  def pose_list
    @battler.poses.pose_list
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    setup_pose
    update_pose
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose
    return unless @data.first && changed_pose?
    @current = @data.dup
    @pose    = @current.first
  end
  #--------------------------------------------------------------------------
  # * New method: changed_pose?
  #--------------------------------------------------------------------------
  def changed_pose?
    @current.size != @data.size || @current.first.name != @data.first.name
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose
    if @pose && @pose.name.symbol?
      update_current_pose
      next_pose unless waiting?
    else
      next_pose
    end
  end
  #--------------------------------------------------------------------------
  # * New method: next_pose
  #--------------------------------------------------------------------------
  def next_pose
    return unless @data
    case @next
    when :loop
      @data.next_item
    when :wait
      @data.shift if @data.size > 1
    when :reset
      @data.shift
    when Symbol
      @data.shift
      poses.pose_list.setup_pose(layer, false) if @data.empty?
      poses.call_pose(@next, :clear)           if @data.empty?
    else
      last = @data.shift
      poses.pose_list.setup_pose(layer) if !@data.empty?
      @data.unshift(last) if @data.empty? && pose_list[@layer].empty?
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_type
  #--------------------------------------------------------------------------
  def update_current_pose
    @wait = false
    send("update_pose_#{@pose.name}")
  end
  #--------------------------------------------------------------------------
  # * New method: get_subjects
  #--------------------------------------------------------------------------
  def get_subjects
    @pose ? @pose.subjects.compact : [active]
  end
  #--------------------------------------------------------------------------
  # * New method: active
  #--------------------------------------------------------------------------
  def active
    @pose.active ? @pose.active : @battler
  end
  #--------------------------------------------------------------------------
  # * New method: pose_list
  #--------------------------------------------------------------------------
  def pose_list
    poses.pose_list
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_wait
  #--------------------------------------------------------------------------
  def update_pose_wait
    case @pose[:wait]
    when :animation
      @pose[:time] -= 1
      anim  = get_subjects.any? {|subject| subject.sprite.animation? }
      @wait = anim || @pose[:time] > 0
    when :active
      @wait = get_subjects.any? {|subject| subject.poses.active? }
    when :action
      @wait = get_subjects.any? {|subject| subject.poses.action?(@layer) }
    when :movement
      @wait = get_subjects.any? {|subject| subject.poses.moving? }
    when :origin
      @wait = get_subjects.any? {|subject| subject.poses.not_origin? }
    when :counter
      @wait = get_subjects.any? {|subject| subject.poses.counter_on }
    when :countered
      @wait = get_subjects.any? {|subject| subject.poses.countered }
    when :substitution
      @wait = get_subjects.any? {|subject| subject.poses.substitution }
    when :throw
      @wait = get_subjects.any? {|subject| subject.sprite.throwing? }
    when :pose
      @wait = get_subjects.any? {|subject| subject.poses.pose? }
    when :freeze
      @wait = get_subjects.any? {|subject| subject.poses.frozen? }
    when :tone
      @wait = $game_troop.screen.tone_change?
    when :log
      @wait = SceneManager.scene.log_window_wait?
    when Numeric
      @pose[:time] -= 1
      @pose[:time]  = @pose[:wait] if @pose[:time] == 0
      @wait         = @pose[:time] != @pose[:wait]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: waiting?
  #--------------------------------------------------------------------------
  def waiting?
    @wait
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_clear
  #--------------------------------------------------------------------------
  def update_pose_clear
    get_subjects.each do |subject|
      subject.poses.clear_loop   if @pose[:idle]
      subject.poses.clear_damage if @pose[:damage]
      subject.poses.reset = true if @pose[:pose]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_action
  #--------------------------------------------------------------------------
  def update_pose_action
    get_subjects.each do |subject|
      item  = poses.current_item
      layer = subject.poses.pose_list.layer + 1
      subject.poses.clear_loop
      subject.poses.call_pose(@pose[:action], layer, item, @battler) 
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_finish
  #--------------------------------------------------------------------------
  def update_pose_finish
    poses.attack_flag += 1 if poses.attack_flag
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_state
  #--------------------------------------------------------------------------
  def update_pose_state
    get_subjects.each do |subject|
      @pose[:add].each    {|id| subject.add_state(id) }
      @pose[:remove].each {|id| subject.remove_state(id) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_appear
  #--------------------------------------------------------------------------
  def update_pose_appear
    get_subjects.each do |subject|
      next if subject.actor?
      subject.appear
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_transform
  #--------------------------------------------------------------------------
  def update_pose_transform
    get_subjects.each do |subject|
      next if subject.actor? || !@pose[:id]
      subject.transform(@pose[:id])
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_anim
  #--------------------------------------------------------------------------
  def update_pose_anim
    active.poses.anim_targets ||= []
    active.poses.anim_targets += get_subjects.dup
    active.poses.anim_targets.uniq!
    active.poses.call_anim = true
    active.poses.animation = @pose[:anim]
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_effect
  #--------------------------------------------------------------------------
  def update_pose_effect
    battler = get_subjects.include?(active) ? active : get_subjects.first
    battler.poses.call_effect = true if battler
    get_subjects.each do |subject|
      battler.poses.active_effect.push(subject) if battler != subject
      subject.poses.setup_subject(battler)      if battler != subject
      subject.poses.damage_flag  = @pose[:damage]
      subject.poses.attack_flag  = @pose[:weapon] if @pose[:weapon]
      subject.poses.no_hurt_flag = @pose[:no_pose]
      subject.poses.element_flag = @pose[:elements]
      if @pose.targets.empty?
        subject.poses.targets = subject.poses.action_targets
      else
        subject.poses.targets = @pose.targets.dup
      end
      subject.poses.targets.each {|target| target.clear_flag = @pose[:clear] }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_loop
  #--------------------------------------------------------------------------
  def update_pose_loop
    get_subjects.each {|subject| subject.pose_loop = @pose[:loop_anim] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_plane
  #--------------------------------------------------------------------------
  def update_pose_plane
    if @pose[:delete]
      SceneManager.scene.spriteset.delete_plane(@pose[:duration])
    elsif @pose[:list]
      SceneManager.scene.spriteset.action_plane(*@pose[:list])
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_sound
  #--------------------------------------------------------------------------
  def update_pose_sound
    se = RPG::SE.new(@pose[:name], @pose[:volume], @pose[:pitch])
    se.play
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_pose
  #--------------------------------------------------------------------------
  def update_pose_pose
    get_subjects.each do |subject|
      poses = subject.poses
      poses.row    = @pose[:row] - 1          if @pose[:row].numeric?
      poses.row    = poses.direction / 2  - 1 if @pose[:row].symbol?
      poses.sufix  = @pose[:sufix]
      poses.angle  = @pose[:angle]
      poses.spin   = @pose[:spin]
      poses.x_adj  = @pose[:x]
      poses.y_adj  = @pose[:y]
      poses.timing = @pose[:pose]
      poses.f_size = @pose[:size]
      poses.frame  = (@pose[:frame] - 1) % subject.sprite_value(:frames)
      poses.f_init = (@pose[:frame] - 1) % subject.sprite_value(:frames)
      poses.frame  = poses.timing[:frame] if poses.timing[:revert]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_move
  #--------------------------------------------------------------------------
  def update_pose_move
    get_subjects.each do |subject|
      subject.poses.teleport   = @pose[:teleport]
      subject.poses.reset_move = @pose[:reset]
      subject.poses.move_over  = @pose[:over]
      setup_target_position(subject)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_counter
  #--------------------------------------------------------------------------
  def update_pose_counter
    subject = poses.counter_target ? poses.counter_target : @battler
    subject.poses.counter_on = false
    poses.counter_target     = nil
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_substitution
  #--------------------------------------------------------------------------
  def update_pose_substitution
    substitution = @pose[:substitution]
    get_subjects.each {|subject| subject.poses.substitution = substitution }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_jump
  #--------------------------------------------------------------------------
  def update_pose_jump
    get_subjects.each do |subject|
      poses  = subject.poses
      height = @pose[:height] ? @pose[:height] : 5
      if @pose[:move]
        x_plus = (poses.target_distance(:x) / 32.0).abs
        y_plus = (poses.target_distance(:y) / 32.0).abs
        speed = Math.sqrt((x_plus ** 2) + (y_plus ** 2)) / poses.move_speed
        poses.jumping[:speed] = height * 5.0 / [speed, 1].max
      else
        poses.jumping[:speed] = @pose[:speed]
      end
      if @pose[:height]
        poses.jumping[:reset]  = @pose[:reset]
        poses.jumping[:height] = @pose[:height]
        poses.jumping[:count]  = poses.jumping[:height] * 2
      end
    end    
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_inactive
  #--------------------------------------------------------------------------
  def update_pose_inactive
    @battler.poses.deactivate
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_inactive
  #--------------------------------------------------------------------------
  def update_pose_countered
    @battler.poses.countered = false
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_target
  #--------------------------------------------------------------------------
  def update_pose_target
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_direction
  #--------------------------------------------------------------------------
  def update_pose_direction
    get_subjects.each do |subject|
      subject.poses.origin_direction  if @pose[:return]
      subject.poses.active_direction  if @pose[:active]
      subject.poses.default_direction if @pose[:default]
      subject.poses.action_direction(@pose.targets) if @pose[:targets]
      subject.poses.direction = @pose[:direction]   if @pose[:direction]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_condition
  #--------------------------------------------------------------------------
  def update_pose_condition
    return if condition_met || @pose[:condition] == :end
    loop do
      next_pose
      setup_pose
      break if @current.empty? || [@pose && @pose[:condition] == :end]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_script
  #--------------------------------------------------------------------------
  def update_pose_script
    @battler.script_processing(@pose[:script])
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_icon
  #--------------------------------------------------------------------------
  def update_pose_icon
    get_subjects.each do |subject|
      if @pose[:delete]
        subject.poses.icon_list.delete(@pose[:index])
      else
        icon = Game_PoseIcon.new(@pose, subject, subject)
        subject.poses.icon_list[@pose[:index]] = icon
      end
      subject.sprite.update_icon
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_picture
  #--------------------------------------------------------------------------
  def update_pose_picture
    if @pose[:show]
      $game_troop.screen.pictures[@pose[:id]].show(*@pose[:show])
    elsif @pose[:move]
      $game_troop.screen.pictures[@pose[:id]].move(*@pose[:move])
    elsif @pose[:delete]
     $game_troop.screen.pictures[@pose[:id]].erase
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_throw
  #--------------------------------------------------------------------------
  def update_pose_throw
    get_subjects.each do |subject|
      @pose.targets.each do |target|
        icon = Game_PoseIcon.new(@pose.data.dup, target, subject)
        subject.poses.throw_list.push(icon)
      end
      subject.sprite.update_throw
    end   
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_shake
  #--------------------------------------------------------------------------
  def update_pose_shake
    if @pose[:screen]
      $game_troop.screen.start_shake(*@pose[:shake])
    else
      get_subjects.each {|subject| subject.poses.start_shake(*@pose[:shake]) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_flash
  #--------------------------------------------------------------------------
  def update_pose_flash
    if @pose[:screen]
      $game_troop.screen.start_flash(*@pose[:flash])
    else
      get_subjects.each {|subject| subject.sprite.flash(*@pose[:flash]) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_freeze
  #--------------------------------------------------------------------------
  def update_pose_freeze
    get_subjects.each {|subject| subject.poses.freeze = @pose[:duration] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_movie
  #--------------------------------------------------------------------------
  def update_pose_movie
    Graphics.play_movie("Movies/" + @pose[:name]) if @pose[:name] != ""
    update_pose_tone
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_drain
  #--------------------------------------------------------------------------
  def update_pose_drain
    get_subjects.each do |subject|
      subject.drain_setup if subject.hp_drain != 0 || subject.mp_drain != 0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_transition
  #--------------------------------------------------------------------------
  def update_pose_transition
    if @pose[:prepare]
      Graphics.freeze
    elsif @pose[:execute]
      time  = @pose[:duration]
      name  = "Graphics/System/" + @pose[:name]
      value = @pose[:name] == "" ? [time] : [time, name]
      Graphics.transition(*value)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_hide
  #--------------------------------------------------------------------------
  def update_pose_hide
    hidden_list.each {|subject| subject.poses.invisible = !@pose[:unhide] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_tone
  #--------------------------------------------------------------------------
  def update_pose_tone
    send("update_#{@pose[:priority]}_tone")
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_afterimage
  #--------------------------------------------------------------------------
  def update_pose_afterimage
    get_subjects.each do |subject|
      if @pose[:off]
        subject.poses.afterimage = nil
      else
        subject.poses.afterimage = {}
        subject.poses.afterimage[:wait]    = @pose[:wait]
        subject.poses.afterimage[:opacity] = @pose[:opacity]
        subject.poses.afterimage[:color]   = @pose[:color]
        subject.poses.afterimage[:fade]    = @pose[:fade]
        subject.poses.afterimage[:blend]   = @pose[:blend]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: hidden_list
  #--------------------------------------------------------------------------
  def hidden_list
    list = []
    if @pose[:all_battler]
      list += BattleManager.all_battle_members
    elsif @pose[:all_enemies]
      list += @battler.opponents_unit
    elsif @pose[:all_friends]
      list += @battler.friends_unit
    elsif @pose[:all_targets]
      list += @battler.poses.action_targets
    elsif @pose[:not_targets]
      list += BattleManager.all_battle_members - @battler.poses.action_targets
    end
    if @pose[:exc_user]
      list -= [active]
    elsif @pose[:inc_user]
      list += [active]
    end
    list = get_subjects.dup if list.empty?
    list
  end
  #--------------------------------------------------------------------------
  # * New method: update_low_tone
  #--------------------------------------------------------------------------
  def update_low_tone
    screen = $game_troop.screen
    screen.old_low_tone = screen.low_tone.dup unless screen.old_low_tone
    tone = @pose[:clear] ? screen.old_low_tone.dup : @pose[:tone] 
    $game_troop.screen.old_low_tone = nil if @pose[:clear]
    $game_troop.screen.start_low_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: update_normal_tone
  #--------------------------------------------------------------------------
  def update_normal_tone
    screen = $game_troop.screen
    screen.old_tone = screen.tone.dup unless screen.old_tone
    tone = @pose[:clear] ? $game_troop.screen.old_tone.dup : @pose[:tone] 
    $game_troop.screen.old_tone = nil if @pose[:clear]
    $game_troop.screen.start_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: update_high_tone
  #--------------------------------------------------------------------------  
  def update_high_tone
    screen = $game_troop.screen
    screen.old_high_tone = screen.high_tone.dup unless screen.old_high_tone
    tone = @pose[:clear] ? screen.old_high_tone.dup : @pose[:tone] 
    $game_troop.screen.old_high_tone = nil if @pose[:clear]
    $game_troop.screen.start_high_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: condition_met
  #--------------------------------------------------------------------------
  def condition_met
    @pose[:condition].string? && @battler.script_processing(@pose[:condition])
  end
  #--------------------------------------------------------------------------
  # * New method: setup_target_position
  #--------------------------------------------------------------------------
  def setup_target_position(subject)
    return unless @battler.use_sprite?
    if @pose[:value] == :move_to
      setup_move_to_target_position(subject)
    elsif @pose[:value] == :move_to_front
      setup_move_to_front_position(subject)
    elsif @pose[:value] == :step_forward
      setup_step_forward_position(subject)
    elsif @pose[:value] == :step_backward
      setup_step_backward_position(subject)
    elsif @pose[:value] == :escape
      setup_escape_position(subject)
    elsif @pose[:value] == :retreat
      setup_retreat_position(subject)
    elsif @pose[:value] == :substitution
      setup_substitution_position(subject)
    end
    return if waiting?
    subject.poses.position_fix while subject.poses.sharing_position?
    subject.poses.move_over = false
    setup_final_target_position(subject)
    subject.poses.fix_position if subject.unmovable?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_move_to_target_position
  #--------------------------------------------------------------------------
  def setup_move_to_target_position(subject)
    targets = @pose.targets.select {|member| member.use_sprite? }
    return if targets.empty?
    return @wait = true if targets.any? {|member| member.poses.moving? }
    return @wait = true if targets.any? {|member| member.poses.damage_pose? }
    x = targets.collect {|member| member.current_x}.average
    y = targets.collect {|member| member.current_y}.average
    subject.poses.target_position[:x] = x
    subject.poses.target_position[:y] = y
    return if subject.target_current?
    subject.poses.target_direction(x, y)
    subject.poses.adjust_position(32)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_move_to_target_position
  #--------------------------------------------------------------------------
  def setup_move_to_front_position(subject)
    targets = @pose.targets.select {|member| member.use_sprite? }
    return if targets.empty?
    return @wait = true if targets.any? {|member| member.poses.moving?}
    return @wait = true if targets.any? {|member| member.poses.damage_pose? }
    battler = targets.first
    adjustx = battler.poses.right? ? 32 : battler.poses.left? ? -32 : 0
    adjusty = battler.poses.down?  ? 32 : battler.poses.up?   ? -32 : 0
    x = battler.current_x + adjustx
    y = battler.current_y + adjusty
    subject.poses.target_position[:x] = x
    subject.poses.target_position[:y] = y
    return if subject.target_current?
    subject.poses.target_direction(x, y)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_step_forward_position
  #--------------------------------------------------------------------------
  def setup_step_forward_position(subject)
    subject.poses.adjust_position(-48)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_step_backward_position
  #--------------------------------------------------------------------------
  def setup_step_backward_position(subject)
    subject.poses.adjust_position(48)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_escape_position
  #--------------------------------------------------------------------------
  def setup_escape_position(subject)
    subject.poses.adjust_position(320)
    subject.poses.target_direction(subject.target_x, subject.target_y)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_retreat_position
  #--------------------------------------------------------------------------
  def setup_retreat_position(subject)
    return if subject.target_origin? || subject.current_origin?
    x = subject.poses.target_position[:x] = subject.screen_x
    y = subject.poses.target_position[:y] = subject.screen_y
    subject.poses.target_direction(x, y)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_substitution_position
  #--------------------------------------------------------------------------
  def setup_substitution_position(subject)
    battler = subject.poses.action_targets.first
    subject.poses.target_position = battler.poses.current_position.dup
    x = battler.left? ? -16 : battler.right? ? 16 : 0
    y = battler.up?   ? -16 : battler.down?  ? 16 : 1
    subject.poses.target_position[:x] += x
    subject.poses.target_position[:y] += y
  end
  #--------------------------------------------------------------------------
  # * New method: setup_final_target_positio
  #--------------------------------------------------------------------------
  def setup_final_target_position(subject)
    poses = subject.poses
    if subject.left?  || subject.right?
      poses.target_position[:x] += subject.left? ? @pose[:x] : -@pose[:x]
      poses.target_position[:y] += @pose[:y]
    elsif subject.up? || subject.down?
      poses.target_position[:y] += subject.up?   ? @pose[:x] : -@pose[:x]
      poses.target_position[:x] += @pose[:y]
    end
    poses.target_position[:h] += @pose[:h]
    poses.move_speed           = @pose[:speed]
  end
end

#==============================================================================
# ** Game_PoseIcon
#------------------------------------------------------------------------------
#  This class deals with pose icons.
#==============================================================================

class Game_PoseIcon
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :user
  attr_reader   :data
  attr_reader   :icon
  attr_reader   :target
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(data, user, target)
    @user   = user
    @target = target
    @data   = data
    @icon   = setup_pose_icon(user)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose_icon
  #--------------------------------------------------------------------------
  def setup_pose_icon(subject)
    icon = subject.weapon_icon(@data[:weapon]) if @data[:weapon]
    icon = subject.armor_icon(@data[:armor])   if @data[:armor]
    icon = subject.action_icon if @data[:action]
    icon = @data[:custom]      if @data[:custom]
    icon = @data[:image]       if @data[:image]
    icon ? icon : 0
  end
end

#==============================================================================
# ** Game_PoseList
#------------------------------------------------------------------------------
#  This class deals with battlers pose list.
#==============================================================================

class Game_PoseList
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :data
  attr_reader   :pose
  attr_reader   :list
  attr_reader   :name
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    @data    = {}
    @pose    = {}
    @list    = {}
    @name    = {}
  end
  #--------------------------------------------------------------------------
  # * New method: []
  #--------------------------------------------------------------------------
  def [](id)
    @data[id] ||= []
  end
  #--------------------------------------------------------------------------
  # * New method: []=
  #--------------------------------------------------------------------------
  def []=(id, value)
    @data[id] = value
  end
  #--------------------------------------------------------------------------
  # * New method: insert
  #--------------------------------------------------------------------------
  def insert(id, index, value)
    self[id].insert(index, *value)
  end
  #--------------------------------------------------------------------------
  # * New method: shift
  #--------------------------------------------------------------------------
  def shift(id)
    self[id].shift
  end
  #--------------------------------------------------------------------------
  # * New method: delete
  #--------------------------------------------------------------------------
  def delete(value)
    @data.delete(value)
  end
  #--------------------------------------------------------------------------
  # * New method: include?
  #--------------------------------------------------------------------------
  def include?(pose)
    all_names.include?(pose)
  end
  #--------------------------------------------------------------------------
  # * New method: keys
  #--------------------------------------------------------------------------
  def keys
    @data.keys.compact.collect {|key| yield key } if block_given?
  end
  #--------------------------------------------------------------------------
  # * New method: any?
  #--------------------------------------------------------------------------
  def any?
    @data.keys.compact.any? {|key| yield key } if block_given?
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    @data.keys.compact.each do |key|
      setup_pose(key)  if @pose[key] != self[key].first
      update_pose(key) if @pose[key]
      self.delete(key) if self[key].empty? && key != 1
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose(key, update = true)
    @pose[key] = self[key].first
    @name[key] = @pose[key] ? @pose[key].name : nil
    @list[key] = self[key].collect {|value| value.name }
    @battler.poses.icon_list.clear if !inactive_pose?(@name[key])
    @pose[key].update if @pose[key] && update
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose(key)
    @pose[key].update
    return if @pose[key].waiting? || !@pose[key].empty?
    self[key].shift
    self[key].shift if no_retreat?(first_name(key))
    @battler.reset_pose if @pose[key].next == :reset
    @battler.poses.afterimage = nil
  end
  #--------------------------------------------------------------------------
  # * New method: first_name
  #--------------------------------------------------------------------------
  def first_name(key = 1)
    self[key].first ? self[key].first.name : nil
  end
  #--------------------------------------------------------------------------
  # * New method: all_names
  #--------------------------------------------------------------------------
  def all_names
    @data.keys.compact.inject([]) {|r, key| r += get_names(key) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_names
  #--------------------------------------------------------------------------
  def get_names(key)
    self[key].collect {|value| value.name }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_all_poses
  #--------------------------------------------------------------------------
  def setup_all_poses
    @data.keys.compact.reverse.each do |key|
      self[key].first.setup_pose if self[key].first
    end
  end
  #--------------------------------------------------------------------------
  # * New method: layer
  #--------------------------------------------------------------------------
  def layer
    @data.keys.compact.size
  end
  #--------------------------------------------------------------------------
  # * New method: clear_loop
  #--------------------------------------------------------------------------
  def clear_loop
    keys {|key| self[key].delete_if {|pose| pose.next == :loop } }
  end
  #--------------------------------------------------------------------------
  # * New method: clear_damage
  #--------------------------------------------------------------------------
  def clear_damage
    keys {|key| self[key].delete_if {|pose| is_damage_pose?(pose.name)} }
  end
  #--------------------------------------------------------------------------
  # * New method: is_damage_pose?
  #--------------------------------------------------------------------------
  def is_damage_pose?(name)
    name == :hurt || name == :miss || name == :evade || name == :critical
  end
  #--------------------------------------------------------------------------
  # * New method: damage_pose?
  #--------------------------------------------------------------------------
  def damage_pose?
    any? {|key| self[key].first && is_damage_pose?(self[key].first.name) }
  end
  #--------------------------------------------------------------------------
  # * New method: inactive_pose?
  #--------------------------------------------------------------------------
  def inactive_pose?(name)
    name.nil? || name == :inactive || name == :finish || name == :retreat
  end
  #--------------------------------------------------------------------------
  # * New method: no_retreat?
  #--------------------------------------------------------------------------
  def no_retreat?(name)
    name == :retreat && @battler.current_origin?
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :battler
  attr_reader   :battler_name
  #--------------------------------------------------------------------------
  # * Overwrite method: update_bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    setup_bitmap if graphic_changed?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: init_visibility
  #--------------------------------------------------------------------------
  def init_visibility
    @battler_visible = !@battler.hidden?
    self.opacity = 0 unless @battler_visible
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_origin
  #--------------------------------------------------------------------------
  def update_origin
    update_rect if bitmap
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize(viewport, battler = nil)
    initialize_ve_animated_battle(viewport, battler)
    init_variables
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_effect
  #--------------------------------------------------------------------------
  alias :update_effect_ve_animated_battle :update_effect
  def update_effect
    setup_collapse
    update_effect_ve_animated_battle
    update_pose
    update_afterimage
    update_pose_loop if $imported[:ve_loop_animation]
  end
  #--------------------------------------------------------------------------
  # * Alias method: revert_to_normal
  #--------------------------------------------------------------------------
  alias :revert_to_normal_ve_animated_battle :revert_to_normal
  def revert_to_normal
    revert_to_normal_ve_animated_battle
    update_rect if bitmap
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias :setup_new_effect_ve_animated_battle :setup_new_effect
  def setup_new_effect
    if @battler_visible && !@invisible && @battler.poses.invisible
      @invisible = true
      @effect_type = :disappear
      @effect_duration = 12
    elsif @battler_visible && @invisible && !@battler.poses.invisible
      @invisible = false
      @effect_type = :appear
      @effect_duration = 12
    end
    setup_new_effect_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: init_variables
  #--------------------------------------------------------------------------
  def init_variables
    @spin  = 0
    @frame = 0
    @sufix = ""
    @pose_sufix = ""
    @anim_sufix = VE_SPRITE_SUFIX
    @returning    = 0
    @frame_width  = 0
    @frame_height = 0
    @icon_list    = {}
    @throw_list   = []
    @afterimage_wait    = 0
    @afterimage_sprites = []
    start_effect(:appear) if $game_system.intro_fade && !@battler.hidden?
    poses.clear_poses
    setup_positions
  end
  #--------------------------------------------------------------------------
  # * New method: setup_collapse
  #--------------------------------------------------------------------------
  def setup_collapse
    if @battler.dead? && !@dead
      @battler.perform_collapse_effect if !@fast_collapse
      @battler.perform_fast_collapse   if  @fast_collapse
      @fast_collapse = false
      @dead = true
    elsif @dead && !@battler.dead?
      @dead = false
    end
  end
  #--------------------------------------------------------------------------
  # * New method: subject
  #--------------------------------------------------------------------------
  def subject
    @pose_battler ? @pose_battler : @battler
  end
  #--------------------------------------------------------------------------
  # * New method: poses
  #--------------------------------------------------------------------------
  def poses
    @battler.poses
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_value
  #--------------------------------------------------------------------------
  def sprite_value(value)
    @battler.sprite_value(value)
  end
  #--------------------------------------------------------------------------
  # * New method: graphic_changed?
  #--------------------------------------------------------------------------
  def graphic_changed?
    actor_name_change? || battler_name_change? || misc_change?
  end
  #--------------------------------------------------------------------------
  # * New method: actor_name_change?
  #--------------------------------------------------------------------------
  def actor_name_change?
    use_charset? && (@battler_name != @battler.character_name ||
    @battler_index != @battler.character_index ||
    @battler_hue   != @battler.character_hue)
  end
  #--------------------------------------------------------------------------
  # * New method: battler_name_change?
  #--------------------------------------------------------------------------
  def battler_name_change?
    !use_charset? && (@battler_name != @battler.battler_name ||
    @battler_hue  != @battler.battler_hue)
  end
  #--------------------------------------------------------------------------
  # * New method: misc_change?
  #--------------------------------------------------------------------------
  def misc_change?
    (visual_equip? && @visual_items != @battler.visual_items) ||
     @direction != poses.direction || @frame_size != poses.f_size ||
     @sufix != poses.sufix
  end
  #--------------------------------------------------------------------------
  # * New method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    sprite_value(:mode) == :charset
  end
  #--------------------------------------------------------------------------
  # * New method: visual_equip?
  #--------------------------------------------------------------------------
  def visual_equip?
    $imported[:ve_visual_equip]
  end
  #--------------------------------------------------------------------------
  # * New method: collapse?
  #--------------------------------------------------------------------------
  def collapse?
    @effect_type == :collapse || @effect_type == :custom_collapse
  end
  #--------------------------------------------------------------------------
  # * New method: setup_bitmap
  #--------------------------------------------------------------------------
  def setup_bitmap
    if use_charset?
      @battler_name  = @battler.character_name
      @battler_hue   = @battler.character_hue
      @battler_index = @battler.character_index
    else
      @battler_name  = @battler.battler_name
      @battler_hue   = @battler.battler_hue
    end
    @frame_size   = poses.f_size
    @sufix        = poses.sufix
    @direction    = poses.direction
    @visual_items = @battler.visual_items.dup if visual_equip?
    init_bitmap
    init_frame
    init_visibility
  end
  #--------------------------------------------------------------------------
  # * New method: init_bitmap
  #--------------------------------------------------------------------------
  def init_bitmap
    self.bitmap = setup_bitmap_sprite
  end
  #--------------------------------------------------------------------------
  # * New method: setup_bitmap_sprite
  #--------------------------------------------------------------------------
  def setup_bitmap_sprite
    case sprite_value(:mode)
    when :charset
      if visual_equip?
        args = [@battler_name, @battler_hue, @visual_items, sufix]
        Cache.character(*args)
      else
        Cache.character(get_character_name, @battler_hue)
      end
    when :single
      Cache.battler(get_battler_name, @battler_hue)
    when :sprite
      Cache.battler(get_battler_name, @battler_hue)
    else
      Cache.battler(@battler_name, @battler_hue)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: sufix
  #--------------------------------------------------------------------------
  def sufix
    case sprite_value(:mode)
    when :charset then @sufix
    when :sprite  then @anim_sufix + @sufix
    else @sufix
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_battler_name
  #--------------------------------------------------------------------------
  def get_battler_name
    name = @battler_name + sufix
    battler_exist?(name) ? name : @battler_name
  end
  #--------------------------------------------------------------------------
  # * New method: get_character_name
  #--------------------------------------------------------------------------
  def get_character_name
    name = @battler_name + sufix
    character_exist?(name) ? name : @battler_name
  end
  #--------------------------------------------------------------------------
  # * New method: init_frame
  #--------------------------------------------------------------------------
  def init_frame
    @frame_width  = bitmap.width  / frame_number
    @frame_height = bitmap.height / row_number
  end
  #--------------------------------------------------------------------------
  # * New method: frame_number
  #--------------------------------------------------------------------------
  def frame_number
    return poses.frames     if single_char?
    return poses.frames * 4 if multi_char?
    return 1 unless battler_exist?(@battler_name + sufix)
    return poses.f_size     if poses.f_size
    return sprite_value(:frames) if sprite_value(:mode) == :sprite
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: row_number
  #--------------------------------------------------------------------------
  def row_number
    return 4 if single_char?
    return 8 if multi_char?
    return 1 unless battler_exist?(@battler_name + sufix)
    return sprite_value(:rows) if sprite_value(:mode) == :sprite
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: single_char?
  #--------------------------------------------------------------------------
  def single_char?
    use_charset? && (single_normal? && !visual_equip?)
  end
  #--------------------------------------------------------------------------
  # * New method: multi_char?
  #--------------------------------------------------------------------------
  def multi_char?
    use_charset? && (multi_normal? || visual_equip?)
  end
  #--------------------------------------------------------------------------
  # * New method: single_normal?
  #--------------------------------------------------------------------------
  def single_normal?
    !visual_equip? && @battler_name[/^[!]?[$]./]
  end
  #--------------------------------------------------------------------------
  # * New method: multi_normal?
  #--------------------------------------------------------------------------
  def multi_normal?
    !visual_equip? && !@battler_name[/^[!]?[$]./]
  end
  #--------------------------------------------------------------------------
  # * New method: get_sign
  #--------------------------------------------------------------------------
  def get_sign
    @visual_items.any? {|part| !part[:name][/^[!]?[$]./] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_rect
  #--------------------------------------------------------------------------
  def update_rect
    setup_frame2
    setup_rect
    self.ox = @frame_width / 2
    self.oy = @frame_height
    self.mirror = pose_mirror
    reset_frame if poses.reset
  end
  #--------------------------------------------------------------------------
  # * New method: pose_mirror
  #--------------------------------------------------------------------------
  def pose_mirror
    mirror = sprite_value(:invert)
    mirror = !mirror if timing && timing[:invert]
    mirror = !mirror if right? && sprite_value(:mirror)
    mirror
  end
  #--------------------------------------------------------------------------
  # * New method: down?
  #--------------------------------------------------------------------------
  def down?
    poses.down?
  end
  #--------------------------------------------------------------------------
  # * New method: left?
  #--------------------------------------------------------------------------
  def left?
    poses.left?
  end
  #--------------------------------------------------------------------------
  # * New method: right?
  #--------------------------------------------------------------------------
  def right?
    poses.right?
  end
  #--------------------------------------------------------------------------
  # * New method: up?
  #--------------------------------------------------------------------------
  def up?
    poses.up?
  end
  #--------------------------------------------------------------------------
  # * New method: timing
  #--------------------------------------------------------------------------
  def timing
    poses.timing
  end
  #--------------------------------------------------------------------------
  # * New method: setup_frame
  #--------------------------------------------------------------------------
  def setup_frame2
    return if !poses.pose?
    timing[:time] -= 1
    timing[:time]  = timing[:wait] if timing[:time] == 0
    return if timing[:time] != timing[:wait]
    return if poses.reset
    update_frame
  end
  #--------------------------------------------------------------------------
  # * New method: update_frame
  #--------------------------------------------------------------------------
  def update_frame
    @max_frame = timing[:frame]
    @min_frame = poses.f_init
    update_frame_return if  timing[:return] && !timing[:revert]
    update_frame_revert if !timing[:return] &&  timing[:revert]
    update_frame_normal if !timing[:return] && !timing[:revert]
    poses.frame = [@frame, sprite_value(:frames) - 1].min
  end
  #--------------------------------------------------------------------------
  # * New method: update_frame_return
  #--------------------------------------------------------------------------
  def update_frame_return
    @returning += 1
    @frame = returning_value(@returning, @max_frame)
    poses.reset = true if !timing[:loop] && @returning > @max_frame * 2 - 1
  end
  #--------------------------------------------------------------------------
  # * New method: update_frame_revert
  #--------------------------------------------------------------------------
  def update_frame_revert
    @frame -= 1 
    @frame  = @max_frame if @frame < @min_frame
    poses.reset = true   if !timing[:loop] && @frame < @min_frame
  end
  #--------------------------------------------------------------------------
  # * New method: update_frame_normal
  #--------------------------------------------------------------------------
  def update_frame_normal
    @frame += 1
    @frame  = @min_frame if @frame < @min_frame || @frame > @max_frame + 1
    poses.reset = true   if !timing[:loop] && @frame > @max_frame
  end
  #--------------------------------------------------------------------------
  # * New method: reset_frame
  #--------------------------------------------------------------------------
  def reset_frame
    invert       = timing[:invert]
    poses.timing = {invert: invert}
    poses.reset  = false
    @returning   = 0
    @frame       = 0
    @spin        = 0
  end
  #--------------------------------------------------------------------------
  # * New method: setup_rect
  #--------------------------------------------------------------------------
  def setup_rect
    sign = @battler_name[/^[$]./]
    if use_charset? && !sign
      index = @battler_index
      frame = (index % 4 * poses.frames + poses.frame) * @frame_width
      row   = (index / 4 * 4 + poses.row) * @frame_height
    else
      frame = [[poses.frame, 0].max, frame_number - 1].min * @frame_width
      row   = [[poses.row,   0].max,   row_number - 1].min * @frame_height
    end
    self.src_rect.set(frame, row, @frame_width, @frame_height)
  end  
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose
    poses.pose_list.update
  end
  #--------------------------------------------------------------------------
  # * New method: reset_pose
  #--------------------------------------------------------------------------
  def reset_pose
    next_pose = get_idle_pose
    return if next_pose == poses.pose_list.name
    reset_frame
    poses.clear_loop
    poses.call_pose(next_pose)
    poses.pose_list.setup_all_poses
  end
  #--------------------------------------------------------------------------
  # * New method: get_idle_pose
  #--------------------------------------------------------------------------
  def get_idle_pose
    value = :idle
    value = :danger if @battler.danger?
    value = :guard  if @battler.guard?
    value = poses.state_pose  if poses.state_pose?
    value = poses.active_pose if poses.active_pose
    value = poses.cast_pose   if cast_pose?
    value = :escaping if escaping? && @battler.actor?
    value = :dead     if @battler.dead?
    value
  end
  #--------------------------------------------------------------------------
  # * New method: cast_pose?
  #--------------------------------------------------------------------------
  def cast_pose?
    $imported[:ve_active_time_battle] && @battler.cast_action &&
    @battler.cast_action.item
  end
  #--------------------------------------------------------------------------
  # * New method: escaping?
  #--------------------------------------------------------------------------
  def escaping?
    $imported[:ve_active_time_battle] && BattleManager.escaping? &&
    VE_ATB_ESCAPING_ANIM
  end
  #--------------------------------------------------------------------------
  # * New method: setup_positions
  #--------------------------------------------------------------------------
  def setup_positions
    positions   = {x: @battler.screen_x, y: @battler.screen_y, h: 0, j: 0}
    poses.target_position  = positions.dup
    poses.current_position = positions.dup
    poses.jumping   = {count: 0, height: 0, speed: 10}
    @fast_collapse = true if @battler.dead? && @battler.collapse_type != 3
    reset_pose
  end
  #--------------------------------------------------------------------------
  # * New method: position
  #--------------------------------------------------------------------------
  def position
    poses.current_position
  end
  #--------------------------------------------------------------------------
  # * New method: update_position
  #--------------------------------------------------------------------------
  def update_position
    update_misc
    update_movement
    update_jumping
    self.x  = position[:x] + adjust_x
    self.y  = position[:y] + adjust_y
    self.z  = [[self.y / (Graphics.height / 100.0), 1].max, 100].min
    self.ox = @frame_width / 2
    self.oy = @frame_height + position[:h] + position[:j] 
    @spin += 1 if Graphics.frame_count % 2 == 0
    self.angle = poses.angle + poses.spin * @spin
    update_ajust
    update_icon
    update_throw
  end
  #--------------------------------------------------------------------------
  # * New method: update_movement
  #--------------------------------------------------------------------------
  def update_ajust
    angle_move(:x, sprite_value(:ox)) if sprite_value(:ox)
    angle_move(:y, sprite_value(:oy)) if sprite_value(:oy)
  end
  #--------------------------------------------------------------------------
  # * New method: angle_move
  #--------------------------------------------------------------------------
  def angle_move(axis, amount)
    a = (360 - angle) * Math::PI / 180
    cos = Math.cos(a)
    sin = Math.sin(a)
    self.ox += (axis == :x ? -cos : -sin) * amount
    self.oy += (axis == :x ?  sin : -cos) * amount
  end
  #--------------------------------------------------------------------------
  # * New method: update_misc
  #--------------------------------------------------------------------------
  def update_misc
    poses.update_shake
    poses.update_freeze
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_x
  #--------------------------------------------------------------------------
  def adjust_x
    poses.x_adj + [1, -1].random * rand(poses.shake + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_y
  #--------------------------------------------------------------------------
  def adjust_y
    poses.y_adj + [1, -1].random * rand(poses.shake + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    return if poses.frozen? || !poses.moving?
    poses.teleport ? update_teleport_movement : update_normal_movement
  end
  #--------------------------------------------------------------------------
  # * New method: update_teleport_movement
  #--------------------------------------------------------------------------
  def update_teleport_movement
    poses.current_position[:x] = poses.target_position[:x]
    poses.current_position[:y] = poses.target_position[:y]
    poses.current_position[:h] = [poses.target_position[:h], 0].max
    poses.teleport = false
  end
  #--------------------------------------------------------------------------
  # * New method: update_afterimage
  #--------------------------------------------------------------------------  
  def update_afterimage
    update_afterimage_sprites
    setup_afterimage_sprites if poses.afterimage && @afterimage_wait <= 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_afterimage_sprites
  #--------------------------------------------------------------------------  
  def update_afterimage_sprites
    @afterimage_wait -= 1 if @afterimage_wait > 0
    @afterimage_sprites.each do |sprite| 
      sprite.update
      next if sprite.opacity > 0
      sprite.dispose
      @afterimage_sprites.delete(sprite)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_afterimage_sprites
  #--------------------------------------------------------------------------  
  def setup_afterimage_sprites
    @afterimage_sprites.push(Sprite_AfterImage.new(self))
    @afterimage_wait = poses.afterimage[:wait]
  end
  #--------------------------------------------------------------------------
  # * New method: update_normal_movement
  #--------------------------------------------------------------------------
  def update_normal_movement
    distance = set_distance
    move     = {x: 1.0, y: 1.0, h: 1.0}
    if distance[:x].abs < distance[:y].abs
      move[:x] = 1.0 / (distance[:y].abs.to_f / distance[:x].abs)
    elsif distance[:y].abs < distance[:x].abs
      move[:y] = 1.0 / (distance[:x].abs.to_f / distance[:y].abs)
    elsif distance[:h].abs < distance[:x].abs
      move[:h] = 1.0 / (distance[:x].abs.to_f / distance[:h].abs)
    end
    speed = set_speed(distance)
    x = move[:x] * speed[:x]
    y = move[:y] * speed[:y]
    h = move[:h] * speed[:h]
    set_movement(x, y, h)
  end
  #--------------------------------------------------------------------------
  # * New method: set_distance
  #--------------------------------------------------------------------------
  def set_distance
    x = poses.target_distance(:x)
    y = poses.target_distance(:y)
    h = poses.target_distance(:h)
    {x: x, y: y, h: h}
  end
  #--------------------------------------------------------------------------
  # * New method: set_speed
  #--------------------------------------------------------------------------
  def set_speed(distance)
    move_speed = poses.move_speed
    x = move_speed * (distance[:x] == 0 ? 0 : (distance[:x] > 0 ? 8 : -8))
    y = move_speed * (distance[:y] == 0 ? 0 : (distance[:y] > 0 ? 8 : -8))
    h = move_speed * (distance[:h] == 0 ? 0 : (distance[:h] > 0 ? 8 : -8))
    {x: x, y: y, h: h}
  end
  #--------------------------------------------------------------------------
  # * New method: set_movement
  #--------------------------------------------------------------------------
  def set_movement(x, y, h)
    target  = poses.target_position
    current = poses.current_position
    current[:x] += x
    current[:y] += y
    current[:h] += h
    current[:x] = target[:x] if in_distance?(current[:x], target[:x], x)
    current[:y] = target[:y] if in_distance?(current[:y], target[:y], y)
    current[:h] = target[:h] if in_distance?(current[:h], target[:h], h)
    reset_move if poses.reset_move && !poses.moving?
  end
  #--------------------------------------------------------------------------
  # * New method: reset_move
  #--------------------------------------------------------------------------
  def reset_move
    poses.reset_move = nil
    poses.call_pose(:reset, :clear)
    poses.targets_direction
  end
  #--------------------------------------------------------------------------
  # * New method: in_distance?
  #--------------------------------------------------------------------------
  def in_distance?(x, y, z)
    x.between?(y - z - 1, y + z + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_jumping
  #--------------------------------------------------------------------------
  def update_jumping
    return if poses.jumping[:count] == 0 || poses.frozen?
    jump = poses.jumping
    jump[:count] = [jump[:count] - (1 * jump[:speed] / 10.0), 0].max.to_f
    count  = jump[:count]
    speed  = jump[:speed]
    peak   = jump[:height]
    result = (peak ** 2 - (count - peak).abs ** 2) / 2
    poses.current_position[:j] = [result, 0].max
    if poses.current_position[:j] == 0
      jump[:count] = 0
      reset_move if jump[:reset]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_icon
  #--------------------------------------------------------------------------
  def update_icon
    poses.icon_list.each do |key, value|
      @icon_list[key] = Sprite_Icon.new(value) unless @icon_list[key]
      @icon_list[key].refresh(value) if @icon_list[key].changed_icon?(value)
    end
    @icon_list.each do |key, value|
      value.update
      delete_icon(key) if value && !poses.icon_list[key]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_throw
  #--------------------------------------------------------------------------
  def update_throw
    poses.throw_list.each do |value|
      @throw_list.push(Sprite_Throw.new(value))
      poses.throw_list.delete(value)
    end
    @throw_list.each_with_index do |value, index|
      value.update
      delete_throw(index) if value.disposing?
    end
    @throw_list.compact!
  end
  #--------------------------------------------------------------------------
  # * New method: delete_icon
  #--------------------------------------------------------------------------
  def delete_icon(key)
    @icon_list[key].dispose
    @icon_list.delete(key)
  end
  #--------------------------------------------------------------------------
  # * New method: delete_throw
  #--------------------------------------------------------------------------
  def delete_throw(index)
    @throw_list[index].dispose
    @throw_list.delete_at(index)
  end
  #--------------------------------------------------------------------------
  # * New method: throwing?
  #--------------------------------------------------------------------------
  def throwing?
    @throw_list.any? {|value| value.target == @battler }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_loop
  #--------------------------------------------------------------------------
  def update_pose_loop
    if poses.pose_loop && !loop_anim?(:pose_anim)
      @pose_name = poses.pose_name
      animation  = {type: :pose_anim, anim: poses.pose_loop, loop: 1}     
      add_loop_animation(animation)
    end
    if poses.pose_loop && loop_anim?(:pose_anim) && 
       @pose_name_list != poses.pose_name.first
      @pose_loop = nil
      poses.pose_loop = nil
      end_loop_anim(:pose_anim)
    end
  end
end

#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Overwrite method: create_actors
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = $game_party.battle_members.reverse.collect do |actor|
      Sprite_Battler.new(@viewport1, actor)
    end
    @actors_party = $game_party.battle_members.dup
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_actors
  #--------------------------------------------------------------------------
  def update_actors
    update_party if $game_party.battle_members != @actors_party
    @actor_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    init_action_plane
    initialize_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_animated_battle :update
  def update
    update_ve_animated_battle
    update_action_plane
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_animated_battle :dispose
  def dispose
    dispose_ve_animated_battle
    dispose_action_plane
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_pictures
  #--------------------------------------------------------------------------
  alias :create_pictures_ve_animated_battle :create_pictures
  def create_pictures
    battler_sprites.each {|battler| battler.setup_positions }
    create_pictures_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_viewports
  #--------------------------------------------------------------------------
  alias :create_viewports_ve_animated_battle :create_viewports
  def create_viewports
    create_viewports_ve_animated_battle
    @viewport4   = Viewport.new
    @viewport4.z = 200
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_viewports
  #--------------------------------------------------------------------------
  alias :update_viewports_ve_animated_battle :update_viewports
  def update_viewports
    update_viewports_ve_animated_battle
    @viewport1.ox = [1, -1].random * rand($game_troop.screen.shake)
    @viewport1.oy = [1, -1].random * rand($game_troop.screen.shake)
    @back1_sprite.tone.set($game_troop.screen.low_tone) if @back1_sprite
    @back2_sprite.tone.set($game_troop.screen.low_tone) if @back2_sprite
    @viewport4.tone.set($game_troop.screen.high_tone)
  end
  #--------------------------------------------------------------------------
  # * New method: update_party
  #--------------------------------------------------------------------------
  def update_party
    @actor_sprites.each_index do |i|
      next if $game_party.battle_members.include?(@actor_sprites[i].battler)
      @actor_sprites[i].dispose
      @actor_sprites[i] = nil
    end
    $game_party.battle_members.collect do |actor|
      next if @actors_party.include?(actor)
      @actor_sprites.push(Sprite_Battler.new(@viewport1, actor))
    end
    @actor_sprites.compact!
    @actors_party = $game_party.battle_members.dup
  end
  #--------------------------------------------------------------------------
  # * New method: collapse?
  #--------------------------------------------------------------------------
  def collapse?
    battler_sprites.compact.any? {|sprite| sprite.collapse? }
  end
  #--------------------------------------------------------------------------
  # * New method: init_action_plane
  #--------------------------------------------------------------------------
  def init_action_plane
    @action_plane = Plane_ActionPlane.new(@viewport1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_action_plane
  #--------------------------------------------------------------------------
  def update_action_plane
    @action_plane.update
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_action_plane
  #--------------------------------------------------------------------------
  def dispose_action_plane
    @action_plane.dispose
  end
  #--------------------------------------------------------------------------
  # * New method: action_plane
  #--------------------------------------------------------------------------
  def action_plane(name, x, y, z, zx, zy, opacity, blend, duration)
    @action_plane.setup(name, x, y, z, zx, zy, opacity, blend, duration)
  end
  #--------------------------------------------------------------------------
  # * New method: delete_plane
  #--------------------------------------------------------------------------
  def delete_plane(duration)
    @action_plane.delete(duration)
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: wait_and_clear
  #--------------------------------------------------------------------------
  def wait_and_clear
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: wait
  #--------------------------------------------------------------------------
  def wait
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: back_to
  #--------------------------------------------------------------------------
  def back_to(line_number)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: back_one
  #--------------------------------------------------------------------------
  def back_one
    return unless last_text.empty?
    @lines.pop
    refresh
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: display_added_states
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      next if state_msg.empty?
      replace_text(target.name + state_msg)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: wait_and_clear
  #--------------------------------------------------------------------------
  alias :add_text_ve_animated_battle :add_text
  def add_text(text)
    skip_second_line while @lines.size > max_line_number
    add_text_ve_animated_battle(text)
  end
  #--------------------------------------------------------------------------
  # * New method: skip_second_line
  #--------------------------------------------------------------------------
  def skip_second_line
    first_line = @lines.shift
    @lines.shift
    @lines.unshift(first_line)
  end
  #--------------------------------------------------------------------------
  # * New method: wait_message_end
  #--------------------------------------------------------------------------
  def wait_message_end
    @method_wait.call(message_speed) if @method_wait && line_number > 0
    clear
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Overwrite method: abs_wait_short
  #--------------------------------------------------------------------------
  def abs_wait_short
    update_for_wait
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: apply_item_effects
  #--------------------------------------------------------------------------
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: execute_action
  #--------------------------------------------------------------------------
  def execute_action
    @subject.poses.activate
    use_item
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: use_item
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.poses.action_pose(item)
    @subject.use_item(item)
    refresh_status
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: show_animation
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id)
    if animation_id < 0
      show_animated_battle_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: invoke_counter_attack
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    if target == @subject || target.poses.counter_on
      return if retaliation_counter?(target, item)
      target.counter = false if $imported[:ve_damage_pop]
      apply_item_effects(apply_substitute(target, item), item)
      return
    end
    target.poses.setup_counter(@subject, item)
    @counter_flag.push(target)
  end
  #--------------------------------------------------------------------------
  # * New method: retaliation_counter?(target, item)
  #--------------------------------------------------------------------------
  def retaliation_counter?(target, item)
    $imported[:ve_retaliation_damage] && damage_on_counter?(target, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    if target == @subject
      target.reflect = false if $imported[:ve_damage_pop]
      apply_item_effects(apply_substitute(target, item), item)
      return
    end
    @subject.poses.setup_reflect(item)
    @reflect_flag.push(target)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: apply_substitute
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    if check_substitute(target, item)
      substitute = target.friends_unit.substitute_battler
      if substitute && target != substitute
        @substitution = {target: target, substitute: substitute}
        substitute.poses.setup_substitute(target)
        return substitute
      end
    end
    target
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_spriteset
  #--------------------------------------------------------------------------
  alias :create_spriteset_ve_animated_battle :create_spriteset
  def create_spriteset
    create_spriteset_ve_animated_battle
    setup_spriteset
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_basic
  #--------------------------------------------------------------------------
  alias :update_basic_ve_animated_battle :update_basic
  def update_basic
    update_basic_ve_animated_battle
    update_sprite_action
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_action
  #--------------------------------------------------------------------------
  alias :process_action_ve_animated_battle :process_action
  def process_action
    return if active?
    process_action_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: turn_end
  #--------------------------------------------------------------------------
  alias :turn_end_ve_animated_battle :turn_end
  def turn_end
    turn_end_ve_animated_battle
    @spriteset.battler_sprites.each {|sprite| sprite.reset_pose }
  end
  #--------------------------------------------------------------------------
  # * Alias method: next_command
  #--------------------------------------------------------------------------
  alias :next_command_ve_animated_battle :next_command
  def next_command
    previous =  BattleManager.actor
    BattleManager.actor.input_pose   if BattleManager.actor
    next_command_ve_animated_battle
    previous.poses.set_active_pose   if previous 
    BattleManager.actor.command_pose if BattleManager.actor
  end
  #--------------------------------------------------------------------------
  # * Alias method: prior_command
  #--------------------------------------------------------------------------
  alias :prior_command_ve_animated_battle :prior_command
  def prior_command
    BattleManager.actor.cancel_pose  if BattleManager.actor
    prior_command_ve_animated_battle
    BattleManager.clear_active_pose
    BattleManager.actor.command_pose if BattleManager.actor
  end
  #--------------------------------------------------------------------------
  # * New method: close_window
  #--------------------------------------------------------------------------
  def close_window
    abs_wait(10)
    update_for_wait while @message_window.openness > 0
    $game_message.clear
  end
  #--------------------------------------------------------------------------
  # * New method: setup_spriteset
  #--------------------------------------------------------------------------
  def setup_spriteset
    all_battle_members.each {|member| member.poses.default_direction }
    BattleManager.all_movable_members.each do |member| 
      next if $game_system.no_intro || !member.intro_pose?
      member.poses.call_pose(:intro, :clear)
    end
    2.times { @spriteset.update }
  end
  #--------------------------------------------------------------------------
  # * New method: log_window_wait?
  #--------------------------------------------------------------------------
  def log_window_wait?
    @log_window.line_number > 0
  end
  #--------------------------------------------------------------------------
  # * New method: log_window_clear
  #--------------------------------------------------------------------------
  def log_window_clear
    @log_window.clear
  end
  #--------------------------------------------------------------------------
  # * New method: show_animated_battle_attack_animation
  #--------------------------------------------------------------------------
  def show_animated_battle_attack_animation(targets)
    if @subject.actor? || $imported[:ve_actor_battlers]
      show_normal_animation(targets, @subject.atk_animation_id1, false)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  #--------------------------------------------------------------------------
  # * New method: next_subject?
  #--------------------------------------------------------------------------
  def next_subject?
    !@subject || !@subject.current_action
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?
    all_battle_members.any? {|member| member.poses.active? }
  end
  #--------------------------------------------------------------------------
  # * New method: active
  #--------------------------------------------------------------------------
  def active
    all_battle_members.select {|member| member.poses.active? }.first
  end
  #--------------------------------------------------------------------------
  # * New method: update_sprite_action
  #--------------------------------------------------------------------------
  def update_sprite_action
    @old_subject = @subject
    all_battle_members.each do |subject|
      @subject = subject
      call_animation if @subject.poses.call_anim
      call_effect    if @subject.poses.call_effect
      call_end       if @subject.poses.call_end
    end
    @subject = @old_subject
  end
  #--------------------------------------------------------------------------
  # * New method: call_animation
  #--------------------------------------------------------------------------
  def call_animation
    @subject.poses.call_anim = false
    animation = @subject.poses.animation
    targets   = @subject.poses.anim_targets.dup
    @subject.poses.animation = 0
    @subject.poses.anim_targets.clear
    show_animation(targets, animation)
  end
  #--------------------------------------------------------------------------
  # * New method: call_effect
  #--------------------------------------------------------------------------
  def call_effect
    @counter_flag = []
    @reflect_flag = []
    @substitution = nil
    @subject.poses.call_effect = false
    targets = @subject.poses.targets.dup
    item    = @subject.poses.current_item
    @subject.poses.targets.clear
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    @counter_flag.each {|target| @log_window.display_counter(target, item) }
    @reflect_flag.each {|target| @log_window.display_reflection(target, item) }
    if @substitution
      substitute = @substitution[:substitute]
      target     = @substitution[:target]
      @log_window.display_substitute(substitute, target) 
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_end
  #--------------------------------------------------------------------------
  def call_end
    @subject.poses.call_end = false
    process_action_end if @subject.alive? && @old_subject == @subject
    @log_window.wait_message_end
  end
end

#==============================================================================
# ** Sprite_AfterImag
#------------------------------------------------------------------------------
#  This sprite is used to display battlers afterimages.
#==============================================================================

class Sprite_AfterImage < Sprite_Battler
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(sprite)
    info = sprite.battler.poses.afterimage
    @afterimage_opacity  = [info[:opacity], sprite.opacity].min
    @afterimage_fade     = info[:fade]
    @afterimage_color    = info[:color]
    @afterimage_blend    = info[:blend]
    @original_battler    = sprite.battler
    @battler_icons       = @original_battler.poses.icon_list.dup
    @poses               = @original_battler.poses.clone
    super(sprite.viewport, @original_battler.dup)
    update_icon
  end
  #--------------------------------------------------------------------------
  # * New method: poses
  #--------------------------------------------------------------------------
  def poses
    @poses 
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    super
    self.color.set(*@afterimage_color)
    self.blend_type      = @afterimage_blend
    self.opacity         = @afterimage_opacity
    @afterimage_opacity -= @afterimage_fade
    update_icon
  end
  #--------------------------------------------------------------------------
  # * New method: init_bitmap
  #--------------------------------------------------------------------------
  def init_bitmap
    self.bitmap = setup_bitmap_sprite.clone
  end
  #--------------------------------------------------------------------------
  # * New method: setup_positions
  #--------------------------------------------------------------------------
  def setup_positions
    poses.current_position       = @original_battler.poses.current_position.dup
    poses.target_position        = poses.current_position 
    @sufix     = poses.sufix     = @original_battler.poses.sufix
    @frame     = poses.frame     = @original_battler.poses.frame
    @direction = poses.direction = @original_battler.poses.direction
    poses.jumping = {count: 0, height: 0, speed: 10}
  end
  #--------------------------------------------------------------------------
  # * New method: update_icon
  #--------------------------------------------------------------------------
  def update_icon
    @battler_icons.each do |key, value|
      @icon_list[key] = Sprite_Icon.new(value) unless @icon_list[key]
      @icon_list[key].refresh(value) if @icon_list[key].changed_icon?(value)
    end
    @icon_list.each do |key, value|
      value.update
      value.opacity    = self.opacity
      value.blend_type = self.blend_type
      value.color.set(*@afterimage_color)
      delete_icon(key) if value && !@battler_icons[key]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose
  end
  #--------------------------------------------------------------------------
  # * New method: update_afterimage
  #--------------------------------------------------------------------------
  def update_afterimage
  end
end

#==============================================================================
# ** Sprite_IconBase
#------------------------------------------------------------------------------
#  This the base sprite used to display icons and throw animations.
#==============================================================================

class Sprite_IconBase < Sprite_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :data
  attr_reader   :user
  attr_reader   :icon
  attr_reader   :value
  attr_reader   :target
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @right    = user.right?
    @left     = user.left?
    @down     = user.down?
    @up       = user.up?
    @spin     = 0
    @zooming  = 0
    @fade_in  = 0
    @fade_out = 0
    self.zoom_x = @data[:izm]
    self.zoom_y = @data[:izm]
  end
  #--------------------------------------------------------------------------
  # * New method: refresh
  #-------------------------------------------------------------------------- 
  def refresh(value)
    @user   = value.user
    @target = value.target
    @icon   = value.icon
    @data   = value.data.dup
  end
  #--------------------------------------------------------------------------
  # * New method: changed_icon?
  #--------------------------------------------------------------------------
  def changed_icon?(value)
    @user != value.user || @target != value.target || @icon != value.icon ||
    @data != value.data
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_zoom
    update_angle
    update_opacity
    update_position
  end
  #--------------------------------------------------------------------------
  # * New method: update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    if @data[:fin] > 0
      @fade_in += 1
      self.opacity = [@fade_in * @data[:fin], @data[:o]].min
    elsif @data[:fout] > 0
      @fade_out += 1
      self.opacity = [@data[:o] - @fade_out * @data[:fin], 0].max
    else
      self.opacity =  @data[:o]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_angle
  #--------------------------------------------------------------------------
  def update_angle
    @spin      += 1 if Graphics.frame_count % 2 == 0
    self.angle  = @data[:a] + @data[:spin] * @spin
    self.angle *= -1 if @right 
    self.angle -= 90 if @up
    self.angle += 90 if @down
    self.angle  = 360 + self.angle if self.angle < 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    if self.zoom_x < @data[:ezm]
      @zooming += 1
      self.zoom_x = [@data[:izm] + @zooming * @data[:szm], @data[:ezm]].min
      self.zoom_y = [@data[:izm] + @zooming * @data[:szm], @data[:ezm]].min
    elsif self.zoom_x > @data[:ezm]
      @zooming += 1
      self.zoom_x = [@data[:izm] - @zooming * @data[:szm], @data[:ezm]].max
      self.zoom_y = [@data[:izm] - @zooming * @data[:szm], @data[:ezm]].max
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_icon
  #--------------------------------------------------------------------------
  def setup_icon
    @current_icon = @icon
    if @icon.string?
      self.bitmap = Cache.picture(icon)
      self.src_rect.set(0, 0, bitmap.width, bitmap.height)
      @icon_ox = bitmap.width  / 2
      @icon_oy = bitmap.height / 2
    else
      self.bitmap = Cache.system("Iconset")
      size = bitmap.width / 16
      self.src_rect.set(icon % 16 * size, icon / 16 * size, size, size)
      @icon_ox = size / 2
      @icon_oy = size / 2
    end
  end  
end

#==============================================================================
# ** Sprite_Icon
#------------------------------------------------------------------------------
#  This sprite is used to display icons.
#==============================================================================

class Sprite_Icon < Sprite_IconBase
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(value)
    refresh(value)
    super(target.sprite.viewport)
    setup_icon
  end
  #--------------------------------------------------------------------------
  # * New method: update_position
  #--------------------------------------------------------------------------
  def update_position
    setup_icon if @current_icon != @icon
    self.x      = user.sprite.x
    self.y      = user.sprite.y - 1
    self.z      = user.sprite.z + (@data[:above] ? 1 : 0)
    self.ox     = @icon_ox
    self.oy     = @icon_oy
    self.mirror = @right
    update_movement
  end
  #--------------------------------------------------------------------------
  # * New method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    if @right || @left
      angle_move(:x, (@right ? adjust_x : -adjust_x))
      angle_move(:y, adjust_y)
    elsif @up || @down
      angle_move(:x, (@down ? adjust_y : -adjust_y))
      angle_move(:y, (@down ? adjust_x : -adjust_x) - 8)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: angle_move
  #--------------------------------------------------------------------------
  def angle_move(axis, amount)
    a = (360 - angle) * Math::PI / 180
    cos = Math.cos(a)
    sin = Math.sin(a)
    self.ox += (axis == :x ? -cos : -sin) * amount
    self.oy += (axis == :x ?  sin : -cos) * amount
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_x
  #--------------------------------------------------------------------------
  def adjust_x
    user.sprite.ox / 2 - @data[:x] 
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_y
  #--------------------------------------------------------------------------
  def adjust_y
    @data[:y] - (position[:h] + position[:j] + user.sprite.oy) / 2
  end
  #--------------------------------------------------------------------------
  # * New method: position
  #--------------------------------------------------------------------------
  def position
    user.sprite.position
  end
end

#==============================================================================
# ** Sprite_Throw
#------------------------------------------------------------------------------
#  This sprite is used to display throw animations.
#==============================================================================

class Sprite_Throw < Sprite_IconBase
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(value)
    refresh(value)
    super(target.sprite.viewport)
    setup_throw
  end
  #--------------------------------------------------------------------------
  # * New method: setup_throw
  #--------------------------------------------------------------------------
  def setup_throw
    set_initial_position
    setup_arc
    setup_icon
    setup_animation if $imported[:ve_loop_animation] && @data[:anim]
  end
  #--------------------------------------------------------------------------
  # * New method: set_initial_position
  #--------------------------------------------------------------------------
  def set_initial_position
    value = set_initial_values(user, target) 
    value = set_initial_values(target, user) if @data[:return]
    @current_position[:x] += @data[:init_x] + value[:init_ox]
    @current_position[:y] += @data[:init_y] + value[:init_oy]
    @target_position[:x]  += @data[:end_x]  + value[:end_ox]
    @target_position[:y]  += @data[:end_y]  + value[:end_oy]
    @initial_position = @current_position.dup
  end
  #--------------------------------------------------------------------------
  # * New method: set_initial_values
  #--------------------------------------------------------------------------
  def set_initial_values(battler1, battler2)
    @current_position = battler1.sprite.position.dup
    @target_position  = battler2.sprite.position.dup
    x1 = battler1.right? ? -@data[:init_x] : @data[:init_x]
    y1 = battler1.up?    ? -@data[:init_x] : @data[:init_x]
    x2 = battler2.right? ? -@data[:end_x]  : @data[:end_x]
    y2 = battler2.up?    ? -@data[:end_y]  : @data[:end_y]
    {init_ox:  x1, init_oy: y1, end_ox: x2, end_oy: y2}
  end
  #--------------------------------------------------------------------------
  # * New method: setup_arc
  #--------------------------------------------------------------------------
  def setup_arc
    @arc   = {}
    x_plus = (target_distance(:x) / 32.0).abs
    y_plus = (target_distance(:y) / 32.0).abs
    speed  = Math.sqrt((x_plus ** 2) + (y_plus ** 2)) / @data[:speed]
    @arc[:speed]  = @data[:arc] * 5.0 / [speed, 1].max
    @arc[:height] = @data[:arc]
    @arc[:count]  = @data[:arc] * 2
    @current_position[:a] = 0
  end
  #--------------------------------------------------------------------------
  # * New method: setup_icon
  #--------------------------------------------------------------------------
  def setup_icon
    super
    self.angle = @data[:a]
  end
  #--------------------------------------------------------------------------
  # * New method: setup_animation
  #--------------------------------------------------------------------------
  def setup_animation
    animation = {type: :throw, anim: @data[:anim], loop: 1}
    add_loop_animation(animation)
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_move
    update_arc
  end
  #--------------------------------------------------------------------------
  # * New method: update_move
  #--------------------------------------------------------------------------
  def update_move
    distance = set_distance
    move     = {x: 1.0, y: 1.0}
    if distance[:x].abs < distance[:y].abs
      move[:x] = 1.0 / (distance[:y].abs.to_f / distance[:x].abs)
    elsif distance[:y].abs < distance[:x].abs
      move[:y] = 1.0 / (distance[:x].abs.to_f / distance[:y].abs)
    end
    speed = set_speed(distance)
    x = move[:x] * speed[:x]
    y = move[:y] * speed[:y]
    set_movement(x, y)
  end
  #--------------------------------------------------------------------------
  # * New method: set_distance
  #--------------------------------------------------------------------------
  def set_distance
    {x: target_distance(:x), y: target_distance(:y)}
  end
  #--------------------------------------------------------------------------
  # * New method: target_distance
  #--------------------------------------------------------------------------
  def target_distance(symbol)
    @target_position[symbol] - @current_position[symbol]
  end
  #--------------------------------------------------------------------------
  # * New method: set_speed
  #--------------------------------------------------------------------------
  def set_speed(distance)
    x = @data[:speed] * (distance[:x] == 0 ? 0 : (distance[:x] > 0 ? 8 : -8))
    y = @data[:speed] * (distance[:y] == 0 ? 0 : (distance[:y] > 0 ? 8 : -8))
    {x: x, y: y}
  end
  #--------------------------------------------------------------------------
  # * New method: set_movement
  #--------------------------------------------------------------------------
  def set_movement(x, y)
    target  = @target_position
    current = @current_position
    current[:x] += x
    current[:y] += y
    current[:x] = target[:x] if in_distance?(current[:x], target[:x], x)
    current[:y] = target[:y] if in_distance?(current[:y], target[:y], y)
  end
  #--------------------------------------------------------------------------
  # * New method: in_distance?
  #--------------------------------------------------------------------------
  def in_distance?(x, y, z)
    x.between?(y - z - 1, y + z + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_arc
  #--------------------------------------------------------------------------
  def update_arc
    return if @arc[:count] == 0
    @arc[:count] = [@arc[:count] - (1 * @arc[:speed] / 10.0), 0].max.to_f
    count = @arc[:count]
    speed = @arc[:speed]
    peak  = @arc[:height]   
    result = (peak ** 2 - (count - peak).abs ** 2) / 2
    @current_position[:a] = @data[:revert] ? -result : result
  end
  #--------------------------------------------------------------------------
  # * New method: update_position
  #--------------------------------------------------------------------------
  def update_position
    setup_icon if @current_icon != @icon
    self.x      = current[:x]
    self.y      = current[:y] - current[:h] - current[:a]
    self.z      = [target.sprite.z, user.sprite.z].max
    self.ox     = @icon_ox
    self.oy     = @icon_oy
    self.mirror = @right || @up
  end
  #--------------------------------------------------------------------------
  # * New method: current
  #--------------------------------------------------------------------------
  def current
    @current_position
  end
  #--------------------------------------------------------------------------
  # * New method: disposing?
  #--------------------------------------------------------------------------
  def disposing?
    current[:x] == @target_position[:x] && current[:y] == @target_position[:y]
  end
end

#==============================================================================
# ** Plane_ActionPlane
#------------------------------------------------------------------------------
#  This is the plane used to display action plane images
#==============================================================================

class Plane_ActionPlane < Plane
  #--------------------------------------------------------------------------
  # * New method: initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @settings = {x: 0, y: 0, opacity: 0, zoom_x: 1.0, zoom_y: 1.0}
    @duration = 1
  end
  #--------------------------------------------------------------------------
  # * New method: dispose
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # * New method: setup
  #--------------------------------------------------------------------------
  def setup(name, x, y, z, zoom_x, zoom_y, opacity, blend, duration)
    self.bitmap = Cache.picture(name)
    self.z = z
    @settings[:x] = x
    @settings[:y] = y
    @settings[:zoom_x]  = zoom_x / 100.0
    @settings[:zoom_y]  = zoom_y / 100.0
    @settings[:opacity] = opacity
    @blend_type = blend
    @delete     = false
    @duration   = [duration, 1].max
  end
  #--------------------------------------------------------------------------
  # * New method: delete
  #--------------------------------------------------------------------------
  def delete(duration = 60)
    @settings[:opacity] = 0
    @duration = [duration, 1].max
    @delete   = true
  end
  #--------------------------------------------------------------------------
  # * New method: value
  #--------------------------------------------------------------------------
  def value
    @settings
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def update
    update_position
    update_opacity
    update_zoom
    update_delete
    @duration -= 1 if @duration > 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_position
  #--------------------------------------------------------------------------
  def update_position
    self.ox += value[:x]
    self.oy += value[:y]
  end
  #--------------------------------------------------------------------------
  # * New method: update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    return if @duration == 0
    d = @duration
    self.opacity = (self.opacity * (d - 1) + value[:opacity]) / d
  end
  #--------------------------------------------------------------------------
  # * New method: update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    return if @duration == 0
    d = @duration
    self.zoom_x = (self.zoom_x * (d - 1) + value[:zoom_x]) / d
    self.zoom_y = (self.zoom_y * (d - 1) + value[:zoom_y]) / d
  end
  #--------------------------------------------------------------------------
  # * New method: update_delete
  #--------------------------------------------------------------------------
  def update_delete
    return if !@delete || @duration > 0
    self.bitmap.dispose
    self.bitmap = nil
    @settings   = {x: 0, y: 0, opacity: 0, zoom_x: 100.0, zoon_y: 100.0}
    @blend_type = 0
    @delete = false
  end
end