RSpec.describe Blurhash do
  it 'has a version number' do
    expect(Blurhash::VERSION).not_to be nil
  end

  describe '.encode' do
    it 'returns a string' do
      pixels = File.read(File.join(__dir__, 'fixtures', 'test.bin')).unpack('C*')
      expect(Blurhash.encode(204, 204, pixels)).to eq 'LFE.@D9F01_2%L%MIVD*9Goe-;WB'
    end

    it 'raises if pixels array has wrong size' do
      expect { Blurhash.encode(204, 204, [0, 1, 2]) }.to raise_error(RuntimeError, 'Pixels array has wrong size')
    end
  end

  describe '.components' do
    it 'returns an array' do
      expect(Blurhash.components('LFE.@D9F01_2%L%MIVD*9Goe-;WB')).to eq [4, 3]
    end

    it 'returns nil' do
      expect(Blurhash.components('foo')).to be_nil
    end
  end
end
