#==============================================================================
# ** Victor Engine - Events Conditions
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.15 > First release
#  v 1.01 - 2012.08.02 > Compatibility with Basic Module 1.27
#------------------------------------------------------------------------------
#  This script allows to set custom conditions for event pages, you can use
# any valid script code as the condition for the page to start.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#
# * Alias methods
#   class Game_Event < Game_Character
#     def refresh
#     def update
#     def conditions_met?(page)
#
#   class Game_Troop < Game_Unit
#     def setup(troop_id)
#     def conditions_met?(page)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Event and Battle Comment boxes note tags:
#   Tags to be used on events and troops Comment boxes.
#
#  <event condition>
#  string
#  string
#  </event condition>
#    You can set a custom condition based on script code. Replace the string
#    withe the code that will be evaluted.
#
#------------------------------------------------------------------------------
# Additional instructions:
#  
#  The other page conditions for the event are still valid, you can add any
#  code to the string and it will be evaluted.
#  Ex.:
#    <event condition>
#    $game_party.steps > 10 && $game_system.battle_count == 10
#    </event condition>
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
$imported[:ve_event_condition] = 1.01
Victor_Engine.required(:ve_event_condition, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_event_condition :refresh
  def refresh
    @has_condition = has_custom_condition?
    refresh_ve_event_condition
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_event_condition :update
  def update
    update_ve_event_condition
    refresh if need_refresh?
  end
  #--------------------------------------------------------------------------
  # * Alias method: conditions_met?
  #--------------------------------------------------------------------------
  alias :conditions_met_ve_event_condition? :conditions_met?
  def conditions_met?(page)
    result = conditions_met_ve_event_condition?(page)
    return false if @has_condition && custom_condition_not_met(page)
    result
  end
  #--------------------------------------------------------------------------
  # * New method: has_custom_condition?
  #--------------------------------------------------------------------------
  def has_custom_condition?
    @event.pages.find {|page| custom_condition_not_met(page) }
  end
  #--------------------------------------------------------------------------
  # * New method: need_refresh?
  #--------------------------------------------------------------------------
  def need_refresh?
    return false if !@has_condition or Graphics.frame_count % 5 != 0
    new_page = @erased ? nil : find_proper_page
    !new_page || new_page != @page
  end
  #--------------------------------------------------------------------------
  # * New method: custom_condition_not_met
  #--------------------------------------------------------------------------
  def custom_condition_not_met(page)
    notes  = page_note(page)    
    regexp = get_all_values("EVENT CONDITION")
    notes.scan(regexp) { return true if eval("!(#{$1})") }
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: page_note
  #--------------------------------------------------------------------------
  def page_note(page)
    return "" if !page || !page.list || page.list.size <= 0
    comment_list = []
    page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    comment_list.join(";")
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_event_condition :setup
  def setup(troop_id)
    setup_ve_event_condition(troop_id)
    @has_condition = has_custom_condition?
  end
  #--------------------------------------------------------------------------
  # * Alias method: conditions_met?
  #--------------------------------------------------------------------------
  alias :conditions_met_ve_event_condition? :conditions_met?
  def conditions_met?(page)
    result = conditions_met_ve_event_condition?(page)
    return false if @has_condition && custom_condition_not_met(page)
    result
  end
  #--------------------------------------------------------------------------
  # * New method: has_custom_condition?
  #--------------------------------------------------------------------------
  def has_custom_condition?
    troop.pages.find {|page| custom_condition_not_met(page) }
  end
  #--------------------------------------------------------------------------
  # * New method: custom_condition_not_met
  #--------------------------------------------------------------------------
  def custom_condition_not_met(page)
    notes  = page_note(page)
    regexp = get_all_values("EVENT CONDITION")
    notes.scan(regexp) { return true if eval("!(#{$1})") }
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: page_note
  #--------------------------------------------------------------------------
  def page_note(page)
    return "" if !page || !page.list || page.list.size <= 0
    comment_list = []
    page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    comment_list.join(";")
  end
end