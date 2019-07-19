# frozen_string_literal: true

require 'paybox/system/integrity'
require 'paybox/system/helpers'

module Paybox
  module System
    class Engine < ::Rails::Engine
      isolate_namespace Paybox::System

      ActiveSupport.on_load(:action_view_base) do
        prepend Paybox::System::Rails::Helpers
      end

      ActiveSupport.on_load(:action_controller_base) do
        prepend Paybox::System::Rails::Integrity
      end

      ActiveSupport.on_load(:action_controller_api) do
        prepend Paybox::System::Rails::Integrity
      end
    end
  end
end
