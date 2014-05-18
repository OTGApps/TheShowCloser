describe 'WishlistItem' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a WishlistItem entity' do
    WishlistItem.entity_description.name.should == 'WishlistItem'
  end
end
