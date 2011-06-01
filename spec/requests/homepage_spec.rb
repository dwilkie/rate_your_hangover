require 'spec_helper'

def test_hangover_summary_categories(options = {})
  options[:title] ||= Factory.build(:hangover).title
  options[:image_link] = true unless options[:image_link] == false

  summary_categories.each_with_index do |summary_category, index|
    title = options[summary_category] || options[:title]

    it "should display the container for the slide" do
      page.should have_selector "#hangover_#{index + 1}.slide"
    end

    context "div#hangover_#{index + 1}.slide" do
      before { parent_selector << "#hangover_#{index + 1}.slide" }

      context "div.caption p" do
        before { parent_selector << ".caption p" }

        it "should show the hangover: \"#{summary_category.to_s.humanize.downcase}\"'s title as: \"#{title}\"" do
          within "#{join_parent_selector}" do
            page.should have_content(
              I18n.t("hangover.#{summary_category}", :title => title)
            )
          end
        end
      end

      if options[:image_link] && options[summary_category].nil?

        it "should show a link to the hangover" do
          within "#{join_parent_selector}" do
            page.should have_selector "a[href=\"#{hangover_path(hangover)}\"]"
          end
        end

        context "a" do
          before { parent_selector << "a" }

          it "should show the thumbnail image inside the link" do
            within "#{join_parent_selector}" do
              page.should have_selector "img[src=\"#{hangover.image_url(:thumb)}\"]"
            end
          end
        end

      else
        it "should not show a link to the hangover" do
          within "#{join_parent_selector}" do
            page.should_not have_selector "a"
          end
        end

        it "should show the thumbnail image" do
          within "#{join_parent_selector}" do
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
    let(:parent_selector) { [] }

    def join_parent_selector
      parent_selector.join(" ")
    end

    def visit_root_path
      visit root_path
    end

    it "should display the hangovers within #hangovers #images" do
      visit_root_path
      page.should have_selector("#hangovers #images")
    end

    context "within" do

      context "div#hangovers div#images" do
        before { parent_selector << "#hangovers #images" }

        it "should display the frame" do
          visit_root_path
          within "#{join_parent_selector}" do
            page.should have_selector ".frame"
          end
        end

        it "should display the slides" do
          visit_root_path
          within "#{join_parent_selector}" do
            page.should have_selector "#slides"
          end
        end

        context "div#slides" do
          before { parent_selector << "#slides"}
          it "should display the slides container" do
            visit_root_path
            within "#{join_parent_selector}" do
              page.should have_selector ".slides_container"
            end
          end

          it "should display a link to the previous image" do
            visit_root_path
            within "#{join_parent_selector}" do
              page.should have_selector :xpath, './/a[@href="#" and @class="prev"]'
            end
          end

          it "should display a link to the next image" do
            visit_root_path
            within "#{join_parent_selector}" do
              page.should have_selector :xpath, './/a[@href="#" and @class="next"]'
            end
          end

          context "div.slides_container" do
            before { parent_selector << ".slides_container" }

            context "no hangovers exist" do
              before { visit_root_path }
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
                  before { visit_root_path }
                  test_hangover_summary_categories
                else
                  utc_time = Time.now.utc
                  previous_time_period = Hangover::TIME_PERIODS[index - 1]

                  sober_text = I18n.t("hangover.sober")

                  sober_periods[
                    "of_the_#{previous_time_period}".to_sym
                  ] = sober_text

                  temporary_sober_periods = {}
                  unless time_period == Hangover::TIME_PERIODS.last
                    next_time_period = Hangover::TIME_PERIODS[index + 1]
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

                  context "but not for this #{previous_time_period}" do
                    before do
                      created_at = hangover.created_at
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
                      visit_root_path
                    end
                    test_hangover_summary_categories(
                      sober_periods.merge(temporary_sober_periods)
                    )
                  end
                end
              end
            end
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

