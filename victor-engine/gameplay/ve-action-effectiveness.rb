#==============================================================================
# ** Victor Engine - Action Effectiveness
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.16 > First release
#  v 1.01 - 2012.07.12 > Action restrictions moved to another script
#                      > Compatibility with Element States
#  v 1.02 - 2012.07.13 > Compatibility with Action Restriction
#  v 1.03 - 2013.01.24 > Fixed issue with skill use and item use rate
#  v 1.04 - 2013.02.13 > Compatibility with Toggle Target
#------------------------------------------------------------------------------
#  This script allows to set the rate of effectivess of actions based on
# the user or target.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#
# * Overwrite methods
#   class Game_Battler < Game_BattlerBase
#     def item_effect_add_state_attack(user, item, effect)
#     def item_effect_add_state_normal(user, item, effect)
#     def item_effect_remove_state(user, item, effect)
#     def item_effect_add_debuff(user, item, effect)
#
#   class Scene_ItemBase < Scene_MenuBase
#     def user
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_value_recover_hp(user, item, effect)
#     def item_value_recover_mp(user, item, effect)
#     def item_value_gain_tp(user, item, effect)
#     def item_hit(user, item)
#     def make_damage_value(user, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, States, Weapons and Armors note tags:
#   Tags to be used on the Actors, Classes, Enemies, States, Weapons and Armors 
#   note box in the database
#
#  <skill use effectiveness x: y%>    <item use effectiveness x: y%>    
#   The actions will have it's effectiveness (damage or sucess chance) changed
#   by y% when used by a battler with this attribute
#     x = item or skill ID
#     y = effectiveness rate
#
#  <skill effect effectiveness x: y%>    <item effect effectiveness x: y%>    
#   The actions will have it's effectiveness (damage or sucess chance) changed
#   by y% when targeting a battler with this attribute
#     x = item or skill ID
#     y = effectiveness rate
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
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
$imported[:ve_action_effectiveness] = 1.04
Victor_Engine.required(:ve_action_effectiveness, :ve_basic_module, 1.35, :above)
Victor_Engine.required(:ve_action_effectiveness, :ve_element_states, 1.00, :bellow)
Victor_Engine.required(:ve_action_effectiveness, :ve_action_restriction, 1.00, :bellow)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_recover_hp
  #--------------------------------------------------------------------------
  alias :item_value_recover_hp_ve_action_effectiveness :item_value_recover_hp
  def item_value_recover_hp(user, item, effect)
    value = item_value_recover_hp_ve_action_effectiveness(user, item, effect)
    value * effectiveness(user, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_recover_mp
  #--------------------------------------------------------------------------
  alias :item_value_recover_mp_ve_action_effectiveness :item_value_recover_mp
  def item_value_recover_mp(user, item, effect)
    value = item_value_recover_mp_ve_action_effectiveness(user, item, effect)
    value * effectiveness(user, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_recover_yp
  #--------------------------------------------------------------------------
  alias :item_value_recover_tp_ve_action_effectiveness :item_value_recover_tp
  def item_value_recover_tp(user, item, effect)
    value = item_value_recover_tp_ve_action_effectiveness(user, item, effect)
    value * effectiveness(user, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_add_state_normal
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= effectiveness(user, item)
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user)      if opposite?(user)
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_remove_state
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    chance *= effectiveness(user, item)
    if rand < chance
      remove_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: item_effect_add_debuff
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    chance *= effectiveness(user, item)
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_hit
  #--------------------------------------------------------------------------
  alias :item_hit_ve_action_effectiveness :item_hit
  def item_hit(user, item)
    rate = item_hit_ve_action_effectiveness(user, item)
    rate *= effectiveness(user, item)
    rate
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_action_effectiveness :make_damage_value
  def make_damage_value(user, item)
    @effectivess_rate = effectiveness(user, item)
    make_damage_value_ve_action_effectiveness(user, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: apply_guard
  #--------------------------------------------------------------------------
  alias :apply_guard_all_ve_action_effectiveness :apply_guard
  def apply_guard(damage)
    damage  = apply_guard_all_ve_action_effectiveness(damage)
    damage *= @effectivess_rate
    damage
  end
  #--------------------------------------------------------------------------
  # * New method: effectiveness
  #--------------------------------------------------------------------------
  def effectiveness(user, item)
    value = 1.0
    value *= user.get_effectivenes(item, "USE")
    value *= self.get_effectivenes(item, "EFFECT")
    value
  end
  #--------------------------------------------------------------------------
  # * New method: get_effectivenes
  #--------------------------------------------------------------------------
  def get_effectivenes(item, type)
    action = item.skill? ? "SKILL" : "ITEM"
    regexp = /<#{action} #{type} EFFECTIVENESS #{item.id}: *(\d+)%?>/i
    get_all_notes.scan(regexp).inject(1.0) {|r, i| r *= i.first.to_f / 100.0 }
  end
end

#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
#  This is the superclass for the classes that performs the item and skill
# screens.
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Overwrite method: user
  #--------------------------------------------------------------------------
  def user
    users = $game_party.movable_members.select {|member| member.usable?(item)}
    users.max_by {|member| item_modifier(member, item) }
  end
  #--------------------------------------------------------------------------
  # * New method: item_modifier
  #--------------------------------------------------------------------------
  def item_modifier(member, item)
    value = member.pha
    value *= member.effectiveness(member, item)
    value
  end
end