#==============================================================================
# ** Victor Engine - Trait Control
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.13 > First release
#  v 1.01 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to a higher control over the traits. You can
# set traits to be active only if certain conditions are met or add and
# remove traits manually with comment calls.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#
# * Alias methods
#   class Game_BattlerBase
#     def initialize
#     def all_features
#     def refresh
#
#   class Game_Interpreter
#     def command_121
#     def command_122
#     def comment_call
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <actor add trait x: info> 
#   Adds a trait to an specific actor
#     x    : actor ID
#     info : trait info (check trait list for details)
#
#  <actor remove trait x: info> 
#   Removes a trait to an specific actor
#     x    : actor ID
#     info : trait info (check trait list for details)
#
#  <enemy add trait x: info> 
#   Adds a trait to an specific enemy
#     x    : enemy troop index
#     info : trait info (check trait list for details)
#
#  <enemy remove trait x: info> 
#   Removes a trait to an specific enemy
#     x    : enemy troop index
#     info : trait info (check trait list for details)
#
#------------------------------------------------------------------------------
# Actors, Classes, Wapons, Armors, States and Enemies note tags:
#   Tags to be used on  Actors, Classes, Wapons, Armors, States and Enemies
#   note boxes.
#
#  <trait switch on x: info>
#  <trait switch off x: info>
#   Trait will be active if the switch set is on of off.
#     x    : switch ID
#     info : trait info (check trait list for details)
#
#  <trait variable x higher y: info>   <trait variable x equal y: info>
#  <trait variable x lower y: info>    <trait variable x different y: info>
#   Trait will be active if the variable x meets the condition when compared
#   with value y.
#     x    : variable ID
#     y    : value (can be evaluted)
#     info : trait info (check trait list for details)
#
#  <trait stat higher x: info>    <trait stat equal x: info>
#  <trait stat higher x%: info>   <trait stat equal x%: info>
#  <trait stat lower x: info>     <trait stat different x: info>
#  <trait stat lower x%: info>    <trait stat different x%: info>
#   Trait will be active if the stat set meets the condition when compared with
#   value y. You can use any stat available for the battler, even custom ones.
#     stat : stat name (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#     x    : value (can be evaluted), % value can only be used with
#            the stats "hp", "mp" and "tp"
#     info : trait info (check trait list for details)
#
#  <trait custom: info>
#  string
#  string
#  </trait customn>
#   You can set a custom condition based on script code. Replace the string
#   withe the script code that will be evaluted.
#     info : trait info (check trait list for details)
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Trait info:
#  The trait info on the settings must have be se as the follow:
#  name, data, value. 
#  The data id is a numeric value that set the trait type, the value a numeric
#  value that set the effect, it's not used for some traits.
#  Each trait works in a particular way so here is a list of all traits:
#
#  Element Efficiency
#    name  : element rate
#    data  : element ID (database value)
#    value : efficiency rate (0-1000)
#
#  Debuff Efficiency
#    name  : debuff rate
#    data  : 0: hp, 1: mp, 2: atk, 3: def, 4: mdf, 5: mat, 6: agi, 7: luk
#    value : efficiency rate (0-1000)
#
#  State Efficiency
#    name  : state rate
#    data  : state ID (database value)
#    value : efficiency rate (0-1000)
#
#  State Immunity
#    name  : state resist
#    data  : state ID (database value)
#    value : none
#
#  Basic Parameter Value
#    name  : basic param
#    data  : 0: hp, 1: mp, 2: atk, 3: def, 4: mdf, 5: mat, 6: agi, 7: luk
#    value : efficiency rate (0-1000)
#
#  Extra Parameter Value
#    name  : extra param
#    data  : 0: hit, 1: evasion, 2: critical, 3: critical eva, 4: magic eva,
#            5: reflection, 6: counter, 7: HP regen, 8: MP regen, 9: TP regen
#    value : efficiency rate (0-1000)
#
#  Special Parameter Value
#    name  : special param
#    data  : 0: aggro, 1: defense, 2: recovery, 3: pharmacology, 4: MP cost,
#            5: TP charge, 6: physical damage, 7: magic damage,
#            8: terrain damage, 9: Experience aquisition
#    value : efficiency rate (0-1000)
#
#  Element on Attack
#    name  : attack element
#    data  : element ID (database value)
#    value : none
#
#  State on Attack
#    name  : attack state
#    data  : state ID (database value)
#    value : efficiency rate (0-1000)
#
#  Attack Speed Correction
#    name  : attack speed
#    data  : correction (0-999, can be negative)
#    value : none
#
#  Additional Attacks
#    name  : attack time
#    data  : number of extra attack (0-9)
#    value : none
#
#  Add Skill type
#    name  : add stype
#    data  : skill type ID (database value)
#    value : none
#
#  Sealed Skill type
#    name  : seal stype
#    data  : skill type ID (database value)
#    value : none
#
#  Add Skill
#    name  : add skill
#    data  : skill ID (database value)
#    value : none
#
#  Sealed Skill
#    name  : seal skill
#    data  : skill ID (database value)
#    value : none
#
#  Equip Weapon Type
#    name  : equip wtype
#    data  : weapon type ID (database value)
#    value : none
#
#  Equip Armor Type
#    name  : equip atype
#    data  : armor type ID (database value)
#    value : none
#
#  Fixed Equipment
#    name  : equip fix
#    data  : 0: weapon, 1: shield, 2: helmet, 3: armor, 4: accessory
#    value : none
#
#  Sealed Equipment
#    name  : equip seal
#    data  : 0: weapon, 1: shield, 2: helmet, 3: armor, 4: accessory
#    value : none
#
#  Equipment Slot type
#    name  : equip slot
#    data  : 0: two swords
#    value : none
#
#  Chance of Additional Actions
#    name  : extra actions
#    data  : rate (0-1000)
#    value : none
#
#  Special Flag
#    name  : special flag
#    data  : 0: auto combat, 1: guard, 2: substitute, 3: TP carried over
#    value : none
#
#  Collapse Type
#    name  : collapse type
#    data  : 0: boss, 1: instant disappear, 3: Doesn't disappear
#    value : none
#
#  Party Ability
#    name  : party ability
#    data  : 0: encounter halved, 1: encounter disabled, 2: surprise disabled,
#            3: preemptive bonus, 4: money get x2, 5: experience get x2
#    value : none
#
# Ex.:
#  Add element 5 to attack if switch 5 on
#    <trait switch on 5: attack element, 3>
#
#  Immunity to state 4 if HP lower than 25%
#    <trait hp lower 25%: state resist, 4>
#
#  Adds MP 25% for actor 3
#    <actor add trait 3: basic param, 2, 125> 
#    
#  About remove trait:
#   Remove trait remove only the traits that are *exactly* the same.
#   So, if you have the trait "element rate, 2, 75", you must remove the trait
#   "element rate, 2, 75", if you change a single value, let's say
#   "element rate, 2, 74", it will not remove the trait with value 75.
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
$imported[:ve_trait_control] = 1.01
Victor_Engine.required(:ve_trait_control, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_control_traits :initialize
  def initialize
    initialize_ve_control_traits
    @custom_traits    = []
    @removed_traits   = []
    @condition_traits = []
  end
  #--------------------------------------------------------------------------
  # * Alias method: all_features
  #--------------------------------------------------------------------------
  alias :all_features_ve_control_traits :all_features
  def all_features
    all_features_ve_control_traits + @custom_traits + @condition_traits -
    @removed_traits
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_control_traits :refresh
  def refresh
    refresh_ve_control_traits
    refresh_traits
  end
  #--------------------------------------------------------------------------
  # * New method: trait_regexp
  #--------------------------------------------------------------------------
  def trait_regexp
    "([\\w ]+), (\\d+)(?: *, *(\\d+)\\%?)?"
  end
  #--------------------------------------------------------------------------
  # * New method: set_switch_traits
  #--------------------------------------------------------------------------
  def set_switch_traits
    regexp = /<TRAIT SWITCH (ON|OFF) (\d+): #{trait_regexp}>/i
    get_all_notes.scan(regexp) do |cond, value1, type, id, value2|
      next if cond.upcase == "ON"  && !$game_switches[value1.to_i]
      next if cond.upcase == "OFF" && $game_switches[value1.to_i]
      add_condition_trait(type, id.to_i, value2.to_i ? value2.to_i / 100.0 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_variable_traits
  #--------------------------------------------------------------------------
  def set_variable_traits
    value  = "(HIGHER|LOWER|EQUAL|DIFFERENT) ([^><:]*): #{trait_regexp}"
    regexp = /<TRAIT VARIABLE (\d+) #{value}>/i
    get_all_notes.scan(regexp) do |var, cond, value1, type, id, value2|
      variable = $game_variables[var.to_i]
      next unless eval("#{variable} #{get_cond(cond)} #{value1}")
      add_condition_trait(type, id.to_i, value2.to_i ? value2.to_i / 100.0 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_stat_traits
  #--------------------------------------------------------------------------
  def set_stat_traits
    value  = "(HIGHER|LOWER|EQUAL|DIFFERENT) ([^><:]*): #{trait_regexp}"
    regexp = /<TRAIT (\w+) #{value}>/i
    get_all_notes.scan(regexp) do |stat, cond, value1, type, id, value2|
      if value1 =~ /(\d+)\%/i and ["HP","MP","TP"].include?(stat.upcase)
        rate = hp_rate * 100 if stat.upcase == "HP"
        rate = mp_rate * 100 if stat.upcase == "MP"
        rate = tp_rate * 100 if stat.upcase == "TP"
        next unless eval("#{rate} #{get_cond(cond)} #{$1}")
      else
        next unless eval("#{get_param(stat)} #{get_cond(cond)} #{value1}")
      end
      add_condition_trait(type, id.to_i, value2.to_i ? value2.to_i / 100.0 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_custom_traits
  #--------------------------------------------------------------------------
  def set_custom_traits
    regexp = get_all_values("TRAIT CUSTOM: #{trait_regexp}", "TRAIT CUSTOM")
    get_all_notes.scan(regexp) do |type, id, value, cond|
      next unless eval("#{cond.gsub(/\r\n/i, ";")}")
      add_condition_trait(type, id.to_i, value2.to_i ? value2.to_i / 100.0 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: add_condition_trait
  #--------------------------------------------------------------------------
  def add_condition_trait(type, id, value)
    code = get_code(type)
    return unless code
    all_features.each do |trait|
      return if [trait.code, trait.data_id, trait.value] == [code, id, value]
    end
    @condition_traits.push(RPG::BaseItem::Feature.new(code, id, value))
  end
  #--------------------------------------------------------------------------
  # * New method: add_custom_trait
  #--------------------------------------------------------------------------
  def add_custom_trait(type, id, value)
    code = get_code(type)
    return unless code
    all_features.each do |trait|
      return if [trait.code, trait.data_id, trait.value] == [code, id, value]
    end
    @custom_traits.push(RPG::BaseItem::Feature.new(code, id, value))
  end
  #--------------------------------------------------------------------------
  # * New method: remove_trait
  #--------------------------------------------------------------------------
  def remove_trait(type, id, value)
    code = get_code(type)
    return unless code
    all_features.each do |trait|
      next if [trait.code, trait.data_id, trait.value] != [code, id, value]
      @removed_traits.push(trait)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_code
  #--------------------------------------------------------------------------
  def get_code(type)
    case type.upcase
    when "ELEMENT RATE"   then FEATURE_ELEMENT_RATE
    when "DEBUFF RATE"    then FEATURE_DEBUFF_RATE
    when "STATE RATE"     then FEATURE_STATE_RATE
    when "STATE RESIST"   then FEATURE_STATE_RESIST 
    when "BASIC PARAM"    then FEATURE_PARAM
    when "EXTRA PARAM"    then FEATURE_XPARAM
    when "SPECIAL PARAM"  then FEATURE_SPARAM
    when "ATTACK ELEMENT" then FEATURE_ATK_ELEMENT
    when "ATTACK STATE"   then FEATURE_ATK_STATE
    when "ATTACK SPEED"   then FEATURE_ATK_SPEED
    when "ATTACK TIMES"   then FEATURE_ATK_TIMES
    when "ADD STYPE"      then FEATURE_STYPE_ADD
    when "SEAL STYPE"     then FEATURE_STYPE_SEAL
    when "ADD SKILL"      then FEATURE_SKILL_ADD
    when "SEAL SKILL"     then FEATURE_SKILL_SEAL
    when "EQUIP WTYPE"    then FEATURE_EQUIP_WTYPE
    when "EQUIP ATYPE"    then FEATURE_EQUIP_ATYPE
    when "EQUIP FIX"      then FEATURE_EQUIP_FIX
    when "EQUIP SEAL"     then FEATURE_EQUIP_SEAL
    when "EQUIP SLOT"     then FEATURE_EQUIP_SLOT_TYPE
    when "EXTRA ACTIONS"  then FEATURE_ACTION_PLUS
    when "SPECIAL FLAG"   then FEATURE_SPECIAL_FLAG
    when "COLLAPSE TYPE"  then FEATURE_COLLAPSE_TYPE
    when "PARTY ABILITY"  then FEATURE_PARTY_ABILITY
    end
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
  # * New method: refresh_traits
  #--------------------------------------------------------------------------
  def refresh_traits
    @condition_traits.clear
    set_stat_traits
    set_switch_traits
    set_variable_traits
    set_custom_traits
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * New method: refresh_traits
  #--------------------------------------------------------------------------
  def refresh_traits
    @condition_traits.clear
    set_stat_traits
    set_switch_traits
    set_variable_traits
    set_custom_traits
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * New method: refresh_traits
  #--------------------------------------------------------------------------
  def refresh_traits
    members.each {|member| member.refresh_traits }
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias method: command_121
  #--------------------------------------------------------------------------
  alias :command_121_ve_control_traits :command_121
  def command_121
    command_121_ve_control_traits
    $game_party.refresh_traits
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_122
  #--------------------------------------------------------------------------
  alias :command_122_ve_control_traits :command_122
  def command_122
    command_122_ve_control_traits
    $game_party.refresh_traits
  end
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_control_traits :comment_call
  def comment_call
    call_change_trait("ACTOR", "ADD")
    call_change_trait("ENEMY", "ADD")
    call_change_trait("ACTOR", "REMOVE")
    call_change_trait("ENEMY", "REMOVE")
    comment_call_ve_control_traits
  end
  #--------------------------------------------------------------------------
  # * New method: call_change_trait
  #--------------------------------------------------------------------------
  def call_change_trait(target, change)
    trait  = "([\\w ]+) *, *(\\d+)(?: *, *(\\d+)\\%?)?"
    regexp = /<#{target} #{change} TRAIT (\d+): #{trait}>/i
    note.scan(regexp) do |i, type, id, value|
      subject = $game_actors[i.to_i]        if target.upcase == "ACTOR"
      subject = $game_troop.enemies[i.to_i] if target.upcase == "ENEMY"
      next unless subject
      list = [type, id.to_i, value ? value.to_i / 100.0 : 0]
      subject.add_custom_trait(*list) if change.upcase == "ADD"
      subject.remove_trait(*list)     if change.upcase == "REMOVE"
    end
  end
end

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a superclass of all scenes in the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: start
  #--------------------------------------------------------------------------
  alias :start_ve_control_traits :start
  def start
    start_ve_control_traits
    $game_party.refresh_traits if $game_party
  end
end