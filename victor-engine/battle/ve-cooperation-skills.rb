#==============================================================================
# ** Victor Engine - Cooperation Skills
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2013.02.13 > First relase
#------------------------------------------------------------------------------
#  This script is an add-on for the 'Victor Engine - Animated Battle' script.
# It allows to implement "Cooperation Skill", skills that can be used by more
# than one battler at the same time.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#   Requires the script 'Victor Engine - Animated Battle' v 1.21 or higher
#   If used with 'Victor Engine - Active Time Battle' place this bellow it.
#   If used with 'Victor Engine - Element Set' place this bellow it.
#
# * Alias methods
#   class << BattleManager
#     def clear_active_pose
#
#   class Game_Action
#     def clear
#     def prepare
#     def set_skill(skill_id)
#
#   class Game_BattlerBase
#     def skill_conditions_met?(skill)
#     def inputable?
#
#   class Game_Battler < Game_BattlerBase
#     def make_speed
#
#   class Window_SkillList < Window_Selectable
#     def make_item_list
#
#   class Window_BattleLog < Window_Selectable
#     def display_use_item(subject, item)
#
#   class Scene_Battle < Scene_Base
#     def start_actor_command_selection
#     def command_skill
#     def on_actor_cancel
#     def on_enemy_cancel
#     def use_item
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Skills note tags:
#  Tags to be used on the Skills note box in the database
#
#  <actor cooperation: x, x>
#    Skills with this notetag will be used by all actors listed. The skill
#    will be disabled if the actors are unable to use it for any reason.
#      x : actor ID
#
#  <enemy cooperation: x, x>
#    Skills with this notetag will be used by all enemies listed. When a enemy
#    use the skill, all enemies listed will "join" the attack. This affect all
#    enemies with the same id if there is multple copies of the same enemy, so
#    all enemies with the same ID will join the attack.
#      x : enemy ID
#
#  <hide cooperation>
#   This tag will hide the skill if not all actors are present on the party.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Don't make a skill both a actor cooperation and enemy cooperation.
#  Don't make the same skill the cooperation for two different sets of actors.
#
#  If you want the same skills for different actors/enemies, create two copies
#  of the same skill and assign each a different set of battlers.
#
#  When used with the VE - Active Time Battle, the cooperation skills will
#  be available only when all battlers involved are with the ATB full.
#  For that reason, it will not work for actors with the :full_wait mode and 
#  never will workf for enemies independent of the wait mode.
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
  VE_DEFAULT_COOPERATION = "
  
    # Wait active actor before retreat (important, avoid change)
    <action: wait active, reset>
    wait: cooperation all, active;
    </action>

    # Default pose for Skill Cooperation
    <action: cooperation skill, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    action: cooperation all, move to target;
    wait: cooperation all, action;
    wait: 10;
    pose: cooperation all, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    </action>
    
    # Default pose for Magic Cooperation
    <action: cooperation magic, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 43;
    wait: cooperation all, animation;
    pose: cooperation all, row magic, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    </action>
    
  "
  #--------------------------------------------------------------------------
  # * Charset Template Leap Action
  #--------------------------------------------------------------------------
  VE_CHARSET_COOPERATION = "
  
    # Wait active actor before retreat (important, avoid change)
    <action: wait active, reset>
    wait: cooperation all, active;
    </action>

    # Default pose for Skill Cooperation
    <action: cooperation skill, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    action: cooperation all, move to target;
    wait: cooperation all, action;
    wait: 10;
    direction: cooperation all, subjects;
    pose: cooperation all, row direction, all frames, wait 2, y +1;
    icon: cooperation all, weapon, angle -90, x +12, y -16;
    icon: cooperation all, weapon, angle -45, x +6, y -16;
    icon: cooperation all, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: cooperation all, weapon, angle 45, x -10, y +8;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    icon: cooperation all, delete;
    </action>
    
    # Default pose for Magic Cooperation
    <action: cooperation magic, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 43;
    wait: cooperation all, animation;
    action: cooperation all, step forward;
    direction: cooperation all, subjects;
    pose: cooperation all, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    wait: targets, animation;
    action: cooperation all, step backward;
    </action>

    "
    
  #--------------------------------------------------------------------------
  # * Kaduki Template Leap Action
  #--------------------------------------------------------------------------
  VE_KADUKI_COOPERATION = "
  
    # Wait active actor before retreat (important, avoid change)
    <action: wait active, reset>
    wait: cooperation all, active;
    </action>
    
    # Default pose for Skill Cooperation
    <action: cooperation skill, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    action: cooperation all, move to target;
    wait: cooperation all, action;
    direction: cooperation all, subjects;
    wait: 10;
    pose: cooperation all, row 1, all frames, sufix _3, wait 3, y +1;
    icon: cooperation all, weapon, angle -90, x +12, y -16;
    icon: cooperation all, weapon, angle -45, x +6, y -16;
    icon: cooperation all, weapon, angle 0, x -6;
    anim: targets, effect;
    icon: cooperation all, weapon, angle 45, x -10, y +8;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    icon: cooperation all, delete;
    </action>
    
    # Default pose for Magic Cooperation
    <action: cooperation magic, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 43;
    wait: cooperation all, animation;
    action: cooperation all, step forward;
    direction: cooperation all, subjects;
    pose: cooperation all, row 3, all frames, sufix _3, wait 3;
    wait: 8;
    anim: targets, effect;
    wait: 12;
    effect: cooperation all, targets, 100%, clear;
    wait: 20;
    wait: targets, animation;
    action: cooperation all, step backward;
    </action>

    <action: cross slash, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    move: cooperation 1, move to, x +32, y -24, reset;
    move: cooperation 2, move to, x +32, y +24, reset;
    direction: cooperation all, subjects;
    pose: cooperation all, row 4, all frames, sufix _1, return, wait 8, loop;
    wait: cooperation all, movement;
    direction: cooperation all, subjects;
    wait: 10;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    afterimage: cooperation all, red 160, green 160, alpha 128;
    move: cooperation 1, move to, x -80, y +32;
    move: cooperation 2, move to, x -80, y -32;
    pose: cooperation all, row 1, all frames, sufix _3, wait 3, y +1;
    icon: cooperation all, weapon, angle -90, x +12, y -16;
    icon: cooperation all, weapon, angle -45, x +6, y -16;
    icon: cooperation all, weapon, angle 0, x -6;
    anim: targets, id 115;
    anim: targets, id 116;
    icon: cooperation all, weapon, angle 45, x -10, y +8;
    effect: cooperation all, targets, 100%, clear;
    wait: cooperation all, movement;
    afterimage: cooperation all, off;
    wait: 40;
    icon: cooperation all, delete;
    </action>
    
    <action: flame blade, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    wait: 10;
    action: cooperation 2, step forward;
    wait: cooperation 2, action;
    pose: cooperation 2, row 4, all frames, sufix _3, loop, wait 8;
    anim: cooperation 2, id 43;
    wait: cooperation 2, animation;
    pose: cooperation 2, row 3, all frames, sufix _3, wait 3;
    pose: cooperation 1, row 2, sufix _3, all frames, wait 3, y +1;
    icon: cooperation 1, weapon, angle 45, x -6, y +6;
    icon: cooperation 1, weapon, angle 30, x -10, y +0;
    icon: cooperation 1, weapon, angle 15, x -14, y -6;
    icon: cooperation 1, weapon, angle 0, x -10, y -10;
    anim: cooperation 1, id 117;
    wait: cooperation 1, animation;
    icon: cooperation 1, delete;
    pose: cooperation 2, row 1, all frames, sufix _1, return, wait 16;
    afterimage: cooperation 1, on, red 160, alpha 128, wait 3;
    direction: cooperation all, subjects;
    pose: cooperation 1, row 4, all frames, sufix _1, return, wait 8, loop;
    move: cooperation 1, move to, x +32, reset;
    wait: cooperation all, movement;
    direction: cooperation all, subjects;
    move: cooperation 1, x -144, speed 15;
    pose: cooperation 1, row 1, sufix _3, all frames, wait 3, y +1;
    afterimage: cooperation 1, on, red 160, alpha 128;
    icon: cooperation 1, weapon, angle -90, x +12, y -16;
    icon: cooperation 1, weapon, angle -45, x +6, y -16;
    icon: cooperation 1, weapon, angle 0, x -6;
    icon: cooperation 1, weapon, angle 45, x -10, y +8;
    anim: targets, effect;
    effect: cooperation all, targets, 100%, clear;
    wait: cooperation 1, movement;
    afterimage: cooperation 1, off;
    wait: 20;
    action: cooperation 2, step backward;
    icon: cooperation 1, delete;
    </action>
    
    <action: triple smash, reset>
    wait: targets, movement;
    wait: cooperation all, movement;
    wait: 20;
    move: cooperation 1, move to, x +32, reset;
    move: cooperation 2, move to, x -128, reset;
    direction: cooperation all, subjects;
    pose: cooperation all, row 4, all frames, sufix _1, return, wait 8, loop;
    wait: cooperation all, movement;
    direction: cooperation all, subjects;
    anim: cooperation all, id 81;
    wait: cooperation all, animation;
    wait: 10;
    action: cooperation 1, triple smash 1;
    wait: cooperation 1, action;
    action: cooperation 2, triple smash 2;
    wait: cooperation 2, action;
    action: cooperation 1, triple smash 3;
    wait: cooperation 1, action;
    </action>
    
    <action: triple smash 1, reset>
    icon: self, shield, y +8, above;
    pose: self, row 3, frame 2, sufix _3;
    anim: targets, id 35;
    move: self, x -48, speed 15;
    wait: self, movement;
    effect: self, targets, 100%, no pose;
    action: targets, hurt pose;
    move: targets, x +64, speed 14;
    wait: targets, movement;
    icon: self, delete;
    pose: self, row 1, all frames, sufix _1, return, wait 16, loop;
    </action>
    
    <action: triple smash 2, reset>
    pose: self, row 2, all frames, sufix _2, wait 4, y +1;
    anim: targets, id 118;
    move: targets, x -64, speed 5;
    jump: targets, height 12, speed 5;
    effect: self, targets, 100%, no pose;
    action: targets, hurt pose;
    wait: self, pose;
    pose: self, row 1, all frames, sufix _1, return, wait 16, loop;
    </action>
    
    <action: triple smash 3, reset>
    pose: self, row 2, sufix _2, frame 1;
    icon: self, weapon, angle -90, x +12, y -16;
    jump: self, height 13, speed 7, reset;
    wait: 8;
    pose: self, row 3, sufix _3, reverse, all frames, wait 3, y +1;
    icon: self, weapon, angle -45, x +6, y -16;
    icon: self, weapon, angle 0, x -6;
    icon: self, weapon, angle 45, x -10, y +8;
    anim: targets, id 119;
    effect: self, targets, 100%, clear, no pose;
    jump: targets, speed 20;
    action: targets, hurt pose;
    wait: 30;
    </action>
    
    # Pose for Tetra Disaster
    <action: tetra disaster, reset>
    pose: cooperation all, row 4, all frames, sufix _3, loop, wait 8;
    wait: targets, movement;
    wait: 20;
    anim: cooperation all, id 43;
    wait: cooperation all, animation;
    wait: 10;
    action: friend 1, tetra disaster spell;
    wait: friend 1, action;
    action: friend 2, tetra disaster spell;
    wait: friend 2, action;
    action: friend 3, tetra disaster spell;
    wait: friend 3, action;
    action: friend 4, tetra disaster spell;
    wait: friend 4, action;
    action: cooperation all, step backward;
    </action>
        
    <action: tetra disaster spell, reset>
    action: self, step forward;
    wait: self, action;
    direction: self, subjects;
    pose: self, row 3, all frames, sufix _3, wait 3;
    condition: self.id == 9;
    action: self, tetra disaster earth;
    condition: end;
    condition: self.id == 10;
    action: self, tetra disaster wind;
    condition: end;
    condition: self.id == 11;
    action: self, tetra disaster ice;
    condition: end;
    condition: self.id == 12;
    action: self, tetra disaster fire;
    condition: end;
    wait: 30;
    </action>
    
    <action: tetra disaster fire, reset>
    anim: targets, id 57;
    wait: 8;
    effect: self, targets, 100%, elements 3;
    </action>
    
    <action: tetra disaster ice, reset>
    anim: targets, id 61;
    effect: self, targets, 100%, elements 4;
    </action>
    wait: 8;
    <action: tetra disaster wind, reset>
    anim: targets, id 73;
    wait: 8;
    effect: self, targets, 100%, elements 8;
    </action>
    
    <action: tetra disaster earth, reset>
    anim: targets, id 71;
    wait: 8;
    effect: self, targets, 100%, elements 7;
    </action>

    "
  #--------------------------------------------------------------------------
  # * Add new actions sequences.
  #--------------------------------------------------------------------------
  if $imported[:ve_animated_battle]
    VE_DEFAULT_ACTION += VE_DEFAULT_COOPERATION
    VE_ACTION_SETTINGS[:charset] += VE_CHARSET_COOPERATION if VE_ACTION_SETTINGS[:charset]
    VE_ACTION_SETTINGS[:kaduki]  += VE_KADUKI_COOPERATION  if VE_ACTION_SETTINGS[:kaduki]
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
$imported[:ve_cooperation_skill] = 1.00
Victor_Engine.required(:ve_cooperation_skill, :ve_basic_module, 1.35, :above)
Victor_Engine.required(:ve_cooperation_skill, :ve_basic_module, 1.21, :above)

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  This class is the superclass of all other classes.
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * New method: cooperation?
  #--------------------------------------------------------------------------
  def cooperation?
    return false
  end
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  This is the data class for skills.
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * New method: cooperation?
  #--------------------------------------------------------------------------
  def cooperation?
    !actor_cooperation.empty? || !enemy_cooperation.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: hide_cooperation
  #--------------------------------------------------------------------------
  def hide_cooperation
    return @hide_cooperation if @hide_cooperation
    @hide_cooperation = note =~ /<HIDE COOPERATION>/i
    @hide_cooperation
  end
  #--------------------------------------------------------------------------
  # * New method: hide_cooperation?
  #--------------------------------------------------------------------------
  def hide_cooperation?
    return false unless cooperation? && hide_cooperation
    !actor_cooperation.all? {|i| $game_party.members.include?($game_actors[i]) }
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_cooperation?
  #--------------------------------------------------------------------------
  def actor_cooperation?
    !actor_cooperation.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_cooperation?
  #--------------------------------------------------------------------------
  def enemy_cooperation?
    !enemy_cooperation.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_members
  #--------------------------------------------------------------------------
  def cooperation_members
    actor_cooperation? ? actor_cooperation : enemy_cooperation 
  end
  #--------------------------------------------------------------------------
  # * New method: actor_cooperation
  #--------------------------------------------------------------------------
  def actor_cooperation
    return @actor_cooperation if @actor_cooperation
    regexp = /<ACTOR COOPERATION: *((?:\d+ *,? *)+)>/i
    @actor_cooperation =  note.scan(regexp).inject([]) do |r, obj| 
      r += obj.first.scan(/\d+/i).collect {|i| i.to_i }
    end
    @actor_cooperation.uniq!
    @actor_cooperation
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_cooperation
  #--------------------------------------------------------------------------
  def enemy_cooperation
    return @enemy_cooperation if @enemy_cooperation
    regexp = /<ENEMY COOPERATION: *((?:\d+ *,? *)+)>/i
    @enemy_cooperation =  note.scan(regexp).inject([]) do |r, obj| 
      r += obj.first.scan(/\d+/i).collect {|i| i.to_i }
    end
    @enemy_cooperation.uniq!
    @enemy_cooperation
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Alias method: clear_active_pose
  #--------------------------------------------------------------------------
  alias :clear_active_pose_ve_cooperation_skill :clear_active_pose
  def clear_active_pose
    return unless actor && actor.poses.active_pose
    clear_active_pose_ve_cooperation_skill
    clear_cooperation_active_pose
  end
  #--------------------------------------------------------------------------
  # * New method: clear_cooperation_active_pose
  #--------------------------------------------------------------------------
  def clear_cooperation_active_pose
    $game_party.members.each do |member|
      next if member.cooperation_member?
      member.poses.active_pose = nil
      member.reset_pose
    end
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_members
  #--------------------------------------------------------------------------
  def cooperation_members
    return [] unless active
    active.current_action.cooperation_members.sort {|a, b| a.id <=> b.id }
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :cooperation_members
  #--------------------------------------------------------------------------
  # * Alias method: clear
  #--------------------------------------------------------------------------
  alias :clear_ve_cooperation_skill :clear
  def clear
    clear_ve_cooperation_skill
    @cooperation_members = []
  end
  #--------------------------------------------------------------------------
  # * Alias method: prepare
  #--------------------------------------------------------------------------
  alias :prepare_ve_cooperation_skill :prepare
  def prepare
    prepare_ve_cooperation_skill
    cooperation_ready if cooperation?
    clear_cooperation if clear_cooperation_member?
    clear             if other_cooperation_member?
  end
  #--------------------------------------------------------------------------
  # * Alias method: set_skill
  #--------------------------------------------------------------------------
  alias :set_skill_ve_cooperation_skill :set_skill
  def set_skill(skill_id)
    result = set_skill_ve_cooperation_skill(skill_id)
    subject.actor? ? setup_actor_cooperation : setup_enemy_cooperation
    result
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def clear_cooperation
    members = subject.current_action.cooperation_members - [subject]
    members.each do |member|
      member.atb = item ? member.atb * item.atb_cost : 0 
      BattleManager.clear_battler(member)
      member.clear_actions
    end
  end
  #--------------------------------------------------------------------------
  # * New method: 
  #--------------------------------------------------------------------------
  def cooperation_ready
    @cooperation_members.each {|member| member.poses.cooperation_ready = true }
  end
  #--------------------------------------------------------------------------
  # * New method: clear_cooperation_member?
  #--------------------------------------------------------------------------
  def clear_cooperation_member?
    $imported[:ve_active_time_battle] && item.cooperation?
  end
  #--------------------------------------------------------------------------
  # * New method: other_cooperation_member?
  #--------------------------------------------------------------------------
  def other_cooperation_member?
    !item.cooperation? && subject.cooperation_member?
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation?
  #--------------------------------------------------------------------------
  def cooperation?
    item.cooperation?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_cooperation
  #--------------------------------------------------------------------------
  def setup_enemy_cooperation
    @cooperation_members.clear
    list = item.cooperation_members
    list.each {|id| @cooperation_members += $game_troop.get_enemy(id, item) }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_actor_cooperation
  #--------------------------------------------------------------------------
  def setup_actor_cooperation
    @cooperation_members.clear
    list = item.cooperation_members
    list.each {|id| @cooperation_members += [$game_actors[id]] }
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
  # * Alias method: skill_conditions_met?
  #--------------------------------------------------------------------------
  alias :skill_conditions_met_ve_cooperation_skill? :skill_conditions_met?
  def skill_conditions_met?(skill)
    skill_conditions_met_ve_cooperation_skill?(skill) && 
    (actor_cooperation?(skill) && enemy_cooperation?(skill))
  end
  #--------------------------------------------------------------------------
  # * Alias method: inputable?
  #--------------------------------------------------------------------------
  alias :inputable_ve_cooperation_skill? :inputable?
  def inputable?
    inputable_ve_cooperation_skill? && !cooperation_member?(true)
  end
  #--------------------------------------------------------------------------
  # * New method: actor_cooperation?
  #--------------------------------------------------------------------------
  def actor_cooperation?(skill)
    !skill.actor_cooperation? || actor_cooperation_conditions_met?(skill)
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_cooperation?
  #--------------------------------------------------------------------------
  def enemy_cooperation?(skill)
    !skill.enemy_cooperation? || enemy_cooperation_conditions_met?(skill)
  end
  #--------------------------------------------------------------------------
  # * New method: actor_cooperation_conditions_met?
  #--------------------------------------------------------------------------
  def actor_cooperation_conditions_met?(skill)
    skill.actor_cooperation.all? do |id|
      actor = $game_actors[id]
      actor.can_use_cooperation?(skill)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_cooperation_conditions_met?
  #--------------------------------------------------------------------------
  def enemy_cooperation_conditions_met?(skill)
    $game_troop.enemies_available?(skill)
  end
  #--------------------------------------------------------------------------
  # * New method: can_use_cooperation?
  #--------------------------------------------------------------------------
  def can_use_cooperation?(skill)
    skill_conditions_met_ve_cooperation_skill?(skill) && in_active_party? && 
    normal? && !auto_battle? && cooperation_ready?
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_ready?
  #--------------------------------------------------------------------------
  def cooperation_ready?
    poses.cooperation_ready || (cooperation_enabled? && !cooperation_member?)
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_atb?
  #--------------------------------------------------------------------------
  def cooperation_enabled?
    cooperation_atb? && cooperation_leap?
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_atb?
  #--------------------------------------------------------------------------
  def cooperation_atb?
    !$imported[:ve_active_time_battle] || (atb_full? && !cast_action?)
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_atb?
  #--------------------------------------------------------------------------
  def cooperation_leap?
    !$imported[:ve_leap_attack] || !poses.leap
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation?
  #--------------------------------------------------------------------------
  def cooperation?(member, input)
    return false if input && member == self
    @actions.any? {|action| action.cooperation_members.include?(member) }
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_member?
  #--------------------------------------------------------------------------
  def cooperation_member?(input = false)
    $game_party.cooperation?(self, input)
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
  # * Alias method: make_speed
  #--------------------------------------------------------------------------
  alias :make_speed_ve_cooperation_skill :make_speed
  def make_speed
    make_speed_ve_cooperation_skill
    if cooperation_member?
      members = all_cooperation_members - [self]
      @speed  = members.inject([@speed]) {|r, m| r += [m.base_speed] }.average
    end
  end
  #--------------------------------------------------------------------------
  # * New method: base_speed
  #--------------------------------------------------------------------------
  def base_speed
    agi + rand(5 + agi / 4)
  end
  #--------------------------------------------------------------------------
  # * New method: all_cooperation_members
  #--------------------------------------------------------------------------
  def all_cooperation_members
    @actions.inject([]) {|r, action| r += action.cooperation_members }.uniq
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
  # * New method: cooperation?
  #--------------------------------------------------------------------------
  def cooperation?(battler, input)
    members.any? {|member| member.cooperation?(battler, input) }
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
  # * New method: get_enemy
  #--------------------------------------------------------------------------
  def get_enemy(id, skill)
    members.select do |member| 
      member.skill_conditions_met_ve_cooperation_skill?(skill) && 
      member.normal? && member.enemy_id == id
    end
  end
  #--------------------------------------------------------------------------
  # * New method: enemies_available?
  #--------------------------------------------------------------------------
  def enemies_available?(skill)
    skill.enemy_cooperation.all? {|id| !get_enemy(id, skill).empty? }
  end
