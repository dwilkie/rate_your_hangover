require 'spec_helper'

def within_hangover(hangover_index = 1, &block)
  example_group_class = context "div#hangover_#{hangover_index}" do
    let(:parent_selector) { ".slides_container #hangover_#{hangover_index}" }
  end
  example_group_class.class_eval &block
end

def showing_and_following_the_rate_it_link(&block)

  it "should show a link to '#{spec_translate(:rate_it)}'" do
    within(parent_selector) do
      page.should have_link(spec_translate(:rate_it))
    end
  end

  example_group_class = context "following the link '#{spec_translate(:rate_it)}'" do
    before do
      within(parent_selector) do
        click_link spec_translate(:rate_it)
      end
    end

    it "should show that the hangover has 1 vote" do
      within(parent_selector) do
        page.should have_content("1 #{I18n.t("vote", :count => 1)}")
      end
    end
  end

  example_group_class.class_eval &block
end

def test_hangover_summary_categories(all = true, sober_periods = {})
  default_hangover = Factory.build(:hangover)
  sober_text = I18n.t("hangover.sober")

  summary_categories.each_with_index do |summary_category, index|
    caption_options = {}
    caption_options[:category] = summary_category

    if all || sober_periods[summary_category]
      caption_options[:title] = sober_text
    else
      caption_options[:title] = default_hangover.title
      caption_options[:votes] = default_hangover.votes_count
      caption_options[:owner] = default_hangover.user.display_name
    end

    caption = I18n.t("hangover.caption", caption_options)

    within_hangover(index + 1) do
      it "should show the hangover: \"#{summary_category.to_s.humanize.downcase}\"'s caption as: \"#{caption}\"" do
        within(parent_selector) do
          page.should have_content(caption)
        end
      end
    end
  end
end

