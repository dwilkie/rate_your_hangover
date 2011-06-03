require 'spec_helper'

def test_hangover_summary_categories(options = {})
  options[:title] ||= Factory.build(:hangover).title
  options[:image_link] = true unless options[:image_link] == false

  summary_categories.each_with_index do |summary_category, index|
    title = options[summary_category] || options[:title]
    votes = nil

    context "within hangover_#{index + 1}" do
      let(:parent_selector) { ".slides_container #hangover_#{index + 1}" }

      if options[:image_link] && options[summary_category].nil?
        votes = 0

        it "should show a link to the hangover" do
          within(parent_selector) do
            page.should have_selector hangover_link
          end
        end
      else
        it "should not show a link to the hangover" do
          within(parent_selector) do
            page.should_not have_selector hangover_link
          end
        end
      end

      it "should show the thumbnail image" do
        within(parent_selector) do
          page.should have_selector "img[src=\"#{hangover.image_url(:thumb)}\"]"
        end
      end

      caption = I18n.t("hangover.caption", {
        :category => summary_category,
        :title => title,
      }.merge(:votes => votes))


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

    context "no hangovers exist" do
      before { visit_root_path }
      test_hangover_summary_categories(
        :title => I18n.t("hangover.sober"),
        :image_link => false
      )
    end

    sober_periods = {}
    utc_time = Time.now.utc
    sober_text = I18n.t("hangover.sober")
    Hangover::TIME_PERIODS.each_with_index do |time_period, index|
      context "a hangover exists this #{time_period}" do
        before do
          update_hangover_created_at(index, utc_time)
          visit_root_path
        end

        if index.zero?
          test_hangover_summary_categories
        else
          previous_time_period = Hangover::TIME_PERIODS[index - 1]

          context "but not for this #{previous_time_period}" do
            # adds the previous time period to the sober periods
            sober_periods[
              "of_the_#{previous_time_period}".to_sym
            ] = sober_text

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
              sober_periods.merge(temporary_sober_periods)
            )
          end
        end
      end
    end

    it "should show a link to '#{I18n.t('hangover.got_one')}'" do
      visit root_path
      page.should have_link(I18n.t('hangover.got_one'))
    end
  end
end

