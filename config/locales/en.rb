{
  :en => {
    :hangover => {
      :caption => lambda {|key, options|
        caption = I18n.t("hangover.#{options[:category]}") <<
                 " - " << "\"#{options[:title]}\""
        caption << ", #{options[:votes]} #{I18n.t("vote", :count => options[:votes])}" if
          options[:votes]
        caption
      }
    }
  }
}

