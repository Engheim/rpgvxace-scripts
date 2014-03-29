#==============================================================================
# ** Victor Engine - State Cancel
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.05.23 > First release
#  v 1.01 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to setup some custom conditions for states to be removed
# beside the turn and after battle. You can set conditions based on status or
# custom conditions.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#
# * Alias methods
#   class Game_BattlerBase
#     def refresh
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on States note boxes.
# 
#  <cancel state stat higher x>    <cancel state stat equal x>
#  <cancel state stat higher x%>   <cancel state stat equal x%>
#  <cancel state stat lower x>     <cancel state stat different x>
#  <cancel state stat lower x%>    <cancel state stat different x%>
#   The state will be canceled if the stat set meets the condition
#   when compared with value y. You can use any stat available for the battler,
#   even custom ones.
#     stat : stat name (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#     x    : value (can be evaluted), % value can only be used with
#            the stats "hp", "mp" and "tp"
#
#  <cancel state custom>
#  string
#  string
#  </cancel state customn>
#   You can set a custom condition based on script code. Replace the string
#   withe the script code that will be evaluted.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   This DON'T remove states applied by the passivel states.
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
$imported[:ve_state_cancel] = 1.01
Victor_Engine.required(:ve_state_cancel, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_state_cancel :refresh
  def refresh
    remove_conditioned_states
    refresh_ve_state_cancel
  end
  #--------------------------------------------------------------------------
  # * New method: emove_conditioned_states
  #--------------------------------------------------------------------------
  def remove_conditioned_states
    states.each {|state| remove_state_cancel(state) }
  end
  #--------------------------------------------------------------------------
  # * New method: remove_state_cancel
  #--------------------------------------------------------------------------
  def remove_state_cancel(state)
    remove_state(state.id) if cancel_state_stat?(state.note)
    remove_state(state.id) if cancel_state_custom?(state.note)
  end
  #--------------------------------------------------------------------------
  # * New method: cancel_state_stat?
  #--------------------------------------------------------------------------
  def cancel_state_stat?(notes)
    value  = "(HIGHER|LOWER|EQUAL|DIFFERENT) ([^><]*)"
    regexp = /<CANCEL STATE (\w+) #{value}>/i
    return false unless notes =~ regexp
    notes.scan(regexp) do |stat, cond, value|
      if value =~ /(\d+)\%/i and ["HP","MP","TP"].include?(stat.upcase)
        rate = hp_rate * 100 if stat.upcase == "HP"
        rate = mp_rate * 100 if stat.upcase == "MP"
        rate = tp_rate * 100 if stat.upcase == "TP"
        return false if !eval("#{rate} #{get_cond(cond)} #{$1}")
      else
        return false if !eval("#{get_param(stat)} #{get_cond(cond)} #{value}")
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: cancel_state_custom?
  #--------------------------------------------------------------------------
  def cancel_state_custom?(notes)
    regexp = get_all_values("CANCEL STATE CUSTOM")
    return false unless notes =~ regexp
    notes.scan(regexp) { return false if !eval("#{$1.gsub(/\r\n/i, ";")}") }
    return true
  end
end