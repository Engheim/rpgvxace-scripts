#==============================================================================
# ** Victor Engine - Retaliation Damage
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.18 > First release
#  v 1.01 - 2012.12.24 > Compatibility with Damage Popup
#                      > Compatibility with Counter Options
#------------------------------------------------------------------------------
#  This scripts allows to change the default mechanic of counters and reflect:
# the attacker can deal damage to the defending player before receiving the
# counter attack or magic reflect.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#
# * Alias methods
#   class Scene_Battle < Scene_Base
#     def invoke_counter_attack(target, item)
#     def invoke_magic_reflection(target, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
#  Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes.
# 
#  <counter damage>
#   Skills and Items with this tag will deal damage to the target before
#   a counter attack
# 
#  <reflect damage>
#   Skills and Items with this tag will deal damage to the target before
#   a magic reflect
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
# 
#  <counter damage>
#   Battlers with this tag will deal damage to the target before
#   a counter attack
# 
#  <reflect damage>
#   Battlers with this tag will deal damage to the target before 
#   a magic reflect
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   By default when the retailation occurs, the defending battler evades the
#   attack automatically. It's possible to avoid this and allows the attacker
#   to deal damage to the defending battler before the retaliation in three ways:
#   - Setting the constants VE_DAMAGE_ON_ALL_COUNTERS = true and/or 
#     VE_DAMAGE_ON_ALL_REFLECTS = false
#   - Adding the tag <counter damage> and/or <reflect damage> to the skill or
#     item.
#   - Adding the tag <counter damage> and/or <reflect damage> to the battler
#     (wich can be done via states or equips also)
#
#   Using the tags, only the actions with the tag will triggers the retaliation
#   damage on the defender, setting the constant true will make the defender
#   recive damage on all attacks that countered/reflected.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Setup damage on all counters
  #   Setting this true allows the attacker to deal damage to the defending
  #   battler when receiving a countered.
  #--------------------------------------------------------------------------
  VE_DAMAGE_ON_ALL_COUNTERS = true
  #--------------------------------------------------------------------------
  # * Setup damage on all reflects
  #   Stting this true allows the attacker to deal damage to the defending
  #   battler when receiving a magic reflect.
  #--------------------------------------------------------------------------
  VE_DAMAGE_ON_ALL_REFLECTS = false
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
$imported[:ve_retaliation_damage] = 1.01
Victor_Engine.required(:ve_retaliation_damage, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_retaliation_damage, :ve_damage_pop, 1.00, :bellow)
Victor_Engine.required(:ve_retaliation_damage, :ve_counter_options, 1.00, :bellow)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: counter_damage?
  #--------------------------------------------------------------------------
  def counter_damage?
    note =~ /<COUNTER DAMAGE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: reflect_damage?
  #--------------------------------------------------------------------------
  def reflect_damage?
    note =~ /<REFLECT DAMAGE>/i
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
  # * New method: counter_damage?
  #--------------------------------------------------------------------------
  def counter_damage?
    VE_DAMAGE_ON_ALL_COUNTERS || get_all_notes =~ /<COUNTER DAMAGE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: reflect_damage?
  #--------------------------------------------------------------------------
  def reflect_damage?
    VE_DAMAGE_ON_ALL_REFLECTS || get_all_notes =~ /<REFLECT DAMAGE>/i
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: invoke_counter_attack
  #--------------------------------------------------------------------------
  alias :invoke_counter_attack_ve_retaliation_damage :invoke_counter_attack
  def invoke_counter_attack(target, item)
    if damage_on_counter?(target, item)
      apply_item_effects(apply_substitute(target, item), item)
      return if target.hp <= 0
    end
    invoke_counter_attack_ve_retaliation_damage(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  alias :invoke_magic_reflection_ve_retaliation_damage :invoke_magic_reflection
  def invoke_magic_reflection(target, item)
    if damage_on_reflect?(target, item)
      apply_item_effects(apply_substitute(target, item), item)
      return if target.hp <= 0
    end
    invoke_magic_reflection_ve_retaliation_damage(target, item)
  end
  #--------------------------------------------------------------------------
  # * New method: damage_on_counter?
  #--------------------------------------------------------------------------
  def damage_on_counter?(target, item)
    (@subject.counter_damage? || item.counter_damage?) && target != @subject
  end
  #--------------------------------------------------------------------------
  # * New method: damage_on_reflect?
  #--------------------------------------------------------------------------
  def damage_on_reflect?(target, item)
    (@subject.reflect_damage? || item.reflect_damage?) && target != @subject
  end
end