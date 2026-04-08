cask "directorscut" do
  version "0.1.0"
  sha256 "b1793c8dbeb9c9dbd304365cacb3c2c6823d2fc94aa70c4884fde372680081e2"

  url "https://github.com/MatthewWaller/homebrew-directorscut/releases/download/v#{version}/directorscut-#{version}-arm64.tar.gz"
  name "DirectorsCut"
  desc "AI video editing from the command line"
  homepage "https://github.com/MatthewWaller/homebrew-directorscut"

  depends_on macos: ">= :monterey"
  depends_on arch: :arm64
  depends_on formula: "ffmpeg"

  binary "directorscut/directorscut"

  postflight do
    # Remove quarantine so Gatekeeper doesn't block the unsigned binary
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", staged_path/"directorscut"],
                   sudo: false

    config_dir = Pathname.new(Dir.home) / ".directorscut"
    config_dir.mkpath unless config_dir.exist?

    env_file = config_dir / ".env"
    unless env_file.exist?
      env_example = staged_path / "directorscut" / ".env.example"
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
