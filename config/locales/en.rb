{
  :en => {
    :hangover => {
      :caption => lambda {|key, options|
        caption = I18n.t("hangover.#{options[:category]}") <<
                 " is " << "\"#{options[:title]}\""
        caption << " by #{options[:owner]}" if options[:owner]
        caption << " with #{options[:votes]} " <<
                   I18n.t("vote", :count => options[:votes]) if options[:votes]
        caption
      }
    }
  }
}

