# encoding: utf-8
module ChinaSMS
  module Service
    module Submail
      extend self

      SEND_URL = 'https://api.submail.cn/message/xsend.json'

      def to(receiver, project, options = {})
        opts = {
          appid: options[:username],
          signature: options[:password],
          to: receiver,
          project: project
        }
        opts[:vars] = options[:vars].is_a?(Hash) ? JSON.generate(options[:vars]) : options[:vars]

        res = Net::HTTP.post_form(URI.parse(SEND_URL), opts)
        result res.body
      end


      private

      def result body
        begin
          JSON.parse body
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
