# encoding: utf-8
module ChinaSMS
  module Service
    module Submail
      extend self

      URL = 'https://api.submail.cn/message/xsend.json'

      def to(receiver, content, options = {})
        project = options.delete(:project)
        opts = {
          appid: options[:username],
          signature: options[:password],
          to: receiver,
          project: project,
          vars: JSON.generate(content)
        }

        res = Net::HTTP.post_form(URI.parse(URL), opts)
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
