#==============================================================================
# ** Victor Engine - Target Arrow
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.15 > First release
#  v 1.01 - 2012.03.08 > Fixed self action help name display
#  v 1.02 - 2012.05.30 > Fixed bug with Loop Animation arrow
#  v 1.03 - 2012.08.02 > Compatibility with Basic Module 1.27
#  v 1.04 - 2012.11.03 > Compatibility with Direct Commands
#                      > Fixed issue with line 408 undefined method
#  v 1.05 - 2012.12.24 > Compatibility with Active Time Battle
#  v 1.06 - 2012.12.30 > Fixed issue with enemy name when cancel selection
#  v 1.07 - 2013.01.07 > Improved arrow movement
#  v 1.08 - 2013.01.24 > Compatibility with Toggle Target
#------------------------------------------------------------------------------
#  This script allows to change target selection to a arrow like selection.
# It's possible to make it animated and set different graphics for enemies
# and actors target selections.
# If using the script 'Victor Engine - Loop Animation', it's also possible
# to make the cursor an animation
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   If used with 'Victor Engine - Custom Basic Actions' place this bellow it.
# 
# * Overwrite methods
#   class RPG::UsableItem < RPG::BaseItem
#     def need_selection?
#
#   class Window_BattleEnemy < Window_Selectable
#     def show
#     def hide
#     def cursor_movable?
#     def cursor_down(wrap = false)
#     def cursor_up(wrap = false)
#     def cursor_right(wrap = false)
#     def cursor_left(wrap = false)
#     def update_help
#
#   class Window_BattleActor < Window_BattleStatus
#     def cursor_movable?
#     def cursor_down(wrap = false)
#     def cursor_up(wrap = false)
#     def cursor_right(wrap = false)
#     def cursor_left(wrap = false)
#     def update_help
#     def update_cursor
#
# * Alias methods
#   class Window_BattleEnemy < Window_Selectable
#     def initialize(info_viewport)
#     def update
#     def dispose
#
#   class Window_BattleActor < Window_BattleStatus
#     def initialize(info_viewport)
#     def update
#     def show
#     def hide
#     def update_cursor
#     def dispose
#
#   class Scene_Battle < Scene_Base
#     def create_actor_window
#     def create_enemy_window
#     def command_attack
#     def on_skill_ok
#     def on_item_ok
#     def on_enemy_cancel
#     def on_actor_cancel
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the scripts 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes.
#
#  <target description>
#  string
#  </target description>
#   The target description text, the string is the text, to add a break line
#   use \\n.
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
  # * Set the automatic text control codes
  #   when false, it's needed to add \# on the start of the text to use
  #   control codes
  #--------------------------------------------------------------------------
  VE_ARROW_DEFAULT = {
    name:   "Cursor", # Cursor graphic filename ("filename")
    frames: 4,        # Number of frames of the arrow (1 for no animation)
    speed:  10,       # Cursto animation wait time (60 frames = 1 second)
    height: true,     # Adjust arrow based on target height
    help:   true,     # Show help window when selecting target
    x:      0,        # Coordinate x adjust
    y:      0,        # Coordinate y adjust
    move:   0,        # Set move type. 0 : all directions, 1 : left and right
                      # 2 : up and down
    anim:   111,        # Animation ID displayed as arrow. Requires the script
                      # "Victor Engine - Loop Animation", this makes the
                      # arrow a looping battle animation instead of a
                      # simple bitmap graphic
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Custom arrow settings
  #    Set different configuration for arrows based on the window class
  #    it is being shown. It needs to add only the changed values.
  #      type: {setting},
  #      type: actor: or enemy:
  #--------------------------------------------------------------------------
  VE_ARROW_CUSTOM = {
    actor: {name: "Green Cursor"},
    enemy: {name: "Blue Cursor"},
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Hide skill window during target selection
  #    Since the window is placed above the battlers, the arrow stay behind
  #    the skill window. you can set it false if the window is placed
  #    in a different position with scripts.
  #--------------------------------------------------------------------------
  VE_HIDE_SKILL_WINDOW = true
  #--------------------------------------------------------------------------
  # * Hide item window during target selection
  #    Since the window is placed above the battlers, the arrow stay behind
  #    the item window. you can set it false if the window is placed
  #    in a different position with scripts.
  #--------------------------------------------------------------------------
  VE_HIDE_ITEM_WINDOW = true
  #--------------------------------------------------------------------------
  # * Set the use of target help window
  #--------------------------------------------------------------------------
  VE_USE_TARGET_HELP = true
  #--------------------------------------------------------------------------
  # * Settings for the target help window.
  #--------------------------------------------------------------------------
  VE_TARGET_HELP_WINDOW = {
    text_align:    1,    # Text align, 0: left, 1: center, 2: right
    target_info:   true, # If true show target info, if false show skill name
    all_enemies:   "All Enemies",   # Target info for all enemies actions
    all_actors:    "All Allies",    # Target info for all actors actions
    all_target:    "All Targets",   # Target info for all targets actions
    random_enemy:  "Random Enemy",  # Target info for random enemy actions
    random_actor:  "Random Ally",   # Target info for random actor actions
    random_target: "Random Target", # Target info for random target actions
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
$imported[:ve_target_arrow] = 1.08
Victor_Engine.required(:ve_target_arrow, :ve_basic_module, 1.27, :above)
Victor_Engine.required(:ve_target_arrow, :ve_toggle_target, 1.00, :bellow)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Overwrite method: need_selection?
  #--------------------------------------------------------------------------
  def need_selection?
    @scope > 0
  end
end

#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  This window contains cursor movement and scroll functions.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * New method: init_arrow
  #--------------------------------------------------------------------------
  def init_arrow
    @arrows = []
    @arrows_anim = 0
    @arrows_value = VE_ARROW_CUSTOM.dup
    @arrows_value.default = VE_ARROW_DEFAULT.dup
    @arrows_value.each do |key, value|
      arrow = @arrows_value[key]
      arrow[:x]      = VE_ARROW_DEFAULT[:x]      if !value[:x]
      arrow[:y]      = VE_ARROW_DEFAULT[:y]      if !value[:y]
      arrow[:name]   = VE_ARROW_DEFAULT[:name]   if !value[:name]
      arrow[:frames] = VE_ARROW_DEFAULT[:frames] if !value[:frames]
      arrow[:rect]   = VE_ARROW_DEFAULT[:rect]   if !value[:rect]
      arrow[:speed]  = VE_ARROW_DEFAULT[:speed]  if !value[:speed]
      arrow[:anim]   = VE_ARROW_DEFAULT[:anim]   if !value[:anim]
      arrow[:move]   = VE_ARROW_DEFAULT[:move]   if !value[:move]
      arrow[:height] = VE_ARROW_DEFAULT[:height] if !value[:height]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: init_arrow_sprite
  #--------------------------------------------------------------------------
  def init_arrow_sprite(forced = false)
    dispose_arrow if @arrows_index != @index || forced || item_max == 0
    return unless active
    if target_all? && item_max > 0
      item_max.times {|i| create_arrow_sprite(i) }
    elsif @index > -1 && item_max > 0
      create_arrow_sprite(0)
    end
    @arrows_index = @index
    update_arrow_sprite
  end
  #--------------------------------------------------------------------------
  # * New method: set_action
  #--------------------------------------------------------------------------
  def set_action(action)
    @action = action
  end
  #--------------------------------------------------------------------------
  # * New method: target_all?
  #--------------------------------------------------------------------------
  def target_all?
    @action && (@action.for_all? || @action.for_random?)
  end
  #--------------------------------------------------------------------------
  # * New method: target_self?
  #--------------------------------------------------------------------------
  def target_self?
    @action && @action.for_user?
  end
  #--------------------------------------------------------------------------
  # * New method: create_arrow_sprite
  #--------------------------------------------------------------------------
  def create_arrow_sprite(i)
    return if @arrows[i]
    @arrows[i] = Sprite_Base.new
    @arrows[i].bitmap = Cache.system(arrow_filename)
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_animation
  #--------------------------------------------------------------------------
  def arrow_animation?
    arrow_animation != 0 && $imported[:ve_loop_animation]
  end
  #--------------------------------------------------------------------------
  # * New method: update_arrow_sprite
  #--------------------------------------------------------------------------
  def update_arrow_sprite
    @arrows.each_index do |i|
      next unless @arrows[i] && target(i)
      @arrows[i].viewport = target(i).sprite.viewport
      arrow_animation? ? set_arrow_animation(i) : set_arrow_bitmap(i)
      update_arrow_position(i)
    end
    update_all_arrows
  end
  #--------------------------------------------------------------------------
  # * New method: set_arrow_bitmap
  #--------------------------------------------------------------------------
  def set_arrow_bitmap(i)
    bitmap = @arrows[i].bitmap
    arrow_width   = bitmap.width / arrow_frames
    current_frame = arrow_width * @arrows_anim
    @arrows[i].src_rect.set(current_frame, 0, arrow_width, bitmap.height)
  end
  #--------------------------------------------------------------------------
  # * New method: set_arrow_animation
  #--------------------------------------------------------------------------
  def set_arrow_animation(i)
    target = target(i)
    return if !target || target.sprite.loop_anim?(:arrow)
    settings = {anim: arrow_animation, type: :arrow, loop: 1}
    target.sprite.add_loop_animation(settings)
  end
  #--------------------------------------------------------------------------
  # * New method: update_arrow_position
  #--------------------------------------------------------------------------
  def update_arrow_position(i)
    adjust = arrow_height ? target(i).sprite.oy / 2 : 0
    @arrows[i].x  = position_x(i) + arrow_x
    @arrows[i].y  = position_y(i) + arrow_y - adjust
    @arrows[i].z  = self.z + 1000
    @arrows[i].ox = @arrows[i].width  / 2
    @arrows[i].oy = @arrows[i].height / 2
  end
  #--------------------------------------------------------------------------
  # * New method: position_x
  #--------------------------------------------------------------------------
  def position_x(i)
    $imported[:ve_animated_battle] ? target(i).current_x : target(i).screen_x
  end
  #--------------------------------------------------------------------------
  # * New method: position_y
  #--------------------------------------------------------------------------
  def position_y(i)
    $imported[:ve_animated_battle] ? target(i).current_y : target(i).screen_y
  end
  #--------------------------------------------------------------------------
  # * New method: update_all_arrows
  #--------------------------------------------------------------------------
  def update_all_arrows
    @arrows.each {|arrow| arrow.update }
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_frames
  #--------------------------------------------------------------------------
  def target_window_type
    instance_of?(Window_BattleEnemy) ? :enemy : :actor
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_filename
  #--------------------------------------------------------------------------
  def arrow_filename
    arrow_animation? ? "" : @arrows_value[target_window_type][:name]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_frames
  #--------------------------------------------------------------------------
  def arrow_frames
    [@arrows_value[target_window_type][:frames], 1].max
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_old_rect
  #--------------------------------------------------------------------------
  def arrow_old_rect
    @arrows_value[target_window_type][:rect]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_animspeed
  #--------------------------------------------------------------------------
  def arrow_animspeed
    [@arrows_value[target_window_type][:speed], 1].max
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_x
  #--------------------------------------------------------------------------
  def arrow_x
    @arrows_value[target_window_type][:x]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_y
  #--------------------------------------------------------------------------
  def arrow_y
    @arrows_value[target_window_type][:y]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_animation
  #--------------------------------------------------------------------------
  def arrow_animation
    @arrows_value[target_window_type][:anim]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_height
  #--------------------------------------------------------------------------
  def arrow_height
    @arrows_value[target_window_type][:height]
  end
  #--------------------------------------------------------------------------
  # * New method: arrow_move
  #--------------------------------------------------------------------------
  def arrow_move
    @arrows_value[target_window_type][:move]
  end
  #--------------------------------------------------------------------------
  # * New method: help_info
  #--------------------------------------------------------------------------
  def help_info
    VE_TARGET_HELP_WINDOW
  end
  #--------------------------------------------------------------------------
  # * New method: target_description
  #--------------------------------------------------------------------------
  def target_description
    return "" unless @action
    regexp = get_all_values("TARGET DESCRIPTION")
    text   = ""
    @action.note.scan(regexp) do
      info = $1.dup
      info.gsub!(/\r\n/) { "" }
      info.gsub!(/\\n/)  { "\r\n" }
      text += info
    end
    text
  end
  #--------------------------------------------------------------------------
  # * New method: update_target_help
  #--------------------------------------------------------------------------  
  def update_target_help
    text  = target_description
    align = help_info[:text_align]
    @help_window.visible = true
    if text != ""
      @help_window.set_info_text(text, align)
    else
      if help_info[:target_info]
        draw_tartge_info(align)
      else
        @help_window.set_item_text(@action, align)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: draw_tartge_inf
  #--------------------------------------------------------------------------  
  def draw_tartge_info(align)
    if @action.for_one?
      @help_window.set_target_text(target(0), align)
    elsif @action.for_all? && @action.for_random? 
      text = help_info[:random_enemies] if @action.for_opponent? 
      text = help_info[:random_actors]  if @action.for_friend? 
      text = help_info[:random_target]  if @action.for_all_targets?
      @help_window.set_info_text(text, align)
    elsif @action.for_all? && !@action.for_random? 
      text = help_info[:all_enemies] if @action.for_opponent? 
      text = help_info[:all_actors]  if @action.for_friend? 
      text = help_info[:all_target]  if @action.for_all_targets?
      @help_window.set_info_text(text, align)
    end
  end
end

#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  This window shows skill and item explanations along with actor status.
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Alias method: set_item
  #--------------------------------------------------------------------------
  alias :set_item_ve_arrow_arrow :set_item
  def set_item(item)
    set_item_ve_arrow_arrow(item)
    refresh
  end
  #--------------------------------------------------------------------------
  # * New method: set_target_text
  #--------------------------------------------------------------------------
  def set_target_text(target, align = 0)
    if target && (target != @target || @target.name != @text)
      @text   = ""
      @target = target
      @align  = align
      target_info
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_info_text
  #--------------------------------------------------------------------------
  def set_info_text(text, align = 0)
    if text != @text
      @text = text
      contents.clear
      adj = @text[/\r\n/i]
      draw_text(0, 0, width, line_height * (adj ? 1 : 2), @text, align)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_item_text
  #--------------------------------------------------------------------------
  def set_item_text(item, align = 0)
    if item.name != @text
      @text = item.name
      contents.clear
      iw = item.icon_index == 0 ? 0 : 24
      text_width = text_size(@text).width
      x = align == 0 ? 0 : (contents_width - 24 - text_width) / (3 - align)
      draw_icon(item.icon_index, x, line_height / 2, true)
      draw_text(iw + 2, 0, contents_width - iw, line_height * 2, @text, align)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: target_info
  #--------------------------------------------------------------------------
  def target_info
    contents.clear
    change_color(hp_color(@target))
    adj = (@target.state_icons + @target.buff_icons).size == 0
    height = line_height * (adj ? 2 : 1)
    draw_text(0, 0, contents_width, height, @target.name, @align)
    draw_target_icons
  end
  #--------------------------------------------------------------------------
  # * New method: draw_target_icons
  #--------------------------------------------------------------------------
  def draw_target_icons
    icons = (@target.state_icons + @target.buff_icons)[0, contents_width / 24]
    x = @align == 0 ? 0 : (contents_width - icons.size * 24) / (3 - @align)
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, line_height) }
  end
end

#==============================================================================
# ** Window_BattleEnemy
#------------------------------------------------------------------------------
#  This window display a list of enemies on the battle screen.
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: show
  #--------------------------------------------------------------------------
  def show
    result = super
    fix_selection(arrow_move == 1 ? :horz : :vert)
    select(0)
    init_arrow_sprite(true)
    self.visible = false
    result
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: hide
  #--------------------------------------------------------------------------
  def hide
    result = super
    dispose_arrow
    result
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: enemy
  #--------------------------------------------------------------------------
  def enemy
    enemy_list[@index]
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_movable?
  #--------------------------------------------------------------------------
  def cursor_movable?
    super && active && !cursor_all && !target_all? && !target_self?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    fix_selection(:vert) if arrow_move != 1 && @mode == :horz
    select((index - 1 + item_max) % item_max) if arrow_move != 1
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    fix_selection(:vert) if arrow_move != 1 && @mode == :horz
    select((index + 1) % item_max) if arrow_move != 1
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_right
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    fix_selection(:horz) if arrow_move != 2 && @mode == :vert
    select((index + 1) % item_max) if arrow_move != 2
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    fix_selection(:horz) if arrow_move != 2 && @mode == :vert
    select((index - 1 + item_max) % item_max) if arrow_move != 2
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_help
  #--------------------------------------------------------------------------
  def update_help
    update_target_help
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_arrow_arrow :initialize
  def initialize(info_viewport)
    initialize_ve_arrow_arrow(info_viewport)
    init_arrow
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_arrow_arrow :update
  def update
    update_ve_arrow_arrow
    init_arrow_sprite
    update_arrow_sprite
    return if Graphics.frame_count % arrow_animspeed != 0
    @arrows_anim = (@arrows_anim + 1) % arrow_frames
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_arrow_arrow :dispose
  def dispose
    dispose_ve_arrow_arrow
    dispose_arrow
  end
  #--------------------------------------------------------------------------
  # * New method: enemies
  #--------------------------------------------------------------------------
  def enemies
    enemy_list
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_list
  #--------------------------------------------------------------------------
  def enemy_list
    enemies = $game_troop.alive_members.dup
    enemies.sort! {|a, b| b.screen_y <=> a.screen_y } if @mode == :vert
    enemies.sort! {|a, b| a.screen_x <=> b.screen_x } if @mode == :horz
    enemies
  end
  #--------------------------------------------------------------------------
  # * New method: fix_selection
  #--------------------------------------------------------------------------
  def fix_selection(type)
    current = enemy
    @mode   = type
    @index  = enemy_list.index(current)
  end
  #--------------------------------------------------------------------------
  # * New method: target
  #--------------------------------------------------------------------------
  def target(i)
    target_all? ? enemies[i] : enemy
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_arrow
  #--------------------------------------------------------------------------
  def dispose_arrow
    if arrow_animation?
      enemies.each do |enemy|
        enemy.sprite && enemy.sprite.end_loop_anim(:arrow)
      end
    end
    @arrows.each {|arrow| arrow.dispose }
    @arrows.clear
  end
end

#==============================================================================
# ** Window_BattleActor
#------------------------------------------------------------------------------
#  This window display a list of actors on the battle screen.
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_movable?
  #--------------------------------------------------------------------------
  def cursor_movable?
    super && active && !cursor_all && !target_all? && !target_self?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    return if show_actor && arrow_move == 1
    fix_selection(:vert) if show_actor && arrow_move != 1 && @mode == :horz
    show_actor ? select((index + 1) % item_max) : super
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    return if show_actor && arrow_move == 1
    fix_selection(:vert) if show_actor && arrow_move != 1 && @mode == :horz
    show_actor ? select((index - 1 + item_max) % item_max) : super
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_right(
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    return if show_actor && arrow_move == 2
    fix_selection(:horz) if show_actor && arrow_move != 2 && @mode == :vert
    show_actor ? select((index + 1) % item_max) : super
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: cursor_left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    return if show_actor && arrow_move == 2
    fix_selection(:horz) if show_actor && arrow_move != 2 && @mode == :vert
    show_actor ? select((index - 1 + item_max) % item_max) :  super
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_help
  #--------------------------------------------------------------------------
  def update_help
    update_target_help
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    @cursor_all = cursor_all
    super
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_arrow_arrow :initialize
  def initialize(info_viewport)
    initialize_ve_arrow_arrow(info_viewport)
    init_arrow if show_actor
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_arrow_arrow :update
  def update
    update_ve_arrow_arrow
    return unless show_actor
    init_arrow_sprite
    update_arrow_sprite
    return if Graphics.frame_count % arrow_animspeed != 0
    @arrows_anim = (@arrows_anim + 1) % arrow_frames
  end
  #--------------------------------------------------------------------------
  # * Alias method: show
  #--------------------------------------------------------------------------
  alias :show_ve_arrow_arrow :show
  def show
    if show_actor
      result = super
      self.visible = false
      select(0)
      result
    else
      show_ve_arrow_arrow
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: hide
  #--------------------------------------------------------------------------
  alias :hide_ve_arrow_arrow :hide
  def hide
    result = hide_ve_arrow_arrow
    dispose_arrow if show_actor
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :update_cursor_ve_arrow_arrow :update_cursor
  def update_cursor
    show_actor ? cursor_rect.empty : update_cursor_ve_arrow_arrow
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_arrow_arrow :dispose
  def dispose
    dispose_ve_arrow_arrow
    dispose_arrow if show_actor 
  end
  #--------------------------------------------------------------------------
  # * New method: cursor_all
  #--------------------------------------------------------------------------
  def cursor_all
    @action && @action.for_all?
  end
  #--------------------------------------------------------------------------
  # * New method: actor
  #--------------------------------------------------------------------------
  def actor
    actor_list[@index]
  end
  #--------------------------------------------------------------------------
  # * New method: actors
  #--------------------------------------------------------------------------
  def actors
    actor_list
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_list
  #--------------------------------------------------------------------------
  def actor_list
    actors = $game_party.battle_members.dup
    actors.sort! {|a, b| b.screen_y <=> a.screen_y } if @mode == :vert
    actors.sort! {|a, b| a.screen_x <=> b.screen_x } if @mode == :horz
    actors
  end
  #--------------------------------------------------------------------------
  # * New method: fix_selection
  #--------------------------------------------------------------------------
  def fix_selection(type)
    current = actor
    @mode   = type
    @index  = actor_list.index(current)
  end
  #--------------------------------------------------------------------------
  # * New method: target
  #--------------------------------------------------------------------------
  def target(i)
    @index = BattleManager.actor.index if @action.for_user?
    target_all? ? actors[i] : actor
  end
  #--------------------------------------------------------------------------
  # * New method: show_actor
  #--------------------------------------------------------------------------
  def show_actor
    $imported[:ve_actor_battlers]
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_arrow
  #--------------------------------------------------------------------------
  def dispose_arrow
    if arrow_animation?
      actors.each {|actor| actor.sprite.end_loop_anim(:arrow) if actor.sprite }
    end
    @arrows.each {|arrow| arrow.dispose }
    @arrows.clear
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: create_actor_window
  #--------------------------------------------------------------------------
  alias :create_actor_window_ve_arrow_arrow :create_actor_window
  def create_actor_window
    create_actor_window_ve_arrow_arrow
    @actor_window.help_window = @help_window if VE_USE_TARGET_HELP
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_enemy_window
  #--------------------------------------------------------------------------
  alias :create_enemy_window_ve_arrow_arrow :create_enemy_window
  def create_enemy_window
    create_enemy_window_ve_arrow_arrow
    @enemy_window.help_window = @help_window if VE_USE_TARGET_HELP
  end
  #--------------------------------------------------------------------------
  # * Alias method: command_attack
  #--------------------------------------------------------------------------
  alias :command_attack_ve_arrow_arrow :command_attack
  def command_attack
    set_window_action($data_skills[BattleManager.actor.attack_skill_id])
    command_attack_ve_arrow_arrow
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_skill_ok
  #--------------------------------------------------------------------------
  alias :on_skill_ok_ve_arrow_arrow :on_skill_ok
  def on_skill_ok
    set_window_action(@skill_window.item)
    on_skill_ok_ve_arrow_arrow
    @skill_window.visible = false if VE_HIDE_SKILL_WINDOW
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_item_ok
  #--------------------------------------------------------------------------
  alias :on_item_ok_ve_arrow_arrow :on_item_ok
  def on_item_ok
    set_window_action(@item_window.item)
    on_item_ok_ve_arrow_arrow
    @item_window.visible = false if VE_HIDE_ITEM_WINDOW
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_enemy_cancel
  #--------------------------------------------------------------------------
  alias :on_enemy_cancel_ve_arrow_arrow :on_enemy_cancel
  def on_enemy_cancel
    on_enemy_cancel_ve_arrow_arrow
    case @actor_command_window.current_symbol
    when :skill then @skill_window.visible = true
    when :item  then @item_window.visible  = true
    when :attack, :direct_skill, :direct_item
      @help_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_actor_cancel
  #--------------------------------------------------------------------------
  alias :on_actor_cancel_ve_arrow_arrow :on_actor_cancel
  def on_actor_cancel
    on_actor_cancel_ve_arrow_arrow
    case @actor_command_window.current_symbol
    when :skill then @skill_window.visible = true
    when :item  then @item_window.visible  = true
    when :attack, :direct_skill, :direct_item
      @help_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_window_action
  #--------------------------------------------------------------------------
  def set_window_action(item)
    @enemy_window.set_action(item) if item.for_opponent?
    @enemy_window.update_help      if item.for_opponent?
    @actor_window.set_action(item) if item.for_friend?
    @actor_window.update_help      if item.for_friend?
  end
end