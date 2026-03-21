# ZeroClaw NixOS module (dotfiles)

NixOS packaging and typed `services.zeroclaw.settings` for [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw): upstream binary is built from a pinned Git revision; configuration is merged from small Nix modules and rendered to TOML for the daemon.

## 1. Upstream version and documentation

| Item | Location |
|------|----------|
| **Pinned ZeroClaw version** | **`v0.5.1`** — see `version` in [`default.nix`](./default.nix) (`fetchFromGitHub.rev`). |
| **Official repository** | <https://github.com/zeroclaw-labs/zeroclaw> |
| **Operator-oriented config reference** (tables, defaults, examples) | <https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/config-reference.md> |
| **Additional API docs** | [Providers](https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/providers-reference.md), [Channels](https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/channels-reference.md) |
| **Machine-readable schema (JSON Schema)** | Run against the **same version** you ship: `zeroclaw config schema` (stdout). Documented in [config-reference.md](https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/config-reference.md). |
| **Rust source of truth for types/defaults** | [`src/config/schema.rs`](https://github.com/zeroclaw-labs/zeroclaw/blob/v0.5.1/src/config/schema.rs) on the tag matching `default.nix` (currently `v0.5.1`). |

> **Note:** Documentation on `master` may be newer than the pinned tag. When upgrading the package, align `config-reference` / schema checks with the **new tag**, not necessarily `master`.

---

## 2. Configuration blocks → Nix files → upstream

Options under `services.zeroclaw.settings` are defined by `lib.types.submoduleWith { modules = import ./settings/default.nix; }` in [`settings.nix`](./settings.nix). Each fragment lives under [`settings/`](./settings/).

The **TOML section name** usually matches the **top-level key** in the table below (e.g. `[agent]` → `agent.nix`). Scalar top-level keys are grouped in [`settings/scalar_options.nix`](./settings/scalar_options.nix).

**Upstream paths** are relative to the [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) repository root (use the same **git tag** as `version` in [`default.nix`](./default.nix)). Unless noted, types live in a single file: `src/config/schema.rs`. Re-exports are listed in `src/config/mod.rs`. Runtime workspace helpers (not the `[workspace]` table type) are in `src/config/workspace.rs`.

| Config key / section | Nix module | Upstream source (paths in zeroclaw repo) |
|---------------------|------------|------------------------------------------|
| `agent` | [`settings/agent.nix`](./settings/agent.nix) | `src/config/schema.rs` — `AgentConfig` |
| `agents` | [`settings/agents.nix`](./settings/agents.nix) | `src/config/schema.rs` — `Config::agents` (`HashMap<String, DelegateAgentConfig>`), `DelegateAgentConfig` |
| `api_key`, `api_path`, `api_url`, `default_model`, `default_provider`, `default_temperature`, `extra_headers`, `locale`, `provider_timeout_secs` | [`settings/scalar_options.nix`](./settings/scalar_options.nix) | `src/config/schema.rs` — `Config` fields (`api_key`, `api_url`, `api_path`, `default_provider`, `default_model`, `default_temperature`, `provider_timeout_secs`, `extra_headers`, `locale`) |
| `autonomy` | [`settings/autonomy.nix`](./settings/autonomy.nix) | `src/config/schema.rs` — `AutonomyConfig` |
| `backup` | [`settings/backup.nix`](./settings/backup.nix) | `src/config/schema.rs` — `BackupConfig` |
| `browser` | [`settings/browser.nix`](./settings/browser.nix) | `src/config/schema.rs` — `BrowserConfig`, `BrowserComputerUseConfig` |
| `browser_delegate` | [`settings/browser_delegate.nix`](./settings/browser_delegate.nix) | `src/tools/browser_delegate.rs` — `BrowserDelegateConfig` (referenced from `Config` in `schema.rs`) |
| `channels_config` | [`settings/channels_config.nix`](./settings/channels_config.nix) | `src/config/schema.rs` — `ChannelsConfig` and per-channel structs in the same file (e.g. `TelegramConfig`, `DiscordConfig`, …) |
| `cloud_ops` | [`settings/cloud_ops.nix`](./settings/cloud_ops.nix) | `src/config/schema.rs` — `CloudOpsConfig` |
| `composio` | [`settings/composio.nix`](./settings/composio.nix) | `src/config/schema.rs` — `ComposioConfig` |
| `conversational_ai` | [`settings/conversational_ai.nix`](./settings/conversational_ai.nix) | `src/config/schema.rs` — `ConversationalAiConfig` |
| `cost` | [`settings/cost.nix`](./settings/cost.nix) | `src/config/schema.rs` — `CostConfig` |
| `cron` | [`settings/cron.nix`](./settings/cron.nix) | `src/config/schema.rs` — `CronConfig` |
| `data_retention` | [`settings/data_retention.nix`](./settings/data_retention.nix) | `src/config/schema.rs` — `DataRetentionConfig` |
| `embedding_routes` | [`settings/embedding_routes.nix`](./settings/embedding_routes.nix) | `src/config/schema.rs` — `Config::embedding_routes`, `EmbeddingRouteConfig` |
| `gateway` | [`settings/gateway.nix`](./settings/gateway.nix) | `src/config/schema.rs` — `GatewayConfig`, `PairingDashboardConfig`, … |
| `google_workspace` | [`settings/google_workspace.nix`](./settings/google_workspace.nix) | `src/config/schema.rs` — `GoogleWorkspaceConfig` |
| `hardware` | [`settings/hardware.nix`](./settings/hardware.nix) | `src/config/schema.rs` — `HardwareConfig`, `HardwareTransport` |
| `heartbeat` | [`settings/heartbeat.nix`](./settings/heartbeat.nix) | `src/config/schema.rs` — `HeartbeatConfig` |
| `hooks` | [`settings/hooks.nix`](./settings/hooks.nix) | `src/config/schema.rs` — `HooksConfig`, `BuiltinHooksConfig`, `WebhookAuditConfig`, … |
| `http_request` | [`settings/http_request.nix`](./settings/http_request.nix) | `src/config/schema.rs` — `HttpRequestConfig` |
| `identity` | [`settings/identity.nix`](./settings/identity.nix) | `src/config/schema.rs` — `IdentityConfig` |
| `knowledge` | [`settings/knowledge.nix`](./settings/knowledge.nix) | `src/config/schema.rs` — `KnowledgeConfig` |
| `linkedin` | [`settings/linkedin.nix`](./settings/linkedin.nix) | `src/config/schema.rs` — `LinkedInConfig`, `LinkedInContentConfig`, `LinkedInImageConfig`, image provider subconfigs |
| `mcp` | [`settings/mcp.nix`](./settings/mcp.nix) | `src/config/schema.rs` — `McpConfig`, `McpServerConfig`, `McpTransport` |
| `memory` | [`settings/memory.nix`](./settings/memory.nix) | `src/config/schema.rs` — `MemoryConfig`, `QdrantConfig` |
| `microsoft365` | [`settings/microsoft365.nix`](./settings/microsoft365.nix) | `src/config/schema.rs` — `Microsoft365Config` |
| `model_providers` | [`settings/model_providers.nix`](./settings/model_providers.nix) | `src/config/schema.rs` — `Config::model_providers`, `ModelProviderConfig` |
| `model_routes` | [`settings/model_routes.nix`](./settings/model_routes.nix) | `src/config/schema.rs` — `Config::model_routes`, `ModelRouteConfig` |
| `multimodal` | [`settings/multimodal.nix`](./settings/multimodal.nix) | `src/config/schema.rs` — `MultimodalConfig` |
| `node_transport` | [`settings/node_transport.nix`](./settings/node_transport.nix) | `src/config/schema.rs` — `NodeTransportConfig` |
| `nodes` | [`settings/nodes.nix`](./settings/nodes.nix) | `src/config/schema.rs` — `NodesConfig` |
| `notion` | [`settings/notion.nix`](./settings/notion.nix) | `src/config/schema.rs` — `NotionConfig` |
| `observability` | [`settings/observability.nix`](./settings/observability.nix) | `src/config/schema.rs` — `ObservabilityConfig` |
| `peripherals` | [`settings/peripherals.nix`](./settings/peripherals.nix) | `src/config/schema.rs` — `PeripheralsConfig`, `PeripheralBoardConfig` |
| `plugins` | [`settings/plugins.nix`](./settings/plugins.nix) | `src/config/schema.rs` — `PluginsConfig` |
| `project_intel` | [`settings/project_intel.nix`](./settings/project_intel.nix) | `src/config/schema.rs` — `ProjectIntelConfig` |
| `proxy` | [`settings/proxy.nix`](./settings/proxy.nix) | `src/config/schema.rs` — `ProxyConfig`, `ProxyScope` |
| `query_classification` | [`settings/query_classification.nix`](./settings/query_classification.nix) | `src/config/schema.rs` — `QueryClassificationConfig`, `ClassificationRule` |
| `reliability` | [`settings/reliability.nix`](./settings/reliability.nix) | `src/config/schema.rs` — `ReliabilityConfig` |
| `runtime` | [`settings/runtime.nix`](./settings/runtime.nix) | `src/config/schema.rs` — `RuntimeConfig`, `DockerRuntimeConfig` |
| `scheduler` | [`settings/scheduler.nix`](./settings/scheduler.nix) | `src/config/schema.rs` — `SchedulerConfig` |
| `secrets` | [`settings/secrets.nix`](./settings/secrets.nix) | `src/config/schema.rs` — `SecretsConfig` |
| `security` | [`settings/security.nix`](./settings/security.nix) | `src/config/schema.rs` — `SecurityConfig`, `AuditConfig`, `SandboxConfig`, `ResourceLimitsConfig`, `OtpConfig`, `EstopConfig`, `NevisConfig`, `NevisRoleMappingConfig`, … |
| `security_ops` | [`settings/security_ops.nix`](./settings/security_ops.nix) | `src/config/schema.rs` — `SecurityOpsConfig` |
| `skills` | [`settings/skills.nix`](./settings/skills.nix) | `src/config/schema.rs` — `SkillsConfig`, `SkillCreationConfig`, `SkillsPromptInjectionMode` |
| `storage` | [`settings/storage.nix`](./settings/storage.nix) | `src/config/schema.rs` — `StorageConfig`, `StorageProviderConfig`, `StorageProviderSection` |
| `swarms` | [`settings/swarms.nix`](./settings/swarms.nix) | `src/config/schema.rs` — `Config::swarms`, `SwarmConfig`, `SwarmStrategy` |
| `transcription` | [`settings/transcription.nix`](./settings/transcription.nix) | `src/config/schema.rs` — `TranscriptionConfig`, `DeepgramSttConfig`, `AssemblyAiSttConfig`, … |
| `tts` | [`settings/tts.nix`](./settings/tts.nix) | `src/config/schema.rs` — `TtsConfig`, `OpenAiTtsConfig`, `ElevenLabsTtsConfig`, `GoogleTtsConfig`, `EdgeTtsConfig` |
| `tunnel` | [`settings/tunnel.nix`](./settings/tunnel.nix) | `src/config/schema.rs` — `TunnelConfig` and tunnel backend structs (`OpenVpnTunnelConfig`, …) |
| `web_fetch` | [`settings/web_fetch.nix`](./settings/web_fetch.nix) | `src/config/schema.rs` — `WebFetchConfig` |
| `web_search` | [`settings/web_search.nix`](./settings/web_search.nix) | `src/config/schema.rs` — `WebSearchConfig` |
| `workspace` | [`settings/workspace.nix`](./settings/workspace.nix) | `src/config/schema.rs` — `WorkspaceConfig` (multi-client isolation table; distinct from `src/config/workspace.rs` runtime helpers) |

**Module index:** explicit import order is [`settings/default.nix`](./settings/default.nix) (order only matters if two modules defined the same option name; they must not overlap).

---

## 3. Verification and update workflow

Use this when bumping ZeroClaw or changing settings so the module stays consistent and the generated TOML stays valid.

### 3.1 Bump the package version

1. In [`default.nix`](./default.nix), set `version` to the new tag (e.g. `v0.6.0`).
2. Update `fetchFromGitHub` **`hash`** (`sha256-...`) — use `lib.fakeHash` or empty hash once, run `nix build` / `nixos-rebuild`, then paste the correct hash from the error message.
3. If the **npm** frontend build changes, update `npmDepsHash` in the `zeroclaw-web` `buildNpmPackage` call the same way.

### 3.2 Align Nix options with upstream

There is **no** committed code generator in this repo that regenerates all fragments from schema; options are maintained as explicit Nix.

For each release:

1. **Read** [config-reference.md](https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/config-reference.md) at the tag you care about (or diff `master` vs previous tag for breaking notes).
2. **Inspect** [`schema.rs`](https://github.com/zeroclaw-labs/zeroclaw/blob/v0.5.1/src/config/schema.rs) on the **same tag** as `default.nix` for new fields, renamed keys, enum variants, and defaults.
3. **Export JSON Schema** from the built CLI (matches runtime parsing):
   ```bash
   # After building the pinned version, e.g. from nix build or cargo:
   zeroclaw config schema > /tmp/zschema.json
   ```
4. **Edit** the relevant file under [`settings/`](./settings/) (or add a new fragment and append it to [`settings/default.nix`](./settings/default.nix)).
5. Prefer **`lib.types.enum`** for closed string sets, **`lib.types.submodule`** for nested tables, and **`lib.types.nullOr`** only where upstream uses optional/nullable values. Keep `description` in sync with upstream docs where practical.
6. **Optional strings:** if `type = lib.types.nullOr lib.types.str` (or `nullOr (lib.types.str)`), set **`default = null`**, not `default = ""`. Unset optional fields should be absent from the merged config / TOML after sanitization; an empty string is a distinct value and is easy to confuse with “not set”.

### 3.3 Validate in NixOS

1. **Typecheck / merge:** evaluate your host, e.g.  
   `nix eval .#nixosConfigurations.<hostname>.config.services.zeroclaw.settings --json`  
   Fix any option type or missing attribute errors.
2. **TOML output:** the module runs `pkgs.formats.toml` on a **sanitized** tree (`sanitizeForToml` in [`settings.nix`](./settings.nix)) to drop `null` and empty attrsets (TOML has no `null`; empty sections are omitted on purpose).
3. **Secrets template:** if you use `sops.templates."zeroclaw-config"`, evaluate  
   `nix eval --raw '.#nixosConfigurations.<hostname>.config.sops.templates."zeroclaw-config".content'`  
   and confirm the file builds (no `null` left in serialized data).
4. **Runtime:** on the machine, `zeroclaw doctor`, `zeroclaw status`, and exercise critical paths after deploy.

### 3.4 Host-specific overrides

Per-machine values (tokens, ports, allowlists) belong in host modules (e.g. `tv-box/system/modules/zeroclaw.nix`), not in `shared/builts/zeroclaw/settings/*`, unless the change is a **global default** for all your systems.

### 3.5 Git / flake note

Paths under `settings/` must be **tracked by git** if your flake uses `git+file:` filtering so `import ./settings/default.nix` resolves inside the flake source.

---

## Quick links

- **Project:** <https://github.com/zeroclaw-labs/zeroclaw>  
- **Config reference:** <https://github.com/zeroclaw-labs/zeroclaw/blob/master/docs/reference/api/config-reference.md>  
- **Schema source (v0.5.1):** <https://github.com/zeroclaw-labs/zeroclaw/blob/v0.5.1/src/config/schema.rs>  
