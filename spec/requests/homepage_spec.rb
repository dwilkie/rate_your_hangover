require 'spec_helper'

def test_hangover_summary_categories(options = {})
  options[:title] ||= Factory.build(:hangover).title
  summary_categories.each do |summary_category|
    title = options[summary_category] || options[:title]
    it "should show the hangover: \"#{summary_category.to_s.humanize.downcase}\"'s caption as: \"#{title}\"" do
      page.should have_content I18n.t(
        "hangover.#{summary_category}", :title => title
      )
    end
  end
end

describe "Homepage" do
  describe "GET /" do

    let(:hangover) { Factory(:hangover) }

    context "no hangovers exist" do
      before { visit root_path }
      test_hangover_summary_categories(:title => I18n.t("hangover.sober"))
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

