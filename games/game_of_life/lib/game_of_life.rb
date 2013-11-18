require 'pry'
require 'set'

#http://en.wikipedia.org/wiki/Conway's_Game_of_Life
#example of good specs: https://github.com/mongoid/mongoid/blob/v3.0.3/spec/mongoid_spec.rb

Position = Struct.new(:x, :y) do
  def to_s
    "#{x}|#{y}"
  end

  def from_sym(sym)
    self.x, self.y = sym.to_s.split('|').map {|str| str.to_i}
    self
  end

  def to_sym
    to_s.to_sym
  end

  def neighbors
    [Position.new(x-1,y-1),
     Position.new(x,y-1),
     Position.new(x+1,y-1),
     Position.new(x-1,y),
     Position.new(x+1,y),
     Position.new(x-1,y+1),
     Position.new(x,y+1),
     Position.new(x+1,y+1)]
  end
end

class World
  attr_reader :generation

  def initialize
    # Note: intentionally not allowing grid setup in the constructor
    @cells = {}
    @next_tick_cells = {}
    @bounds = {
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
    }
    @generation = 1
  end

  def next_tick
    calculate_next_states_for_live_cells
    calculate_next_states_for_dead_cells
    @cells = @next_tick_cells
    @next_tick_cells = {}
    reset_boundaries
  end

  def calculate_next_states_for_live_cells
    @cells.keys.each do |cell_key|
      live_cell = Position.new.from_sym(cell_key)
      count = live_neighbors_for_cell(live_cell).count

      if count < 2
        # Note: no need to delete, just don't transfer...
      elsif count == 2 || count == 3
        # let it live!
        @next_tick_cells[cell_key] = 1
      elsif count > 3
        # Note: no need to delete, just don't transfer...
      end
    end
  end

  def live_neighbors_for_cell(cell)
    cell.neighbors.select {|cell| cell if @cells[cell.to_sym] }
  end

  def calculate_next_states_for_dead_cells
    all_nearby_dead_cells.each do |cell|
      count = live_neighbors_for_cell(cell).count
      if count == 3
        @next_tick_cells[cell.to_sym] = 1      
      end
    end 
  end

  def all_nearby_dead_cells
    @cells.keys.each_with_object(Set.new) do |live_cell_key, dead_cells|
      live_cell = Position.new.from_sym(live_cell_key)
      dead_cells.merge(live_cell.neighbors.reject {|cell| cell if @cells[cell.to_sym] }.to_set)
    end
  end

  def load_from_array(arr)
    # Note: process from bottom-to-top, so the indexes are aligned to the x-axis (y=0)
    arr.reverse.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        add_live_cell(Position.new(x, y)) if cell == 1
      end
    end
  end

  def add_live_cell(position)
    @cells[position.to_sym] = 1
    update_boundaries(position)
  end

  def reset_boundaries
    @cells.keys.each do |cell_key|
      update_boundaries Position.new.from_sym(cell_key)
    end
  end

  def update_boundaries(position)
    @bounds[:top] = [@bounds[:top], position.y].max
    @bounds[:bottom] = [@bounds[:bottom], position.y].min
    @bounds[:left] = [@bounds[:left], position.x].min
    @bounds[:right] = [@bounds[:right], position.x].max
  end

  def cols
    @bounds[:right].abs + @bounds[:left].abs
  end

  def rows
    @bounds[:bottom].abs + @bounds[:top].abs
  end

  def to_a
    # translate the grid into "print coordinates"
    horizontal_offset = -1 * @bounds[:left]
    left = 0
    right = @bounds[:right] + horizontal_offset

    vertical_offset = -1 * @bounds[:bottom]
    top = @bounds[:top] + vertical_offset
    bottom = 0

    top.downto(bottom).map do |y|
      left.upto(right).map do |x|
        @cells[Position.new(x - horizontal_offset, y - vertical_offset).to_sym] ? 1 : 0
      end
    end
  end
end