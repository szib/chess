require 'highline'
require './lib/Chessboard.rb'
require './lib/Command.rb'

class Game
  attr_reader :board

  def initialize
    @board = Chessboard.new
    @save_dir = './save/'
    @save_filename = 'saved_game'
  end

  def save_game(*arg)
    data = board.serialize
    if arg.empty?
      ask_filename
    else
      @save_filename = arg[0]
    end
    File.open("#{@save_dir}#{@save_filename}.json", 'w') { |f| f.puts data }
    data
  rescue StandardError
    puts 'Save error...'
  end

  def load_game(*arg)
    if arg.empty?
      ask_filename
    else
      @save_filename = arg[0]
    end
    data = File.open("#{@save_dir}#{@save_filename}.json", 'r', &:read)
    board.unserialize(data)
    board.serialize
  rescue StandardError
    puts 'Load error...'
  end

  def show_help
    help = %(
    Commands:
      quit                        Quit game
      resign                      Resign from the game
      save                        Save game
      load                        Load game
      display | board             Display board
      move <from> <to>            Move piece eg. "move a2 a4"
      <from> <to>                 Move piece eg. "a2 a4"

      Castling: move two tiles with king eg. "move e1 g1" or "e1 c1"

    )
    puts help
  end

  def user_input
    cli = HighLine.new
    answer = nil
    while answer.nil?
      answer = cli.ask("\n[#{@board.current_player}] ~~> ", Command)
      puts "Unknown or illegal command. Type 'help' for help." if answer.nil?
    end
    answer
  end

  def play ## main game loop
    puts @board.display
    game_over = board.game_over?
    until game_over

      if @board.stalemate?
        puts 'Stalemate.'
        exit
      end

      input = user_input
      exit if input[:command] == :quit

      case input[:command]
      when :help
        show_help
      when :move
        @board.move(input[:from], input[:to])
      when :load
        load_game
      when :save
        save_game
      when :resign
        puts "Resignation. The winner is: #{other_color(@board.current_player)}"
        exit
      end

      game_over = @board.game_over?
      puts @board.display

    end

    case game_over[:reason]
    when :checkmate
      puts "Checkmate. The winner is: #{game_over[:winner]}"
    when :insufficient_material
      puts "Insufficient material. It's a draw."
    end
  end

  private

  def ask_filename
    cli = HighLine.new
    answer = nil
    while answer.nil?
      answer = cli.ask("\nfilename? [#{@save_filename}] >> ")
      unless answer.empty? || answer =~ /^\w+$/
        puts 'Illegal filename. It can contain only letters, numbers and underscore.'
        answer = nil
      end
    end
    @save_filename = answer unless answer.empty?
  end
end
