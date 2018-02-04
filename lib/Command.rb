require './lib/Helpers.rb'

class Command
  def self.parse(string)
    commands = %w[save load quit resign move help display board]
    s = string.downcase.split(' ')
    s.unshift('move') unless commands.include? s[0]

    hash = {}
    hash[:command] = s[0].to_sym

    if s[0] == 'move'
      return nil unless is_a_valid_tile?(s[1]) && is_a_valid_tile?(s[2])
      hash[:from] = s[1].to_sym
      hash[:to] = s[2].to_sym
    end
    hash
  end
end
