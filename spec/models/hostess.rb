describe 'Hostess' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Hostess entity' do
    Hostess.entity_description.name.should == 'Hostess'
  end
end
