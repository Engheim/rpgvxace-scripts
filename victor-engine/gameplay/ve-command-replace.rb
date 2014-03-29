#==============================================================================
# ** Victor Engine - Command Replace
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.06 > First release
#------------------------------------------------------------------------------
#  This script allows to setup a trait that replace commands from the actor
# command list with other commands. It's also possible to setup a condition
# for the command to be replaced
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#   If used with 'Victor Engine - Direct Commands' place this bellow it.
#   If used with 'Victor Engine - Item Command' place this bellow it.
#
# * Alias methods
#   class Window_ActorCommand < Window_Command
#     def make_command_list
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Weapons, Armors and States note boxes.
#
#  <command replace: x>
#  settings
#  </command replace>
#   Replace the command with name x with another command.
#     x = name of the command to be replaced
#     add the following values for the setting
#       name: *;      : Name of the new command
#       type: *;      : Type of the new command (see bellow)
#       ext: *;       : Extension of the new command (see bellow, opitional)
#       condition: *; : Custom condition, can be any valid ruby code, you can
#                       use "a" to refer to the actor (opitional)
#
#         The type of the command must be one of the follower values:
#          attack, guard, skill, item, direct
#           attack  : if the new command is a physical attack
#           guard   : if the new command is a guard action
#           skill   : if the new command is a list of skill, require ext
#           item    : if the new command is use item, if using the script
#                     'Item Command' you can set a ext, then only items from
#                     that type will be available
#           direct skill : if the new command is a direct skill, require the 
#                          script "Direct Commands", require ext
#           direct item  : if the new command is a direct item, require the
#                          script "Direct Commands", require ext
#
#         The ext is an additional info for the command, when the command
#         is a skill list, setup the skill type id, when the command is
#         a direct item or skill, decide wich skill will be used.
#
#------------------------------------------------------------------------------
# Examples:
#
#  <command replace: Attack>
#  name: Limit;
#  type: skill;
#  ext: 4;
#  condition: a.tp == 100;
#  </command replace>
#   Replace the 'Attack' command with the command 'Limit', wich allows to select
#   skills from the skill type 4, when the actor to equal 100.
#
#  <command replace: Magic>
#  name: Arcane;
#  type: skill;
#  ext: 2;
#  condition; a.state?(25);
#  </command replace>
#   Replace the Magic command with the command 'Arcane' wich allows to select
#   skills from the skill type 2, while the actor is under the state id 25.
#   This didn't actually changed the command, just changed the name.
#
#  <command replace: Steal>
#  name: Mug;
#  type: direct;
#  ext: 100;
#  </command replace>
#   Replace the Steal command with the command 'Mug' wich allows use the skill
#   id 100 directly from the command menu (require script "Direct Commands")
#   This one don't have a condition, so you can place maybe on an equipment
#   to "upgrade" the command.
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
$imported[:ve_command_replace] = 1.00
Victor_Engine.required(:ve_command_replace, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Window_Command
#------------------------------------------------------------------------------
#  This window deals with general command choices.
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # * New method: replace_commands
  #--------------------------------------------------------------------------
  def replace_commands
    @list = @list.collect do |cmd|
      new_command = replace_command(cmd)
      new_command ? new_command : cmd
    end
  end
  #--------------------------------------------------------------------------
  # * New method: replace_command
  #--------------------------------------------------------------------------
  def replace_command(cmd)
    text    = "COMMAND REPLACE"
    regepx  = get_all_values("#{text}: #{cmd[:name]}", text)
    result  = @actor.get_all_notes.scan(regepx).collect do
      value = $1.dup
      setup_new_command(value) if new_command_condition(value)
    end
    result.compact.empty? ? nil : result.first
  end
  #--------------------------------------------------------------------------
  # * New method: new_command_condition
  #--------------------------------------------------------------------------
  def new_command_condition(value)
    a = @actor
    eval(value =~ /CONDITION:([^;]*);/i ? $1 : "true")
  end
  #--------------------------------------------------------------------------
  # * New method: setup_new_command
  #--------------------------------------------------------------------------
  def setup_new_command(value)
    new_command = {}
    new_command[:name]    = value =~ /NAME: ([\w ]+)/i ? $1.dup : ""
    new_command[:symbol]  = value =~ /TYPE: ([\w ]+)/i ? make_symbol($1) : :nil
    new_command[:ext]     = value =~ /EXT: ([\w ]+)/i  ? eval($1) : nil
    new_command[:enabled] = setup_usable(new_command)
    new_command
  end
  #--------------------------------------------------------------------------
  # * New method: setup_usable
  #--------------------------------------------------------------------------
  def setup_usable(cmd)
    case cmd[:symbol]
    when :attack
      @actor.attack_usable?
    when :guard
      @actor.guard_usable?
    when :direct_skill
      @actor.usable?($data_skills[cmd[:ext]])
    when :direct_item
      @actor.usable?($data_items[cmd[:ext]])
    when :skill, :item
      true
    else
      false
    end
  end
end

#==============================================================================
# ** Window_SkillCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (special attacks, magic, etc.) on the
# skill screen.
#==============================================================================

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Criaзгo da lista de comandos
  #--------------------------------------------------------------------------
  alias :make_command_list_ve_command_replace :make_command_list
  def make_command_list
    return unless @actor
    make_command_list_ve_command_replace
    replace_commands
  end
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Alias method: make_command_list
  #--------------------------------------------------------------------------
  alias :make_command_list_ve_command_replace :make_command_list
  def make_command_list
    return unless @actor
    make_command_list_ve_command_replace
    replace_commands
  end
end