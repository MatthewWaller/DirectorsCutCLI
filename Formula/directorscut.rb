class Directorscut < Formula
  desc "AI video editing from the command line"
  homepage "https://github.com/MatthewWaller/homebrew-directorscut"
  url "https://github.com/MatthewWaller/homebrew-directorscut/releases/download/v0.1.0/directorscut-0.1.0-arm64.tar.gz"
  sha256 "48d962ac8298252a92b685752f2c01479b18ea826bcf4ffc7a86c3daa3e5b0d6"
  version "0.1.0"

  depends_on macos: :monterey
  depends_on arch: :arm64
  depends_on "ffmpeg"

  # Skip Homebrew's dylib relocation — PyInstaller bundles are self-contained
  skip_clean :all

  def install
    # Install the entire directory bundle (binary + shared libs)
    libexec.install Dir["*"]
    # Wrapper script so the binary can find its co-located libs
    (bin/"directorscut").write <<~SH
      #!/bin/bash
      exec "#{libexec}/directorscut" "$@"
    SH
  end

  def post_install
    config_dir = Pathname.new(Dir.home) / ".directorscut"
    config_dir.mkpath unless config_dir.exist?

    env_file = config_dir / ".env"
    unless env_file.exist?
      env_example = libexec / ".env.example"
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
