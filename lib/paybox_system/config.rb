# frozen_string_literal: true

module PayboxSystem
  class Config
    def self.attr_presence(*attributes)
      attributes.each do |attribute|
        define_method attribute.to_s + '?' do
          !send(attribute).nil? && send(attribute).to_s !~ /\A[[:space:]]*\z/
        end
      end
    end

    attr_accessor :secret_key, :site, :rank, :identifier
    attr_reader :environment, :currency
    attr_presence :site, :rank, :identifier, :currency

    def environment=(value)
      unless value.nil?
        # TODO: Remove "old names" support in next major release (v3.0)
        value = {
          pre_production:    :test,
          production:        :live,
          production_rescue: :live_backup
        }[value] || value.to_sym
        unless PayboxSystem::SERVERS.key?(value)
          raise PayboxSystem::MissingEnvironment, "Invalid environment: #{value.inspect}. Expected: #{PayboxSystem::SERVERS.keys.join(', ')}"
        end
      end

      @environment = value
    end

    def currency=(value)
      if value.is_a?(String) || value.is_a?(Symbol)
        @currency = PayboxSystem::CURRENCY_CODES[value.to_s]
      else
        @currency = value
      end
    end
  end
end
