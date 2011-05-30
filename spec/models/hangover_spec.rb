require 'spec_helper'

def test_captions(options = {})
  if options[:new_record]
    hangover = Hangover.new
    title = I18n.t("hangover.sober")
  else
    hangover = Factory.create(:hangover)
    title = hangover.title
  end

  summary_categories.each do |summary_category|
    caption = I18n.t(
      "hangover.#{summary_category}",
      :title => title
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

  let(:hangover) {
    Factory(:hangover)
  }

  describe "Validations" do
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

  end

  describe "Associations" do
    it "should belong to a user" do
      subject.should respond_to(:user)
    end

    it "should have many votes" do
      subject.should respond_to(:votes)
    end
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

    summary_categories.each do |summary_category|
      before {
        Hangover.stub(summary_category)
      }

      it "should call .#{summary_category}" do
        Hangover.should_receive(summary_category)
        Hangover.summary
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
end

