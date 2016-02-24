# encoding: utf-8
require 'spec_helper'

describe "Submail" do
  describe "#to" do
    let(:appid) { '12345' }
    let(:appkey) { '2022b1599967a8cb788c05ddd9fc339e' }
    let(:send_url) { "http://api.example.cn/message/xsend.json" }
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
              "vars" => { var: '123' }.to_json
            }).
          to_return(
            body: {
              'status' => 'success',
              'send_id' => '093c0a7df143c087d6cba9cdf0cf3738',
              "fee" => "2",
              "sms_credits" => "46"
            }.to_json
          )
        ChinaSMS.use :submail, base_uri: send_url, username: appid, password: appkey
      end

      context 'string content' do
        subject { ChinaSMS.to phone, project, vars: { var: '123' } }

        its(["status"]) { should eql 'success' }
        its(["fee"]) { should eql "2" }
      end

    end

  end
end
