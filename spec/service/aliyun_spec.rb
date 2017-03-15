# encoding: utf-8
require 'spec_helper'

describe "Aliyun" do
  describe "#to" do
    let(:appid) { '12345' }
    let(:appkey) { '2022b1599967a8cb788c05ddd9fc339e' }
    let(:send_url) { "https://sms.aliyuncs.com/" }
    let(:project) { 'SMS_12344' }
    let(:sign_name) { 'Apple' }

    describe 'single phone' do
      let(:phone) { '13928452841' }

      before do
        allow(Time).to receive(:now).and_return(Time.parse("2017-03-15T11:20:34Z"))
        stub_request(:post, send_url).
          with(
            body: {
              AccessKeyId: appid,
              Action: "SingleSendSms",
              Format: "json",
              ParamString: JSON.generate({ var: '123' }),
              RecNum: phone,
              RegionId: "cn-hangzhou",
              SignName: sign_name,
              Signature: "HIYq31s2lhJY/A+hiohRbB7ZbVA=",
              SignatureMethod: "HMAC-SHA1",
              SignatureNonce: Time.now.utc.strftime("%Y%m%d%H%M%S%L"),
              SignatureVersion: "1.0",
              TemplateCode: project,
              Timestamp: Time.now.utc.strftime("%FT%TZ"),
              Version: "2016-09-27"
            })
          .to_return(
            body: {
              'Model' => '111122^23344',
              'RequestId' => 'eeeedddd-aaaaawwwss-qqqqa',
            }.to_json
          )
      end

      context 'string content' do
        subject { ChinaSMS::Service::Aliyun.to phone, { var: '123' }, template_code: project, username: appid, password: appkey, sign_name: sign_name }

        its(["status"]) { should eql 'success' }
        its(["Model"]) { should eql '111122^23344' }
      end

    end

  end
end
