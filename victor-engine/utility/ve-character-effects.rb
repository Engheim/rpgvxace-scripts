#==============================================================================
# ** Victor Engine - Character Effects
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.01 > First release
#  v 1.01 - 2012.01.07 > Player setting carry over Saves
#  v 1.02 - 2012.01.15 > Fixed the positive sign on some Regular Expressions
#------------------------------------------------------------------------------
#  This scripts allows to set a different effects for the characters.
# It's possible to change the hue, opacity, zoom and tone from events
# vehicles, player and followers
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.05 or higher
#   If used with 'Victor Engine - Follower Options' place this bellow it.
#
# * Alias methods
#   class Game_CharacterBase
#     def init_public_members
#     def init_private_members
#     def update
#
#   class Game_Event < Game_Character
#     def clear_starting_flag
#
#   class Game_Follower < Game_Character
#     def update
#
#   class Sprite_Character < Sprite_Base
#     def initialize(viewport, character = nil)
#     def graphic_changed?
#     def set_character_bitmap
#     def update_other
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
#  Tags to be used in events comment box, works like a script call.
#
#  <event hue i: x, d>
#   This tag allows to change gradually the event hue
#     i : event ID
#     x : hue (0-320) 
#     d : wait until complete change (60 frames = 1 second)
#
#  <event opacity i: x, d>
#   This tag allows to change gradually the event opacity
#     i : event index
#     x : opacity (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <event zoom i: x, y, d>
#   This tag allows to change gradually the event zoom
#     i : event ID
#     x : horizontal zoom. (default = 100)
#     y : vetical zoom.    (default = 100)
#     d : wait until complete change (60 frames = 1 second)
#
#  <event tone i: r, g, b, y, d>
#   This tag allows to change gradually the event opacity
#     i : event ID
#     r : red tone   (0-255, can be negative)
#     g : green tone (0-255, can be negative)
#     b : blue tone  (0-255, can be negative)
#     y : gray tone  (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <actor hue i: x, d>
#   This tag allows to change gradually the actor hue
#     i : actor index
#     x : hue (0-320) 
#     d : wait until complete change (60 frames = 1 second)
#
#  <actor opacity i: x, d>
#   This tag allows to change gradually the actor opacity
#     i : actor index
#     x : opacity (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <actor zoom i: x, y, d>
#   This tag allows to change gradually the actor zoom
#     i : actor index
#     x : horizontal zoom. (default = 100)
#     y : vetical zoom.    (default = 100)
#     d : wait until complete change (60 frames = 1 second)
#
#  <actor tone i: r, g, b, y, d>
#   This tag allows to change gradually the actor opacity
#     i : actor index
#     r : red tone   (0-255, can be negative)
#     g : green tone (0-255, can be negative)
#     b : blue tone  (0-255, can be negative)
#     y : gray tone  (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <party hue: d, x, d>
#   This tag allows to change gradually the whole party hue
#     x : hue (0-320) 
#     d : wait until complete change (60 frames = 1 second)
#
#  <party opacity: x, d>
#   This tag allows to change gradually the whole party opacity
#     x : opacity (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <party zoom: x, y, d>
#   This tag allows to change gradually the whole party zoom
#     x : horizontal zoom. (default = 100)
#     y : vetical zoom.    (default = 100)
#     d : wait until complete change (60 frames = 1 second)
#
#  <party tone: r, g, b, y, d>
#   This tag allows to change gradually the whole party opacity
#     r : red tone   (0-255, can be negative)
#     g : green tone (0-255, can be negative)
#     b : blue tone  (0-255, can be negative)
#     y : gray tone  (0-255)
#     d : wait until complete change (60 frames = 1 second)
#
#  <vehicle type hue: d, x, d>
#   This tag allows to change gradually the vehicle hue
#     type : vehicle type name
#     x    : hue (0-320) 
#     d    : wait until complete change (60 frames = 1 second)
#
#  <vehicle type opacity: x, d>
#   This tag allows to change gradually the vehicle opacity
#     type : vehicle type name
#     x    : opacity (0-255)
#     d    : wait until complete change (60 frames = 1 second)
#
#  <vehicle type zoom: x, y, d>
#   This tag allows to change gradually the vehicle zoom
#     type : vehicle type name
#     x    : horizontal zoom. (default = 100)
#     y    : vetical zoom.    (default = 100)
#     d    : wait until complete change (60 frames = 1 second)
#
#  <vehicle type tone: r, g, b, y, d>
#   This tag allows to change gradually the vehicle opacity
#     type : vehicle type name
#     r    : red tone   (0-255, can be negative)
#     g    : green tone (0-255, can be negative)
#     b    : blue tone  (0-255, can be negative)
#     y    : gray tone  (0-255)
#     d    : wait until complete change (60 frames = 1 second)
#
#------------------------------------------------------------------------------
# Comment boxes note tags:
#   Tags to be used on events Comment boxes. They're different from the
#   comment call, they're called always the even refresh.
#
#  <self hue: x>
#   This tag allows to set the event hue
#     x : hue (0-320) 
#
#  <self opacity: x>
#   This tag allows to set the event opacity
#     x : opacity (0-255)
#
#  <self blend: x>
#   This tag allows to set the event blend type
#     x : blend type (0: normal, 1: add, 2: subtract)
#
#  <self zoom: x, y>
#   This tag allows to set the event zoom
#     x : horizontal zoom. (default = 100)
#     y : vetical zoom.    (default = 100)
#
#  <self tone: r, g, b, y>
#   This tag allows to set the event opacity
#     r  : red tone   (0-255, can be negative)
#     g  : green tone (0-255, can be negative)
#     b  : blue tone  (0-255, can be negative)
#     y  : gray tone  (0-255)
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
$imported[:ve_character_effects] = 1.02
Victor_Engine.required(:ve_character_effects, :ve_basic_module, 1.05, :above)

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :blend
  attr_accessor :tone
  attr_accessor :hue
  attr_accessor :opacity
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_character_effects :setup
  def setup(actor_id)
    setup_ve_character_effects(actor_id)
    @blend   = 0
    @hue     = 0  
    @opacity = 255
    @zoom_x  = 100.0
    @zoom_y  = 100.0
    @tone    = Tone.new
  end
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :hue
  attr_reader   :tone
  attr_reader   :zoom_x
  attr_reader   :zoom_y
  #--------------------------------------------------------------------------
  # * Alias method: init_public_members
  #--------------------------------------------------------------------------
  alias :init_public_members_ve_character_effects :init_public_members
  def init_public_members
    init_public_members_ve_character_effects
    @hue    = 0
    @tone   = Tone.new
    @zoom_x = 100.0
    @zoom_y = 100.0
  end
  #--------------------------------------------------------------------------
  # * Alias method: init_private_members
  #--------------------------------------------------------------------------
  alias :init_private_members_ve_character_effects :init_private_members
  def init_private_members
    init_private_members_ve_character_effects
    @opacity_duration = 0
    @zoom_x_duration  = 0
    @zoom_y_duration  = 0
    @tone_duration    = 0
    @hue_duration     = 0
    @opacity_target = 0
    @zoom_x_target  = 0
    @zoom_y_target  = 0
    @hue_target     = 0
    @tone_target    = Tone.new
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_character_effects :update
  def update
    update_hue
    updade_tone
    updade_zoom_x
    updade_zoom_y
    update_opacity
    update_ve_character_effects
  end
  #--------------------------------------------------------------------------
  # * New method: blend_type=
  #--------------------------------------------------------------------------
  def blend_type=(n)
    @blend_type = n
  end
  #--------------------------------------------------------------------------
  # * New method: start_hue_change
  #--------------------------------------------------------------------------
  def start_hue_change(hue, duration)
    @hue_duration = duration
    @hue_target   = hue
    @hue = @hue_target if @hue_duration == 0
  end 
  #--------------------------------------------------------------------------
  # * New method: start_opacity_change
  #--------------------------------------------------------------------------
  def start_opacity_change(opacity, duration)
    @opacity_duration = duration
    @opacity_target   = opacity
    @opacity = @opacity_target if @opacity_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: start_tone_change
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_duration = duration
    @tone_target   = tone
    @tone = @tone_target if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: start_zoom_change
  #--------------------------------------------------------------------------
  def start_zoom_change(x, y, duration)
    @zoom_x_duration = duration
    @zoom_y_duration = duration
    @zoom_x_target   = x
    @zoom_y_target   = y
    @zoom_x = @zoom_x_target if @zoom_x_duration == 0
    @zoom_y = @zoom_y_target if @zoom_y_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_hue
  #--------------------------------------------------------------------------
  def update_hue
    return if @hue_duration == 0
    d = @hue_duration 
    @hue = (@hue * (d - 1) + @hue_target) / d
    @hue_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    return if @opacity_duration == 0
    d = @opacity_duration
    @opacity = (@opacity * (d - 1) + @opacity_target) / d
    @opacity_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: updade_tone
  #--------------------------------------------------------------------------
  def updade_tone
    return if @tone_duration == 0
    if @tone_duration == 1 || @tone_duration % 10 == 0
      d = @tone_duration
      @tone.red   = (@tone.red   * (d - 1) + @tone_target.red)   / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue  = (@tone.blue  * (d - 1) + @tone_target.blue)  / d
      @tone.gray  = (@tone.gray  * (d - 1) + @tone_target.gray)  / d
    end
    @tone_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: updade_zoom_x
  #--------------------------------------------------------------------------
  def updade_zoom_x
    return if @zoom_x_duration == 0
    d = @zoom_x_duration
    @zoom_x = (@zoom_x * (d - 1) + @zoom_x_target) / d
    @zoom_x_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: updade_zoom_y
  #--------------------------------------------------------------------------
  def updade_zoom_y
    return if @zoom_y_duration == 0
    d = @zoom_y_duration
    @zoom_y = (@zoom_y * (d - 1) + @zoom_y_target) / d
    @zoom_y_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: set_hue_effect
  #--------------------------------------------------------------------------
  def set_hue_effect(value)
    if value =~ /(\d+)(?: *, *(\d+))?/i
      d = $2 ? $2.to_i : 0
      start_hue_change($1.to_i, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_opacity_effect
  #--------------------------------------------------------------------------
  def set_opacity_effect(value)
    if value =~ /(\d+)(?: *, *(\d+))?/i
      d = $2 ? $2.to_i : 0
      start_opacity_change($1.to_i, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_zoom_effect
  #--------------------------------------------------------------------------
  def set_zoom_effect(value)
    if value =~ /(\d+) *, *(\d+)(?: *, *(\d+))?/i
      d = $3 ? $3.to_i : 0
      start_zoom_change($1.to_i, $2.to_i, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_tone_effect
  #--------------------------------------------------------------------------
  def set_tone_effect(value)
    regex = "([+-]?\\d+) *, *"
    if value =~ /#{regex}#{regex}#{regex}(\d+)(?: *, *(\d+))?/i
      t = Tone.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
      d = $5 ? $5.to_i : 0
      start_tone_change(t, d)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update
  #--------------------------------------------------------------------------
  def init_effect
    blend_type = actor.blend
    @opacity   = actor.opacity
    @hue       = actor.hue
    @zoom_x    = actor.zoom_x
    @zoom_y    = actor.zoom_y
    @tone      = actor.tone
  end
  #--------------------------------------------------------------------------
  # * New method: update_effect
  #--------------------------------------------------------------------------
  def update_effect
    actor.blend   = @blend_type
    actor.opacity = @opacity
    actor.hue     = @hue
    actor.zoom_x  = @zoom_x
    actor.zoom_y  = @zoom_y
    actor.tone    = @tone
  end  
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player.
# The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_character_effects :refresh
  def refresh
    refresh_ve_character_effects
    init_effect if actor
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_gp_ve_character_effects :update
  def update
    update_gp_ve_character_effects
    update_effect if actor
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
  # * Alias method: clear_starting_flag
  #--------------------------------------------------------------------------
  alias :clear_starting_flag_ve_character_effects :clear_starting_flag
  def clear_starting_flag
    clear_starting_flag_ve_character_effects
    refresh_effects if @page
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_effects
  #--------------------------------------------------------------------------
  def refresh_effects
    note.scan(/<SELF (\w+): ([^>]*)>/i) do |type, value|
      case type.upcase
      when "HUE"     then set_hue_effect(value)
      when "OPACITY" then set_opacity_effect(value)
      when "ZOOM"    then set_zoom_effect(value)
      when "TONE"    then set_tone_effect(value)
      when "BLEND"   then @blend_type = $1.to_i if value =~ /(\d+)/i
      end
    end
  end
end

#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles the followers. Followers are the actors of the party
# that follows the leader in a line. It's used within the Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_gf_ve_character_effects :update
  def update
    real_opacity = @opacity
    real_blend   = @blend_type
    update_gf_ve_character_effects
    @opacity    = real_opacity
    @blend_type = real_blend
    update_effect if actor
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_character_effects :refresh
  def refresh
    refresh_ve_character_effects
    init_effect if actor
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
  alias :comment_call_ve_character_effects :comment_call
  def comment_call
    call_event_effect
    call_actor_effect
    call_party_effect
    call_vehicle_effect
    comment_call_ve_character_effects
  end
  #--------------------------------------------------------------------------
  # * New method: call_event_effect
  #--------------------------------------------------------------------------
  def call_event_effect
    note.scan(/<EVENT (\w+) (\d+): ([^>]*)>/i) do |type, id, value|
      event = $game_map.events[id.to_i]
      next unless event
      case type.upcase
      when "HUE"     then event.set_hue_effect(value)
      when "OPACITY" then event.set_opacity_effect(value)
      when "ZOOM"    then event.set_zoom_effect(value)
      when "TONE"    then event.set_tone_effect(value)
      when "BLEND"   then event.blend_type = $1.to_i if value =~ /(\d+)/i
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_actor_effect
  #--------------------------------------------------------------------------
  def call_actor_effect
    note.scan(/<ACTOR (\w+) (\d+): ([^>]*)>/i) do |type, id, value|
      actor = $game_map.actors[id.to_i]
      next unless actor
      case type.upcase
      when "HUE"     then actor.set_hue_effect(value)
      when "OPACITY" then actor.set_opacity_effect(value)
      when "ZOOM"    then actor.set_zoom_effect(value)
      when "TONE"    then actor.set_tone_effect(value)
      when "BLEND"   then actor.blend_type = $1.to_i if value =~ /(\d+)/i
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_party_effect
  #--------------------------------------------------------------------------
  def call_party_effect
    note.scan(/<PARTY (\w+): ([^>]*)>/i) do |type, value|
      $game_map.actors.each do |actor|
        next unless actor
        case type.upcase
        when "HUE"     then actor.set_hue_effect(value)
        when "OPACITY" then actor.set_opacity_effect(value)
        when "ZOOM"    then actor.set_zoom_effect(value)
        when "TONE"    then actor.set_tone_effect(value)
        when "BLEND"   then actor.blend_type = $1.to_i if value =~ /(\d+)/i
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_vehicle_effect
  #--------------------------------------------------------------------------
  def call_vehicle_effect
    note.scan(/<VEHICLE (\w+) (\w+): ([^>]*)>/i) do |type, id, value|
      vehicle = $game_map.vehicle(eval(":#{id}"))
      next unless vehicle
      case type.upcase
      when "HUE"     then vehicle.set_hue_effect(value)
      when "OPACITY" then vehicle.set_opacity_effect(value)
      when "ZOOM"    then vehicle.set_zoom_effect(value)
      when "TONE"    then vehicle.set_tone_effect(value)
      when "BLEND"   then vehicle.blend_type = $1.to_i if value =~ /(\d+)/i
      end
    end
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_character_effects :initialize
  def initialize(viewport, character = nil)
    initialize_ve_character_effects(viewport, character)
    @hue = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: graphic_changed?
  #--------------------------------------------------------------------------
  alias :graphic_changed_ve_character_effects? :graphic_changed?
  def graphic_changed?
    graphic_changed_ve_character_effects? ||
    @hue != @character.hue
  end
  #--------------------------------------------------------------------------
  # * New method: update_character_info
  #--------------------------------------------------------------------------
  alias :update_character_info_ve_character_effect :update_character_info
  def update_character_info
    update_character_info_ve_character_effect
    @hue = @character.hue
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_other
  #--------------------------------------------------------------------------
  alias :update_other_ve_character_effects :update_other
  def update_other
    update_other_ve_character_effects
    self.zoom_x = @character.zoom_x / 100.0
    self.zoom_y = @character.zoom_y / 100.0
    self.tone.set(@character.tone)
  end
end