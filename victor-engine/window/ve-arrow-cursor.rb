#==============================================================================
# ** Victor Engine - Arrow Cursor
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.01 > First release
#  v 1.01 - 2012.01.15 > Compatibility for Target Arrow
#------------------------------------------------------------------------------
#  This script allows to change the cursor display to a arrow like display.
# It's possible to make it animated and set different graphics for each window
# If using the script 'Victor Engine - Loop Animation', it's also possible
# to make the cursor an animation
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.09 or higher
# 
# * Alias methods (Default)
#   class Window_Base < Window
#     def initialize(x, y, width, height)
#     def visible=(n)
#     def cursor_rect=(rect)
#     def x=(n)
#     def y=(n)
#     def update_open
#     def update_close
#     def open
#     def close
#     def update
#     def dispose
#
#   class Window_ChoiceList < Window_Command
#     def initialize(message_window)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section on bellow the Materials section. This script must also
#  be bellow the scripts 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The cursors graphics must be in the folder Graphics/System.
#
#  To use animations as cursors you need the script  
#  'Victor Engine - Loop Animation' v 1.02 or higher. 
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Default cursor setting
  #   These are the global setings for the cursor
  #--------------------------------------------------------------------------
  VE_CURSOR_DEFAULT = {
    name:   "Cursor", # Cursor graphic filename ("filename")
    frames: 4,        # Number of frames of the cursor (1 for no animation)
    speed:  10,       # Cursto animation wait time (60 frames = 1 second)
    rect:   false,    # Show the old cursor rectangle (true/false)
    x:      12,       # Coordinate x adjust
    y:      12,       # Coordinate y adjust
    anim:   0,        # Animation ID displayed as cursor. Requires the script
                      # "Victor Engine - Loop Animation", this makes the
                      # cursor a looping battle animation instead of a
                      # simple bitmap graphic
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Custom cursor settings
  #    Set different configuration for cursors based on the window class
  #    it is being shown. It needs to add only the changed values.
  #      "Window_ClassName"   => {setting},
  #--------------------------------------------------------------------------
  VE_CUSTOM_CURSOR = {
    "Window_MenuStatus" => {name: "Blue Cursor"},
    "Window_SkillList"  => {name: "Blue Cursor"},
    "Window_EquipSlot"  => {name: "Blue Cursor"},
    "Window_EquipItem"  => {name: "Green Cursor"},
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
$imported[:ve_arrow_cursor] = 1.01
Victor_Engine.required(:ve_arrow_cursor, :ve_basic_module, 1.09, :above)

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_arrow_cursor :initialize
  def initialize(x, y, width, height)
    init_cursor
    initialize_ve_arrow_cursor(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * Alias method: visible=
  #--------------------------------------------------------------------------
  alias :visible_ve_arrow_cursor :visible=
  def visible=(n)
    visible_ve_arrow_cursor(n)
    @cursor_all = false
    dispose_cursor
    init_cursor_sprite(cursor_rect, true) if @index && n
  end
  #--------------------------------------------------------------------------
  # * Alias method: cursor_rect=
  #--------------------------------------------------------------------------
  alias :cursor_rect_ve_arrow_cursor :cursor_rect=
  def cursor_rect=(rect)
    cursor_rect_ve_arrow_cursor(rect) if cursor_old_rect
    init_cursor_sprite(rect)
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_cursor
  #--------------------------------------------------------------------------
  alias :y_ve_arrow_cursor :y=
  def y=(n)
    y_ve_arrow_cursor(n)
    init_cursor_sprite(cursor_rect, true) if @index
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_cursor
  #--------------------------------------------------------------------------
  alias :x_ve_arrow_cursor :x=
  def x=(n)
    x_ve_arrow_cursor(n)
    init_cursor_sprite(cursor_rect, true) if @index
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_open
  #--------------------------------------------------------------------------
  alias :update_open_ve_arrow_cursor :update_open
  def update_open
    update_open_ve_arrow_cursor
    init_cursor_sprite(cursor_rect, true) if @index
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_close
  #--------------------------------------------------------------------------
  alias :update_close_ve_arrow_cursor :update_close
  def update_close
    update_close_ve_arrow_cursor
    init_cursor_sprite(cursor_rect, true) if @index
  end
  #--------------------------------------------------------------------------
  # * Alias method: open
  #--------------------------------------------------------------------------
  alias :open_ve_arrow_cursor :open
  def open
    open_ve_arrow_cursor
    init_cursor_sprite(cursor_rect, true) if @index
    self
  end
  #--------------------------------------------------------------------------
  # * Alias method: close
  #--------------------------------------------------------------------------
  alias :close_ve_arrow_cursor :close
  def close
    close_ve_arrow_cursor
    init_cursor_sprite(cursor_rect, true) if @index
    self
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_arrow_cursor :update
  def update
    update_ve_arrow_cursor
    update_cursor_sprite
    return if Graphics.frame_count % cursor_animspeed != 0
    @cursor_anim = (@cursor_anim + 1) % cursor_frames
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_arrow_cursor :dispose
  def dispose
    dispose_ve_arrow_cursor
    dispose_cursor
  end
  #--------------------------------------------------------------------------
  # * New method: init_cursor
  #--------------------------------------------------------------------------
  def init_cursor
    @cursor = []
    @cursor_anim = 0
    @cursor_value = VE_CUSTOM_CURSOR.dup
    @cursor_value.default = VE_CURSOR_DEFAULT.dup
    @cursor_value.each do |key, value|
      cursor = @cursor_value[key]
      cursor[:x]      = VE_CURSOR_DEFAULT[:x]      if !value[:x]
      cursor[:y]      = VE_CURSOR_DEFAULT[:y]      if !value[:y]
      cursor[:name]   = VE_CURSOR_DEFAULT[:name]   if !value[:name]
      cursor[:frames] = VE_CURSOR_DEFAULT[:frames] if !value[:frames]
      cursor[:rect]   = VE_CURSOR_DEFAULT[:rect]   if !value[:rect]
      cursor[:speed]  = VE_CURSOR_DEFAULT[:speed]  if !value[:speed]
      cursor[:anim]   = VE_CURSOR_DEFAULT[:anim]   if !value[:anim]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: init_cursor_sprite
  #--------------------------------------------------------------------------
  def init_cursor_sprite(rect, forced = false)
    dispose_cursor if @old_index != @index || forced
    if !rect_empty?(rect) && opened? && !cursor_all
      create_cursor_sprite(0)
    elsif !rect_empty?(rect) && opened? && cursor_all
      row_max.times {|i| create_cursor_sprite(i) }
    end
    @old_index = @index
    update_cursor_sprite
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_all
  #--------------------------------------------------------------------------
  def cursor_all
    @curtor_all
  end
  #--------------------------------------------------------------------------
  # * New method: rect_empty?
  #--------------------------------------------------------------------------
  def rect_empty?(rect)
    rect == Rect.new(0, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # * New method: opened?
  #--------------------------------------------------------------------------
  def opened?
    visible && !@opening && !@closing && active
  end
  #--------------------------------------------------------------------------
  # * New method: item_height
  #--------------------------------------------------------------------------
  def item_height
    line_height
  end
  #--------------------------------------------------------------------------
  # * New method: create_cursor_sprite
  #--------------------------------------------------------------------------
  def create_cursor_sprite(i)
    return if @cursor[i]
    @cursor[i] = Sprite_Base.new
    @cursor[i].bitmap = Cache.system(cursor_filename)
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_filename
  #--------------------------------------------------------------------------
  def cursor_filename
    cursor_animation? ? "" : @cursor_value["#{self.class}"][:name]
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_frames
  #--------------------------------------------------------------------------
  def cursor_frames
    [@cursor_value["#{self.class}"][:frames], 1].max
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_old_rect
  #--------------------------------------------------------------------------
  def cursor_old_rect
    @cursor_value["#{self.class}"][:rect]
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_animspeed
  #--------------------------------------------------------------------------
  def cursor_animspeed
    [@cursor_value["#{self.class}"][:speed], 1].max
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_x
  #--------------------------------------------------------------------------
  def cursor_x
    @cursor_value["#{self.class}"][:x]
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_y
  #--------------------------------------------------------------------------
  def cursor_y
    @cursor_value["#{self.class}"][:y]
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_animation
  #--------------------------------------------------------------------------
  def cursor_animation
    @cursor_value["#{self.class}"][:anim]
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_animation
  #--------------------------------------------------------------------------
  def cursor_animation?
    cursor_animation != 0 && $imported[:ve_loop_animation]
  end
  #--------------------------------------------------------------------------
  # * New method: update_cursor_sprite
  #--------------------------------------------------------------------------
  def update_cursor_sprite
    @cursor.each_index do |i|
      @cursor[i].viewport = self.viewport
      cursor_animation? ? set_cursor_animation(i) : set_cursor_bitmap(i)
      update_cursor_position(i)
    end
    update_all_cursors
  end
  #--------------------------------------------------------------------------
  # * New method: set_cursor_bitmap
  #--------------------------------------------------------------------------
  def set_cursor_bitmap(i)
    bitmap = @cursor[i].bitmap
    cursor_width  = bitmap.width / cursor_frames
    current_frame = cursor_width * @cursor_anim
    @cursor[i].src_rect.set(current_frame, 0, cursor_width, bitmap.height)
  end
  #--------------------------------------------------------------------------
  # * New method: set_cursor_animation
  #--------------------------------------------------------------------------
  def set_cursor_animation(i)
    return if @cursor[i].loop_anim?(:cursor) && !active
    settings = {anim: cursor_animation, type: :cursor, loop: 1}
    valid = (@cursor_all && row_max)
    @cursor[i].add_loop_animation(settings)
  end
  #--------------------------------------------------------------------------
  # * New method: update_cursor_position
  #--------------------------------------------------------------------------
  def update_cursor_position(i)
    valid = (@cursor_all && row_max)
    h = cursor_rect.height / (valid ? [row_max * 2, 2].max : 2) + cursor_y
    @cursor[i].x  = self.x - self.ox + cursor_rect.x + cursor_x
    @cursor[i].y  = self.y - self.oy + cursor_rect.y + h + item_height * i
    @cursor[i].z  = self.z + 100
    @cursor[i].ox = @cursor[i].width  / 2
    @cursor[i].oy = @cursor[i].height / 2
    return unless cursor_animation?
    @cursor[i].set_loop_anim_origin(:cursor) if @cursor[i].loop_anim?(:cursor)
  end
  #--------------------------------------------------------------------------
  # * New method: update_all_cursors
  #--------------------------------------------------------------------------
  def update_all_cursors
    @cursor.each {|cursor| cursor.update }
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_cursor
  #--------------------------------------------------------------------------
  def dispose_cursor
    @cursor.each {|cursor| cursor.end_all_loop_anim } if cursor_animation?
    @cursor.each {|cursor| cursor.dispose }
    @cursor.clear
  end
end

#==============================================================================
# ** Window_ChoiceList
#------------------------------------------------------------------------------
#  This window displays event commands [Show Choices]
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_wn_ve_arrow_cursor :initialize
  def initialize(message_window)
    initialize_wn_ve_arrow_cursor(message_window)
    dispose_cursor
  end
end

#==============================================================================
# ** Window_SaveFile
#------------------------------------------------------------------------------
#  This window displays save files on the save and load screens.
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * New method: init_cursor_sprite
  #--------------------------------------------------------------------------
  def init_cursor_sprite(rect, forced = false)
    super(rect, true)
  end
end