class Directorscut < Formula
  desc "AI video editing from the command line"
  homepage "https://github.com/MatthewWaller/homebrew-directorscut"
  url "https://github.com/MatthewWaller/homebrew-directorscut/releases/download/v0.1.0/directorscut-0.1.0-arm64.tar.gz"
  sha256 "dd154e7e5cd46434ce021088bffc3737fc83761b36e779007b5d8c2cba5b1779"
  version "0.1.0"

  depends_on macos: :monterey
  depends_on arch: :arm64
  depends_on "ffmpeg"

  def install
    bin.install "directorscut"
  end

  def post_install
    config_dir = Pathname.new(Dir.home) / ".directorscut"
    config_dir.mkpath unless config_dir.exist?

    env_file = config_dir / ".env"
    unless env_file.exist?
      env_example = prefix / ".env.example"
      cp env_example, env_file if env_example.exist?
    end
  end

  def caveats
    <<~EOS
      To get started, add your API keys:

        #{Pathname.new(Dir.home)}/.directorscut/.env

      Required:
        DIRECTORSCUT_GEMINI_API_KEY=your_key_here

      Optional (for cloud narration):
        DIRECTORSCUT_ELEVENLABS_API_KEY=your_key_here

      Or run interactive setup:
        directorscut setup

      Then verify your install:
        directorscut doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/directorscut --version")
  end
end
