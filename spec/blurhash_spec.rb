RSpec.describe Blurhash do
  it 'has a version number' do
    expect(Blurhash::VERSION).not_to be nil
  end

  describe '.encode' do
    it 'returns a string' do
      image = Magick::ImageList.new(File.join(__dir__, 'fixtures', 'test.png'))
      expect(Blurhash.encode(image.columns, image.rows, image.export_pixels)).to eq 'LFE.@D9F01_2%L%MIVD*9Goe-;WB'
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
