#==============================================================================
# ** Victor Engine - Custom Hit Formula
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.18 > First relase
#  v 1.01 - 2012.02.13 > Changed the hit result (now true = hit, false = miss)
#------------------------------------------------------------------------------
#  This script allows to setup custom hit formulas for actions. You can use
# any valid ruby command to make different ways to decide if an action will
# be successful. Some scripting knowlegde is required.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#
# * Overwrite methods
#   class Game_Battler < Game_BattlerBase
#     def item_apply(user, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on the Skills and Items note box in the database
# 
#  <hit formula>
#  formula
#  </hit formula>
#   Setup the custom hit formula for the action. The formula can be any valid
#   ruby command.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   You can setup formulas in a similar way as you do with damage formula, but
#   with one difference: the formula must return true or false instead of
#   a numeric value. The script checks if the battler hit the action so:
#   true  = hit
#   false = miss
#
#   You can setup formulas like the ones for skill and item damage.
#   You can use "a" to refer to the attacker, "b" to refer to the defender,
#   "v[x]" to use variables on the formula, "hit" to refer to the attacker hit
#   rate and "eva" to refer to the defender evasion.
#
#   "hit" and "eva" don't need to be assigned to the attacker or defender,
#   "hit" always stand for the attacker and "eva" always stand for defender.
#
#   "rand" will generate a value between 0.00 and 0.99.
#   The hit and eva value are % values, so 85% hit will result in 0.85 in 
#   the formulas.
#
#   Also please don't ask "How can I do a formula that do [your formula here]"
#   This script provides a free formula setup, and this setup is up to the user
#   If you don't know anything about ruby and can't make your own formulas,
#   i can't help.
#
#------------------------------------------------------------------------------
# Examples:
#
#   <hit formula>
#   rand < hit - eva
#   </hit formula>
#    This one will compare check if the hit rate minus the target eva is lower
#    than a random value. So a 125% hit against 45% eva will result in 80% hit
#    rand < 1.25 - 0.45   >>   rand < 0.8
#
#   <hit formula>
#   b.level % 5 == 0
#   </hit formula>
#    This will make the famous "level 5" skills from FF, where the skill hits
#    if the target level is divisible by 5. Remember that by default, enemies
#    don't have level so this would work only for actors unless you manage
#    to give levels to enemies.
#
#   <hit formula>
#   rand < hit * a.luk / b.agi 
#   </hit formula>
#    This formula uses the attacker luk and target agi to change the hit 
#    rate, then subtracts the target eva.
#
#   <hit formula>
#   rand < hit * [((255 - eva * 2) + 1), 1].max, 255].min / 256.0
#   </hit formula>
#    This formula is the hit formula from FF6.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Setup the default hit formula
  #   This method setup a default hit formula for all actions. You can setup
  #   a string with any valid ruby code. Leave nil to use default 
  #   RPG Maker VX Ace hit calculation.
  #--------------------------------------------------------------------------
  VE_DEFAULT_HIT_FORMULA = nil
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
$imported[:ve_custom_hit] = 1.01
Victor_Engine.required(:ve_custom_hit, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_custom_hit, :ve_damage_pop, 1.00, :bellow)
Victor_Engine.required(:ve_custom_hit, :ve_custom_collapse, 1.00, :bellow)
Victor_Engine.required(:ve_custom_hit, :ve_mp_level, 1.00, :bellow)
Victor_Engine.required(:ve_custom_hit, :ve_techs_points, 1.00, :bellow)
Victor_Engine.required(:ve_custom_hit, :ve_animated_battle, 1.00, :bellow)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: hit_formula
  #--------------------------------------------------------------------------
  def hit_formula
    return @hit_formula if @hit_formula
    @hit_formula = VE_DEFAULT_HIT_FORMULA
    @hit_formula = note =~ get_all_values("HIT FORMULA") ? $1 : @hit_formula
    @hit_formula
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
  # * Overwrite method: item_apply
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    item.hit_formula ? custom_hit(user, item) : normal_hit(user, item)
    setup_hit_result(user, item) if @result.hit?
  end
  #--------------------------------------------------------------------------
  # * New method: normal_hit
  #--------------------------------------------------------------------------
  def normal_hit(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
  end
  #--------------------------------------------------------------------------
  # * New method: custom_hit
  #--------------------------------------------------------------------------
  def custom_hit(user, item)
    @result.missed = (@result.used && !custom_hit_result(user, item))
    @result.evaded = (@result.missed &&  rand < item_eva(user, item))
  end
  #--------------------------------------------------------------------------
  # * New method: custom_hit_result
  #--------------------------------------------------------------------------
  def custom_hit_result(user, item)
    hit = item_hit(user, item)
    eva = item_eva(user, item)
    @hit_formula = item.hit_formula
    eval_hit(user, self, $game_variables, hit, eva)
  end
  #--------------------------------------------------------------------------
  # * New method: eval_hit
  #--------------------------------------------------------------------------
  def eval_hit(a, b, v, hit, eva)
    Kernel.eval(@hit_formula) rescue false
  end
  #--------------------------------------------------------------------------
  # * New method: setup_hit_result
  #--------------------------------------------------------------------------
  def setup_hit_result(user, item)
    unless item.damage.none?
      @result.critical = (rand < item_cri(user, item))
      make_damage_value(user, item)
      execute_damage(user)
    end
    item.effects.each {|effect| item_effect_apply(user, item, effect) }
    item_user_effect(user, item)
  end
end