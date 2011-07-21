require 'spec_helper'

describe "Given I want to create a new hangover" do
  include RequestHelpers
  include AmazonS3Helpers

  context "and I am signed in" do
    SAMPLE_DATA = {
      :display_name => "Mara",
      :hangover_title => "Bliiiiind"
    }.freeze

    let(:user) { Factory(:user, :display_name => sample(:display_name)) }

    before { sign_in(user) }

    context "and on the new hangover by upload page" do

      create_hangover_narrative = "and I fill in title correctly then press '#{spec_translate(:create_hangover)}'".freeze

      def create_hangover(options = {})
        fill_in(spec_translate(:title), :with => sample(:hangover_title))
        ResqueSpec.reset!
        with_resque do
          click_button spec_translate(:create_hangover)
        end
      end

      before { visit new_hangover_image_path }

      it_should_show_the_page_title(spec_translate(:new_hangover))

      context "and I select a valid file then press '#{spec_translate(:next)}'" do

        before do
          attach_file(spec_translate(:image), image_fixture_path)
          upload_to_s3 spec_translate(:next), :process_image => true
        end

        # This test is here for a placeholder only. It does not actually check that
        # Amazon redirects me to /hangovers/new. This is difficult to check without
        # actually contacting Amazon. Even using FakeWeb you still know the desired
        # outcome before the test starts. What's important is that we can simulate
        # it and move on.

        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end

        it_should_show_the_page_title(spec_translate(:new_hangover))

        context create_hangover_narrative do

          before { create_hangover }

          # FIXME Change this to my_hangovers
          it "should redirect me to /hangovers" do
            current_path.should == hangovers_path
          end

          it "should show me that the hangover is being created" do
            page.should have_content spec_translate(
              :hangover_being_created,
              :refresh_link => spec_translate(:refresh)
            )
          end

          context "assuming my hangover is successfully created" do
            context "when I click '#{spec_translate(:refresh)}'" do
              before { click_link(spec_translate(:refresh)) }

              it "should show the latest hangover as my hangover" do
                page.should have_content spec_translate(
                  :caption,
                  :category => summary_categories.first,
                  :votes => 0,
                  :title => sample(:hangover_title),
                  :owner => sample(:display_name)
                )
              end
            end
          end
        end

        context "and I press '#{spec_translate(:create_hangover)}' without filling in the form" do
          before { click_button spec_translate(:create_hangover) }

          context "within" do
            it_should_display_errors_for(:hangover, :title, :cant_be_blank)
          end
        end
      end

      context "and I press '#{spec_translate(:next)}' without selecting a file" do
        before { upload_to_s3 spec_translate(:next), :fail => true }

        # This test is here for a placeholder only. It does not actually check that
        # Amazon returns an error page

        it "should remain on the amazon s3 upload page" do
          current_url.should == ImageUploader.new.direct_fog_url
        end
      end

      context "and I upload an invalid file" do
        before do
          attach_file(spec_translate(:image), image_fixture_path(:invalid => true))
          upload_to_s3 spec_translate(:next)
        end

        # Placeholder test
        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end

        context create_hangover_narrative do
          context "when the hangover fails to create" do
            it "should send an email notification" do
              pending
            end
          end
        end
      end

      context "and I follow '#{spec_translate(:upload_from_url)}'" do
        before { click_link(spec_translate(:upload_from_url)) }

        it "should redirect take me to the new hangover from upload page" do
          current_path.should == new_hangover_path
        end
      end
    end
  end

  context "and I am not signed in" do
    before do
      sign_out
      visit new_hangover_image_path
    end

    it "should take me to the sign in page" do
      current_path.should == new_user_session_path
    end

    it "should show me '#{spec_translate(:sign_up_or_sign_in_to_continue)}'" do
      page.should have_content spec_translate(:sign_up_or_sign_in_to_continue)
    end
  end
end

