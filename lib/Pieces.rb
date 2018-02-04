require 'highline'
require './lib/Helpers.rb'

class Piece
  attr_reader :type, :color
  attr_accessor :moved

  def initialize(color)
    extend(Serializable)
    @type = [:Piece]
    @color = color
    @visual = {}
    @visual[:white] = 'W'
    @visual[:black] = 'B'
    @moves = []
    @moved = false
  end

  def move_set(tile)
    return false unless is_a_valid_tile?(tile)
    @moves.map { |move| "#{(tile.to_file.ord + move[0]).chr}#{tile.to_rank + move[1]}".to_sym }
          .select { |t| is_a_valid_tile?(t) }
  end

  def to_s
    @visual[@color]
  end
end

module Pawn
  def init
    @visual[:white] = "\u265f"
    @visual[:black] = "\u2659"
    @moves = [[-1, 1], [0, 1], [1, 1], [0, 2]] if color == :white
    @moves = [[-1, -1], [0, -1], [1, -1], [0, -2]] if color == :black
  end

  def has_reached_the_other_side?(tile)
    return false if @color == :white && tile.to_rank != 8
    return false if @color == :black && tile.to_rank != 1
    true
  end

  def promote(_tile)
    Piece.new(@color).extend(Kernel.const_get(new_rank))
  end

  def self.extended(mod)
    mod.type << :Pawn
    mod.init
  end

  private

  def new_rank
    cli = HighLine.new
    cli.choose do |menu|
      menu.prompt = 'Which rank would you like it promoted?'
      menu.choices(:Queen, :Rook, :Bishop, :Knight) { |c| return c }
      menu.default = :Queen
    end
  end
end

module Rook
  def init
    @visual[:white] = "\u265c"
    @visual[:black] = "\u2656"
    @moves = (-7..7).to_a.permutation(2).select { |x| x[0] == 0 || x[1] == 0 }
  end

  def self.extended(mod)
    mod.type << :Rook
    mod.init
  end
end

module Knight
  def init
    @visual[:white] = "\u265e"
    @visual[:black] = "\u2658"
    @moves = [-2, -1, 1, 2].permutation(2).to_a.reject { |x| x[0].abs == x[1].abs }
  end

  def self.extended(mod)
    mod.type << :Knight
    mod.init
  end
end

module Bishop
  def init
    @visual[:white] = "\u265d"
    @visual[:black] = "\u2657"
    @moves = (-7..7).to_a.repeated_permutation(2).select { |x| x[0].abs == x[1].abs }
  end

  def self.extended(mod)
    mod.type << :Bishop
    mod.init
  end
end

module Queen
  def init
    @visual[:white] = "\u265b"
    @visual[:black] = "\u2655"
    @moves = (-7..7).to_a.repeated_permutation(2).select { |x| x[0].abs == x[1].abs }
    @moves.concat((-7..7).to_a.permutation(2).select { |x| x[0] == 0 || x[1] == 0 })
  end

  def self.extended(mod)
    mod.type << :Queen
    mod.init
  end
end

module King
  attr_reader :castlingmoves
  def init
    @visual[:white] = "\u265a"
    @visual[:black] = "\u2654"
    @moves = [-1, 1, 0].repeated_permutation(2)
                       .reject { |t| t == [0, 0] }
                       .to_a
    @castlingmoves = [[2, 0], [-2, 0]]
  end

  def castling_move_set(tile)
    return false unless is_a_valid_tile?(tile)
    @castlingmoves.map { |move| "#{(tile.to_file.ord + move[0]).chr}#{tile.to_rank + move[1]}".to_sym }
                  .select { |t| is_a_valid_tile?(t) }
  end

  def self.extended(mod)
    mod.type << :King
    mod.init
  end
end
