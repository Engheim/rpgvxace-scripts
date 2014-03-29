#==============================================================================
# ** Victor Engine - Direct Commands
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.04 > First release
#  v 1.01 - 2012.11.03 > Fixed issue with dual wield and different weapons.
#                      > Compatibility with Target Arrow
#  v 1.02 - 2012.12.13 > Fixed issue when canceling actions
#------------------------------------------------------------------------------
#  This script allows to set skills or items to be used directly when selecting 
# the commands, so the skill or item selection menu won't be opened. Useful to
# make commands with special effects, such as 'Steal'.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module'
#
# * Alias methods
#   class Window_SkillCommand < Window_Command
#     def make_command_list
#
#   class Window_SkillList < Window_Selectable
#     def make_item_list
#
#   class Window_ActorCommand < Window_Command
#     def add_attack_command
#
#   class Scene_Battle < Scene_Base
#     def create_actor_command_window
#     def on_actor_cancel
#     def on_enemy_cancel
#
#------------------------------------------------------------------------------
# Actors, Classes, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Weapons, Armors and States note boxes.
#
#  <direct skill: x>
#  <direct skill: x, y>
#   Add direct command skill to the actor list
#    x : skill id
#    y : condition, should be equal usable or learned. optional
#
#  <direct item: x>
#  <direct item: x, y>
#   Add direct command item to the actor list
#    x : item id
#    y : condition, should be equal usable or possession. opitional
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Additional instructions:
#  
#  The skills and items costs and requirements for use still valid for direct
#  commands actions. So if an action consume MP, it will not be usable if
#  the is lower than required.
#
#  Costs are still consumed normall.
#
#  If the conditions usable, learned (for skills) or possession (for items)
#  are set, the commands will not show up until the condition is met.
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
$imported[:ve_direct_commands] = 1.02
Victor_Engine.required(:ve_direct_commands, :ve_basic_module, 1.00, :above)
Victor_Engine.required(:ve_direct_commands, :ve_command_replace, 1.00, :bellow)

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * New method: direct_skill_commands
  #--------------------------------------------------------------------------
  def direct_skills
    regexp  = /<DIRECT SKILL: (\d+)(?: *, *(\w+))?>/i
    skills  = get_all_notes.scan(regexp).collect {|id, cond|  [id, cond] } 
    list    = skills.collect do |id, cond|
      skill = $data_skills[id.to_i]
      direct_skill?(cond, skill) ? skill : nil
    end
    list.compact
  end
  #--------------------------------------------------------------------------
  # * New method: direct_item_commands
  #--------------------------------------------------------------------------
  def direct_items
    regexp  = /<DIRECT ITEM: (\d+)(?: *, *(\w+))?>/i
    items   = get_all_notes.scan(regexp).collect {|id, cond|  [id, cond] } 
    list    = items.collect do |id, cond|
      skill = $data_items[id.to_i]
      direct_item?(cond, item) ? item : nil
    end
    list.compact
  end
  #--------------------------------------------------------------------------
  # * New method: usable_skill?
  #--------------------------------------------------------------------------
  def direct_skill?(value, skill)
    return true if value.nil?
    return true if value =~ /LEARNED/i && skill_learn?(skill)
    return true if value =~ /USABLE/i  && usable?(skill)
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: usable_skill?
  #--------------------------------------------------------------------------
  def direct_item?(value, item)
    return true if value.nil?
    return true if value =~ /POSSESSION/i && $game_party.has_item?(item)
    return true if value =~ /USABLE/i && usable?(item)
    return false
  end
end

#==============================================================================
# ** Window_SkillCommand
#------------------------------------------------------------------------------
#  Esta janela exibe a lista de comandos para tela de habilidades 
# (como habilidades especiais e magias).
#==============================================================================

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Criaзгo da lista de comandos
  #--------------------------------------------------------------------------
  alias :make_command_list_ve_direct_commands :make_command_list
  def make_command_list
    return unless @actor
    make_command_list_ve_direct_commands
    @actor.direct_skills.each do |skill|
      add_command(skill.name, :direct_skill, true, skill.id)
    end
    @actor.direct_items.each do |item|
      add_command(item.name, :direct_item, true, item.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Criaзгo da lista de comandos
  #--------------------------------------------------------------------------
  def update_help
    item = $data_skills[current_ext] if current_symbol == :direct_skill
    item = $data_items[current_ext]  if current_symbol == :direct_item
    @help_window.set_item(item)
  end
end

#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills on the skill screen.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: make_item_list
  #--------------------------------------------------------------------------
  alias :make_item_list_ve_direct_commands :make_item_list
  def make_item_list
    make_item_list_ve_direct_commands
    @actor ? @data -= @actor.direct_skills : @data
  end
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Alias method: add_attack_command
  #--------------------------------------------------------------------------
  alias :add_attack_command_ve_direct_commands :add_attack_command
  def add_attack_command
    add_attack_command_ve_direct_commands
    @actor.direct_skills.each do |s|
      add_command(s.name, :direct_skill, @actor.usable?(s), s.id)
    end
    @actor.direct_items.each do |i|
      add_command(i.name, :direct_item, @actor.usable?(i), i.id)
    end
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: create_actor_command_window
  #--------------------------------------------------------------------------
  alias :create_command_window_ve_direct_commands :create_actor_command_window
  def create_actor_command_window
    create_command_window_ve_direct_commands
    @actor_command_window.set_handler(:direct_skill,  method(:direct_skill))
    @actor_command_window.set_handler(:direct_item,  method(:direct_item))
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_actor_cancel
  #--------------------------------------------------------------------------
  alias :on_actor_cancel_ve_direct_commands :on_actor_cancel
  def on_actor_cancel
    on_actor_cancel_ve_direct_commands
    case @actor_command_window.current_symbol
    when :direct_skill, :direct_item
      @actor_command_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_enemy_cancel
  #--------------------------------------------------------------------------
  alias :on_enemy_cancel_ve_direct_commands :on_enemy_cancel
  def on_enemy_cancel
    on_enemy_cancel_ve_direct_commands
    case @actor_command_window.current_symbol
    when :direct_skill, :direct_item
      @actor_command_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # * New method: direct_skill
  #--------------------------------------------------------------------------  
  def direct_skill
    skill_id = @actor_command_window.current_ext
    BattleManager.actor.input.set_skill(skill_id)
    skill = $data_skills[skill_id]
    set_window_action(skill) if $imported[:ve_target_arrow]
    if !skill.need_selection?
      next_command
    elsif skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # * New method: direct_item
  #--------------------------------------------------------------------------  
  def direct_item
    item_id = @actor_command_window.current_ext
    BattleManager.actor.input.set_item(item_id)
    item = $data_items[item_id]
    set_window_action(item) if $imported[:ve_target_arrow]
    if !item.need_selection?
      next_command
    elsif item.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
end