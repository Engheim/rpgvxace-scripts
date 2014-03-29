#==============================================================================
# ** Victor Engine - Action Conditions
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2011.12.22 > First release
#  v 1.01 - 2011.12.30 > Faster Regular Expressions
#  v 1.02 - 2012.01.15 > Compatibility with Trait Control
#  v 1.03 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to set special conditions to determine if a skill or
# item can be used. You can set states, status, switches, variables or even
# use an custom condition that must be met for the skill or item to be useable.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
# 
# * Alias methods
#   class Game_BattlerBase
#     def usable?(item)
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
#  <condition any state added: x>     <condition any state removed: x>
#  <condition any state added: x, x>  <condition any state removed: x, x>
#   The skill or item can only be used if one of the listed states meets
#   the condition, added or removed.
#     x : state ID
#
#  <condition all state added: x>     <condition all state removed: x>
#  <condition all state added: x, x>  <condition all state removed: x, x>
#   The skill or item can only be used if *all* the listed states meets
#   the condition, added or removed.
#     x : state ID
#
#  <condition any switch on: x>      <condition any switch off: x>
#  <condition any switch on: x, x>   <condition any switch off: x, x>
#   The skill or item can only be used if one of the listed switches meets
#   the condition, On or Off.
#     x : switch ID
#
#  <condition all switch on: x>      <condition all switch off: x>
#  <condition all switch on: x, x>   <condition all switch off: x, x>
#   The skill or item can only be used if *all* the listed switches meets
#   the condition, On or Off.
#     x : switch ID
#
#  <condition variable x higher: y>   <condition variable x equal: y>
#  <condition variable x lower: y>    <condition variable x different: y>
#   The skill or item can only be used if the variable x meets the condition
#   when compared with value y.
#     x : variable ID
#     y : value (can be evaluted)
#  
#  <condition stat higher: x>    <condition stat equal: x>
#  <condition stat higher: x%>   <condition stat equal: x%>
#  <condition stat lower: x>     <condition stat different: x>
#  <condition stat lower: x%>    <condition stat different: x%>
#   The skill or item can only be used if the stat set meets the condition
#   when compared with value y. You can use any stat available for the 
#   battler, even custom ones.
#     stat : stat name (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#     x    : value (can be evaluted), % value can only be used with
#            the stats "hp", "mp" and "tp"
#
#  <custom condition>
#  string
#  string
#  </custom condition>
#    You can set a custom condition based on script code. Replace the string
#    withe the code that will be evaluted
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
$imported[:ve_action_condition] = 1.03
Victor_Engine.required(:ve_action_condition, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: usable?
  #--------------------------------------------------------------------------
  alias :usable_action_condition? :usable?
  def usable?(item)
    return false if !custom_conditions_met?(item)
    return usable_action_condition?(item)
  end
  #--------------------------------------------------------------------------
  # * New method: custom_conditions_met?
  #--------------------------------------------------------------------------
  def custom_conditions_met?(item)
    return true  if !item
    return false if item_param_condition?(item)
    return false if item_custom_condition?(item)
    return false if item_variable_condition?(item)
    return false if item_all_state_condition?(item)
    return false if item_any_state_condition?(item)
    return false if item_all_switch_condition?(item)
    return false if item_any_switch_condition?(item)
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: item_any_state_condition?
  #--------------------------------------------------------------------------
  def item_any_state_condition?(item)
    regexp = /<CONDITION ANY STATE (ADD|REMOV)ED: ((?:\d+ *,? *)+)>/i
    item.note.scan(regexp) do |cond, values|
      values.scan(/(\d+)/i) do
        case cond.upcase
        when "ADD"   then return false if @states.include?($1.to_i)
        when "REMOV" then return false if !@states.include?($1.to_i)
        end
      end
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_all_state_condition?
  #--------------------------------------------------------------------------
  def item_all_state_condition?(item)
    regexp = /<CONDITION ALL STATE (ADD|REMOV)ED: ((?:\d+ *,? *)+)>/i
    item.note.scan(regexp) do |cond, values|
      values.scan(/(\d+)/i) do
        case cond.upcase
        when "ADD"   then return true if !@states.include?($1.to_i)
        when "REMOV" then return true if @states.include?($1.to_i)
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_any_switch_condition?
  #--------------------------------------------------------------------------
  def item_any_switch_condition?(item)
    regexp = /<CONDITION ANY SWITCH (ON|OFF): ((?:\d+ *,? *)+)>/i
    item.note.scan(regexp) do |cond, values|
      values.scan(/(\d+)/i) do
        case cond.upcase
        when "ON"  then return false if $game_switches[$1.to_i]
        when "OFF" then return false if !$game_switches[$1.to_i]
        end
      end
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_all_switch_condition?
  #--------------------------------------------------------------------------
  def item_all_switch_condition?(item)
    regexp = /<CONDITION ALL SWITCH (ON|OFF): ((?:\d+ *,? *)+)>/i
    item.note.scan(regexp) do |cond, values|
      values.scan(/(\d+)/i) do 
        case cond.upcase
        when "ON"  then return true if !$game_switches[$1.to_i]
        when "OFF" then return true if $game_switches[$1.to_i]
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_variable_condition?
  #--------------------------------------------------------------------------
  def item_variable_condition?(item)
    cond   = "(HIGHER|LOWER|EQUAL|DIFFERENT)"
    regexp = /<CONDITION VARIABLE (\d+) #{cond}: ([^><]*)>/i
    item.note.scan(regexp) do |id, cond, value|
      string = "!(#{$game_variables[id.to_i]} #{get_cond(cond)} #{value})"
      return true if eval(string)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_param_condition?
  #--------------------------------------------------------------------------
  def item_param_condition?(item)
    cond   = "(HIGHER|LOWER|EQUAL|DIFFERENT)"
    regexp = /<CONDITION (\w+) #{cond}: ([^><]*)>/i
    item.note.scan(regexp) do |stat, cond, value|
      if value =~ /(\d+)\%/i && ["HP","MP","TP"].include?(stat.upcase)
        rate = hp_rate * 100 if stat.upcase == "HP"
        rate = mp_rate * 100 if stat.upcase == "MP"
        rate = tp_rate * 100 if stat.upcase == "TP"
        return true if eval("!(#{rate} #{get_cond(cond)} #{$1.to_i})")
      else
        return true if eval("!(#{get_param(stat)} #{get_cond(cond)} #{value})")
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: item_custom_condition?
  #--------------------------------------------------------------------------
  def item_custom_condition?(item)
    item.note.scan(get_all_values("CUSTOM CONDITION")) do
      return true if eval("!(#{$1.gsub(/\r\n/i, ";")})")
    end
    return false
  end
end