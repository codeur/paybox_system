# frozen_string_literal: true

require 'test_helper'

module Paybox
  class SystemTest < Minitest::Test
    def setup
      Paybox::System.config.secret_key = nil
    end

    def test_that_it_has_a_version_number
      assert ::Paybox::System::VERSION
    end

    def test_config
      assert_instance_of Paybox::System::Config, Paybox::System.config
      Paybox::System.config.secret_key = 'pipo'
      assert_equal 'pipo', Paybox::System.config.secret_key
      assert_raises NoMethodError do
        Paybox::System.config.public_key
      end
    end

    def test_formatted_params
      assert_raises ::Paybox::System::MissingSecretKey do
        ::Paybox::System.formatted_params
      end

      Paybox::System.config.secret_key = '0123456789ABCDEF' * 8

      hash = ::Paybox::System.formatted_params(aaa: 'aaa', bbb: 'bbb', ccc: 'ccc')
      assert_instance_of Hash, hash
      assert_equal %w[PBX_AAA PBX_BBB PBX_CCC PBX_HASH PBX_HMAC PBX_TIME], hash.keys.sort
      assert_equal 'SHA512', hash['PBX_HASH']
      assert(hash['PBX_HMAC'] =~ /\A[A-F0-9]{128}\z/)
    end

    def test_response_check
      params = 'reference=id%204f3c497294b3026bfa000001&error=00001'
      signature = 'NuHxwhK%2BENWuXSXeqtGLa2Zezc7ttXvDvCuJa8h4iWXfDSkHCRAYgPazS1Fo%2Fn%2Bk8%2FksD5C6jP0%2Fgf9xQR0JndC0MPKvA6eDeDknEdAsQAriS%2Fk7vjazARAAY1h%2Bt4zROoMVWI8Ph5u%2Bcf6nKuShUOOBuoqyomVphJLKxVMfGtM%3D'

      assert Paybox::System.valid_response?(params, signature)
      assert !Paybox::System.valid_response?(params.upcase, signature)
    end
  end
end
