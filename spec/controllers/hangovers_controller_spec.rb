require 'spec_helper'

describe HangoversController do

  SAMPLE_DATA = {
    :id => 1,
    :error_messages => ["Uploaded file was wrong", "Uploaded file is silly"]
  }

  let(:hangover) { mock_model(Hangover).as_null_object }
  let(:s3_params) { { :key => "key", :etag => "etag", :bucket => "bucket" } }
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

  describe "GET /hangovers/#{sample(:id)}" do

    def do_show
      get :show, :id => sample(:id)
    end

    before do
      Hangover.stub(:find).and_return(hangover)
    end

    it "should render the show template" do
      do_show
      response.should render_template(:show)
    end

    it "should find the hangover" do
      Hangover.should_receive(:find).with(sample(:id))
      do_show
    end

    it "should assign '@hangover'" do
      do_show
      assigns[:hangover].should == hangover
    end
  end

  describe "GET /hangovers/new" do

    def do_new(params = {})
      get :new, params
    end


    context "user is signed in" do
      before do
        sign_in current_user
        Hangover.stub(:new).and_return(hangover.as_new_record)
      end

      it "should tell the hangover to delete its upload later" do
        hangover.should_receive(:delete_upload)
        do_new
      end

      it "should build a new hangover with the input params" do
        Hangover.should_receive(:new).with(
          hash_including(s3_params.stringify_keys)
        )
        do_new s3_params
      end

      context "the new hangover's upload path" do
        context "is valid" do
          before { hangover.stub(:upload_path_valid?).and_return(true) }

          it "should render the new template" do
            do_new
            response.should render_template(:new)
          end

          it "should assign '@hangover'" do
            do_new
            assigns[:hangover].should == hangover
          end
        end

        context "is invalid" do
          before { hangover.stub(:upload_path_valid?).and_return(false) }

          it "should redirect to the new hangover image action" do
            do_new
            response.should redirect_to new_hangover_image_path
          end

          context "with the full messages: '#{sample(:error_messages)}'" do
            before { hangover.stub_chain(:errors, :full_messages).and_return(sample(:error_messages)) }

            it "should set the flash error to: '#{sample(:error_messages).to_sentence}'" do
              do_new
              flash[:error].should == sample(:error_messages).to_sentence
            end
          end
        end
      end
    end

    it_should_behave_like "an action which requires authentication" do
      let(:action) { :do_new }
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

      it "should direct the hangover to save and process its image" do
        hangover.should_receive(:save_and_process_image)
        do_create
      end

      context "#save_and_process_image returns true" do
        before { hangover.stub(:save_and_process_image).and_return(true) }

        it "should redirect to the index action" do
          do_create
          response.should redirect_to(:action => :index)
        end

        it "should set the flash message to tell the user that the hangover is being created" do
          do_create
          flash[:notice].should == spec_translate(
            :hangover_being_created,
            :refresh_link => controller.view_context.link_to(
              spec_translate(:refresh), hangovers_path
            )
          )
        end

        it "the flash message should be html_safe" do
          do_create
          flash[:notice].should be_html_safe
        end

      end

      context "#save_and_process_image returns false" do
        before { hangover.stub(:save_and_process_image).and_return(false) }

        it "should render the new action" do
          do_create
          response.should render_template(:new)
        end
      end
    end

    it_should_behave_like "an action which requires authentication" do
      let(:action) { :do_create }
    end
  end

end

