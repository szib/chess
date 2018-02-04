require './lib/Command.rb'

RSpec.describe Command do
  context 'invalid command' do
    it 'returns nil' do
      expect(Command.parse('move aa')).to be_nil
      expect(Command.parse('move a2 a9')).to be_nil
      expect(Command.parse('move a2 r1')).to be_nil
      expect(Command.parse('move 11')).to be_nil
      expect(Command.parse('move')).to be_nil
      expect(Command.parse('move 11 22')).to be_nil
      expect(Command.parse('11 22')).to be_nil
      expect(Command.parse('a3 r3')).to be_nil
      expect(Command.parse('')).to be_nil
      expect(Command.parse('sdlfj sjdb ldsfb')).to be_nil
    end
  end

  context 'valid commands' do
    context 'save' do
      it 'returns the correct hash' do
        command = 'save'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :save)
      end
    end
    context 'load' do
      it 'returns the correct hash' do
        command = 'load'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :load)
      end
    end
    context 'quit' do
      it 'returns the correct hash' do
        command = 'quit'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :quit)
      end
    end
    context 'resign' do
      it 'returns the correct hash' do
        command = 'resign'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :resign)
      end
    end
  end

  context 'move command' do
    context 'only tiles without command' do
      it 'returns the correct hash' do
        command = 'a2 a4'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :move)
        expect(Command.parse(command)).to include(from: :a2)
        expect(Command.parse(command)).to include(to: :a4)
      end
    end
    context 'tiles with move command' do
      it 'returns the correct hash' do
        command = 'move a2 a4'
        expect(Command.parse(command)).to be_instance_of Hash
        expect(Command.parse(command)).to include(command: :move)
        expect(Command.parse(command)).to include(from: :a2)
        expect(Command.parse(command)).to include(to: :a4)
      end
    end
  end
end
