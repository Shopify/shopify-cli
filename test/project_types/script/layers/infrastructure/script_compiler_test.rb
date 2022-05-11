require "securerandom"

describe Script::Layers::Infrastructure::ScriptCompiler do
  describe "ScriptCompiler" do
    let(:script_service) { mock }
    let(:instance) { Script::Layers::Infrastructure::ScriptCompiler.new(script_service) }
    let(:module_upload_url) { "https://fake/#{SecureRandom.uuid}.wasm" }
    let(:job_id) { SecureRandom.uuid }
    let(:status) { "completed" }

    describe "#compile" do
      subject { instance.compile(module_upload_url: module_upload_url) }

      it "should return job id" do
        script_service.expects(:compile).with(module_upload_url: module_upload_url).returns(job_id)

        assert_equal(job_id, subject)
      end
    end

    describe "#compilation_status" do
      subject { instance.compilation_status(job_id: job_id) }

      it "should return status" do
        script_service.expects(:compilation_status).with(job_id: job_id).returns(status)

        assert_equal(status, subject)
      end
    end
  end
end
