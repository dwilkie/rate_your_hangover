require 'spec_helper'

def test_captions(options = {})
  if options[:new_record]
    hangover = Hangover.new
    title = I18n.t("hangover.sober")
    votes = nil
    owner = nil
  else
    hangover = Factory.create(:hangover)
    title = hangover.title
    votes = hangover.votes_count
    owner = hangover.user.display_name
  end

  summary_categories.each do |summary_category|
    caption = I18n.t(
      "hangover.caption",
      :category => summary_category,
      :title => title,
      :votes => votes,
      :owner => owner
    )
    context "passing :#{summary_category}" do
      before { hangover.build_caption(summary_category) }
      context "#caption" do
        it "should == '#{caption}'" do
          hangover.caption.should == caption
        end
      end
    end
  end
end

describe Hangover do
  include UploaderHelpers

  def hangover_key(options = {})
    sample_key(options.merge(:subject => subject.class))
  end

  let(:hangover) {
    Factory(:hangover)
  }

  let(:hangover_without_image) {
    Factory.build(:hangover_without_image)
  }

  # Accessors

  it_should_have_accessor(:user_id => 1, :accessible => false)
  it_should_have_accessor(:title, :accessible => true)

  describe "#key = 'sample key'" do
    it "should set the image key" do
      subject.key = "sample key"
      subject.image.key.should == "sample key"
    end
  end

  describe "#key" do
    it "should return the key from the image" do
      subject.image.key = "sample key"
      subject.key.should == "sample key"
    end
  end

  # Validations
  it "Factory should be valid" do
    hangover.should be_valid
  end

  context "without a title" do
    before { hangover.title = nil }

    it "should not be valid" do
      hangover.should_not be_valid
    end
  end

  context "without a user" do
    before { hangover.user = nil }

    it "should not be valid" do
      hangover.should_not be_valid
    end
  end

  context "without an image" do
    it "should not be valid" do
      hangover_without_image.should_not be_valid
    end
  end

  context "without a key" do
    before { hangover.key = nil }

    it "should not be valid on create" do
      hangover.should_not be_valid(:create)
    end

    it "should be valid on update" do
      hangover.should be_valid(:update)
    end
  end

  context "with an invalid key" do
    before { hangover.key = hangover_key(:valid => false) }

    it "should not be valid on create" do
      hangover.should_not be_valid(:create)
    end

    it "should be valid on update" do
      hangover.should be_valid(:update)
    end
  end

  # Associations
  it "should belong to a user" do
    subject.should respond_to(:user)
  end

  it "should have many votes" do
    subject.should respond_to(:votes)
  end

  Hangover::TIME_PERIODS.each do |time_period|
    describe ".of_the_#{time_period}" do
      context "a hangover exists" do
        before { hangover }
        context "for this #{time_period}" do

          it "should return the hangover" do
            Hangover.send("of_the_#{time_period}").should == hangover
          end

          context "and another hangover exists for this #{time_period} with more votes" do
            let(:popular_hangover) {
              popular_hangover = Factory.create(:hangover)
              Factory.create(:hangover_vote, :voteable => popular_hangover)
              popular_hangover
            }

            before { popular_hangover }

            it "should return the more popular hangover" do
              Hangover.send("of_the_#{time_period}").should == popular_hangover
            end
          end
        end

        context "but not for this #{time_period}" do
          before {
            hangover.update_attribute(
              :created_at, 1.send(time_period).ago
            )
          }

          it "should return nil" do
            Hangover.send("of_the_#{time_period}").should be_nil
          end
        end
      end
    end
  end

  describe ".latest" do
    let(:latest_hangover) { Factory.create(:hangover) }
    before do
      hangover
      latest_hangover
    end

    it "should return the latest hangover" do
      Hangover.latest.should == latest_hangover
    end
  end

  describe ".best" do
    let(:best_hangover) {
      best_hangover = Factory.create(:hangover)
      Factory.create(:hangover_vote, :voteable => best_hangover)
      best_hangover
    }

    before do
      hangover
      best_hangover
    end

    it "should return the best hangover" do
      Hangover.best.should == best_hangover
    end
  end

  describe ".inventory" do
    context "passing no args" do
      it "should call .summary" do
        Hangover.should_receive(:summary)
        Hangover.inventory
      end
    end

    context "passing nil" do
      it "should call .summary" do
        Hangover.should_receive(:summary)
        Hangover.inventory(nil)
      end
    end
  end

  describe ".summary" do
    summary_categories.each_with_index do |summary_category, index|

      it "should call .#{summary_category}" do
        Hangover.stub(summary_category)
        Hangover.should_receive(summary_category)
        Hangover.summary
      end

      context "[#{index}]" do
        context "when .#{summary_category} returns a hangover" do
          let(:"#{summary_category}_hangover") { mock_model(Hangover).as_null_object }

          before {
            Hangover.stub(summary_category).and_return(
              send("#{summary_category}_hangover")
            )
          }

          it "should be the result of .#{summary_category}" do
            Hangover.summary[index].should == send("#{summary_category}_hangover")
          end
        end

        context "when .#{summary_category} returns nil" do
          it "should be a new record" do
            Hangover.summary[index].should be_new_record
          end
        end
      end
    end

    it "should return an array" do
      Hangover.summary.should be_a(Array)
    end

    context "the returned array" do
      it "should contain #{summary_categories.length} elements" do
        Hangover.summary.length.should == summary_categories.length
      end

      it "should only contain hangovers" do
        Hangover.summary.each do |hangover|
          hangover.should be_a(Hangover)
        end
      end
    end

    context "no hangovers exist" do
      context "each hangover in the returned array" do
        it "should be a new record" do
          Hangover.summary.each do |hangover|
            hangover.should be_new_record
          end
        end
      end
    end
  end

  describe "#build_caption" do
    context "the hangover is a new record" do
      test_captions(:new_record => true)
    end

    context "the hangover is an existing record" do
      test_captions
    end
  end

  describe "#rated_by?" do
    let(:user) { Factory(:user) }

    context "is not persisted" do
      it "should return nil" do
        subject.rated_by?(user).should be_nil
      end
    end

    context "passing nil" do
      it "should return false" do
        hangover.rated_by?(nil).should be_false
      end
    end

    context "passing a user who already rated this hangover" do
      before { hangover.votes.create(:user => user) }
      it "should return true" do
        hangover.rated_by?(user).should be_true
      end
    end

    context "passing a user has not yet rated this hangover" do
      it "should return false" do
        hangover.rated_by?(user).should be_false
      end
    end
  end

  describe "#delete_upload" do
    context "passing no args" do
      before do
        ResqueSpec.reset!
        Timecop.freeze(Time.now)
      end

      after {Timecop.return}

      it "should schedule the remote upload to be deleted 24 hours from now" do
        hangover_without_image.delete_upload
        UploadGarbageCollector.should have_scheduled_at(
          24.hours.from_now,
          {:key => hangover_without_image.key}
        )
      end
    end

    context "passing {:now => true}" do
      let(:args) { { :now => true } }
      let(:uploaded_file) { mock("Fog::File") }

      def stub_fog
         Fog::Storage.stub_chain(:new, :directories, :new, :files, :new).and_return(uploaded_file)
      end

      context "no hangover exists with this upload" do

        before { stub_fog }

        it "should delete the remote upload" do
          uploaded_file.should_receive(:destroy)
          hangover_without_image.delete_upload(args)
        end
      end

      context "a hangover already exists with this key" do
        let(:previously_uploaded_image_path) { hangover_key }

        before do
          Factory(:hangover, :key => previously_uploaded_image_path)
          hangover_without_image.key = previously_uploaded_image_path
          # Make sure we stub fog after we create the hangover otherwise it will mess with CarrierWave
          stub_fog
        end

        it "should not delete the remote upload" do
          uploaded_file.should_not_receive(:destroy)
          hangover_without_image.delete_upload(args)
        end
      end
    end
  end

  describe "#save_and_process_image" do
    before { ResqueSpec.reset! }

    context "other than the image" do
      context "the hangover has no errors" do
        context "passing no args" do
          it "should queue the image to be processed and the hangover saved" do
            hangover_without_image.save_and_process_image
            ImageProcessor.should have_queued(
              hangover_without_image.attributes.merge(
                "key" => hangover_without_image.key
              ), ["user_id"]
            ).in(:image_processor_queue)
          end
        end

        context "passing {:now => true}" do
          before do
            hangover_without_image.stub(:remote_image_url=)
            hangover_without_image.stub(:save!)
          end

          it "should try to download the image from a url based off the key" do
            hangover_without_image.key = key = hangover_key
            hangover_without_image.should_receive(:remote_image_url=).with(/\/#{key}$/)
            hangover_without_image.save_and_process_image(:now => true)
          end

          it "should try and save! the hangover" do
            hangover_without_image.should_receive(:save!)
            hangover_without_image.save_and_process_image(:now => true)
          end
        end

        it "should return true" do
          hangover_without_image.save_and_process_image.should be_true
        end
      end

      context "the hangover still has errors" do
        it "should return false" do
          subject.save_and_process_image.should be_false
        end
      end
    end
  end
end

