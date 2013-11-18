require 'rspec'
require 'game_of_life'


describe 'cell determination' do
  subject(:world) { World.new }

  it 'lists 8 dead neighbors for 1 live cell' do
    input = [[1]]
    world.load_from_array(input)
    dead_cells = world.all_nearby_dead_cells

    dead_cells.count.should == 8
  end

  it 'lists 8 dead neighbors for 1 live cell' do
    input = [[1]]
    world.load_from_array(input)
    dead_cells = world.all_nearby_dead_cells

    dead_cells.count.should == 8
  end

  it 'lists 10 dead neighbors for 2 live cells' do
    input = [[1,1]]
    world.load_from_array(input)
    dead_cells = world.all_nearby_dead_cells

    # 0 0 0 0
    # 0 1 1 0
    # 0 0 0 0
    dead_cells.count.should == 10
  end

  it 'lists 16 dead neighbors for 5 live cells in a cross' do
    input = [[0,1,0],
             [1,1,1],
             [0,1,0]]
    world.load_from_array(input)
    dead_cells = world.all_nearby_dead_cells

    # . 0 0 0 .
    # 0 0 1 0 0
    # 0 1 1 1 0
    # 0 0 1 0 0
    # . 0 0 0 .
    dead_cells.count.should == 16
  end

  it 'lists 0 live neighbors for 1 live cell' do
    input = [[1]]
    world.load_from_array(input)
    live_cell = Position.new(0,0)
    neighbors = world.live_neighbors_for_cell(live_cell)
    neighbors.count.should == 0
  end

  it 'lists 1 live neighbor for 2 adjoining live cells' do
    input = [[1,1]]
    world.load_from_array(input)
    live_cell = Position.new(0,0)
    neighbors = world.live_neighbors_for_cell(live_cell)
    neighbors.count.should == 1
  end

  it 'lists 2 live neighbors for 3 adjoining live cells' do
    input = [[1,1],
             [1,0]]
    world.load_from_array(input)
    live_cell = Position.new(0,0)
    neighbors = world.live_neighbors_for_cell(live_cell)
    neighbors.count.should == 2
  end

  it 'lists 8 live neighbors for a block of live cells' do
    input = [[1,1,1],
             [1,1,1],
             [1,1,1]]
    world.load_from_array(input)
    live_cell = Position.new(1,1)
    neighbors = world.live_neighbors_for_cell(live_cell)
    neighbors.count.should == 8
  end

end

describe 'basic rules for a single generation' do
  subject(:world) { World.new }

  it 'kills a cell with no live neighbors' do
    input = [[1]]
    world.load_from_array(input)

    world.next_tick

    expect = [[0]]
    world.to_a.should eq(expect)
  end

  it 'kills cells with 1 live neighbor' do
    input = [[1,1]]
    world.load_from_array(input)

    world.next_tick

    expect = [[0,0]]
    world.to_a.should eq(expect)
  end

  it 'allows a cell to live with 2 live neighbors' do
    input = [[1,1,1]]
    world.load_from_array(input)

    world.next_tick

    expect = [[0,1,0],
              [0,1,0],
              [0,1,0]]
    world.to_a.should eq(expect)
  end

  it 'allows a cell to live with 3 live neighbors' do
    input = [[1,1],
             [1,1]]
    world.load_from_array(input)

    world.next_tick

    expect = [[1,1],
              [1,1]]
    world.to_a.should eq(expect)
  end

  it 'reincarnates a dead cell with 3 live neighbors' do
    input = [[1,1],
             [1,0]]
    world.load_from_array(input)

    world.next_tick

    expect = [[1,1],
              [1,1]]
    world.to_a.should eq(expect)
  end

end 


