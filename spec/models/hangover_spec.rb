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

  let(:hangover) {
    Factory(:hangover)
  }

  def remove_image(from = hangover)
    from.remove_image = true
    # required to actually remove the image
    # http://groups.google.com/group/carrierwave/browse_thread/thread/6ea2d0da9aa136a6
    from.save unless from.new_record?
  end

  it_should_have_accessor(:key, :accessible => true)

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
    before { remove_image }

    it "should not be valid" do
      hangover.should_not be_valid
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
    before { hangover.key = sample_key(:subject => subject.class, :valid => false) }

    it "should not be valid" do
      hangover.should_not be_valid
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

  describe "#save_and_process_image" do
    before { ResqueSpec.reset! }

    context "other than the image" do
      context "the hangover has no errors" do

        let(:new_hangover) { Factory.build(:hangover) }

        before { remove_image(new_hangover) }

        it "should queue the image to processed and the hangover saved" do
          new_hangover.save_and_process_image
          ImageProcessor.should have_queued(new_hangover.attributes, new_hangover.key).in(:image_processor_queue)
        end

        it "should return true" do
          new_hangover.save_and_process_image.should be_true
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

