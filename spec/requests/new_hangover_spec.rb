require 'spec_helper'

describe "Given I want to create a new hangover" do
  include RequestHelpers
  include AmazonS3Helpers
  include NotificationHelpers

  context "and I am signed in" do
    SAMPLE_DATA = {
      :display_name => "Mara",
      :hangover_title => "Bliiiiind",
      :notification_id => 13232,
      :remote_image_net_url => "http://example.com/sample_image.jpg",
      :invalid_remote_image_net_url => "http://example.com/sample_image.invalid",
      :invalid_url => "ftp://example.com/sample_image.jpg"
    }.freeze

    NARRATIVES = {
      :create_hangover => "and I fill in title correctly then press '#{spec_translate(:create_hangover)}'",
      :try_creating_hangover_without_filling_in_form => "and I press '#{spec_translate(:create_hangover)}' without filling in the form",
      :click_refresh => "when I click '#{spec_translate(:refresh)}'"
    }.freeze

    let(:user) { Factory(:user, :display_name => sample(:display_name)) }

    before { sign_in(user) }

    shared_examples_for "showing the title" do
      it_should_show_the_page_title(spec_translate(:new_hangover))
    end

    shared_examples_for "a flash message that" do
      it "should show me that the hangover is being created" do
        page.should have_content spec_translate(
          :hangover_being_created,
          :refresh_link => spec_translate(:refresh)
        )
      end
    end

    shared_examples_for "taking me to the index page" do
      # FIXME Change this to my_hangovers
      it "should redirect me to /hangovers" do
        current_path.should == hangovers_path
      end
    end

    shared_examples_for "a successfully created hangover" do
      context "and" do
        it_should_behave_like "taking me to the index page"
        it_should_behave_like "a flash message that"

        context "assuming my hangover is successfully created" do
          context narrative(:click_refresh) do
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

            it "should show my hangover's image" do
              page.should have_selector :xpath, hangover_image_selector(:thumb, defined?(remote_url) ? remote_url : nil)
            end
          end
        end
      end
    end

    shared_examples_for "a failed hangover" do
      it_should_behave_like "a flash message that"

      context "after the hangover fails to create" do
        context narrative(:click_refresh) do
          before { click_link(spec_translate(:refresh)) }
          it_should_have_a_notification(:upload_failed, :allowed_file_types => extension_white_list.to_sentence)
        end
      end
    end

    shared_examples_for "take me to the next step" do
      context "and" do
        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end

        it "should not show me an input for entering a url" do
          page.should have_no_content spec_translate(:remote_image_net_url)
        end
      end
    end

    def create_hangover(options = {})
      fill_in(spec_translate(:title), :with => sample(:hangover_title))
      ResqueSpec.reset!
      with_resque do
        click_button spec_translate(:create_hangover)
      end
    end

    context "and on the new hangover by upload page" do

      before { visit new_hangover_image_path }

      it_should_behave_like("showing the title")

      context "and I select a valid file then press '#{spec_translate(:next)}'" do

        before do
          attach_file_for_direct_upload(image_fixture_path)
          upload_directly spec_translate(:next), :process_image => true
        end

        # This test is here for a placeholder only. It does not actually check that
        # Amazon redirects me to /hangovers/new. This is difficult to check without
        # actually contacting Amazon. Even using FakeWeb you still know the desired
        # outcome before the test starts. What's important is that we can simulate
        # it and move on.

        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end

        it_should_behave_like "take me to the next step"

        context narrative(:create_hangover) do

          before { create_hangover }

          it_should_behave_like "a successfully created hangover"
        end

        context narrative(:try_creating_hangover_without_filling_in_form) do
          before { click_button spec_translate(:create_hangover) }

          context "within" do
            it_should_display_errors_for(:hangover, :title, :cant_be_blank)
          end
        end
      end

      context "and I press '#{spec_translate(:next)}' without selecting a file" do
        before { upload_directly spec_translate(:next), :fail => true }

        # This test is here for a placeholder only. It does not actually check that
        # Amazon returns an error page

        it "should remain on the amazon s3 upload page" do
          current_url.should == ImageUploader.new.direct_fog_url
        end
      end


      context "and I upload a file with an invalid extension" do
        before do
          attach_file_for_direct_upload(image_fixture_path(:invalid => :filename))
          upload_directly spec_translate(:next)
        end

        it "should redirect me to the image upload page" do
          current_path.should == new_hangover_image_path
        end

        it "should show me '#{spec_translate(:invalid_upload)}'" do
          page.should have_content spec_translate(:invalid_upload)
        end
      end

      context "and I upload an invalid file" do
        before do
          attach_file_for_direct_upload(image_fixture_path(:invalid => :file))
          upload_directly spec_translate(:next), :process_image => true
        end

        # Placeholder test
        it_should_behave_like "take me to the next step"

        context narrative(:create_hangover) do
          before { create_hangover }

          it_should_behave_like "a failed hangover"
        end
      end

      context "and I follow '#{spec_translate(:upload_from_url)}'" do
        before { click_link(spec_translate(:upload_from_url)) }

        it "should redirect take me to the new hangover from upload page" do
          current_path.should == new_hangover_path
        end
      end
    end

    context "and on the new hangover by url page" do
      before { visit new_hangover_path }

      it_should_behave_like "showing the title"

      context narrative(:try_creating_hangover_without_filling_in_form) do
        before { click_button spec_translate(:create_hangover) }

        context "within" do
          it_should_display_errors_for(:hangover, :remote_image_net_url, :cant_be_blank)
          it_should_display_errors_for(:hangover, :title, :cant_be_blank)
        end
      end

      context "and I enter an invalid url" do
        before do
          fill_in spec_translate(:remote_image_net_url), :with => sample(:invalid_url)
        end

        context narrative(:create_hangover) do
          before do
            create_hangover
          end

          context "within" do
            it_should_display_errors_for(:hangover, :remote_image_net_url, :invalid_remote_image_net_url)
          end
        end
      end

      context "and I enter the url of" do
        def fake_the_download(options = {})
          fill_in spec_translate(:remote_image_net_url), :with => sample(:remote_image_net_url)
          image_url = page.find_field(spec_translate(:remote_image_net_url)).value
          FakeWeb.register_uri(:get, image_url, :body => File.open(image_fixture_path(options)))
        end

        context "a valid file" do
          before { fake_the_download }

          context narrative(:create_hangover) do
            before { create_hangover }

            it_should_behave_like "a successfully created hangover" do
              let(:remote_url) { sample(:remote_image_net_url) }
            end
          end
        end

        context "an invalid file" do
          before do
            fill_in(
              spec_translate(:remote_image_net_url),
              :with => sample(:invalid_remote_image_net_url)
            )
          end


          context narrative(:create_hangover) do
            before { create_hangover }

            context "within" do
              it_should_display_errors_for(:hangover, :remote_image_net_url, :invalid_remote_image_net_url)
            end
          end
        end

        context "an invalid file which has a valid url and file extension" do
          before { fake_the_download(:invalid => :file) }

          context narrative(:create_hangover) do
            before { create_hangover }

            it_should_behave_like "a failed hangover"
          end
        end
      end
    end
  end

  context "and I am not signed in" do
    before { sign_out }

    shared_examples_for "require sign in" do
      it "should take me to the sign in page" do
        current_path.should == new_user_session_path
      end

      it "should show me '#{spec_translate(:sign_up_or_sign_in_to_continue)}'" do
        page.should have_content spec_translate(:sign_up_or_sign_in_to_continue)
      end
    end

    context "and I try to go to the new hangover by upload page" do
      before { visit new_hangover_image_path }

      it_should_behave_like "require sign in"
    end

    context "and I try to go to the new hangover by url page" do
      before { visit new_hangover_path }

      it_should_behave_like "require sign in"
    end
  end
end

