#==============================================================================
# ** Victor Engine - Automatic Battlers
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.17 > First release
#  v 1.01 - 2012.01.20 > Fixed all targets actions
#  v 1.02 - 2012.02.07 > Fixed maxhp and maxhp conditions
#  v 1.03 - 2012.07.17 > Fixed hp, mp and tp % conditions
#  v 1.04 - 2012.07.30 > Improved some condition checks
#                      > Enemies can now only use actions available on their
#                      > action list
#  v 1.05 - 2012.08.02 > Compatibility with Basic Module 1.27
#  v 1.06 - 2012.11.03 > Fixed issue with wrong conditions
#------------------------------------------------------------------------------
#  This script allows to set a more complex AI for actors and enemies with
# the trait 'Special Flag: Auto Battle', allowing to set various conditions
# for the actions be used.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#
# * Overwrite methods
#   class Game_Actor < Game_Battler
#     def make_auto_battle_actions
#
# * Alias methods
#   class Game_BattlerBase
#     def refresh
#
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#     def make_actions
#    
#   class Game_Actor < Game_Battler
#     def make_action_list
#
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used on the events comment box, works like a script call
#
#  <actor strategy change id: name>
#  <enemy strategy change id: name>
#   Switch the current strategy of the actor or enemy with one of the default 
#   strategy set on the script setting module
#    id   : actor ID or enemy index
#    name : name of the strategy
#  
#  <type add strategy id: action, priority x, target>
#  conditions
#  conditions
#  </add strategy>
#   Adds a new action strategy to the actor strategy list
#    type       : actor or enemy
#    id         : actor ID or enemy index
#    action     : set action type and IDs 
#    priority x : ser action priority
#    target     : set valid target
#    conditions : set actions conditions
#     check on the Additional Instructions for more deatil about
#
#------------------------------------------------------------------------------
# Actors, Classes, Skills, States, Weapons, Armors and Enemies:
#   Tags to be used on the Actors, Classes, Skills, States, Weapons, Armors
#   and Enemies note box in the database. They can be also used on the script
#   settings within the module
#
#  <strategy: action, priority x, target>
#  conditions
#  conditions
#  </strategy>
#   Set a new action strategy to the actor strategy list
#    action     : set action type and IDs 
#    priority x : ser action priority
#    target     : set valid target
#    conditions : set actions conditions
#     check on the Additional Instructions for more deatil about
#
#------------------------------------------------------------------------------
# Additional instructions:
# 
#  The battler MUST have the auto_battle? flag on, it's gererally set
#  by the trait 'Special Flag: Auto Battle', but it can be turn on with scripts.
#  This is valid even for enemies, if a enemy don't have the Auto Battle trait,
#  he won't use his battle strategy.
#
#  Actors can use only actions that he learned, enemies can use only skills
#  listed on their Action Pattern, no matter what their conditions, enemies 
#  can't use items.
#
#  The VE_BASIC_STRATEGY_LIST are a list of strategies that can be switched
#  with comment calls or script calls
#
#  action : the action that will be used when meeting the condition.
#   it can be one of the following values
#    attack  : uses basic attack
#    guard   : uses basic guard
#    skill   : uses random skill
#    skill x : uses the skill ID x
#    item  x : uses the item ID x
#      For skills and items it's possible to add a list of possible actions
#      to be used by adding more ids separated by comas: x, x, x...
#
#  priority x : the action priority. A value that increase the action priority
#   in a % value. Generally, the priority is based on the damage/heal of the
#   action (actions that deals no damage are considered normal attacks)
#   
#   frequecy of usageof the action. Generally the AI tries to use the "best"
#   action (the one with more damage/heal), the priority increase the odds of
#   using a action even if it will be less effective. But even a high value
#   priority action might be not used if another action seems to be more
#   effective. (let's say your mage is facing an enemy imune to magic, will
#   normal attack instead of
#
#  target: condition so decide the possible targets for the action
#    random : select a random valid target.
#    user   : select always the user, valid only for ally targeted actions
#    state on x  : select the target the state ID active
#    state off x : select the target the state ID not active
#    highest stat : select the target with the higest stat. stat can be any
#             valid stat (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#    lowest stat  : select the target with the lowest stat. stat can be any
#             valid stat (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#    highest buff : select the target with the higest buff. buff can be any
#             buff + stat (buff_hp, buff_mp, buff_atk, buff_def, buff_mat,
#             buff_mdf, buff_agi, buff_luk)
#    lowst buff   :  select the target with the lowest buff. buff can be any
#             buff + stat (buff_hp, buff_mp, buff_atk, buff_def, buff_mat,
#             buff_mdf, buff_agi, buff_luk)
#
#   condition : the condition that must be met for the action to be used.
#     these are the valid conditions:
#       none   : no condition
#       "code" : action will be valid if evaluated code returns true
#       custom : the custom setting is composed by 4 parts:
#         party stat  condition value
#         party state condition value
#          party : the list of battlers that will be checked, can be
#            user     : check the user
#            friend   : check the battlers from the same side
#            opponent : check the battlers from the opposing side
#          stat : the stat that will be checked, can be a can be any
#            stat  : one valid stat (maxhp, maxmp, maxtp, hp, mp, tp, atk...)
#            state : check states.
#            buff  : buff_hp, buff_mp, buff_atk, buff_def, buff_mat, buff_mdf,
#                    buff_agi, buff_luk
#          condition : the condition that must be met
#            stat  : lower, higher, equal, differnt or buff
#            state : on of off
#          value : the status value, or ID for states. if the status
#            is hp, mp or tp, you can add a % to use a percent value.
#            can be evaluated
#
#  Conditions Examples:
#    user hp lower 50%       # Check if user HP is lower than 50%
#    friend state on 2       # Check if any ally is afflicted with state ID 2
#    opponent mp higher 100  # Check if any opponent MP is higher than 100
#    user buff_atk lower 0   # Check if user ATK Buff level is lower than 0
#
#------------------------------------------------------------------------------
# Examples:
#  
#  Smart Foe:
#   With this AI the battler will envenom the enemy unless all enemies are
#   poisoned, heal any ally that have hp lower than 50% and buff the defense
#   of the lowest defense ally wich defense buff is lower than 1.
#   to avoid spamming heal and poison every turn it was added a turn condition
#
#     <strategy: attack, priority 1, random>
#     none
#     </strategy>
#
#     <strategy: attack, priority 1, random>
#     none
#     </strategy>
#
#     <strategy: skill 42, priority 50, self>
#     self buff_def lower 1
#     </strategy>
#
#     <strategy: skill 11, priority 200, lowest hp>
#     ally hp lower 50%
#     '$game_troop.turn_count % 4 == 0'
#     </strategy>
#
#     <strategy: skill 11, priority 50, self>
#     opponent state off 2
#     '$game_troop.turn_count % 4 == 1'
#     </strategy>
#
#  Healer:
#   With this AI the battler will focus on healing the HP and states from the
#   allies, also it will use items to cure states if under Silence.
#
#     <strategy: attack, priority 0, random>
#     none
#     </strategy>
#
#     <strategy: skill, priority 0, random>
#     random
#     </strategy>     
#
#     <strategy: item 7, priority 100, self>
#     self state on 4
#     </strategy>  
#
#     <strategy: skill 26,27,28, priority 50, lowest hp>
#     friend hp lower 50%
#     </strategy>  
#
#     <strategy: skill 26,27,28, priority 100, lowest hp>
#     friend hp lower 25%
#     </strategy>
#
#     <strategy: skill 29,30, priority 50, lowest hp>
#     friend hp lower 30%
#     </strategy>
#
#     <strategy: skill 31, priority 80, lowest hp>
#     friend state on 2
#     </strategy>
#
#     <strategy: skill 31, priority 80, lowest def>
#     friend state on 7
#     </strategy>
#
#     <strategy: skill 32, priority 100, highest atk>
#     friend state on 3
#     </strategy>
#
#     <strategy: skill 32, priority 100, highest mat>
#     friend state on 4
#     </strategy>
#
#     <strategy: skill 32, priority 100, highest atk>
#     friend state on 5
#     </strategy>  
#
#     <strategy: skill 32, priority 100, lowest def>
#     friend state on 6
#     </strategy> 
#
#     <strategy: guard, priority 200, self>
#     self hp lower 25%
#     '$game_troop.turn_count % 2 == 0'
#     </strategy>
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine  
  #--------------------------------------------------------------------------
  # * Set Basic strategies
  #--------------------------------------------------------------------------
  VE_BASIC_STRATEGY_LIST = {
    attacker: "
      <strategy: attack, priority 25, random>
      none
      </strategy>
      
      <strategy: attack, priority 50, lowest hp>
      opponent hp lower 25%
      </strategy>      
    
      <strategy: skill, priority 0, random>
      random
      </strategy>      
    
      <strategy: guard, priority 200, self>
      self hp lower 25%
      '$game_troop.turn_count % 2 == 0'
      </strategy>      
    ",
    
    
    healer: "
      <strategy: attack, priority 0, random>
      none
      </strategy>

      <strategy: skill, priority 0, random>
      random
      </strategy>     

      <strategy: skill 26,27,28, priority 50, lowest hp>
      friend hp lower 50%
      </strategy>  

      <strategy: skill 26,27,28, priority 100, lowest hp>
      friend hp lower 25%
      </strategy>

      <strategy: skill 29,30, priority 50, lowest hp>
      friend hp lower 30%
      </strategy>

      <strategy: skill 31, priority 80, lowest hp>
      friend state on 2
      </strategy>

      <strategy: skill 31, priority 80, lowest def>
      friend state on 7
      </strategy>

      <strategy: skill 32, priority 100, highest atk>
      friend state on 3
      </strategy>

      <strategy: skill 32, priority 100, highest mat>
      friend state on 4
      </strategy>

      <strategy: skill 32, priority 100, highest atk>
      friend state on 5
      </strategy>  

      <strategy: skill 32, priority 100, lowest def>
      friend state on 6
      </strategy> 

      <strategy: guard, priority 200, self>
      self hp lower 25%
      '$game_troop.turn_count % 2 == 0'
      </strategy>
    ",
    
    mage: "
      <strategy: attack, priority 0, random>
      none
      </strategy>

      <strategy: skill, priority 50, lowest mdf>
      none
      </strategy>  

      <strategy: skill, priority 25, random>
      random
      </strategy>      

      <strategy: guard, priority 200, self>
      self hp lower 25%
      '$game_troop.turn_count % 2 == 0'
      </strategy>
    ",
    
  } # Don't remove
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
$imported[:ve_automatic_battlers] = 1.06
Victor_Engine.required(:ve_automatic_battlers, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * New method: evaluate_auto
  #--------------------------------------------------------------------------
  def evaluate_auto(action)
    @value = 0
    auto_evaluate_item(action) if valid?
    @value += rand / 5.0 if @value > 0
    @value *= 1 + action.priority / 50.0
    self
  end
  #--------------------------------------------------------------------------
  # * New method: auto_evaluate_item
  #--------------------------------------------------------------------------
  def auto_evaluate_item(action)
    list = auto_item_target_candidates(action)
    list.each do |target|
      value = auto_evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value >= @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: auto_evaluate_item_with_target
  #--------------------------------------------------------------------------
  def auto_evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if target.result.hp_damage.zero?
      target.make_damage_value(subject, $data_skills[subject.attack_skill_id])
    end
    if item.for_opponent?
      result = target.result.hp_damage.to_f / [target.hp, 1].max
    else
      if target.result.hp_damage > 0
        damage = target.result.hp_damage.to_f * 2
      else
        damage = [-target.result.hp_damage, target.mhp - target.hp].min
      end
      result = damage.to_f / [target.hp, 1].max
    end
    target.result.clear
    result
  end
  #--------------------------------------------------------------------------
  # * New method: auto_item_target_candidates
  #--------------------------------------------------------------------------
  def auto_item_target_candidates(action)
    valid = action.target || action.valid
    valid ? get_valid_targets(action) : item_target_candidates
  end
  #--------------------------------------------------------------------------
  # * New method: get_valid_targets
  #--------------------------------------------------------------------------
  def get_valid_targets(action)
    if action.valid && !action.target
      eval(action.valid)
    elsif action.valid && action.target
      target = eval("(#{action.valid})#{action.target}")
      [target]
    elsif action.target == "subject"
      [subject]
    elsif action.target && item.for_opponent?
      target = eval("auto_targets_for_opponents#{action.target}")
      [target]
    elsif action.target && item.for_friend?
      target = eval("auto_targets_for_friends#{action.target}")
      [target]
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # * New method: auto_targets_for_opponents
  #--------------------------------------------------------------------------
  def auto_targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    else
      opponents_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * New method: auto_targets_for_friends
  #--------------------------------------------------------------------------
  def auto_targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * New method: id
  #--------------------------------------------------------------------------
  def id
    item ? item.id : 0
  end
end

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
  alias :refresh_ve_automatic_battlers :refresh
  def refresh
    @strategy_list = setup_strategy(get_all_notes)
    refresh_ve_automatic_battlers
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
  # * New method: setup_strategy
  #--------------------------------------------------------------------------
  def setup_strategy(notes)
    valid_list = []
    values = "(\\w+(?: *\\d+ *,? *)*) *, *PRIORITY (\\d+) *, *([\\w ]+)"
    regexp = get_all_values("STRATEGY: #{values}", "STRATEGY")
    notes.scan(regexp) do |action, priority, target, conditions|
      valid = get_valid(conditions)
      list = []
      list += get_auto_action(action)
      list += [priority.to_i]
      list += [get_target(target, valid)]
      list += [get_conditions(conditions)]
      list += [valid]
      valid_list.push(Game_AutoAction.new(*list))
    end
    valid_list
  end
  #--------------------------------------------------------------------------
  # * New method: get_auto_action
  #--------------------------------------------------------------------------
  def get_auto_action(action)    
    result = [true, [guard_skill_id]]  
    result = [true, [attack_skill_id]] if action =~ /^ATTACK/i
    result = [false, get_auto_item(action)] if action =~ /^ITEM/i
    result = [true, get_auto_skill(action)] if action =~ /^SKILL/i
    result
  end
  #--------------------------------------------------------------------------
  # * New method: get_auto_item
  #--------------------------------------------------------------------------
  def get_auto_item(action)
    if action =~ /ITEM ((?: *\d+ *,? *)+)/i
      $1.scan(/\d+/i).collect {|i| i.to_i}
    else
      [guard_skill_id]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_auto_skill
  #--------------------------------------------------------------------------
  def get_auto_skill(action)
    if action =~ /SKILL ((?: *\d+ *,? *)+)/i
      $1.scan(/\d+/i).collect {|i| i.to_i}
    else
      list = usable_skills.collect {|skill| skill.id}
      list.empty? ? [guard_skill_id] : list
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_target
  #--------------------------------------------------------------------------
  def get_target(target, valid)
    if target =~ /SELF/i
      "subject"
    elsif target =~ /HIGHEST (\w+)/i
      ".max_by {|target| target.#{$1.downcase} }"
    elsif target =~ /LOWEST (\w+)/i
      ".min_by {|target| target.#{$1.downcase} }"
    elsif valid != "nil"
      ".random"
    else
      nil
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_conditions
  #--------------------------------------------------------------------------
  def get_conditions(conditions)
    result = []
    basic  = "(\\w+) (\\w+) (\\w+) ([^\\n\\r]+)?"
    regexp = /(?:#{basic}|#{get_filename}|(NONE))/im
    conditions.scan(regexp) do |base, stat, cond, value, code, none|
      if code
        result.push(code.gsub(/\r\n/i, ";"))
      elsif none
        result.push("true")
      elsif base && stat.upcase == "STATE"
        result.push(set_state_condition(base, cond, value))
      elsif base && stat.upcase != "STATE"
        result.push(set_stat_condition(base, stat, cond, value))
      end
    end
    result.empty? ? ["false"] : result
  end
  #--------------------------------------------------------------------------
  # * New method: set_stat_condition
  #--------------------------------------------------------------------------
  def set_stat_condition(target, stat, cond, value)
    if target =~ /SELF/i
      set_base_value(stat.downcase, cond, value, "[self]")
    elsif target =~ /FRIEND/i
      set_base_value(stat.downcase, cond, value, "friends_unit.members")
    elsif target =~ /OPPONENT/i
      set_base_value(stat.downcase, cond, value, "opponents_unit.members")
    else
      "false"
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_base_value
  #--------------------------------------------------------------------------
  def set_base_value(stat, cond, value, list)
    base = get_base_value(stat, cond, value)
    "#{list}.any? {|member| member.#{base} }"
  end
  #--------------------------------------------------------------------------
  # * New method: get_base_value
  #--------------------------------------------------------------------------
  def get_base_value(stat, cond, value)
    if stat =~ /BUFF_(\w+)/i
      "buffs[#{get_param_id($1)}] #{get_cond(cond)} #{value}"
    elsif value =~ /^\d+\%/i && ["HP","MP","TP"].include?(stat.upcase)
      "#{stat.downcase}_rate #{get_cond(cond)} #{value.to_i / 100.0}"
    else
      "#{stat.downcase} #{get_cond(cond)} #{value}"
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_state_condition
  #--------------------------------------------------------------------------
  def set_state_condition(target, cond, value)
    if target =~ /SELF/i
      set_self_state_condition(cond, value)
    elsif target =~ /FRIEND/i
      set_friend_state_condition(cond, value)
    elsif target =~ /OPPONENT/i
      set_opponent_state_condition(cond, value)
    else
      "false"
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_self_state_condition
  #--------------------------------------------------------------------------
  def set_self_state_condition(cond, value)
    "#{cond.upcase == "OFF" ? "!" : ""}state?(#{value})"
  end
  #--------------------------------------------------------------------------
  # * New method: set_friend_state_condition
  #--------------------------------------------------------------------------
  def set_friend_state_condition(cond, value)
    sign  = cond.upcase == "OFF" ? "!friends_unit" : "friends_unit"
    "#{sign}.members.any? {|member| member.state?(#{value}) }"
  end
  #--------------------------------------------------------------------------
  # * New method: set_opponent_state_condition
  #--------------------------------------------------------------------------
  def set_opponent_state_condition(cond, value)
    sign  = cond.upcase == "OFF" ? "!opponents_unit" : "opponents_unit"
    "#{sign}.members.any? {|member| member.state?(#{value}) }"
  end
  #--------------------------------------------------------------------------
  # * New method: get_valid
  #--------------------------------------------------------------------------
  def get_valid(conditions)
    result = "[]"
    regexp = /(?:(\w+) (\w+) (\w+) (\d+))/i
    conditions.scan(regexp) do |base, stat, cond, value|
      if base && stat.upcase == "STATE" && cond.upcase == "ON"
        result += get_state_on_targets(base, value.to_i)
      elsif base && stat.upcase == "STATE" && cond.upcase == "OFF"
        result += get_state_off_targets(base, value.to_i)
      end
    end
    result == "[]" ? nil : result
  end
  #--------------------------------------------------------------------------
  # * New method: get_state_on_targets
  #--------------------------------------------------------------------------
  def get_state_on_targets(base, state_id)
    if base =~ /SELF/i
      " + [self]"
    elsif base =~ /FRIEND/i
      " + subject.friends_with_state(#{state_id})"
    elsif base =~ /OPPONENT/i
      " + subject.opponents_with_state(#{state_id})"
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_state_off_targets
  #--------------------------------------------------------------------------
  def get_state_off_targets(base, state_id)
    if base =~ /SELF/i
      " + [self]"
    elsif base =~ /FRIEND/i
      " + subject.friends_without_state(#{state_id})"
    elsif base =~ /OPPONENT/i
      " + subject.opponents_without_state(#{state_id})"
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # * New method: strategy_list
  #--------------------------------------------------------------------------
  def strategy_list
    @custom_strategy ? @custom_strategy : @strategy_list
  end
  #--------------------------------------------------------------------------
  # * New method: make_auto_action_list
  #--------------------------------------------------------------------------
  def make_auto_action_list
    list = []
    usable_auto_action.each do |item|
      list.push(item.skill? ? set_auto_skill(item) : set_auto_item(item))
    end
    list.push(Game_Action.new(self).set_attack) if list.compact.empty?
    list.compact
  end
  #--------------------------------------------------------------------------
  # * New method: usable_auto_action
  #--------------------------------------------------------------------------
  def usable_auto_action
    list = []
    strategy_list.each do |item|
      next unless item.conditions.all? {|condition| eval(condition) }
      next unless check_valid_target(item)
      list.push(item)
    end
    list
  end
  #--------------------------------------------------------------------------
  # * New method: set_auto_skill
  #--------------------------------------------------------------------------
  def set_auto_skill(item)
    list = []
    item.id.each do |id|
      next unless skill_learn?($data_skills[id.to_i]) ||
                  id.to_i == attack_skill_id || id.to_i == guard_skill_id
      list.push(Game_Action.new(self).set_skill(id.to_i).evaluate_auto(item))
    end
    list.max_by {|action| action.value }
  end
  #--------------------------------------------------------------------------
  # * New method: change_strategy
  #--------------------------------------------------------------------------
  def change_strategy(strategy)
    return unless VE_BASIC_STRATEGY_LIST.keys.include?(strategy)
    @custom_strategy = setup_strategy(VE_BASIC_STRATEGY_LIST[strategy])
  end
  #--------------------------------------------------------------------------
  # * New method: add_strategy
  #--------------------------------------------------------------------------
  def add_strategy(strategy)
    @custom_strategy ||= []
    @custom_strategy += setup_strategy(VE_BASIC_STRATEGY_LIST[strategy])
  end
  #--------------------------------------------------------------------------
  # * New method: clear_strategy
  #--------------------------------------------------------------------------
  def clear_strategy
    @custom_strategy = nil
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
  alias :initialize_ve_automatic_battlers :initialize
  def initialize(index, enemy_id)
    initialize_ve_automatic_battlers(index, enemy_id)
    @strategy_list = setup_strategy(get_all_notes)
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_actions
  #--------------------------------------------------------------------------
  alias :make_actions_ve_automatic_battlers :make_actions
  def make_actions
    if auto_battle? && strategy_list && !strategy_list.empty?
      super
      make_auto_battle_actions
    else
      make_actions_ve_automatic_battlers
    end
  end 
  #--------------------------------------------------------------------------
  # * New method: make_auto_battle_actions
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions[i] = make_auto_action_list.max_by {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: check_valid_target
  #--------------------------------------------------------------------------
  def check_valid_target(action)
    return false if !action.skill?
    object = set_auto_skill(action)
    return false if !object || !usable?(object.item)
    !object.auto_item_target_candidates(action).empty?
  end
  #--------------------------------------------------------------------------
  # * New method: friends_with_state
  #--------------------------------------------------------------------------
  def friends_with_state(state_id)
    $game_troop.members.select {|member| member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: opponents_with_state
  #--------------------------------------------------------------------------
  def opponents_with_state(state_id)
    $game_party.members.select {|member| member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: friends_without_state
  #--------------------------------------------------------------------------
  def friends_without_state(state_id)
    $game_troop.members.select {|member| !member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: opponents_without_state
  #--------------------------------------------------------------------------
  def opponents_without_state(state_id)
    $game_party.members.select {|member| !member.state?(state_id)}
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
  # * Overwrite method: make_auto_battle_actions
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      list = make_action_list
      @actions[i] = list.max_by {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_action_list
  #--------------------------------------------------------------------------
  alias :make_action_list_ve_automatic_battlers :make_action_list
  def make_action_list
    if !strategy_list || strategy_list.empty?
      make_action_list_ve_automatic_battlers
    else
      make_auto_action_list
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_auto_item
  #--------------------------------------------------------------------------
  def set_auto_item(item)
    list = []
    item.id.each do |id|
      next if $game_party.item_number($data_items[id.to_i]) == 0
      list.push(Game_Action.new(self).set_item(id.to_i).evaluate_auto(item))
    end
    list.max_by {|action| action.value }
  end
  #--------------------------------------------------------------------------
  # * New method: check_valid_target
  #--------------------------------------------------------------------------
  def check_valid_target(action)
    object = action.skill? ? set_auto_skill(action) : set_auto_item(action)
    return false if !object || !usable?(object.item)
    !object.auto_item_target_candidates(action).empty?
  end
  #--------------------------------------------------------------------------
  # * New method: friends_with_state
  #--------------------------------------------------------------------------
  def friends_with_state(state_id)
    $game_party.members.select {|member| member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: opponents_with_state
  #--------------------------------------------------------------------------
  def opponents_with_state(state_id)
    $game_troop.members.select {|member| member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: friends_without_state
  #--------------------------------------------------------------------------
  def friends_without_state(state_id)
    $game_party.members.select {|member| !member.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # * New method: opponents_without_state
  #--------------------------------------------------------------------------
  def opponents_without_state(state_id)
    $game_troop.members.select {|member| !member.state?(state_id)}
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
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_automatic_battlers :comment_call
  def comment_call
    call_add_strategy("ACTOR")
    call_add_strategy("ENEMY")
    call_strategy_change("ACTOR")
    call_strategy_change("ENEMY")
    comment_call_ve_automatic_battlers
  end  
  #--------------------------------------------------------------------------
  # * New method: call_add_strategy
  #--------------------------------------------------------------------------
  def call_add_strategy(type)
    command = "#{type} ADD STRATEGY"
    values  = "(\\w+(?: *\\d+ *,? *)* *, *PRIORITY \\d+ *, *[\\w ]+)"
    regexp  = get_all_values("#{command} (\\d+): #{values}", command)
    note.scan(regexp) do |id, setting, conditions|
      subject = $game_actors[id.to_i]        if type.upcase == "ACTOR"
      subject = $game_troop.enemies[id.to_i] if type.upcase == "ENEMY"
      next unless subject
      strategy = "<STRATEGY: #{setting}>#{conditions}</STRATEGY>"
      subject.add_strategy(strategy)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_strategy_change
  #--------------------------------------------------------------------------
  def call_strategy_change(type)
    regexp = /<#{type} STRATEGY CHANGE (\d+): (\w+)>/i
    note.scan(regexp) do |id, strategy|
      subject = $game_actors[id.to_i]        if type.upcase == "ACTOR"
      subject = $game_troop.enemies[id.to_i] if type.upcase == "ENEMY"
      next unless subject
      subject.change_strategy(strategy.downcase.to_sym)
    end
  end
end

#==============================================================================
# ** Game_AutoAction
#------------------------------------------------------------------------------
#  This class handles automatic actions data.
#==============================================================================

class Game_AutoAction
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :id
  attr_reader   :priority
  attr_reader   :conditions
  attr_reader   :target
  attr_reader   :valid
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(skill, id, priority, target, conditions, valid = nil)
    @skill      = skill
    @id         = id
    @priority   = priority
    @target     = target
    @conditions = conditions
    @valid      = valid
  end
  #--------------------------------------------------------------------------
  # * skill
  #--------------------------------------------------------------------------
  def skill?
    @skill
  end
end