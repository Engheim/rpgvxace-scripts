#==============================================================================
# ** Victor Engine - Custom Basic Actions
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.10 > First relase
#------------------------------------------------------------------------------
#  This script allows to change the basic actions of the actor: Attack and
# Defend, based on the actor, class, weapons, armors or states.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#
# * Overwrite methods (Default)
#   class Game_Player < Game_Character
#     def attack_skill_id
#     def guard_skill_id
#
#   class Scene_Battle < Scene_Base
#     def command_attack
#
# * Alias methods (Default)
#   class Scene_Battle < Scene_Base
#     def on_actor_cancel
#
#------------------------------------------------------------------------------
# Actor, Classes, States, Weapons and Armors note tags:
#   Tags to be used on Actor, Classes, States, Weapons and Armors note boxes.
#
#  <custom attack: x>
#  <custom attack: x, y>
#   Set a specifc skill to be used during normal attacks.
#     x : Skill ID
#     y : priority, opitional.
#
#  <custom guard: x>
#  <custom guard: x, y>
#   Set a specifc skill to be used during guards.
#     x : Skill ID
#     y : priority, opitional.
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
#  The priority defines wich skill will be used if the actor have more than one
#  skill available. By default, the priority is set by the skill ID 
#  (higher ID, higher priority)
#
#  The skill cost and restriction still valid, so if the skill used as attack 
#  have any cost it will be spent, and the attack won't be usable if the skill
#  isn't usable.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the ID of the default normal attack skill
  #--------------------------------------------------------------------------
  VE_DEFAULT_ATTACK_SKILL_ID = 1
  #--------------------------------------------------------------------------
  # * Set the ID of the default guard skill
  #--------------------------------------------------------------------------
  VE_DEFAULT_GUARD_SKILL_ID = 2
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
$imported[:ve_custom_basic_actions] = 1.00
Victor_Engine.required(:ve_custom_basic_actions, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_custom_basic_actions, :ve_target_arrow, 1.00, :bellow)

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Overwrite method: attack_skill_id
  #--------------------------------------------------------------------------
  def attack_skill_id
    set_action_skill_id(:attack)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: guard_skill_id
  #--------------------------------------------------------------------------
  def guard_skill_id
    set_action_skill_id(:guard)
  end
  #--------------------------------------------------------------------------
  # * New method: set_action_skill_id
  #--------------------------------------------------------------------------
  def set_action_skill_id(type)
    basic_action_id = get_basic_skill_id(type)
    return basic_action_id if basic_action_id
    return VE_DEFAULT_ATTACK_SKILL_ID if type == :attack
    return VE_DEFAULT_GUARD_SKILL_ID  if type == :guard
  end
  #--------------------------------------------------------------------------
  # * New method: get_basic_skill_id
  #--------------------------------------------------------------------------
  def get_basic_skill_id(type)
    attacks = []
    attacks += get_attaks_list(type, states.compact)
    attacks += get_attaks_list(type, weapons.compact)
    attacks += get_attaks_list(type, [self.class])
    attacks += get_attaks_list(type, [self])
    attacks += get_attaks_list(type, armors.compact)
    attacks.sort! {|a, b| b[:id] <=> a[:id]}
    attacks.sort! {|a, b| b[:prior] <=> a[:prior]}
    attacks.first ? attacks.first[:id] : nil
  end
  #--------------------------------------------------------------------------
  # * New method: get_attaks_list
  #--------------------------------------------------------------------------
  def get_attaks_list(type, list)
    attacks = []
    regexp  = /<CUSTOM #{type}: (\d+)(?: *, *(\d+))?>/i
    list.each do |obj|
      next unless obj.note =~ regexp
      attacks.push({id: $1.to_i, prior: $2 ? $2.to_i : 0}) 
    end
    attacks
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Overwrite method: command_attack
  #--------------------------------------------------------------------------
  def command_attack
    BattleManager.actor.input.set_attack
    skill = $data_skills[BattleManager.actor.attack_skill_id]
    if !skill.need_selection?
      next_command
    elsif skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_actor_cancel
  #--------------------------------------------------------------------------
  alias :on_actor_cancel_ve_custom_basic_actions :on_actor_cancel
  def on_actor_cancel
    on_actor_cancel_ve_custom_basic_actions
    case @actor_command_window.current_symbol
    when :attack
      @actor_command_window.activate
    end
  end
end