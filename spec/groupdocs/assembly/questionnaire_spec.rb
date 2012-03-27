require 'spec_helper'

describe GroupDocs::Assembly::Questionnaire do

  it_behaves_like GroupDocs::Api::Entity

  it { should respond_to(:pages)  }
  it { should respond_to(:pages=) }

  it 'has human-readable accessors' do
    subject.should respond_to(:description)
    subject.should respond_to(:description=)
    subject.method(:description).should  == subject.method(:descr)
    subject.method(:description=).should == subject.method(:descr=)
  end

  describe '.executions!' do
    before(:each) do
      mock_api_server(load_json('questionnaire_executions'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.executions!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns an array of GroupDocs::Assembly::Questionnaire::Execution objects' do
      executions = described_class.executions!
      executions.should be_an(Array)
      executions.each do |execution|
        execution.should be_a(GroupDocs::Assembly::Questionnaire::Execution)
      end
    end
  end

  describe '#add_page' do
    it 'raises error if page is not GroupDocs::Assembly::Questionnaire::Page object' do
      -> { subject.add_page('Page') }.should raise_error(ArgumentError)
    end

    it 'adds page to pages instance variable' do
      page = GroupDocs::Assembly::Questionnaire::Page.new
      lambda do
        subject.add_page(page)
      end.should change(subject, :pages).to([page])
    end
  end

  describe '#create!' do
    before(:each) do
      mock_api_server(load_json('questionnaire_create'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.create!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.create!
    end

    it 'adds ID of questionnaire from response to self' do
      lambda do
        subject.create!
      end.should change(subject, :id)
    end
  end
end