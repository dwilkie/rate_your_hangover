require 'spec_helper'

def test_hangover_summary_categories(options = {})
  options[:title] ||= Factory.build(:hangover).title
  options[:image_link] = true unless options[:image_link] == false

  summary_categories.each_with_index do |summary_category, index|
    title = options[summary_category] || options[:title]

    context "within #hangover_#{index + 1}.slide" do
      let(:slide_selector) { "#hangover_#{index + 1}.slide" }
       context ".caption p" do
          it "should show the hangover: \"#{summary_category.to_s.humanize.downcase}\"'s title as: \"#{title}\"" do
            within "#{slide_selector} .caption p" do
              page.should have_content(
                I18n.t("hangover.#{summary_category}", :title => title)
              )
            end
          end
        end

      if options[:image_link] && options[summary_category].nil?
        it "should show a link to the hangover" do
          within "#{slide_selector}" do
            page.should have_selector "a[href=\"#{hangover_path(hangover)}\"]"
          end
        end

        it "should show the thumbnail image inside the link" do
          within "#{slide_selector} a" do
            page.should have_selector "img[src=\"#{hangover.image_url(:thumb)}\"]"
          end
        end
      else
        it "should not show a link to the hangover" do
          within "#{slide_selector}" do
            page.should_not have_selector "a"
          end
        end

        it "should show the thumbnail image" do
          within "#{slide_selector}" do
            page.should have_selector "img[src=\"#{hangover.image_url(:thumb)}\"]"
          end
        end
      end
    end
  end
end

describe "Homepage" do
  describe "GET /" do

    let(:hangover) { Factory(:hangover) }

    context "no hangovers exist" do
      before { visit root_path }
      test_hangover_summary_categories(
        :title => I18n.t("hangover.sober"),
        :image_link => false
      )
    end

    sober_periods = {}
    Hangover::TIME_PERIODS.each_with_index do |time_period, index|
      context "a hangover exists this #{time_period}" do
        before do
          hangover.update_attribute(
            :created_at, Time.now.utc.send("beginning_of_#{time_period}")
          )
        end

        if index.zero?
          before { visit root_path }
          test_hangover_summary_categories
        else
          previous_time_period = Hangover::TIME_PERIODS[index -1]
          sober_periods[
            "of_the_#{previous_time_period}".to_sym
           ] = I18n.t("hangover.sober")
          context "but not for this #{previous_time_period}" do
            before do
              created_at = hangover.created_at
              utc_time = Time.now.utc
              hangover.update_attribute(
                :created_at,
                created_at.advance(
                  previous_time_period.to_s.pluralize.to_sym => 1
                )
              ) if created_at >= utc_time.send(
                  "beginning_of_#{previous_time_period}"
                ) && created_at <= utc_time.send(
                  "end_of_#{previous_time_period}"
                )
              visit root_path
            end
            test_hangover_summary_categories(sober_periods)
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

