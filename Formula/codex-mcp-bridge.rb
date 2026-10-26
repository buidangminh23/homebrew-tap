class CodexMcpBridge < Formula
  desc "Two-way MCP bridge between Claude and Codex"
  homepage "https://github.com/buidangminh23/codex-mcp-bridge"
  url "https://registry.npmjs.org/@minhspark/codex-mcp-bridge/-/codex-mcp-bridge-1.23.0.tgz"
  sha256 "500a37923b1f1778fdc3d2dc03079020c0f57d5fe68143e89568ad3e110da2b0"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/@minhspark/codex-mcp-bridge/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*").reject { |command| command.basename.to_s == "codex-npm-footer-install" }
  end

  def caveats
    <<~EOS
      Register the bridge with your clients:
        codex-mcp-bridge-install      # Claude Desktop
        claude-mcp-bridge-install     # Codex
        codex-native-relay-install    # Codex Desktop native relay (macOS)

      Registrations use Homebrew's stable opt paths, so they keep working after
      `brew upgrade codex-mcp-bridge` and running bridges reload the new version.
    EOS
  end

  test do
    require "open3"
    require "timeout"

    assert_equal version.to_s, shell_output("#{bin}/codex-mcp-bridge --version").strip
    installer = libexec/"lib/node_modules/@minhspark/codex-mcp-bridge/scripts/install-claude-desktop.mjs"
    assert_equal "#!#{formula_opt_bin("node")}/node", installer.read.lines.first.chomp

    initialize = {
      jsonrpc: "2.0",
      id:      1,
      method:  "initialize",
      params:  {
        protocolVersion: "2025-06-18",
        capabilities:    {},
        clientInfo:      { name: "brew-test", version: "1" },
      },
    }
    Open3.popen3(bin/"codex-mcp-bridge") do |stdin, stdout, _stderr, wait|
      stdin.puts JSON.generate(initialize)
      stdin.flush
      response = JSON.parse(Timeout.timeout(60) { stdout.gets })
      assert_equal "codex-bridge", response.dig("result", "serverInfo", "name")
      assert_equal version.to_s, response.dig("result", "serverInfo", "version")
    ensure
      stdin.close
      wait.value
    end
  end
end
