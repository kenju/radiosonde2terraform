module Radiosonde2terraform
  class Options
    def initialize(default_tags: [])
      @default_tags = default_tags
    end
    attr_reader :default_tags
  end
end
