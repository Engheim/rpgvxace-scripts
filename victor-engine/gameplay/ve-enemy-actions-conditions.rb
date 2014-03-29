#==============================================================================
# ** Victor Engine - Enemy Actions Conditions
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.01 > First release
#  v 1.01 - 2012.01.15 > Compatibility with Trait Control
#  v 1.02 - 2012.01.15 > Improved code
#                      > Changed how to setup actions and condition
#  v 1.03 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows the creation of custom conditions for enemies actions.
# Different from the default RPG Maker VX behavior, you can set more than one
# condition for the actions. It also give some extra conditions not avaiable
# by default.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
# 
# * Alias methods
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#     def conditions_met?(action)
#     def action_valid?(action)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on the Enemies note box in the database
#  
#  <enemy action: x, y>
#  conditions;
#  </enemy action>
#    Setup the action ID, rating and conditions.
#      x : skill ID
#      y : skill rating, a value between 1-10
#
#    Conditions: conditions that must be met to for the action to be used
#      the conditions can be status based or a custom script call
#      you can add how many values you want always separating them with a ;
#      at the end. Script calls can have multiple lines, just add the ; at
#      the end of the last line of the condition.
#
#    stat higher x;      stat equal x;
#    stat higher x%;     stat equal x%;
#    stat lower x;       stat different x;
#    stat lower x%;      stat different x%;
#      The action condition will be valid if the stat set meets the
#      condition when compared with value y. You can use any stat
#      available for the battler,   even custom ones.
#        stat : stat name (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#        x    : value (can be evaluted), % value can only be used with
#               the stats "hp", "mp" and "tp"
#    turn: x*;
#      The action condition is valid if the turn count is equal the one set.
#
#    turn: x + x*;
#      the value x* means tuns multiple of x.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Settings from versions previous to 1.02 will not work properly
#
#  *ALL* conditions must be met in order for the action be available for use.
#  The game still choose the action randomly based on the action rating,
#  so this will not ensure that the action will be used always when the
#  condition is met.
#
#------------------------------------------------------------------------------
# Example Actions:
# 
#  <enemy action: 26, 8>
#  hp lower 50%;
#  turn 4*;
#  </enemy action>
#   Use action ID 26 if the HP is lower than 50% on the fourth turns with very
#   high frequency (rating 8)
#
#  <enemy action: 31, 6>
#  state?(2);
#  </enemy action>
#   Use action ID 31 when under the state ID 2
#
#------------------------------------------------------------------------------
# Useful script calls:
#   Here some useful script calls that can be used:
#
#   state?(x)
#    checks if the battler is under state ID x
#
#   state_addable?(x)
#    checks if the state ID x can be added (to avoid adding the state if the
#    battler is immune)
# 
#   $game_swiches[x]
#    checks if game swicth ID x is ON
#
#   $game_variables[x]
#    you can use this to compare the variable ID x with any value (be sure to
#    to add the comparision sign and the value)
#
#   rand(100) > x
#    to make a % chance user rand(100) < x, where x is the % chance
# 
#   you can also use || for "or" and && for "and"
#     state?(1) || state?(2) # if state 1 or state 2 is added
#     state?(1) && state?(2) # if  boths state 1 and state 2 are added
#   
#   you can also add a ! in front of the condition to make the opposite check
#     !state?(2)         # if state 2 is NOT added
#     !$game_switches[3] # if Switch 3 is OFF
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
$imported[:ve_enemy_actions] = 1.03
Victor_Engine.required(:ve_enemy_actions, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#  This is the data class for enemies.
#==============================================================================

class RPG::Enemy
  #--------------------------------------------------------------------------
  # * New method: init_custom_actions
  #--------------------------------------------------------------------------
  def init_custom_actions
    regexp = get_all_values("ENEMY ACTION: (\\d+), *(\\d+)","ENEMY ACTION")
    note.scan(regexp) do |id, rating|
      action = RPG::Enemy::Action.new
      action.skill_id = id.to_i
      action.rating   = rating.to_i
      action.condition_type = :custom
      @actions.push(action)
    end
  end
end

#==============================================================================
# ** RPG::Enemy::Action
#------------------------------------------------------------------------------
#  This is the data class for enemies actions.
#==============================================================================

class RPG::Enemy::Action
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :index
  #--------------------------------------------------------------------------
  # * New method: custom?
  #--------------------------------------------------------------------------
  def custom?
    @condition_type == :custom
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_enemy_actions :initialize
  def initialize(index, enemy_id)
    initialize_ve_enemy_actions(index, enemy_id)
    enemy.init_custom_actions
  end
  #--------------------------------------------------------------------------
  # * Alias method: conditions_met?
  #--------------------------------------------------------------------------
  alias :conditions_met_ve_enemy_actions? :conditions_met?
  def conditions_met?(action)
    return true if action.custom?
    conditions_met_ve_enemy_actions?(action)
  end
  #--------------------------------------------------------------------------
  # * Alias method: action_valid?
  #--------------------------------------------------------------------------
  alias :action_valid_ve_enemy_actions? :action_valid?
  def action_valid?(action)
    action_valid_ve_enemy_actions?(action) && custom_condition?(action)
  end
  #--------------------------------------------------------------------------
  # * New method: custom_condition?
  #--------------------------------------------------------------------------
  def custom_condition?(action)
    return true unless action.custom?
    setup_enemy_actions(action.skill_id)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_enemy_actions
  #--------------------------------------------------------------------------
  def setup_enemy_actions(id)
    regexp = get_all_values("ENEMY ACTION: #{id}, *\\d+", "ENEMY ACTION")
    note.scan(regexp).all? { enemy_action_condition($1.dup) }
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_action_condition
  #--------------------------------------------------------------------------
  def enemy_action_condition(notes)
    notes.scan(/([^;]*);/im) do
      value   = $1.dup
      result1 = value =~ /\w+ (?:HIGHER|LOWER|EQUAL|DIFFERENT) [^><]*/i
      result2 = value =~ /TURN \d+\*? *(?:\+ \d+\*)?/i
      return false if  result1 && !enemy_action_stat?(value)
      return false if  result2 && !enemy_action_turn?(value)
      return false if !result1 && !result2 && !enemy_action_custom?(value)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_action_stat?
  #--------------------------------------------------------------------------
  def enemy_action_stat?(notes)
    if notes =~ /(\w+) (HIGHER|LOWER|EQUAL|DIFFERENT) ([^><]*)/im
      stat  = $1.dup
      cond  = $2.dup
      value = $3.dup
      if value =~ /(\d+)\%/i and ["HP","MP","TP"].include?(stat.upcase)
        return eval("#{stat.downcase}_rate * 100 #{get_cond(cond)} #{$1}")
      else
        return eval("#{get_param(stat)} #{get_cond(cond)} #{value}")
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_action_turn?
  #--------------------------------------------------------------------------
  def enemy_action_turn?(notes)
    n = $game_troop.turn_count
    notes.scan(/TURN (\d+\*?) *(?:\+ *(\d+)\*)?/i) do |value1, value2|
      param1 = value1 =~ /(\d+)\*/i ? 0 : value1.to_i
      param2 = value1 =~ /(\d+)\*/i ? $1.to_i : value2 ? value2.to_i : 0
      if param2 == 0
        return n == param1
      else
        return n > 0 && n >= param1 && n % param2 == param1 % param2
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_action_custom?
  #--------------------------------------------------------------------------
  def enemy_action_custom?(notes)
    eval("#{notes.gsub(/\r\n/i, ";")}") rescue false
  end
end