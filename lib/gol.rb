#!/usr/bin/env ruby

class Grid
  attr_reader :width, :height

  def initialize(seed)

    # Convert ASCII into 2D array
    seed = seed.split("\n").map { |row| row.split('') } unless seed.respond_to?(:each)

    @width = seed[0].count
    @height = seed.count
    @cells = Array.new(@height) do |y|
      Array.new(@width) do |x|
        state = seed[y][x] != '.'
        Cell.new(x, y, state)
      end
    end
  end

  # Find a Cell
  def cell_at(x, y)
    @cells[y][x]
  end

  # Find neighbouring Cells
  def neighbours(x, y)
    neighbours = []

    # Loop through each offset to get all possible adjecent coordinates
    [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]].each do |offset|
      ny = y + offset[0]
      nx = x + offset[1]

      # don't try to return a non-existent cell
      neighbours << @cells[ny][nx] if nx.between?(0, width-1) and ny.between?(0, height-1)
    end

    neighbours
  end

  # Cause cells to change state
  def tick!
    to_die = []
    to_live = []

    @cells.each do |row|
      row.each do |cell|

        # Add up the number of 'alive' neighbouring cells
        live_neighbour_count = neighbours(cell.x, cell.y).select { |n| n.alive? }.count

        if cell.alive? and (live_neighbour_count < 2 || live_neighbour_count > 3)
          to_die << cell
        elsif cell.dead? and live_neighbour_count == 3
          to_live << cell
        end
      end
    end

    to_die.each { |cell| cell.die! }
    to_live.each { |cell| cell.live! }
  end

  def to_s
    @cells.map { |row| row.join }.join("\n")
  end
end

class Cell
  attr_accessor :x, :y

  def initialize(x, y, alive)
    @x = x
    @y = y
    @alive = alive
  end

  def alive?
    @alive
  end

  def dead?
    !alive?
  end

  def live!
    @alive = true
  end

  def die!
    @alive = false
  end

  def to_s
    alive? ? 'X' : '.'
  end
end