describe "Homepage" do
  describe "GET /" do

    let(:hangover) { Factory(:hangover) }
    let(:voting_user) { Factory(:user) }

    def visit_root_path
      visit root_path
    end

    def hangover_link
      "a[href=\"#{hangover_path(hangover)}\"]"
    end

    def update_hangover_created_at(time_period_index, utc_time)
      this_time_period = Hangover::TIME_PERIODS[time_period_index]
      utc_time = Time.now.utc

      beginning_of_this_time_period = utc_time.send(
        "beginning_of_#{this_time_period}"
      )

      create_hangover_at = beginning_of_this_time_period

      unless this_time_period == Hangover::TIME_PERIODS.first
        previous_time_period = Hangover::TIME_PERIODS[time_period_index - 1]

        beginning_of_previous_time_period = utc_time.send(
          "beginning_of_#{previous_time_period}"
        )

        end_of_previous_time_period = utc_time.send(
          "end_of_#{previous_time_period}"
        )

        # advance created at time by 1 previous time period
        # if the beginning of the current time period falls between
        # the beginning of the previous time period and the end of
        # the previous time period
        create_hangover_at = beginning_of_this_time_period.advance(
          previous_time_period.to_s.pluralize.to_sym => 1
        ) if create_hangover_at >= beginning_of_previous_time_period &&
          create_hangover_at <= end_of_previous_time_period
      end

      hangover.update_attribute(:created_at, create_hangover_at)
    end

    def sign_in_user
      visit new_user_session_path
      fill_in 'Email', :with => voting_user.email
      fill_in 'Password', :with => 'secret'
      click_button(spec_translate(:sign_in))
    end

    def sign_out_user
      visit destroy_user_session_path
    end

    context "no hangovers exist" do
      before { visit_root_path }

      test_hangover_summary_categories

      within_hangover do
        it "should not show a link to the hangover" do
          within(parent_selector) do
            page.should_not have_selector hangover_link
          end
        end

        it "should not show a link to '#{spec_translate(:rate_it)}'" do
          within(parent_selector) do
            page.should_not have_link(spec_translate(:rate_it))
          end
        end
      end
    end

    sober_periods = {}
    utc_time = Time.now.utc
    Hangover::TIME_PERIODS.each_with_index do |time_period, index|
      context "a hangover exists this #{time_period}" do
        before do
          update_hangover_created_at(index, utc_time)
          visit_root_path
        end

        if index.zero?
          test_hangover_summary_categories(false)
        else
          previous_time_period = Hangover::TIME_PERIODS[index - 1]

          context "but not for this #{previous_time_period}" do
            # adds the previous time period to the sober periods
            sober_periods["of_the_#{previous_time_period}".to_sym] = true

            temporary_sober_periods = {}
            unless time_period == Hangover::TIME_PERIODS.last
              # there is another time period
              next_time_period = Hangover::TIME_PERIODS[index + 1]

              # if the beginning of this time period period
              # is not in the next time period set the next time period
              # as a sober period
              temporary_sober_periods[
                "of_the_#{next_time_period}".to_sym
              ] = sober_text if utc_time.respond_to?(
                  next_time_period
                ) && utc_time.send(
                  "beginning_of_#{time_period}"
                ).send(next_time_period) != utc_time.send(
                  next_time_period
                )
            end

            test_hangover_summary_categories(
              false,
              sober_periods.merge(temporary_sober_periods)
            )
          end
        end
      end
    end

    within_hangover do
      it "should show the thumbnail image" do
        visit_root_path
        within(parent_selector) do
          page.should have_selector "img[src=\"#{hangover.image_url(:thumb)}\"]"
        end
      end

      context "a hangover exists for today" do
        before { hangover }

        shared_examples_for "do not show the rate it link" do
          it "should not show a link to '#{spec_translate(:rate_it)}'" do
            within(parent_selector) do
              page.should_not have_link(spec_translate(:rate_it))
            end
          end
        end

        shared_examples_for "show that you rate it" do
          it "should show '#{spec_translate(:you_rate_it)}'" do
            page.should have_content spec_translate(:you_rate_it)
          end
        end

        it "should have a link to the hangover" do
          visit_root_path
          within(parent_selector) do
            page.should have_selector hangover_link
          end
        end

        context "following the link to the hangover" do
          before do
            visit_root_path
            within(parent_selector) do
              click_link "hangover_#{hangover.id}"
            end
          end

          it "should take me to that hangover's show page" do
            current_path.should == hangover_path(hangover)
          end
        end

        context "the user is signed in" do
          before { sign_in_user }
          context "and they have not yet 'rated' this hangover" do
            before { visit_root_path }

            showing_and_following_the_rate_it_link do
              it_should_behave_like "show that you rate it"
              it_should_behave_like "do not show the rate it link"
            end
          end

          context "and they have already 'rated' this hangover" do
            let(:hangover_vote) { Factory(:hangover_vote, :user => voting_user) }

            before do
              hangover_vote
              visit_root_path
            end

            it_should_behave_like "do not show the rate it link"
          end
        end

        context "the user is not signed in" do
          before { visit_root_path }
          showing_and_following_the_rate_it_link do
            it_should_behave_like "show that you rate it"
            it_should_behave_like "do not show the rate it link"


            # This tests the use case where the user votes then
            # signs out and tries to vote again
            context "then signing out" do
              before do
                sign_out_user
                visit_root_path
              end

              showing_and_following_the_rate_it_link do

                it "should not show '#{spec_translate(:you_rate_it)}'" do
                  page.should_not have_content spec_translate(:you_rate_it)
                end

                it "should show tell the user to sign in to rate it" do
                  page.should have_content I18n.t(
                    "hangover.sign_in_to_rate_it",
                    :sign_in_link => spec_translate(:sign_in)
                  )
                end
              end
            end
          end
        end
      end
    end

    context "'#{spec_translate(:got_a_hangover)}' link" do
      before { visit_root_path }

      it "should show a link to '#{spec_translate(:got_a_hangover)}'" do
        page.should have_link spec_translate(:got_a_hangover)
      end

      context "following the link to #{spec_translate(:got_a_hangover)}" do
        before { click_link(spec_translate(:got_a_hangover)) }
        it "should go to the new hangover page" do
          current_path.should == new_hangover_path
        end
      end
    end

    context "menu bar" do
      before {visit_root_path }

      it "should show a link to '#{spec_translate(:sign_up)}'" do
        page.should have_link spec_translate(:sign_up)
      end

      context "following the '#{spec_translate(:sign_up)}' link" do
        before { click_link(spec_translate(:sign_up)) }

        it "should go to the sign up page" do
          current_path.should == new_user_registration_path
        end

      end

      it "should show a link to '#{spec_translate(:sign_in)}'" do
        page.should have_link spec_translate(:sign_in)
      end

      context "following the '#{spec_translate(:sign_in)}' link" do
        before { click_link(spec_translate(:sign_in)) }

        it "should go to the sign in page" do
          current_path.should == new_user_session_path
        end
      end
    end
  end
end

