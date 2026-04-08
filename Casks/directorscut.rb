cask "directorscut" do
  version "0.1.0"
  sha256 "48d962ac8298252a92b685752f2c01479b18ea826bcf4ffc7a86c3daa3e5b0d6"

  url "https://github.com/MatthewWaller/homebrew-directorscut/releases/download/v#{version}/directorscut-#{version}-arm64.tar.gz"
  name "DirectorsCut"
  desc "AI video editing from the command line"
  homepage "https://github.com/MatthewWaller/homebrew-directorscut"

  depends_on macos: ">= :monterey"
  depends_on arch: :arm64
  depends_on formula: "ffmpeg"

  binary "directorscut"

  postflight do
    config_dir = Pathname.new(Dir.home) / ".directorscut"
    config_dir.mkpath unless config_dir.exist?

    env_file = config_dir / ".env"
    unless env_file.exist?
      env_example = staged_path / ".env.example"
      FileUtils.cp(env_example, env_file) if env_example.exist?
    end
  end

  caveats <<~EOS
    To get started, add your API keys:

      ~/.directorscut/.env

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
