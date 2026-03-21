{ lib, ... }:
{
  options = {
    memory = lib.mkOption {
      type = lib.types.submodule {
        options = {
          archive_after_days = lib.mkOption {
            type = lib.types.int;
            default = 7;
            description = "Archive daily/session files older than this many days";
          };
          auto_hydrate = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Auto-hydrate from MEMORY_SNAPSHOT.md when brain.db is missing";
          };
          auto_save = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Auto-save user-stated conversation input to memory (assistant output is excluded)";
          };
          backend = lib.mkOption {
            type = lib.types.enum [
              "sqlite"
              "lucid"
              "postgres"
              "qdrant"
              "markdown"
              "none"
            ];
            default = "sqlite";
            description = "Хранилище памяти: `sqlite` | `lucid` | `postgres` | `qdrant` | `markdown` | `none`.\n`postgres` — нужен `db_url` в `[storage.provider.config]`; `qdrant` — `[memory.qdrant]` / `QDRANT_URL`.";
          };
          chunk_max_tokens = lib.mkOption {
            type = lib.types.int;
            default = 512;
            description = "Max tokens per chunk for document splitting";
          };
          conversation_retention_days = lib.mkOption {
            type = lib.types.int;
            default = 30;
            description = "For sqlite backend: prune conversation rows older than this many days";
          };
          embedding_cache_size = lib.mkOption {
            type = lib.types.int;
            default = 10000;
            description = "Max embedding cache entries before LRU eviction";
          };
          embedding_dimensions = lib.mkOption {
            type = lib.types.int;
            default = 1536;
            description = "Embedding vector dimensions";
          };
          embedding_model = lib.mkOption {
            type = lib.types.str;
            default = "text-embedding-3-small";
            description = "Embedding model name (e.g. \"text-embedding-3-small\")";
          };
          embedding_provider = lib.mkOption {
            type = lib.types.oneOf [
              (lib.types.enum [
                "none"
                "openai"
              ])
              (lib.types.strMatching "custom:.*")
            ];
            default = "none";
            description = "Embedding provider: `none`, `openai` или `custom:<URL>`.";
          };
          hygiene_enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Run memory/session hygiene (archiving + retention cleanup)";
          };
          keyword_weight = lib.mkOption {
            type = lib.types.float;
            default = 0.3;
            description = "Weight for keyword BM25 in hybrid search (0.0\u20131.0)";
          };
          min_relevance_score = lib.mkOption {
            type = lib.types.float;
            default = 0.4;
            description = "Minimum hybrid score (0.0\u20131.0) for a memory to be included in context.\nMemories scoring below this threshold are dropped to prevent irrelevant\ncontext from bleeding into conversations. Default: 0.4";
          };
          purge_after_days = lib.mkOption {
            type = lib.types.int;
            default = 30;
            description = "Purge archived files older than this many days";
          };
          qdrant = lib.mkOption {
            type = lib.types.submodule {
              options = {
                api_key = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "Optional API key for Qdrant Cloud or secured instances.\nFalls back to `QDRANT_API_KEY` env var if not set.";
                };
                collection = lib.mkOption {
                  type = lib.types.str;
                  default = "zeroclaw_memories";
                  description = "Qdrant collection name for storing memories.\nFalls back to `QDRANT_COLLECTION` env var, or default \"zeroclaw_memories\".";
                };
                url = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "Qdrant server URL (e.g. \"http://localhost:6333\").\nFalls back to `QDRANT_URL` env var if not set.";
                };
              };
            };
            default = {
              collection = "zeroclaw_memories";
            };
            description = "Memory backend configuration (`[memory]` section).\n\nControls conversation memory storage, embeddings, hybrid search, response caching,\nand memory snapshot/hydration.\nConfiguration for Qdrant vector database backend (`[memory.qdrant]`).\nUsed when `[memory].backend = \"qdrant\"`.";
          };
          response_cache_enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable LLM response caching to avoid paying for duplicate prompts";
          };
          response_cache_hot_entries = lib.mkOption {
            type = lib.types.int;
            default = 256;
            description = "Max in-memory hot cache entries for the two-tier response cache (default: 256)";
          };
          response_cache_max_entries = lib.mkOption {
            type = lib.types.int;
            default = 5000;
            description = "Max number of cached responses before LRU eviction (default: 5000)";
          };
          response_cache_ttl_minutes = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "TTL in minutes for cached responses (default: 60)";
          };
          snapshot_enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable periodic export of core memories to MEMORY_SNAPSHOT.md";
          };
          snapshot_on_hygiene = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Run snapshot during hygiene passes (heartbeat-driven)";
          };
          sqlite_open_timeout_secs = lib.mkOption {
            type = lib.types.nullOr (lib.types.int);
            default = null;
            description = "For sqlite backend: max seconds to wait when opening the DB (e.g. file locked).\nNone = wait indefinitely (default). Recommended max: 300.";
          };
          vector_weight = lib.mkOption {
            type = lib.types.float;
            default = 0.7;
            description = "Weight for vector similarity in hybrid search (0.0\u20131.0)";
          };
        };
      };
      default = {
        archive_after_days = 7;
        auto_hydrate = true;
        auto_save = true;
        backend = "sqlite";
        chunk_max_tokens = 512;
        conversation_retention_days = 30;
        embedding_cache_size = 10000;
        embedding_dimensions = 1536;
        embedding_model = "text-embedding-3-small";
        embedding_provider = "none";
        hygiene_enabled = true;
        keyword_weight = 0.3;
        min_relevance_score = 0.4;
        purge_after_days = 30;
        qdrant = {
          collection = "zeroclaw_memories";
        };
        response_cache_enabled = false;
        response_cache_hot_entries = 256;
        response_cache_max_entries = 5000;
        response_cache_ttl_minutes = 60;
        snapshot_enabled = false;
        snapshot_on_hygiene = false;
        vector_weight = 0.7;
      };
    };
  };
}
