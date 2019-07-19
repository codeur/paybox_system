# frozen_string_literal: true

module Paybox
  module System
    module Rails
      module Helpers
        # Add all formatted params as hidden fields
        def paybox_hidden_field_tags(opts = {})
          formatted_params = Paybox::System.formatted_params(opts)
          capture do
            formatted_params.each do |name, value|
              concat hidden_field_tag(name, Rack::Utils.escape(value))
            end
          end
        end
      end
    end
  end
end
