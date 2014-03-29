#==============================================================================
# ** Victor Engine - Progressive Timer
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.31 > First release
#------------------------------------------------------------------------------
#  This scripts allows to setup a progressive timer. By default the timer is
# a countdown to zero.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.00 or higher
#
# * Alias methods
#   class Game_Timer
#     def initialize
#     def update
#     def stop
#     def working?
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
#  <progressive timer>
#  <progressive timer: x>
#  <progressive timer: y:x>
#   This tag allows to start the progressive timer. 
#     x : time in seconds
#     y : time in minutes
# 
#------------------------------------------------------------------------------
# Additional instructions:
#  
#   You can choose the timer time limit. 
#   If no value is set as time for the timer then the timer will not stop
#   until call the 'Control Timer: Stop' event command.
#   You can also set the time limit only in seconds or minute + seconds.
#   there's no real difference beween them, so 630 sec = 10:30 min
#
#   Any timer based event command still work normally.
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
$imported[:ve_progressive_timer] = 1.00
Victor_Engine.required(:ve_progressive_timer, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** Game_Timer
#------------------------------------------------------------------------------
#  This class handles timers. Instances of this class are referenced by 
# $game_timer.
#==============================================================================

class Game_Timer
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_progressive_timer :initialize
  def initialize
    initialize_ve_progressive_timer
    @final       = 0
    @progressive = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_progressive_timer :update
  def update
    if @progressive && (@final == 0 || @count < @final)
      @count += 1
      on_expire if @final == @count
    end
    update_ve_progressive_timer
  end
  #--------------------------------------------------------------------------
  # * Alias method: stop
  #--------------------------------------------------------------------------
  alias :stop_ve_progressive_timer :stop
  def stop
    stop_ve_progressive_timer
    @progressive = false
  end
  #--------------------------------------------------------------------------
  # * Alias method: working?
  #--------------------------------------------------------------------------
  alias :working_ve_progressive_timer? :working?
  def working?
    working_ve_progressive_timer? || @progressive
  end
  #--------------------------------------------------------------------------
  # * New method: progressive_start
  #--------------------------------------------------------------------------
  def progressive_start(count)
    @count       = 0
    @final       = count
    @progressive = true
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
  alias :comment_call_ve_progressive_timer :comment_call
  def comment_call
    call_progressive_timer
    comment_call_ve_progressive_timer
  end
  #--------------------------------------------------------------------------
  # * New method: call_progressive_timer
  #--------------------------------------------------------------------------
  def call_progressive_timer
    if note =~ /<PROGRESSIVE TIMER(?:: *(\d+|\d+ *: *\d+))?>/i
      $game_timer.progressive_start(setup_progressive_time($1))
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_progressive_time
  #--------------------------------------------------------------------------
  def setup_progressive_time(value)
    if value =~ /(\d+) *(?:: *(\d+))?/i
      ($2 ? $1.to_i * 60 + $2.to_i : $1.to_i) * Graphics.frame_rate
    else
      0
    end
  end
end