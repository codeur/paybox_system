require "time"
require "openssl"
require "base64"
require "rack"

module Paybox
  module System
    class Base
      @@config = {}

      def self.config
        @@config
      end

      def self.config=(new_config)
        @@config = new_config
      end

      def self.hash_form_fields_from(options = {})
        raise StandardError, "missing :secret_key in config Hash" unless @@config[:secret_key]

        formatted_options = Hash[options.map { |k, v| ["PBX_#{format_key(k)}", v] unless blank?(v) }.compact]
        formatted_options["PBX_HASH"] = "SHA512"



        date_iso = Time.now.utc.iso8601
        formatted_options["PBX_TIME"] = date_iso

        base_params_query = formatted_options.to_a.map { |a| a.join("=") }.join("&")

        key = @@config[:secret_key]

        binary_key = [key].pack("H*")
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'),
                      binary_key, base_params_query).upcase

        formatted_options["PBX_HMAC"] = signature


        formatted_options['PBX_PORTEUR'] = CGI.escape(formatted_options['PBX_PORTEUR']) if formatted_options['PBX_PORTEUR']

        formatted_options
      end

      def self.check_response?(params, sign)
        digest = OpenSSL::Digest::SHA1.new
        public_key = OpenSSL::PKey::RSA.new(File.read(File.expand_path(File.dirname(__FILE__) + '/../docs/pubkey.pem')))

        public_key.verify(digest, Base64.decode64(Rack::Utils.unescape(sign)), params)
      end

      def self.format_key(key)
        return '3DS' if key.to_s.upcase == 'TDS'
        key.to_s.upcase
      end

      def self.blank?(value)
        value.respond_to?(:blank?) ? value.blank? : (value.nil? || value.to_s.strip == '')
      end
    end
  end
end
