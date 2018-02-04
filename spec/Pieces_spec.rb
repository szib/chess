require './spec/Helpers.rb'
require './lib/Chessboard.rb'

RSpec.describe 'Pieces' do
  generate_pieces

  context '#to_s' do
    it 'returns the correct Unicode character' do
      expect(blackPawn.to_s).to include('♙')
      expect(whitePawn.to_s).to include('♟')
      expect(blackKing.to_s).to include('♔')
      expect(whiteKing.to_s).to include('♚')
    end
  end

  # context 'promotion', skip: true do
  context 'promotion' do
    context 'when the pawn has has reached the other side' do
      it 'it promotes a black pawn at 1st rank' do
        promoted = blackPawn.promote(:d1)
        expect(promoted).to be_an_instance_of Piece
        expect(promoted).to be_promoted
      end
      it 'it does not promote a black pawn at 8th rank' do
        promoted = blackPawn.promote(:d8) if blackPawn.has_reached_the_other_side?(:d8)
        expect(promoted).to be nil
      end
      it 'it promotes a white pawn at 8th rank' do
        promoted = whitePawn.promote(:d8)
        expect(promoted).to be_an_instance_of Piece
        expect(promoted).to be_promoted
      end
      it 'it does not promote a black pawn at 1st rank' do
        promoted = whitePawn.promote(:d1) if whitePawn.has_reached_the_other_side?(:d1)
        expect(promoted).to be nil
      end
    end

    it 'does not promote black pawn at 5st rank' do
      promoted = blackPawn.promote(:d5) if blackPawn.has_reached_the_other_side?(:d5)
      expect(promoted).to be nil
    end
  end

  context '#move_set' do
    it 'returns legal moves for the piece' do
      expect(blackRook.move_set(:f5)).to include :f8
      expect(blackRook.move_set(:f5)).to include :f1
      expect(blackRook.move_set(:f5)).to include :a5
      expect(blackRook.move_set(:f5)).to include :h5
      expect(blackPawn.move_set(:f5)).to include :f4
      expect(blackPawn.move_set(:f5)).to include :f3
      expect(blackPawn.move_set(:f5)).to include :e4
      expect(blackPawn.move_set(:f5)).to include :g4
      expect(whitePawn.move_set(:f5)).to include :e6
      expect(whitePawn.move_set(:f5)).to include :f6
      expect(whitePawn.move_set(:f5)).to include :g6
      expect(whitePawn.move_set(:f5)).to include :f7
    end

    it 'does not return illegal moves for the piece' do
      expect(blackRook.move_set(:f5)).to_not include :f5
      expect(blackRook.move_set(:f5)).to_not include :d3
    end

    it 'does not returns tiles not on the board' do
      expect(whitePawn.move_set(:f7)).to include :g8
      expect(whitePawn.move_set(:f7)).to include :f8
      expect(whitePawn.move_set(:f7)).to include :e8
      expect(whitePawn.move_set(:f7)).to_not include :f9
      expect(whiteKnight.move_set(:b8)).to_not include :d9
      expect(whiteKnight.move_set(:b8)).to include :d7
    end
  end

  context 'serializaton' do
    it 'responds to serialize & unserialize' do
      expect(blackPawn).to respond_to :serialize
      expect(whiteKing).to respond_to :unserialize
    end
    it 'can be saved and restored' do
      data = blackQueen.serialize
      p = Piece.new(:white)
      p.unserialize(data)
      expect(blackQueen.serialize).to eq p.serialize
    end
    it 'saves @moved correctly' do
      blackQueen.moved = true
      data = blackQueen.serialize
      p = Piece.new(:white)
      p.unserialize(data)
      expect(blackQueen.serialize).to eq p.serialize
    end
  end
end
