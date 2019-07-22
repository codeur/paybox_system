# frozen_string_literal: true

require 'test_helper'

class PayboxSystemTest < Minitest::Test
  def setup
    PayboxSystem.config.secret_key = nil
    PayboxSystem.config.environment = nil
  end

  def test_that_it_has_a_version_number
    assert ::PayboxSystem::VERSION
  end

  def test_config
    assert_instance_of PayboxSystem::Config, PayboxSystem.config
    PayboxSystem.config.secret_key = 'pipo'
    assert_equal 'pipo', PayboxSystem.config.secret_key
    assert_raises NoMethodError do
      PayboxSystem.config.public_key
    end
    assert_raises
  end

  def test_formatted_params
    assert_raises ::PayboxSystem::MissingSecretKey do
      ::PayboxSystem.formatted_params
    end

    PayboxSystem.config.secret_key = '0123456789ABCDEF' * 8

    hash = ::PayboxSystem.formatted_params(aaa: 'aaa', bbb: 'bbb', ccc: 'ccc')
    assert_instance_of Hash, hash
    assert_equal %w[PBX_AAA PBX_BBB PBX_CCC PBX_HASH PBX_HMAC PBX_TIME], hash.keys.sort
    assert_equal 'SHA512', hash['PBX_HASH']
    assert(hash['PBX_HMAC'] =~ /\A[A-F0-9]{128}\z/)
  end

  def test_response_check
    params = 'reference=id%204f3c497294b3026bfa000001&error=00001'
    signature =
      'NuHxwhK%2BENWuXSXeqtGLa2Zezc7ttXvDvCuJa8h4iWXfDSkHCRAYgPazS1Fo%2Fn%2Bk8'\
      '%2FksD5C6jP0%2Fgf9xQR0JndC0MPKvA6eDeDknEdAsQAriS%2Fk7vjazARAAY1h%2Bt4zR'\
      'OoMVWI8Ph5u%2Bcf6nKuShUOOBuoqyomVphJLKxVMfGtM%3D'

    assert PayboxSystem.valid_response?(params, signature)
    assert !PayboxSystem.valid_response?(params.upcase, signature)
  end

  def test_server_url
    PayboxSystem.config.secret_key = '0123456789ABCDEF' * 8
    assert_raises PayboxSystem::MissingEnvironment do
      PayboxSystem.light_url
    end
    PayboxSystem.config.environment = :invalid
    assert_raises PayboxSystem::MissingEnvironment do
      PayboxSystem.light_url
    end
    PayboxSystem.config.environment = :pre_production
    assert_equal 'https://preprod-tpeweb.paybox.com/cgi/MYframepagepaiement_ip.cgi', PayboxSystem.light_url
  end
end
