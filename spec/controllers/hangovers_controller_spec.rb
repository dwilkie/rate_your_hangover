require 'spec_helper'

describe HangoversController do
  SAMPLE_ID = 1


  let(:hangover) { mock_model(Hangover).as_null_object }

  describe "GET /hangovers" do

    let(:hangovers) {[
      hangover
    ]}

    before do
      Hangover.stub(:inventory).and_return(hangovers)
    end

    it "should render index template" do
      get :index
      response.should render_template(:index)
    end

    it "should get the inventory" do
      Hangover.should_receive(:inventory)
      get :index
    end

    it "should assign '@hangovers'" do
      get :index
      assigns[:hangovers].should == hangovers
    end
  end

  describe "GET /hangovers/#{SAMPLE_ID}" do

    def do_show
      get :show, :id => SAMPLE_ID
    end

    before do
      Hangover.stub(:find).with(SAMPLE_ID).and_return(hangover)
    end

    it "should render index template" do
      do_show
      response.should render_template(:show)
    end

    it "should get the inventory" do
      Hangover.should_receive(:find).with(SAMPLE_ID)
      do_show
    end

    it "should assign '@hangover'" do
      do_show
      assigns[:hangover].should == hangover
    end
  end

#  it "show action should render show template" do
#    get :show, :id => Hangover.first
#    response.should render_template(:show)
#  end

#  it "new action should render new template" do
#    get :new
#    response.should render_template(:new)
#  end

#  it "create action should render new template when model is invalid" do
#    Hangover.any_instance.stubs(:valid?).returns(false)
#    post :create
#    response.should render_template(:new)
#  end

#  it "create action should redirect when model is valid" do
#    Hangover.any_instance.stubs(:valid?).returns(true)
#    post :create
#    response.should redirect_to(hangover_url(assigns[:hangover]))
#  end

#  it "edit action should render edit template" do
#    get :edit, :id => Hangover.first
#    response.should render_template(:edit)
#  end

#  it "update action should render edit template when model is invalid" do
#    Hangover.any_instance.stubs(:valid?).returns(false)
#    put :update, :id => Hangover.first
#    response.should render_template(:edit)
#  end

#  it "update action should redirect when model is valid" do
#    Hangover.any_instance.stubs(:valid?).returns(true)
#    put :update, :id => Hangover.first
#    response.should redirect_to(hangover_url(assigns[:hangover]))
#  end

#  it "destroy action should destroy model and redirect to index action" do
#    hangover = Hangover.first
#    delete :destroy, :id => hangover
#    response.should redirect_to(hangovers_url)
#    Hangover.exists?(hangover.id).should be_false
#  end
end

