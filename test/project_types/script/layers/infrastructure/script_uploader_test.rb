describe Script::Layers::Infrastructure::ScriptUploader do
  include TestHelpers::Partners

  describe "UploadScript" do
    let(:script_service) { mock }
    let(:instance) { Script::Layers::Infrastructure::ScriptUploader.new(script_service) }
    let(:script_content) { "(module)" }
    let(:url) { "https://some-bucket" }
    let(:headers) { { "header" => "value" } }
    let(:max_size) { "1234 Bytes" }

    subject { instance.upload(script_content) }

    before do
      script_service.expects(:generate_module_upload_details).returns({
        url: url,
        headers: headers,
        max_size: max_size,
      })
    end

    describe "when fail to upload module" do
      before do
        stub_request(:put, url).with(
          headers: { "Content-Type" => "application/wasm" },
          body: script_content
        ).to_return(status: 500)
      end

      it "should raise an ScriptUploadError" do
        assert_raises(Script::Layers::Infrastructure::Errors::ScriptUploadError) { subject }
      end
    end

    describe "when Wasm is too large" do
      before do
        stub_request(:put, url).with(
          headers: { "Content-Type" => "application/wasm" },
          body: script_content
        ).to_return(
          status: 400,
          body: "<?xml version='1.0' encoding='UTF-8'?><Error><Code>EntityTooLarge</Code><Message>Your proposed " \
            "upload is larger than the maximum object size specified in your Policy Document.</Message><Details>" \
            "Content-length exceeds upper bound on range</Details></Error>",
        )
      end

      it "should raise an ScriptTooLargeError" do
        assert_raises(Script::Layers::Infrastructure::Errors::ScriptTooLargeError) { subject }
      end
    end

    describe "when succeed to upload module" do
      before do
        stub_request(:put, url).with(
          headers: { "Content-Type" => "application/wasm" },
          body: script_content
        ).to_return(status: 200)
      end

      it "should return the url" do
        assert_equal(url, subject)
      end
    end
  end
end