describe 'world setup' do
  subject(:world) { World.new }

  it 'instantiates a new World object' do
    subject.is_a?(World).should be_true
  end

  describe 'initializing empty world' do
    describe '#to_a (the external version of the cell grid)' do
      it 'has #to_a' do
        world.should respond_to(:to_a)
      end      
      it 'returns an array' do
        world.to_a.is_a?(Array).should be_true
      end
      it 'returns a 2-d array' do
        world.to_a.each do |row|
          row.is_a?(Array).should be_true
        end
      end
      it 'returns a grid containing one dead cell' do
        expect = [[0]]
        world.to_a.should eq(expect)
      end
      it 'has a generation count of 1' do
        world.generation.should == 1
      end
    end
  end

  describe 'adding live cells at specific grid positions' do
    describe '#add_live_cell' do
      describe "adding 1 cell" do
        it 'adds with no offset (at world center)' do
          world.add_live_cell(Position.new(0, 0))
          expect = [[1]]
          world.to_a.should eq(expect)
        end

        describe "offset by 1" do
          it 'adds top-right from center' do
            world.add_live_cell(Position.new(1, 1))
            expect = [[0,1],
                      [0,0]]
            world.to_a.should eq(expect)
          end
          it 'adds bottom-right from center' do
            world.add_live_cell(Position.new(1, -1))
            expect = [[0,0],
                      [0,1]]
            world.to_a.should eq(expect)
          end
          it 'adds top-left from center' do
            world.add_live_cell(Position.new(-1, 1))
            expect = [[1, 0],
                      [0, 0]]
            world.to_a.should eq(expect)
          end
          it 'adds bottom-left from center' do
            world.add_live_cell(Position.new(-1, -1))
            expect = [[0,0],
                      [1,0]]
            world.to_a.should eq(expect)
          end
        end

        describe "offset by 2" do
          it 'adds top-right from center' do
            world.add_live_cell(Position.new(2, 2))
            expect = [[0,0,1],
                      [0,0,0],
                      [0,0,0]]
            world.to_a.should eq(expect)
          end
          it 'adds bottom-right from center' do
            world.add_live_cell(Position.new(2, -2))
            expect = [[0,0,0],
                      [0,0,0],
                      [0,0,1]]
            world.to_a.should eq(expect)
          end
          it 'adds top-left from center' do
            world.add_live_cell(Position.new(-2, 2))
            expect = [[1,0,0],
                      [0,0,0],
                      [0,0,0]]
            world.to_a.should eq(expect)
          end
          it 'adds bottom-left from center' do
            world.add_live_cell(Position.new(-2, -2))
            expect = [[0,0,0],
                      [0,0,0],
                      [1,0,0]]
            world.to_a.should eq(expect)
          end
        end

      end

     describe 'adding 2 cells' do
        describe 'with no offset (at center)' do
          it 'adds horizontally' do
            world.add_live_cell(Position.new(0, 0))
            world.add_live_cell(Position.new(1, 0))
            expect = [[1,1]]
            world.to_a.should eq(expect)
          end

          it 'adds vertically' do
            world.add_live_cell(Position.new(0, 0))
            world.add_live_cell(Position.new(0, 1))
            expect = [[1],
                      [1]]
            world.to_a.should eq(expect)
          end
        end

        describe 'offset by 1' do
          it 'adds horizontally, offset down by 1' do
            world.add_live_cell(Position.new(0, -1))
            world.add_live_cell(Position.new(1, -1))
            expect = [[0,0],
                      [1,1]]
            world.to_a.should eq(expect)
          end

          it 'adds horizontally, offset up by 1' do
            world.add_live_cell(Position.new(0, 1))
            world.add_live_cell(Position.new(1, 1))
            expect = [[1,1],
                      [0,0]]
            world.to_a.should eq(expect)
          end

          it 'adds vertically, offset left by 1' do
            world.add_live_cell(Position.new(-1, 0))
            world.add_live_cell(Position.new(-1, 1))
            expect = [[1,0],
                      [1,0]]
            world.to_a.should eq(expect)
          end

        end
      end
    end
  end

  describe "#load_from_array" do

    it 'loads a single cell' do
      input = [[1]]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end

    it 'loads a row of cells' do
      input = [[1, 1, 1]]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end

    it 'loads a column of cells' do
      input = [[1],
               [1],
               [1]]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end

    it 'loads a 2x2 grid of cells' do
      input = [[1,1],
               [1,1]]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end

    it 'loads a cross pattern' do
      input = [[1,1,0],
               [1,1,1],
               [0,1,0],]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end

    it 'loads a toad pattern' do
      input = [[0,1,1,1],
               [1,1,1,0]]
      world.load_from_array(input)
      world.to_a.should eq(input)
    end
  end

  describe 'various popular patterns' do

    describe 'still lifes' do
      it 'renders a Block' do
        input = [[1,1],
                 [1,1]]
        world.load_from_array input
        world.next_tick
        world.to_a.should eq(input)
      end

      it 'renders a Beehive' do
        input = [[0,1,1,0],
                 [1,0,0,1],
                 [0,1,1,0]]
        world.load_from_array input
        world.next_tick
        world.to_a.should eq(input)
      end

      it 'renders a Loaf' do
        input = [[0,1,1,0],
                 [1,0,0,1],
                 [0,1,0,1],
                 [0,0,1,0]]
        world.load_from_array input
        world.next_tick
        world.to_a.should eq(input)
      end

      it 'renders a Boat' do
        input = [[1,1,0],
                 [1,0,1],
                 [0,1,0]]
        world.load_from_array input
        world.next_tick
        world.to_a.should eq(input)
      end
    end

    describe 'oscillators' do
      it 'renders a Blinker' do
        input = [[1,1,1]]
        world.load_from_array(input)

        vertical = [[0,1,0],
                    [0,1,0],
                    [0,1,0]]
        world.next_tick
        world.to_a.should eq(vertical)

        horizontal = [[0,0,0],
                      [1,1,1],
                      [0,0,0]]
        world.next_tick
        expect(world.to_a).to eq(horizontal)

        world.next_tick
        expect(world.to_a).to eq(vertical)
   
        world.next_tick
        expect(world.to_a).to eq(horizontal) 
      end

      it 'renders a Toad' do
        input = [[0,1,1,1],
                 [1,1,1,0]]
        world.load_from_array(input)

        breathe_out = [[0,0,1,0],
                       [1,0,0,1],
                       [1,0,0,1],
                       [0,1,0,0]]
        world.next_tick
        world.to_a.should eq(breathe_out)

        breathe_in = [[0,0,0,0],
                      [0,1,1,1],
                      [1,1,1,0],
                      [0,0,0,0]]
        world.next_tick
        world.to_a.should eq(breathe_in)

        world.next_tick
        world.to_a.should eq(breathe_out)

        world.next_tick
        world.to_a.should eq(breathe_in)
      end
    end

  end

end