end

#==============================================================================
# ** Game_PoseValue
#------------------------------------------------------------------------------
#  This class deals with battlers poses.
#==============================================================================

class Game_PoseValue
  #--------------------------------------------------------------------------
  # * Alias method: set_effect
  #--------------------------------------------------------------------------
  alias :set_effect_ve_cooperation_skill :set_effect
  def set_effect(value)
    set_effect_ve_cooperation_skill(value)
    @data[:cooperation] = value =~ /^ *COOPERATION[,;]/i ? true : false
  end
  #--------------------------------------------------------------------------
  # * Alias method: set_targets
  #--------------------------------------------------------------------------
  alias :set_subjects_ve_cooperation_skill :set_subjects
  def set_subjects(value, code = "^")
    case value
    when /#{code} *COOPERATION ALL/i
      BattleManager.cooperation_members
    when /#{code} *COOPERATION ([^>,;]+)/i
      [BattleManager.cooperation_members[battler.script_processing($1) - 1]]
    else
      set_subjects_ve_cooperation_skill(value, code)
    end
  end
end

#==============================================================================
# ** Game_PoseAction
#------------------------------------------------------------------------------
#  This class deals with battlers pose actions.
#==============================================================================

class Game_PoseAction
  #--------------------------------------------------------------------------
  # * Alias method: update_pose_effect
  #--------------------------------------------------------------------------
  alias :update_pose_effect_ve_cooperation_skill :update_pose_effect
  def update_pose_effect
    update_pose_effect_ve_cooperation_skill
    active.poses.cooperation_damage = @pose[:cooperation]
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
  attr_accessor :cooperation_damage
  attr_accessor :cooperation_ready
  #--------------------------------------------------------------------------
  # * Alias method: setup_basic_pose
  #--------------------------------------------------------------------------
  alias :call_action_poses_ve_cooperation_skill :call_action_poses
  def call_action_poses
    cooperation_activate if @current_item.cooperation?
    call_action_poses_ve_cooperation_skill
    cooperation_retreat  if @current_item.cooperation?
  end
  #--------------------------------------------------------------------------
  # * Alias method: action_pose
  #--------------------------------------------------------------------------
  alias :action_pose_ve_cooperation_skill :action_pose
  def action_pose(item)
    @cooperation_members = current_action.cooperation_members
    action_pose_ve_cooperation_skill(item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_basic_pose
  #--------------------------------------------------------------------------
  alias :setup_basic_pose_ve_cooperation_skill :setup_basic_pose
  def setup_basic_pose(dual)
    item = @current_item
    pose = setup_basic_pose_ve_cooperation_skill(dual)
    pose = cooperation_pose(pose) if item.cooperation?
    pose
  end
  #--------------------------------------------------------------------------
  # * Alias method: need_move?
  #--------------------------------------------------------------------------
  alias :need_move_ve_cooperation_skill? :need_move?
  def need_move?(item)
    return false if item.cooperation?
    need_move_ve_cooperation_skill?(item)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_active_pose
  #--------------------------------------------------------------------------
  alias :setup_active_pose_ve_cooperation_skill :setup_active_pose
  def setup_active_pose(item)
    setup_active_pose_ve_cooperation_skill(item)
    set_cooperation_active_pose(item) if item.cooperation?
  end
  #--------------------------------------------------------------------------
  # * New method: set_cooperation_active_pose
  #--------------------------------------------------------------------------
  def set_cooperation_active_pose(item)
    list = item.actor_cooperation.inject([]) {|r, i| r += [$game_actors[i]] }
    list.each do |member|
      next if member == @battler
      member.poses.active_pose = member.poses.call_active_pose(item)
      member.reset_pose
    end
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_pose
  #--------------------------------------------------------------------------
  def cooperation_pose(pose)
    item = @current_item
    pose = weapons_pose("COOPERATION SKILL", :cooperation_skill)
    pose = weapons_pose("COOPERATION MAGIC", :cooperation_magic) if item.magical?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_activate
  #--------------------------------------------------------------------------
  def cooperation_activate
    cooperation_members.each do |member|
      next if member == @battler
      member.poses.active_pose = nil
      member.poses.setup_subject(@battler)
      member.poses.clear_loop
    end
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_retreat
  #--------------------------------------------------------------------------
  def cooperation_retreat
    cooperation_members.each do |member|
      next if member == @battler
      member.poses.call_pose(:wait_active)
      member.poses.call_custom_pose("RETREAT", :retreat, @current_item)
      member.poses.call_pose(:clear)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_members
  #--------------------------------------------------------------------------
  def cooperation_members
    @cooperation_members ? @cooperation_members : []
  end
end

#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills on the skill screen.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: make_item_list
  #--------------------------------------------------------------------------
  alias :make_item_list_ve_cooperation_skill :make_item_list
  def make_item_list
    make_item_list_ve_cooperation_skill
    @data.delete_if {|skill| skill.hide_cooperation? }
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: display_use_item
  #--------------------------------------------------------------------------
  alias :display_use_item_ve_cooperation_skill :display_use_item
  def display_use_item(subject, item)
    if item.cooperation? && !subject.current_action.cooperation_members.empty?
      list = subject.current_action.cooperation_members.collect {|a| a.name }
      list.sort!
      text = ""
      list.each_with_index do |name, i|
        text += (i == 0 ? "" : i == list.size - 1 ? " and " : ", ") + name
      end
      add_text(text + item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      display_use_item_ve_cooperation_skill(subject, item)
    end
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: start_actor_command_selection
  #--------------------------------------------------------------------------
  alias :start_actor_command_selection_ve_cooperation_skill :start_actor_command_selection
  def start_actor_command_selection
    clear_cooperation
    start_actor_command_selection_ve_cooperation_skill
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_skill
  #--------------------------------------------------------------------------
  alias :command_skill_ve_cooperation_skill :command_skill
  def command_skill
    clear_cooperation
    command_skill_ve_cooperation_skill
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_actor_cancel
  #--------------------------------------------------------------------------
  alias :on_actor_cancel_ve_cooperation_skill :on_actor_cancel
  def on_actor_cancel
    on_actor_cancel_ve_cooperation_skill
    clear_cooperation if @actor_command_window.current_symbol == :skill 
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_enemy_cancel
  #--------------------------------------------------------------------------
  alias :on_enemy_cancel_ve_cooperation_skill :on_enemy_cancel
  def on_enemy_cancel
    on_enemy_cancel_ve_cooperation_skill
    clear_cooperation if @actor_command_window.current_symbol == :skill 
  end
  #--------------------------------------------------------------------------
  # * Alias method: use_item
  #--------------------------------------------------------------------------
  alias :use_item_ve_cooperation_skill :use_item
  def use_item
    cooperation_use if @subject.current_action.cooperation?
    use_item_ve_cooperation_skill
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_use
  #--------------------------------------------------------------------------
  def cooperation_use
    item = @subject.current_action.item
    @subject.poses.cooperation_ready = false
    cooperation_members.each {|member| member.use_item(item) }
    cooperation_members.each {|member| member.clear_actions  }
    cooperation_members.each {|member| member.poses.cooperation_ready = false }
  end
  #--------------------------------------------------------------------------
  # * New method: cooperation_use
  #--------------------------------------------------------------------------
  def cooperation_members
    @subject.current_action.cooperation_members - [@subject]
  end
  #--------------------------------------------------------------------------
  # * New method: clear_cooperation
  #--------------------------------------------------------------------------
  def clear_cooperation
    BattleManager.actor.input.cooperation_members.clear
  end
end