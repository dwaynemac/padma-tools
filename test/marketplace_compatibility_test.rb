# frozen_string_literal: true

require "json"
require "minitest/autorun"

class MarketplaceCompatibilityTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_codex_and_claude_marketplaces_resolve_the_same_plugins
    codex = read_json(".agents/plugins/marketplace.json")
    claude = read_json(".claude-plugin/marketplace.json")

    assert_equal "https://anthropic.com/claude-code/marketplace.schema.json",
                 claude.fetch("$schema")
    assert_equal "PADMA", claude.dig("owner", "name")
    assert_equal codex.fetch("plugins").map { |plugin| plugin.fetch("name") }.sort,
                 claude.fetch("plugins").map { |plugin| plugin.fetch("name") }.sort

    codex.fetch("plugins").each do |plugin|
      assert_equal "local", plugin.dig("source", "source")
      assert_equal "./plugins/#{plugin.fetch("name")}", plugin.dig("source", "path")
    end

    claude.fetch("plugins").each do |plugin|
      name = plugin.fetch("name")
      source = plugin.fetch("source")

      assert_equal "./plugins/#{name}", source
      assert File.directory?(File.join(ROOT, source))

      codex_manifest = read_json("plugins/#{name}/.codex-plugin/plugin.json")
      claude_manifest = read_json("plugins/#{name}/.claude-plugin/plugin.json")

      assert_equal name, claude_manifest.fetch("name")
      assert_equal codex_manifest.fetch("version"), claude_manifest.fetch("version")
      assert_equal "./skills/", claude_manifest.fetch("skills")

      mcp_path = File.join(ROOT, "plugins", name, ".mcp.json")

      if File.file?(mcp_path)
        assert_equal "./.mcp.json", claude_manifest.fetch("mcpServers")
      else
        refute claude_manifest.key?("mcpServers")
      end
    end
  end

  private

  def read_json(path)
    JSON.parse(File.read(File.join(ROOT, path)))
  end
end
