require 'spec_helper'

describe "Create a new hangover" do
  include RequestHelpers
  include AmazonS3Helpers

  context "I am signed in" do
    SAMPLE_DISPLAY_NAME = "Mara"

    let(:user) { Factory(:user, :display_name => SAMPLE_DISPLAY_NAME) }

    before { sign_in(user) }

    context "and on the new hangover page" do
      before { visit new_hangover_image_path }

      it_should_show_the_page_title(spec_translate(:new_hangover))

      context "I select a valid file then press '#{spec_translate(:next)}'" do

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

        context "I fill in title correctly then press '#{spec_translate(:create_hangover)}'" do
          SAMPLE_HANGOVER_TITLE = "Bliiiiind"

          before do
            fill_in(spec_translate(:title), :with => SAMPLE_HANGOVER_TITLE)
            ResqueSpec.reset!
            with_resque do
              click_button spec_translate(:create_hangover)
            end
          end

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

            shared_examples_for "the latest hangover is my hangover" do
              context "by that I mean when I click '#{spec_translate(:refresh)}'" do
                before { click_link(spec_translate(:refresh)) }

                it "the latest hangover should be my hangover" do
                  page.should have_content spec_translate(
                    :caption,
                    :category => summary_categories.first,
                    :votes => 0,
                    :title => SAMPLE_HANGOVER_TITLE,
                    :owner => SAMPLE_DISPLAY_NAME
                  )
                end
              end
            end

            it_should_behave_like "the latest hangover is my hangover"

            context "a little more than 24 hours later" do
              it_should_behave_like "the latest hangover is my hangover"
            end
          end
        end

        context "I press '#{spec_translate(:create_hangover)}' without filling in the form" do
          before { click_button spec_translate(:create_hangover) }

          context "within" do
            it_should_display_errors_for(:hangover, :title, :cant_be_blank)
          end
        end
      end
    end

    context "and directly visit the register hangover page" do
      before { visit new_hangover_path }

      it "should redirect me back to the start of the hangover registration process" do
        current_path.should == new_hangover_image_path
      end

    end

    context "I press '#{spec_translate(:create_hangover)}' without selecting a file" do
      before { upload_to_s3 spec_translate(:next), :fail => true }

      # This test is here for a placeholder only. It does not actually check that
      # Amazon returns an error page

      it "should remain on the amazon s3 upload page" do
        current_url.should == ImageUploader.new.direct_fog_url
      end
    end

    context "I upload an invalid file" do
      before do
        attach_file(spec_translate(:image), image_fixture_path(:invalid => true))
        upload_to_s3 spec_translate(:next)
      end

      # Placeholder test
      it "should redirect the me to the new hangover page" do
        current_path.should == new_hangover_path
      end

      context "I fill in title correctly then press '#{spec_translate(:create_hangover)}'" do
        context "when the hangover fails to create" do
          it "should send an email notification" do
            pending
          end
        end
      end
    end
  end

  context "I am not signed in" do
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

