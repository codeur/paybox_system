# frozen_string_literal: true

module PayboxSystem
  class Config
    attr_accessor :secret_key, :environment, :site, :rank, :identifier, :currency
  end
end
