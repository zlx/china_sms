# encoding: utf-8
require "base64"
module ChinaSMS
  module Service
    module Aliyun
      include ERB::Util
      extend self

      URL = "https://sms.aliyuncs.com/"

      def to(phone, content, options = {})
        template_code = options.delete(:template_code)
        sms_params = create_params(phone, template_code, content, options)
        signature = sign(options[:password], sms_params)
        request(URI.parse(URL), sms_params.merge(Signature: signature))
      end

      private

      def request(url, params)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/x-www-form-urlencoded'
        request.body = query_string(params)
        res = http.request(request)
        result res.body
      end

      def create_params(phone, template_code, message_param, options = {})
        {
          'AccessKeyId' => options[:username],
          'Action' => 'SingleSendSms',
          'Format' => 'json',
          'ParamString' => JSON.generate(message_param),
          'RecNum' => phone,
          'RegionId' => 'cn-hangzhou',
          'SignName' => options[:sign_name],
          'SignatureMethod' => 'HMAC-SHA1',
          'SignatureNonce' => Time.now.utc.strftime("%Y%m%d%H%M%S%L"),
          'SignatureVersion' => '1.0',
          'TemplateCode' => template_code,
          'Timestamp' => Time.now.utc.strftime("%FT%TZ"),
          'Version' => '2016-09-27'
        }
      end

      def sign(key_secret, params)
        key = key_secret + '&'
        signature = 'POST' + '&' + encode('/') + '&' + canonicalized_query_string(params)
        sign = Base64.encode64(OpenSSL::HMAC.digest('sha1', key, signature))
        encode(sign.chomp)
      end

      def query_string(params)
        params.map { |key, value| "#{key}=#{value}" }.join("&")
      end

      def canonicalized_query_string(params)
        encode(params.map { |key, value| "#{encode(key)}=#{encode(value)}" }.join("&"))
      end

      def encode(input)
        url_encode(input)
      end

      def result body
        begin
          parsed_result = JSON.parse body
          if parsed_result.has_key?('Model')
            parsed_result.merge('status' => 'success')
          else
            parsed_result.merge('status' => 'failure')
          end
        rescue => e
          {
            code: 502,
            msg: "内容解析错误",
            status: e.to_s
          }
        end
      end
    end
  end
end
