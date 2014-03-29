#==============================================================================
# ** Victor Engine - Actor Events
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.30 > First release
#  v 1.01 - 2013.02.13 > Added <actor face> notetag
#------------------------------------------------------------------------------
#  This script allows to setup events to have the same character graphic as
# actors with a single comment. This can be used to make easier to create
# cutscenes with the party actors when your party changes a lot.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#
# * Alias methods
#   class Game_Event < Game_Character
#     def setup_page_settings
#
#   class Scene_Map
#     def start
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment Boxes note tags:
#   Tags to be used on Events Comment boxes. The comment boxes are different 
#   from the comment call, they're called always the even refresh.
# 
#  <actor event: x>
#   This tag allows to setup the event to have the graphic of the actor
#   based on their database IDs.
#     x : id of the actor
#
#  <party event: x>
#   This tag allows to setup the event to have the graphic of the actor
#   based on the position on the party
#     x : postion in party
#
#  <actor face>
#    Use this before the message to show the current actor face on the message
#    window. This should be used before every instance of the message window
#    since it's cleared automatically after every page.
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
$imported[:ve_actor_event] = 1.01
Victor_Engine.required(:ve_actor_event, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that displays text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :event_face_name
  attr_accessor :event_face_index
  #--------------------------------------------------------------------------
  # * New method: face_name
  #--------------------------------------------------------------------------
  def face_name
    return event_face_name if event_face_name
    @face_name
  end 
  #--------------------------------------------------------------------------
  # * New method: face_index
  #--------------------------------------------------------------------------
  def face_index
    return event_face_index if event_face_index
    @face_index
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :face_name
  attr_reader   :face_index
  #--------------------------------------------------------------------------
  # * Alias method: setup_page_settings
  #--------------------------------------------------------------------------
  alias :setup_page_settings_ve_actor_event :setup_page_settings
  def setup_page_settings
    setup_page_settings_ve_actor_event
    setup_event_actor_graphic
  end
  #--------------------------------------------------------------------------
  # * New method: setup_event_actor_graphic
  #--------------------------------------------------------------------------
  def setup_event_actor_graphic
    @actor = nil
    @actor = $game_actors[$1.to_i]            if note =~ /<ACTOR EVENT: (\d+)>/i
    @actor = $game_party.members[$1.to_i - 1] if note =~ /<PARTY EVENT: (\d+)>/i
    @priority_type   = 1 if @actor && !@actor.face_name.empty?
    @face_name       = @actor ? @actor.face_name  : nil
    @face_index      = @actor ? @actor.face_index : nil
    @character_name  = @actor.character_name  if @actor
    @character_index = @actor.character_index if @actor
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
  alias :comment_call_ve_actor_event :comment_call
  def comment_call
    call_event_face
    comment_call_ve_actor_event
  end
  #--------------------------------------------------------------------------
  # * New method: call_return_to_safe_position
  #--------------------------------------------------------------------------
  def call_event_face
    return unless note =~ /<ACTOR FACE>/i
    $game_message.event_face_name  = $game_map.events[@event_id].face_name
    $game_message.event_face_index = $game_map.events[@event_id].face_index
  end
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Limpeza das flags
  #--------------------------------------------------------------------------
  alias :clear_flags_ve_actor_event :clear_flags
  def clear_flags
    clear_flags_ve_actor_event
    $game_message.event_face_name  = nil
    $game_message.event_face_index = nil
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Alias method: setup_page_settings
  #--------------------------------------------------------------------------
  alias :start_ve_actor_event :start
  def start
    $game_map.events.values.each {|event| event.setup_event_actor_graphic }
    start_ve_actor_event
  end
end