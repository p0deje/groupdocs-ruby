require 'spec_helper'

describe GroupDocs::Api::Helpers::AccessRights do
  subject do
    GroupDocs::Document::Annotation::Reviewer.new
  end

  describe '#convert_access_rights_to_byte' do
    let(:rights) { %w(export view proof download) }

    it 'raises error if rights is not an array' do
      -> { subject.send(:convert_access_rights_to_byte, :export) }.should raise_error(ArgumentError)
    end

    it 'raises error if right is unknown' do
      -> { subject.send(:convert_access_rights_to_byte, %w(unknown)) }.should raise_error(ArgumentError)
    end

    it 'converts each right to Symbol' do
      rights.each do |right|
        symbol = right.to_sym
        right.should_receive(:to_sym).and_return(symbol)
      end
      subject.send(:convert_access_rights_to_byte, rights)
    end

    it 'returns correct byte flag' do
      subject.send(:convert_access_rights_to_byte, rights).should == 15
    end
  end

  describe '#convert_byte_to_access_rights' do
    let(:rights) { %w(export view proof) }

    it 'raises error if rights is not an integer' do
      -> { subject.send(:convert_byte_to_access_rights, :export) }.should raise_error(ArgumentError)
    end

    it 'returns correct rights array flag' do
      subject.send(:convert_byte_to_access_rights, 13).should =~ rights.map(&:to_sym)
    end
  end
end
