require './lib/Helpers.rb'

RSpec.describe 'Helpers' do
  context '#other_color' do
    it 'returns nil if color is invalid' do
      expect(other_color(:red)).to be_nil
    end

    it 'returns the opposite color' do
      expect(other_color(:black)).to be :white
      expect(other_color(:white)).to be :black
    end
  end

  context 'Symbol.valid_tile?' do
    it 'returns true for valid tiles' do
      expect(is_a_valid_tile?(:a1)).to be true
      expect(is_a_valid_tile?(:a5)).to be true
      expect(is_a_valid_tile?(:h8)).to be true
    end
    it 'returns false for invalid tiles' do
      expect(is_a_valid_tile?(:a9)).to be false
      expect(is_a_valid_tile?(:a0)).to be false
      expect(is_a_valid_tile?(:t9)).to be false
      expect(is_a_valid_tile?(:tt)).to be false
      expect(is_a_valid_tile?(:aa)).to be false
      expect(is_a_valid_tile?(:aaaa)).to be false
    end
  end

  context 'enpassant_tiles' do
    it 'returns two tiles' do
      t = enpassant_tiles(:d4)
      expect(t).to include :e4
      expect(t).to include :c4
      expect(t.length).to eq 2
    end
    it 'returns one tiles for a and h rank' do
      expect(enpassant_tiles(:a4)).to include :b4
      expect(enpassant_tiles(:h4)).to include :g4
      expect(enpassant_tiles(:a4).length).to eq 1
      expect(enpassant_tiles(:h4).length).to eq 1
    end
  end
end
