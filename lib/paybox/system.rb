# frozen_string_literal: true

require 'time'
require 'openssl'
require 'base64'
require 'rack'
require 'pathname'

require 'paybox/system/version'
require 'paybox/system/config'

module Paybox
  module System
    DIGEST_METHOD = 'sha512'

    class Error < StandardError; end
    class MissingSecretKey < Error; end

    class << self
      attr_accessor :config

      def root
        Pathname.new(__dir__).join('..', '..')
      end

      def base_iframe_url
        ENV.fetch('PAYBOX_URL') do
          'https://tpeweb.paybox.com/cgi/MYframepagepaiement_ip.cgi'
        end
      end

      def iframe_url(options = {})
        base_iframe_url + '?' + formatted_query(options)
      end

      def formatted_query(options = {})
        formatted_params(options).map { |k, v| k.to_s + '=' + v.to_s }.join('&')
      end

      def formatted_params(options = {})
        unless Paybox::System.config.secret_key
          raise MissingSecretKey, 'Missing :secret_key in config'
        end

        params = options.each_with_object({}) do |(k, v), h|
          unless v.nil? || v.to_s =~ /\A[[:space:]]*\z/
            h["PBX_#{k == :tds ? '3DS' : k.to_s.upcase}"] = v
          end
        end
        params['PBX_HASH'] = DIGEST_METHOD.upcase
        params['PBX_TIME'] = Time.now.utc.iso8601

        base_params_query = params.map { |k, v| k.to_s + '=' + v.to_s }.join('&')
        binary_key = [Paybox::System.config.secret_key].pack('H*')
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(DIGEST_METHOD), binary_key, base_params_query)
        params['PBX_HMAC'] = signature.upcase

        if params['PBX_PORTEUR']
          params['PBX_PORTEUR'] = CGI.escape(params['PBX_PORTEUR'])
        end

        params
      end

      def valid_response?(params, sign)
        digest = OpenSSL::Digest::SHA1.new
        public_key = OpenSSL::PKey::RSA.new(File.read(root.join('docs', 'pubkey.pem')))
        public_key.verify(digest, Base64.decode64(Rack::Utils.unescape(sign)), params)
      end
    end

    self.config = Config.new
  end
end
