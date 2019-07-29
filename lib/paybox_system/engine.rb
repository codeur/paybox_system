# frozen_string_literal: true

require 'paybox_system/rails/integrity'
require 'paybox_system/rails/helpers'

module PayboxSystem
  class Engine < ::Rails::Engine
    isolate_namespace PayboxSystem

    ActiveSupport.on_load(:action_view_base) do
      prepend PayboxSystem::Rails::Helpers
    end

    ActiveSupport.on_load(:action_controller_base) do
      prepend PayboxSystem::Rails::Integrity
    end

    ActiveSupport.on_load(:action_controller_api) do
      prepend PayboxSystem::Rails::Integrity
    end
  end
end
