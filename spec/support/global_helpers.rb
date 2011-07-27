include ActionView::Helpers::TextHelper

def sample(data)
  SAMPLE_DATA[data]
end

def narrative(text)
  NARRATIVES[text]
end

def snippit(text)
  truncate(text)
end

