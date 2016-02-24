# encoding: utf-8
require 'spec_helper'

describe "Submail" do
  describe "#to" do
    let(:appid) { '12345' }
    let(:appkey) { '2022b1599967a8cb788c05ddd9fc339e' }
    let(:send_url) { "https://api.submail.cn/message/xsend.json" }
    let(:project) { 'SDsw1' }

    describe 'single phone' do
      let(:phone) { '13928452841' }

      before do
        stub_request(:post, send_url).
          with(
            body: {
              "appid" => appid,
              "project" => project,
              "to" => phone,
              "signature" => appkey,
              "vars" => nil
            }).
          to_return(
            body: {
              'status' => 'success',
              'send_id' => '093c0a7df143c087d6cba9cdf0cf3738',
              "fee" => "2",
              "sms_credits" => "46"
            }.to_json
          )
      end

      context 'string content' do
        subject { ChinaSMS::Service::Submail.to phone, project, username: appid, password: appkey }

        its(["status"]) { should eql 'success' }
        its(["fee"]) { should eql "2" }
      end

    end

  end
end
