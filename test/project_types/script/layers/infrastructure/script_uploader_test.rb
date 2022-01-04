# typed: ignore
describe Script::Layers::Infrastructure::ScriptUploader do
  include TestHelpers::Partners

  describe "UploadScript" do
    let(:script_service) { mock }
    let(:instance) { Script::Layers::Infrastructure::ScriptUploader.new(script_service) }
    let(:script_content) { "(module)" }
    let(:url) { "https://some-bucket" }

    subject { instance.upload(script_content) }

    before do
      script_service.expects(:generate_module_upload_url).returns(url)
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
