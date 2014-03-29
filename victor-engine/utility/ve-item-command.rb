#==============================================================================
# ** Victor Engine - Item Command
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.08.05 > First release
#------------------------------------------------------------------------------
#  This scripts allows to setup different item types and to setup commands
# where the player can select only items from a pre-defined type. It
# also allows to setup different items cattegories on the item menu
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#
# * Overwrite methods
#   class RPG::Item < RPG::UsableItem
#     def key_item?
#
#   class Window_ItemCategory < Window_HorzCommand
#     def col_max
#     def make_command_list
#
#   class Window_ItemList < Window_Selectable
#     def include?(item)
#
#   class Window_BattleItem < Window_ItemList
#     def include?(item)
#
#   class Window_ActorCommand < Window_Command
#     def add_item_command
#
# * Alias methods
#   class Game_System
#     def initialize
#
#   class Scene_Battle < Scene_Base
#     def command_item
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
#  <usable item type: x>
#  <usable item type: x, x>
#   Setup a list of usable item type for the actor.
#     x : item type id
#
#------------------------------------------------------------------------------
# Items, Weapons and Armors note tags:
#   Tags to be used on Items, Weapons and Armors note boxes.
#
#  <item type: x>
#  <item type: x, x>
#   Setup a list of item type ids for the item.
#     x : item type id
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  When adding the <usable item type: x> tag, the default item command will
#  be removed, if you want to have the custom item types + the default
#  item command, add the default command as a usable type with the tag.
#
#  When adding the <item type: x> tag, the database setup for item will be
#  ignored, if you want to add multiple types while keeping the database type
#  (Normal or Key Item), add them as item type using the tag
#
#  Assigin the tag <item type: x> for equipment will not make them usable.
#  Just will list them within the item type set.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Initializing $data_system. Don't change.
  #--------------------------------------------------------------------------
  $data_system = load_data('Data/System.rvdata2')
  #--------------------------------------------------------------------------
  # * Setup the list of options available on the Items menu
  #   add the item type set on VE_ITEM_TYPES.
  #--------------------------------------------------------------------------
  VE_MENU_LIST = [:potions, :food, :battle, :weapon, :armor, :key_item]
  #--------------------------------------------------------------------------
  # * Setup the item types
  #   Set here the values for the new item types.
  #     type: {id: x, name: y, help: z},
  #     type:    : item type, used on the VE_MENU_LIST
  #     id: x    : type id, used on the note tags to assign a item type
  #     name: y  : Name displayed on the command and category windows
  #     help: z  : Help message displayed on the item menu
  #--------------------------------------------------------------------------
  VE_ITEM_TYPES = {
    # These are the settings for default items and key items, avoid change
    item:     {id: 1, name: Vocab::item,     help: "List of all Items"},
    key_item: {id: 2, name: Vocab::key_item, help: "List of all Key Items"},
    weapon:   {id: 3, name: Vocab::weapon,   help: "List of all Weapons"},
    armor:    {id: 4, name: Vocab::armor,    help: "List of all Armors"},
    # type:   {id: x, name: y, help: z},
    potions:  {id: 5, name: "Potions", help: "List of Potions"},
    food:     {id: 6, name: "Food",    help: "List of Foods"},
    battle:   {id: 7, name: "Battle",  help: "List of Battle Items"},
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Setup non usable item display on battle
  #   If true, not usable items will be displayed in battle.
  #--------------------------------------------------------------------------
  VE_SHOW_NON_USABLE = false
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
$imported[:ve_item_command] = 1.00
Victor_Engine.required(:ve_item_command, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** RPG::Item
#------------------------------------------------------------------------------
#  This is the data class for items.
#==============================================================================

class RPG::Item < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * Overwrite method: key_item?
  #--------------------------------------------------------------------------
  def key_item?
    type_set.include?(VE_ITEM_TYPES[:key_item][:id])
  end
  #--------------------------------------------------------------------------
  # * New method: normal_item?
  #--------------------------------------------------------------------------
  def normal_item?
    type_set.include?(VE_ITEM_TYPES[:item][:id])
  end
  #--------------------------------------------------------------------------
  # * New method: type_set
  #--------------------------------------------------------------------------
  def type_set
    if note =~ /<ITEM TYPE: ((?:\d+ *,? *)+)>/i
      $1.scan(/(\d+)/i).inject([]) {|r, i|  r += i }.collect {|i| i.to_i }
    else
      [itype_id]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: itype_id?
  #--------------------------------------------------------------------------
  def itype_id?(symbol)
    type_set.include?(VE_ITEM_TYPES[symbol][:id])
  end
end

#==============================================================================
# ** RPG::EquipItem
#------------------------------------------------------------------------------
#  This is the superclass of weapons and armor.
#==============================================================================

class RPG::EquipItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: type_set
  #--------------------------------------------------------------------------
  def type_set
    if note =~ /<ITEM TYPE: ((?:\d+ *,? *)+)>/i
      $1.scan(/(\d+)/i).inject([]) {|r, i|  r += i }.collect {|i| i.to_i }
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # * New method: itype_id?
  #--------------------------------------------------------------------------
  def itype_id?(symbol)
    type_set.include?(VE_ITEM_TYPES[symbol][:id])
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system-related data. Also manages vehicles and BGM, etc.
# The instance of this class is referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :menu_list
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_item_command :initialize
  def initialize
    initialize_ve_item_command
    @menu_list = VE_MENU_LIST.dup
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
  # * New method: added_item_types
  #--------------------------------------------------------------------------
  def added_item_types
    if note =~ /<USABLE ITEM TYPE: ((?:\d+ *,? *)+)>/i
      get_item_types($1)
    else
      [:item]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_item_types
  #--------------------------------------------------------------------------
  def get_item_types(value)
    list = get_itype_id(value).sort
    type = VE_ITEM_TYPES
    type.keys.select {|symbol| list.include?(type[symbol][:id])  }
  end
  #--------------------------------------------------------------------------
  # * New method: get_itype_id
  #--------------------------------------------------------------------------
  def get_itype_id(value)
    value.scan(/(\d+)/i).inject([]) {|r, i|  r += i }.collect {|i| i.to_i }
  end
end

#==============================================================================
# ** Window_ItemCategory
#------------------------------------------------------------------------------
#  This window is for selecting a category of normal items and equipment
# on the item screen or shop screen.
#==============================================================================

class Window_ItemCategory < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    $game_system.menu_list.size
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    $game_system.menu_list.each do |symbol|
      value = VE_ITEM_TYPES[symbol]
      add_command(value[:name], symbol, true, value[:help])
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_help
  #--------------------------------------------------------------------------
  def update_help
    text = current_ext ? current_ext : ""
    @help_window.set_text(text)
  end  
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of party items on the item screen.
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: include?
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && item.normal_item?
    when :key_item
      item.is_a?(RPG::Item) && item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    else
      item && item.itype_id?(@category)
    end
  end
end

#==============================================================================
# ** Window_BattleItem
#------------------------------------------------------------------------------
#  This window is for selecting items to use in the battle window.
#==============================================================================

class Window_BattleItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Overwrite method: include?
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.itype_id?(@category) && (VE_SHOW_NON_USABLE ||
    $game_party.usable?(item))
  end
end

#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Overwrite method: add_item_command
  #--------------------------------------------------------------------------
  def add_item_command
    @actor.added_item_types.each do |symbol|
      value = VE_ITEM_TYPES[symbol]
      add_command(value[:name], :item, true, value[:id])
    end    
  end
  #--------------------------------------------------------------------------
  # * New method: get_category
  #--------------------------------------------------------------------------
  def get_category
    type = VE_ITEM_TYPES
    type.keys.select {|symbol| current_ext == type[symbol][:id] }.first
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: command_item
  #--------------------------------------------------------------------------
  alias :command_item_ve_item_command :command_item
  def command_item
    @item_window.category = @actor_command_window.get_category
    command_item_ve_item_command
  end
end