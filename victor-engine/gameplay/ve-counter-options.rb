#==============================================================================
# ** Victor Engine - Counter Options
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.12.24 > First release
#  v 1.01 - 2013.01.07 > Fixed issue with counters without Animated Battle
#------------------------------------------------------------------------------
#  This script allows to add options to choose wich skill will be used
# on ounter attacks.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#   If used with 'Victor Engine - Retaliation Damage' place this bellow it.
#
# * Overwrite methods
#   class Scene_Battle < Scene_Base
#     def invoke_counter_attack(target, item)
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_cnt(user, item)
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
#  <skill counter: x>        <item counter: x>
#  <skill counter: x, y%>    <item counter: x, y%>  
#   Setup the skill or item to be used as counter
#     x : ID of the skill or item used
#     y : chance of using the skill or item as counter, 100% if not set
#
#  <counter skill x: y>        <counter item x: y>
#  <counter skill x: y, z%>    <counter item x: y, z%>
#   Setup the skill to be used as counter if target by a specific action
#     x : ID of the item or skill that triggered the counter
#     y : ID of the skill used
#     z : chance of using the skill as counter, 100% if not set
#
#  <counter skill type x: y>        <counter item type x: y>
#  <counter skill type x: y, z%>    <counter item type x: y, z%>
#   Setup the skill to be used as counter if target by a specific action type
#     x : ID of the item type or skill type that triggered the counter
#     y : ID of the skill used
#     z : chance of using the skill as counter, 100% if not set
#
#  <counter element x: y>        <counter element x: y>
#  <counter element x: y, z%>    <counter element x: y, z%>
#   Setup the skill to be used as counter if target by actions of a element
#     x : ID of the element that triggered the counter
#     y : ID of the skill used
#     z : chance of using the skill as counter, 100% if not set
#
#  <counter same skill>
#   Counter the skill with the same skill used.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The action will be used as counter attack only if the battler has learned
#  the skill or have enough items, for enemies, the skill must be available on
#  their action list or must be added with the Trait "Add Skill", use the Add
#  Skill Trait if you want the enemy to use the action only as a counter.
#
#  If the battler have two valid counter action for the same type (like
#  two different <skill counter: x>) the action will be decided *at random*
#  between the ones available.
#
#  If the selected skill isn't usable, the counter will be skiped.
#
#  This script *DON'T* add a chance for a counter attack to occur. It just
#  decide wich action will be used as counter attack
#
#  If you want specific actions to trigger specific counters, use this script
#  together with Action Counter and Element Counter
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
$imported[:ve_counter_options] = 1.01
Victor_Engine.required(:ve_counter_options, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_counter_options, :ve_action_counter, 1.00, :bellow)
Victor_Engine.required(:ve_counter_options, :ve_element_counter, 1.00, :bellow)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: item_cnt
  #--------------------------------------------------------------------------
  alias :item_cnt_ve_counter_options :item_cnt
  def item_cnt(user, item)
    setup_counter_skill(item)
    return 0 if @counter_action && !usable?(counter_action)
    item_cnt_ve_counter_options(user, item)
  end
  #--------------------------------------------------------------------------
  # * New method: counter_skill
  #--------------------------------------------------------------------------
  def setup_counter_skill(item)
    result   = []
    result += counter_same?(item)
    result += counter_with?(item)
    result += counter_type?(item)
    result += counter_element?(item)
    result += default_counter?(item)
    list = result.select {|skill| usable?(skill) }
    @counter_action = list.empty? ? result.random : list.random
  end
  #--------------------------------------------------------------------------
  # * New method: counter_action
  #--------------------------------------------------------------------------
  def counter_action
    $data_skills[@counter_action ? @counter_action : attack_skill_id]
  end
  #--------------------------------------------------------------------------
  # * New method: default_counter?
  #--------------------------------------------------------------------------
  def default_counter?(item)
    regexp = /<SKILL COUNTER: (\d+)(?:, *(\d+)%>)?/i
    list   = get_counter_skill_list(regexp)
    list.select {|i| skills.include?($data_skills[i]) }
  end
  #--------------------------------------------------------------------------
  # * New method: counter_same?
  #--------------------------------------------------------------------------
  def counter_same?(item)
    result = get_all_notes =~ /<COUNTER SAME SKILL>/i && skill_learn?(item)
    result ? [item.id] : []
  end
  #--------------------------------------------------------------------------
  # * New method: counter_with?
  #--------------------------------------------------------------------------
  def counter_with?(item)
    type   = item.skill? ? "SKILL" : "ITEM"
    regexp = /<COUNTER #{type} #{item.id}: (\d+)(?:, *(\d+)%>)?>/i
    list   = get_counter_skill_list(regexp)
    list.select {|i| skills.include?($data_skills[i]) }
  end
  #--------------------------------------------------------------------------
  # * New method: counter_element?
  #--------------------------------------------------------------------------
  def counter_element?(item)
    list   = []
    element_set(item).each do |id|
      regexp = /<COUNTER ELEMENT #{id}: (\d+)(?:, *(\d+)%>)?>/i
      list  += get_counter_skill_list(regexp)
    end
    list.select {|i| skills.include?($data_skills[i]) }
  end
  #--------------------------------------------------------------------------
  # * New method: counter_type?
  #--------------------------------------------------------------------------
  def counter_type?(item)
    type   = item.skill? ? "SKILL" : "ITEM"
    id     = item.skill? ? item.stype_id : item.itype_id 
    regexp = /<COUNTER #{type} TYPE #{id}: (\d+)(?:, *(\d+)%>)?>/i
    list   = get_counter_skill_list(regexp)
    list.select {|i| skills.include?($data_skills[i]) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_counter_skill_list
  #--------------------------------------------------------------------------
  def get_counter_skill_list(regexp)
    get_all_notes.scan(regexp).inject([]) do |r|
      r.push($1.to_i) if !$2 || rand < $2.to_f / 100.0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_counter_targets
  #--------------------------------------------------------------------------
  def setup_counter_targets(target, item)
    if item.for_user? || (item.for_friend? && !item.for_all?)
      [self]
    elsif item.for_friend? && item.for_all?
      friends_unit
    elsif item.for_opponent? && !item.for_all?
      [target]
    elsif item.for_opponent? && item.for_all?
      target.friends_unit
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
  # * New method: skill_learn?
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    skill.skill? && skills.include?(skill)
  end
  #--------------------------------------------------------------------------
  # * New method: skills
  #--------------------------------------------------------------------------
  def skills
    (enemy_actions | added_skills).sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_actions
  #--------------------------------------------------------------------------
  def enemy_actions
    enemy.actions.collect {|action| action.skill_id }
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Overwrite method: invoke_counter_attack
  #--------------------------------------------------------------------------
  alias :invoke_counter_attack_ve_counter_options :invoke_counter_attack
  def invoke_counter_attack(target, item)
    if $imported[:ve_animated_battle]
      invoke_counter_attack_ve_counter_options(target, item)
    else
      @log_window.display_counter(target, item)
      item = $data_skills[target.attack_skill_id]
      old  = @subject
      @subject = target
      targets  = @subject.setup_counter_targets(old, item)
      @subject.use_item(item)
      show_animation(targets, item.animation_id)
      @subject = subject
      targets.each {|battler| battler.item_apply(target, item) }
      refresh_status
      @log_window.display_action_results(@subject, item)
    end
  end
end