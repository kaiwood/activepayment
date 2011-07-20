module ActivePayment
  module Payone
    class Gateway < ActivePayment::Gateway::Base

      class_attribute :mid, :portalid, :key, :mode

      attr_accessor :aid

      self.gateway_name = "payone"
      self.test_url = 'https://api.pay1.de/post-gateway/'
      self.live_url = ''

      def authorization
        post_request(self.authorization_request)
      end

      def authorization_request
        build_request(:authorization) do |params|
          params[:aid] = self.aid
          params[:amount] = self.amount
          params[:reference] = self.transaction_params[:reference]
          params[:currency] = Gateway.default_currency

          params.merge!(self.transaction_params)
        end
      end

      private

      def add_optional_param(params, name, value = nil)
        if value.blank? && self.transaction_params.include?(name) && !self.transaction_params[name].blank?
          value = self.transaction_params[name]
        end
        unless value.blank?
          params[name] = value
        end
      end

      def build_request(method, &block)
        params = {:mid => self.mid, :portalid => self.portalid, :key => Digest::MD5.new.hexdigest(self.key), :mode => self.mode, :request => method}
        yield params
        params.to_query
      end

      def post_request(content)
        http_connection do |http|
          response = http.post(self.url.path, content, {'Content-Type'=> 'application/x-www-form-urlencoded'})
          unless response.blank?
            return ActivePayment::Payone::Response.new(response.body)
          end
        end
      end

    end
  end
end