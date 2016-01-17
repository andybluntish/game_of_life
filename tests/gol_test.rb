#!/usr/bin/env ruby

require 'minitest/autorun'
require './gol'

describe "Game of Life" do
  before do
    @seed = <<-EOS
...
...
...
...
EOS
    @grid = Grid.new(@seed)
  end

  describe "Grid" do
    it "has a width" do
      @grid.width.must_equal 3
    end

    it "has a height" do
      @grid.height.must_equal 4
    end

    it "finds the Cell object at a location" do
      @grid.cell_at(0, 0).kind_of?(Cell).must_equal true
    end

    it "finds the cells surrounding a specific cell" do
      @grid.neighbours(1, 1).count.must_equal 8
      @grid.neighbours(1, 1).include?(@grid.cell_at(0, 0)).must_equal true # NW
      @grid.neighbours(1, 1).include?(@grid.cell_at(1, 0)).must_equal true # N
      @grid.neighbours(1, 1).include?(@grid.cell_at(2, 0)).must_equal true # NE
      @grid.neighbours(1, 1).include?(@grid.cell_at(0, 1)).must_equal true # W
      @grid.neighbours(1, 1).include?(@grid.cell_at(2, 1)).must_equal true # E
      @grid.neighbours(1, 1).include?(@grid.cell_at(0, 2)).must_equal true # SW
      @grid.neighbours(1, 1).include?(@grid.cell_at(1, 2)).must_equal true # S
      @grid.neighbours(1, 1).include?(@grid.cell_at(2, 2)).must_equal true # SE

      @grid.neighbours(1, 1).include?(@grid.cell_at(0, 3)).must_equal false
      @grid.neighbours(1, 1).include?(@grid.cell_at(1, 3)).must_equal false
      @grid.neighbours(1, 1).include?(@grid.cell_at(2, 3)).must_equal false
    end
  end

  describe "Cell" do
    before do
      @cell = @grid.cell_at(1, 2);
      @cell.live!
    end

    it "knows its X position" do
      @cell.x.must_equal 1
    end

    it "knows its Y position" do
      @cell.y.must_equal 2
    end

    it "knows if it is alive" do
      @cell.alive?.must_equal true
    end

    it "can die" do
      @cell.die!
      @cell.dead?.must_equal true
    end

    it "can live" do
      @cell.live!
      @cell.alive?.must_equal true
    end

    it "renders itself as a string" do
      @cell.to_s.must_equal 'X'
      @cell.die!
      @cell.to_s.must_equal '.'
    end
  end

  describe "Rules" do
    describe "1: Any live cell with fewer than two live neighbours dies, as if caused by under-population" do
      it "dies with no neighbours" do
        grid = Grid.new(<<-EOS
...
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).dead?.must_equal true
      end

      it "dies with 1 neighbours" do
        grid = Grid.new(<<-EOS
.X.
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).dead?.must_equal true
      end
    end

    describe "2: Any live cell with two or three live neighbours lives on to the next generation" do
      it "survives with 2 neighbours" do
        grid = Grid.new(<<-EOS
.XX
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).alive?.must_equal true
      end

      it "survives with 3 neighbours" do
        grid = Grid.new(<<-EOS
XXX
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).alive?.must_equal true
      end
    end

    describe "3: Any live cell with more than three live neighbours dies, as if by overcrowding" do
      it "dies with 4 neighbours" do
        grid = Grid.new(<<-EOS
XXX
XX.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).dead?.must_equal true
      end
    end

    describe "4: Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction" do
      it "generates a cell in a space with 3 neighbours" do
        grid = Grid.new(<<-EOS
...
XXX
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).alive?.must_equal true
        grid.cell_at(1, 0).alive?.must_equal true
        grid.cell_at(1, 2).alive?.must_equal true

        grid.cell_at(0, 1).dead?.must_equal true
        grid.cell_at(2, 1).dead?.must_equal true
      end
    end
  end
end
