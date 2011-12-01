#!/usr/bin/env ruby

require 'rubygems'
require 'rspec'
require './gol'


describe "Game of Life" do
  let(:grid) do
    seed = <<-EOS
...
...
...
...
EOS
    Grid.new(seed)
  end

  context "Grid" do
    it "has a width" do
      grid.width.should == 3
    end

    it "has a height" do
      grid.height.should == 4
    end

    it "finds the Cell object at a location" do
      grid.cell_at(0, 0).should be_a(Cell)
    end

    it "finds the cells surrounding a specific cell" do
      grid.neighbours(1, 1).count.should == 8
      grid.neighbours(1, 1).should include(grid.cell_at(0, 0)) # NW
      grid.neighbours(1, 1).should include(grid.cell_at(1, 0)) # N
      grid.neighbours(1, 1).should include(grid.cell_at(2, 0)) # NE
      grid.neighbours(1, 1).should include(grid.cell_at(0, 1)) # W
      grid.neighbours(1, 1).should include(grid.cell_at(2, 1)) # E
      grid.neighbours(1, 1).should include(grid.cell_at(0, 2)) # SW
      grid.neighbours(1, 1).should include(grid.cell_at(1, 2)) # S
      grid.neighbours(1, 1).should include(grid.cell_at(2, 2)) # SE

      grid.neighbours(1, 1).should_not include(grid.cell_at(0, 3))
      grid.neighbours(1, 1).should_not include(grid.cell_at(1, 3))
      grid.neighbours(1, 1).should_not include(grid.cell_at(2, 3))
    end
  end


  context "Cell" do
    subject { grid.cell_at(1, 2) }
    before(:each) { subject.live! }

    it "knows its X position" do
      subject.x.should == 1
    end

    it "knows its Y position" do
      subject.y.should == 2
    end

    it "knows if it is alive" do
      subject.should be_alive
    end

    it "can die" do
      subject.die!
      subject.should be_dead
    end

    it "can live" do
      subject.live!
      subject.should be_alive
    end

    it "renders itself as a string" do
      subject.to_s.should == 'X'
      subject.die!
      subject.to_s.should == '.'
    end
  end


  context "Rules" do

    context "1: Any live cell with fewer than two live neighbours dies, as if caused by under-population" do
      it "dies with no neighbours" do
        grid = Grid.new(<<-EOS
...
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_dead
      end

      it "dies with 1 neighbours" do
        grid = Grid.new(<<-EOS
.X.
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_dead
      end
    end

    context "2: Any live cell with two or three live neighbours lives on to the next generation" do
      it "survives with 2 neighbours" do
        grid = Grid.new(<<-EOS
.XX
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_alive
      end

      it "survives with 3 neighbours" do
        grid = Grid.new(<<-EOS
XXX
.X.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_alive
      end
    end

    context "3: Any live cell with more than three live neighbours dies, as if by overcrowding" do
      it "dies with 4 neighbours" do
        grid = Grid.new(<<-EOS
XXX
XX.
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_dead
      end
    end

    context "4: Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction" do
      it "generates a cell in a space with 3 neighbours" do
        grid = Grid.new(<<-EOS
...
XXX
...
EOS
)
        grid.tick!
        grid.cell_at(1, 1).should be_alive
        grid.cell_at(1, 0).should be_alive
        grid.cell_at(1, 2).should be_alive

        grid.cell_at(0, 1).should be_dead
        grid.cell_at(2, 1).should be_dead
      end
    end

  end
end

