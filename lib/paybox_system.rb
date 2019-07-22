# frozen_string_literal: true

require 'time'
require 'openssl'
require 'base64'
require 'rack'
require 'pathname'

require 'paybox_system/version'
require 'paybox_system/config'

module PayboxSystem
  DIGEST_METHOD = 'sha512'
  PUBLIC_KEY_PATH = Pathname.new(__dir__).join('..', 'docs', 'pubkey.pem')
  PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read(PUBLIC_KEY_PATH))

  SERVERS = {
    pre_production:    'https://preprod-tpeweb.paybox.com',
    production:        'https://tpeweb.paybox.com',
    production_rescue: 'https://tpeweb1.paybox.com'
  }.freeze

  class Error < StandardError; end
  class MissingSecretKey < Error; end
  class MissingEnvironment < Error; end

  class << self
    attr_accessor :config

    def classical_url(options = {})
      server_url('/cgi/MYchoix_pagepaiement.cgi', options)
    end

    def light_url(options = {})
      server_url('/cgi/MYframepagepaiement_ip.cgi', options)
    end

    def mobile_url(options = {})
      server_url('/cgi/ChoixPaiementMobile.cgi', options)
    end

    def termination_url(options = {})
      server_url('/cgi-bin/ResAbon.cgi', options)
    end

    def formatted_query(options = {})
      formatted_params(options).map { |k, v| k.to_s + '=' + v.to_s }.join('&')
    end

    def formatted_params(options = {})
      unless config.secret_key
        raise MissingSecretKey, 'Missing :secret_key in config'
      end

      return {} if options.empty?

      params = options.each_with_object({}) do |(k, v), h|
        unless v.nil? || v.to_s =~ /\A[[:space:]]*\z/
          h["PBX_#{k == :tds ? '3DS' : k.to_s.upcase}"] = v
        end
      end
      params['PBX_HASH'] = DIGEST_METHOD.upcase
      params['PBX_TIME'] = Time.now.utc.iso8601

      base_params_query = params.map { |k, v| k.to_s + '=' + v.to_s }.join('&')
      binary_key = [config.secret_key].pack('H*')
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(DIGEST_METHOD), binary_key, base_params_query)
      params['PBX_HMAC'] = signature.upcase

      if params['PBX_PORTEUR']
        params['PBX_PORTEUR'] = CGI.escape(params['PBX_PORTEUR'])
      end

      params
    end

    def valid_response?(params, sign)
      digest = OpenSSL::Digest::SHA1.new
      PUBLIC_KEY.verify(digest, Base64.decode64(Rack::Utils.unescape(sign)), params)
    end

  protected

    def server_url(path, options = {})
      base_url = SERVERS[config.environment]
      unless base_url
        raise MissingEnvironment, 'Missing or invalid :environment in config'
      end

      return base_url + path if options.empty?

      base_url + path + '?' + formatted_query(options)
    end
  end

  self.config = Config.new
end
