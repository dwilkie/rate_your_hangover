Spork.each_run do
  Factory.definition_file_paths = [
          File.join(Rails.root, 'spec', 'factories')
  ]
  Factory.find_definitions
end

