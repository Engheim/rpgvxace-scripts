#==============================================================================
# ** Victor Engine - Action Strenghten
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.16 > First release
#  v 1.01 - 2013.02.13 > Fixed issue with item effects
#------------------------------------------------------------------------------
#  This script allows to setup a trait that change the power of actions based
# on the actions or their type. You can make equipment that strengthen specific
# skills or an whole skill type.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#   If used with 'Victor Engine - Element Set' place this bellow it.
#
# * Alias methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def item_value_recover_hp(user, item, effect)
#     def item_value_recover_mp(user, item, effect)
#     def item_value_gain_tp(user, item, effect)
#     def item_element_rate(user, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
#
#  <skill streghten x: +y%>   <item streghten x: +y%>
#  <skill streghten x: -y%>   <item streghten x: -y%>
#   Setup the skill or item and a rate of streghten for that action
#     x : ID of the skill or item
#     y : streghten rate
#
#  <skill type streghten x: +y%>   <item type streghten x: +y%>
#  <skill type streghten x: -y%>   <item type streghten x: -y%>
#   Setup the skill or item type and a rate of streghten for that actions
#     x : ID of the skill type or item type
#     y : streghten rate
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
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_action_streghten] = 1.01
Victor_Engine.required(:ve_action_streghten, :ve_basic_module, 1.35, :above)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: item_effect_recover_hp
  #--------------------------------------------------------------------------
  alias :item_value_recover_hp_ve_action_streghten :item_value_recover_hp
  def item_value_recover_hp(user, item, effect)
    value = item_value_recover_hp_ve_action_streghten(user, item, effect)
    value *= user.action_streghten(item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_effect_recover_mp
  #--------------------------------------------------------------------------
  alias :item_value_recover_mp_ve_action_streghten :item_value_recover_mp
  def item_value_recover_mp(user, item, effect)
    value = item_value_recover_mp_ve_action_streghten(user, item, effect)
    value *= user.action_streghten(item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_effect_recover_tp
  #--------------------------------------------------------------------------
  alias :item_value_recover_tp_ve_action_streghten :item_value_recover_tp
  def item_value_recover_tp(user, item, effect)
    value = item_value_recover_tp_ve_action_streghten(user, item, effect)
    value *= user.action_streghten(item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_element_rate
  #--------------------------------------------------------------------------
  alias :item_element_rate_ve_action_streghten :item_element_rate
  def item_element_rate(user, item)
    result = item_element_rate_ve_action_streghten(user, item)
    result * user.action_streghten(item)
  end
  #--------------------------------------------------------------------------
  # * New method: action_streghten
  #--------------------------------------------------------------------------
  def action_streghten(item)
    [1.0 + item_streghten(item) + item_type_streghten(item), 0].max
  end
  #--------------------------------------------------------------------------
  # * New method: item_streghten
  #--------------------------------------------------------------------------
  def item_streghten(item)
    get_action_streghten(item.skill? ? "SKILL" : "ITEM", item.id)
  end
  #--------------------------------------------------------------------------
  # * New method: item_type_streghten
  #--------------------------------------------------------------------------
  def item_type_streghten(item)
    type = item.skill? ? "SKILL TYPE" : "ITEM TYPE"
    item.type_set.inject(0.0) {|r, i| r += get_action_streghten(type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_action_streghten
  #--------------------------------------------------------------------------
  def get_action_streghten(type, id)
    regexp = /<#{type} STRENGHTEN #{id}: ([+-]?\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_i / 100.0) }
  end
end