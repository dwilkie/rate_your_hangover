require 'spec_helper'

describe HangoversController do

  SAMPLE_ID = 1

  let(:hangover) { mock_model(Hangover).as_null_object }
  let(:hangover_params) { {:hangover => {:title => "bliind", :image => "some image" }} }
  let(:current_user) { Factory(:user) }

  describe "GET /hangovers" do

    let(:hangovers) {[
      hangover
    ]}

    def do_index
      get :index
    end

    before do
      Hangover.stub(:inventory).and_return(hangovers)
    end

    it "should render the index template" do
      do_index
      response.should render_template(:index)
    end

    it "should get the inventory" do
      Hangover.should_receive(:inventory)
      do_index
    end

    it "should assign '@hangovers'" do
      do_index
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

    it "should render the show template" do
      do_show
      response.should render_template(:show)
    end

    it "should find the hangover" do
      Hangover.should_receive(:find).with(SAMPLE_ID)
      do_show
    end

    it "should assign '@hangover'" do
      do_show
      assigns[:hangover].should == hangover
    end
  end

  describe "GET /hangovers/new" do

    def do_new
      get :new
    end

    context "user is signed in" do
      before do
        sign_in current_user
        Hangover.stub(:new).and_return(hangover.as_new_record)
      end

      it "should render the new template" do
        do_new
        response.should render_template(:new)
      end

      it "should build a new hangover" do
        Hangover.should_receive(:new)
        do_new
      end

      it "should assign '@hangover'" do
        do_new
        assigns[:hangover].should == hangover
      end
    end

    context "user is not signed in" do
      it "should redirect the user to the sign in path" do
        do_new
        response.should redirect_to(new_user_session_path)
      end
    end

  end

  describe "POST /hangovers" do

    def do_create(params = {})
      post :create, params
    end

    context "user is signed in" do

      before do
        sign_in current_user
        # this is required otherwise devise will query the db for the current user
        # then return a different user. i.e. the object_id will be different
        controller.stub(:current_user).and_return(current_user)
        current_user.stub_chain(:hangovers, :build).and_return(hangover.as_new_record)
      end

      it "should assign '@hangover'" do
        do_create
        assigns[:hangover].should == hangover
      end

      it "should build a new hangover for the current user" do
        hangovers = mock("Hangovers")
        current_user.stub(:hangovers).and_return(hangovers)

        # restub build
        hangovers.stub(:build).and_return(hangover.as_new_record)

        hangovers.should_receive(:build).with(hangover_params[:hangover].stringify_keys)
        do_create hangover_params
      end

      it "should try to save the hangover" do
        hangover.should_receive(:save)
        do_create
      end

      context "hangover saves successfully" do
        before { hangover.stub(:save).and_return(true) }

        it "should redirect to the index action" do
          do_create
          response.should redirect_to(:action => :index)
        end

        it "should set the flash message to '#{spec_translate(:hangover_created)}'" do
          do_create
          flash[:notice].should == spec_translate(:hangover_created)
        end
      end

      context "hangover does not save successfully" do
        before { hangover.stub(:save).and_return(false) }

        it "should render the new action" do
          do_create
          response.should render_template(:new)
        end
      end

    end

    context "user is not signed in" do

      it "should redirect the user to sign in" do
        do_create
        response.should redirect_to new_user_session_path
      end

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

