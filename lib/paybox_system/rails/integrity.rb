# frozen_string_literal: true

module PayboxSystem
  module Rails
    module Integrity
      class Error < ::PayboxSystem::Error; end

    protected

      # Raise an exception if request is not valid
      def check_paybox_integrity!
        unless params[:error].present? && params[:sign].present?
          raise Error, 'Bad response'
        end

        request_fullpath = request.fullpath
        request_params = request_fullpath[request_fullpath.index('?') + 1..request_fullpath.index('&sign') - 1]
        request_sign = request_fullpath[request_fullpath.index('&sign') + 6..-1]
        unless PayboxSystem.valid_response?(request_params, request_sign)
          raise Error, 'Bad Paybox integrity test'
        end
      end
    end
  end
end
