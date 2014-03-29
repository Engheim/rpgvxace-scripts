#==============================================================================
# ** Victor Engine - Custom Slip Effect
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.02 > First relase
#  v 1.01 - 2012.08.03 > Fixed issue with death by poison
#                      > Added elements for custom slip damage
#  v 1.02 - 2013.02.13 > Compatibility with Basic Module 1.35
#                      > Added VE_MINIMUM_SLIP_EFFECT
#------------------------------------------------------------------------------
#  This scripts allows to setup custom formulas for regeneration and poison.
# You can setup formulas in the exact same way as you do for skills and items.
# You can also setup elements for the custom clip effects.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#
# * Overwrite methods
#   class Game_Battler < Game_BattlerBase
#     def regenerate_hp
#     def regenerate_mp
#     def regenerate_tp
#
# * Alias methods
#   class Game_BattlerBase
#     def clear_states
#     def erase_state(state_id)
#
#   class Game_BattlerBase
#     def clear_states
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Wapons, Armors, States and Enemies note tags:
#   Tags to be used on  Actors, Classes, Wapons, Armors, States and Enemies
#   note boxes.
# 
#  <custom x regen>   <custom x regen: y>   <custom x regen: y, y>
#  formula            formula               formula
#  </custom x regen>  </custom x regen>     </custom x regen>
#   Setup a custom formula for the regeneration value, you can use any valid
#   ruby method within the formula
#     x : stat affected. hp, mp or tp
#     y : element ID, optional
# 
#  <custom x poison>   <custom x poison: y>   <custom x poison: y, y>
#  formula             formula                formula
#  </custom x poison>  </custom x poison>     </custom x poison>
#   Setup a custom formula for the poison value, you can use any valid ruby
#   method within the formula
#     x : stat affected. hp, mp or tp
#     y : element ID, optional
# 
#------------------------------------------------------------------------------
# Additional instructions:
#
#   You can setup formulas like the ones for skill and item damage.
#   For states you can use "a" for the battler that inflicted the state and "b"
#   for the state target. That way you can have regen and poison staes based on
#   the status of the user and the target.
#
#   For other objects (equipment, actors, enemies and classes), both "a" and "b"
#   will stand for the target.
#
#   you can also use "v[x]" to use variables on the formula, and any other
#   valid ruby method.
#
#------------------------------------------------------------------------------
# Examples:
#
#   <custom hp poison>
#   a.atk * 2 - b.def
#   </custom hp poison>
#   This one should be used for states, it will setup a poison effect that
#   deals damage equal the state user attack * 2 - target def (if set as 
#   something else than a state, both values will be based on the target)
#   
#   <custom tp regen>
#   v[10] + rand(5)
#   </custom tp regen>
#   regenerate tp equal the value of the variable 10 + a random value between
#   0 and 4.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Minimum Slip Effect
  #   If true, the slip effect will be always rounded up. So it will be never
  #   zero even if the value is lower than 1.
  #--------------------------------------------------------------------------
  VE_MINIMUM_SLIP_EFFECT = true
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
$imported[:ve_custom_slip_effect] = 1.02
Victor_Engine.required(:ve_custom_slip_effect, :ve_basic_module, 1.35, :above)
Victor_Engine.required(:ve_custom_slip_effect, :ve_animated_battle, 1.00, :bellow)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: clear_states
  #--------------------------------------------------------------------------
  alias :clear_states_ve_custom_slip_effect :clear_states
  def clear_states
    clear_states_ve_custom_slip_effect
    @state_user = {}
  end
  #--------------------------------------------------------------------------
  # * Alias method: erase_state
  #--------------------------------------------------------------------------
  alias :erase_state_ve_custom_slip_effect :erase_state
  def erase_state(state_id)
    erase_state_ve_custom_slip_effect(state_id)
    @state_user.delete(state_id)
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
  # * Overwrite method: regenerate_hp
  #--------------------------------------------------------------------------
  def regenerate_hp
    damage = setup_hp_regen
    perform_map_damage_effect if $game_party.in_battle && damage > 0
    @result.hp_damage = [damage, max_slip_damage].min
    self.hp -= @result.hp_damage
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: regenerate_mp
  #--------------------------------------------------------------------------
  def regenerate_mp
    @result.mp_damage = setup_mp_regen
    self.mp -= @result.mp_damage
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: regenerate_tp
  #--------------------------------------------------------------------------
  def regenerate_tp
    @result.tp_damage = setup_tp_regen
    self.tp -= @result.tp_damage
  end
  #--------------------------------------------------------------------------
  # * Alias method: clear_states
  #--------------------------------------------------------------------------
  alias :add_new_state_ve_custom_slip_effect :add_new_state
  def add_new_state(state_id)
    battle  = SceneManager.scene_is?(Scene_Battle)
    subject = battle ? SceneManager.scene.subject : self
    valid   = battle && subject && subject != self
    @state_user[state_id] = valid ? subject.clone : self
    add_new_state_ve_custom_slip_effect(state_id)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_hp_regen
  #--------------------------------------------------------------------------
  def setup_hp_regen
    base = 0
    base -= mhp * hrg
    base -= setup_regen("HP")
    VE_MINIMUM_SLIP_EFFECT ? base.to_ceil :  : base.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: setup_mp_regen
  #--------------------------------------------------------------------------
  def setup_mp_regen
    base = 0
    base -= mmp * mrg
    base -= setup_regen("MP")
    VE_MINIMUM_SLIP_EFFECT ? base.to_ceil :  : base.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: setup_tp_regen
  #--------------------------------------------------------------------------
  def setup_tp_regen
    base = 0
    base -= mtp * trg
    base -= setup_regen("TP")
    VE_MINIMUM_SLIP_EFFECT ? base.to_ceil :  : base.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: states_regen
  #--------------------------------------------------------------------------
  def setup_regen(type)
    value1 = "CUSTOM #{type} (REGEN|POISON)((?::? *\\d+ *,? *)*)?"
    value2 = "CUSTOM #{type} (:?REGEN|POISON)"
    regexp = get_all_values(value1, value2)
    result = get_all_objects.collect do |value|
      value.note =~ regexp ? setup_slip_value($1, $2, $3, value) : 0
    end
    result.sum
  end
  #--------------------------------------------------------------------------
  # * New method: get_state_elements
  #--------------------------------------------------------------------------
  def setup_slip_value(a, b, c, value)
    user = value.is_a?(RPG::State) ? @state_user[value.id] : self
    sign = a.upcase == "REGEN" ? 1 : -1
    list = b ? get_state_elements(b.dup) : []
    rate = list.empty? ? 1.0 : elements_max_rate(list)
    @slip_formula = c.dup
    setup_slip_damage(user, self, $game_variables, rate, sign)
  end
  #--------------------------------------------------------------------------
  # * New method: get_state_elements
  #--------------------------------------------------------------------------
  def get_state_elements(value)
    value.scan(/(\d+)/i).inject([]) {|r, i|  r += i }.collect {|i| i.to_i }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_slip_damage
  #--------------------------------------------------------------------------
  def setup_slip_damage(a, b, v, r, s)
    slip_eval(a ? a : b, b, v) * r * s
  end
  #--------------------------------------------------------------------------
  # * New method: regen_eval
  #--------------------------------------------------------------------------
  def slip_eval(a, b, v)
    [Kernel.eval(@slip_formula), 0].max rescue 0
  end
end