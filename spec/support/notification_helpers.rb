module NotificationHelpers
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def it_should_show_the_notification_details(notification_subject, notification_message, unread_count_selector)
      it_should_show_the_page_title(notification_subject)

      it "should show me '#{notification_message}'" do
        page.should have_content notification_message
      end

      it "should show me that I have 0 new notifications" do
        within(unread_count_selector) do
          page.should have_content "0"
        end
      end
    end

    def it_should_have_a_notification(notification_identifier, options = {})
      unread_count_selector = ".usernav .unread_count"

      it "should show me that I have 1 new notification" do
        within(unread_count_selector) do
          page.should have_content "1"
        end
      end

      context "and I click the '1' under my unread notifications" do
        before do
          within(".usernav") do
            click_link("1")
          end
        end

        it "should redirect me to the notifications page" do
          current_path.should == notifications_path
        end

        context "and within the top notification" do
          let(:top_notification) { page.find("#notification_1") }

          notification_subject = spec_translate("#{notification_identifier}_subject".to_sym, options)
          notification_message = spec_translate("#{notification_identifier}_message".to_sym, options)
          message_snippit = snippit(notification_message)

          it "should show '#{notification_subject}'" do
            top_notification.should have_content notification_subject
          end

          it "should show '#{message_snippit}'" do
            top_notification.should have_content message_snippit
          end

          context "I click '#{notification_subject}'" do
            before { top_notification.click_link(notification_subject) }

            it_should_show_the_notification_details(
              notification_subject,
              notification_message,
              unread_count_selector
            )
          end

          context "I click '#{message_snippit}'" do
            before { top_notification.click_link(message_snippit) }

            it_should_show_the_notification_details(
              notification_subject,
              notification_message,
              unread_count_selector
            )
          end
        end
      end
    end
  end
end

