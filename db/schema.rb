# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_13_202411) do
  create_table "admin_data_fetch_tasks", force: :cascade do |t|
    t.integer "chat_id"
    t.string "target_type", null: false
    t.integer "target_id", null: false
    t.string "type", null: false
    t.string "status", null: false
    t.json "input_data"
    t.json "fetched_data"
    t.string "fetch_error_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_admin_data_fetch_tasks_on_chat_id"
    t.index ["target_type", "target_id"], name: "index_admin_data_fetch_tasks_on_target"
  end

  create_table "ai_chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ruby_llm_model_id"
    t.boolean "cancelled", default: false, null: false
    t.index ["ruby_llm_model_id"], name: "index_ai_chats_on_ruby_llm_model_id"
  end

  create_table "ai_messages", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.string "role"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cache_until_here", default: false, null: false
    t.string "finish_reason"
    t.json "citations"
    t.json "server_tool_calls"
    t.json "raw_content"
    t.json "raw_reasoning"
    t.string "cache_ttl"
    t.index ["chat_id"], name: "index_ai_messages_on_chat_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "fullname", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "birth_year"
    t.integer "death_year"
    t.json "aws_photos"
    t.string "original_fullname"
    t.datetime "synced_at"
    t.index ["fullname"], name: "index_authors_on_fullname", unique: true
  end

  create_table "book_authors", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["book_id", "author_id"], name: "index_book_authors_on_book_id_and_author_id", unique: true
    t.index ["book_id"], name: "index_book_authors_on_book_id"
  end

  create_table "book_collections", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_collections_on_book_id"
    t.index ["collection_id", "book_id"], name: "index_book_collections_on_collection_id_and_book_id", unique: true
  end

  create_table "book_genres", force: :cascade do |t|
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "genre_id"
    t.index ["book_id", "genre_id"], name: "index_book_genres_on_book_id_and_genre_id", unique: true
    t.index ["book_id"], name: "index_book_genres_on_book_id"
    t.index ["genre_id"], name: "index_book_genres_on_genre_id"
  end

  create_table "book_public_lists", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "public_list_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "public_list_id"], name: "index_book_public_lists_on_book_id_and_public_list_id", unique: true
    t.index ["book_id"], name: "index_book_public_lists_on_book_id"
    t.index ["public_list_id"], name: "index_book_public_lists_on_public_list_id"
  end

  create_table "book_series", force: :cascade do |t|
    t.integer "series_id", null: false
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "series_id"], name: "index_book_series_on_book_id_and_series_id", unique: true
    t.index ["book_id"], name: "index_book_series_on_book_id"
    t.index ["series_id"], name: "index_book_series_on_series_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.integer "year_published", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_title"
    t.integer "popularity", default: 0
    t.integer "wiki_popularity", default: 0
    t.string "literary_form"
    t.boolean "data_filled", default: false, null: false
    t.index ["data_filled"], name: "index_books_on_data_filled"
    t.index ["year_published"], name: "index_books_on_year_published"
  end

  create_table "cover_designs", force: :cascade do |t|
    t.string "name", null: false
    t.string "title_color", null: false
    t.string "title_font", null: false
    t.string "author_name_color", null: false
    t.string "author_name_font", null: false
    t.string "cover_image", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "descriptions", force: :cascade do |t|
    t.text "text", null: false
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.string "source_type"
    t.integer "source_id"
    t.string "source_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority", default: 0, null: false
    t.index ["owner_type", "owner_id", "priority"], name: "index_descriptions_on_owner_type_and_owner_id_and_priority"
    t.index ["source_type", "source_id"], name: "index_descriptions_on_source_type_and_source_id"
  end

  create_table "external_api_rate_limits", force: :cascade do |t|
    t.string "name", null: false
    t.float "min_interval_seconds", null: false
    t.datetime "last_requested_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_external_api_rate_limits_on_name", unique: true
  end

  create_table "external_identities", force: :cascade do |t|
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.integer "external_resource", null: false
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_link_id"
    t.index ["external_link_id"], name: "index_external_identities_on_external_link_id"
    t.index ["external_resource", "external_id"], name: "index_external_identities_on_external_resource_and_external_id", unique: true
    t.index ["owner_type", "owner_id"], name: "index_external_identities_on_owner_type_and_owner_id"
  end

  create_table "external_links", force: :cascade do |t|
    t.string "url", null: false
    t.string "locale"
    t.string "external_resource", null: false
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_external_links_on_owner_type_and_owner_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cover_design_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cover_design_id"], name: "index_genres_on_cover_design_id"
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "public_list_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_public_list_types_on_name", unique: true
  end

  create_table "public_lists", force: :cascade do |t|
    t.integer "public_list_type_id", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_list_type_id", "year"], name: "index_public_lists_on_public_list_type_id_and_year", unique: true
    t.index ["public_list_type_id"], name: "index_public_lists_on_public_list_type_id"
  end

  create_table "ruby_llm_batches", force: :cascade do |t|
    t.string "provider_batch_id", null: false
    t.string "provider", null: false
    t.string "status", null: false
    t.string "raw_status"
    t.boolean "completed", default: false, null: false
    t.string "chat_type"
    t.string "batch_protocol"
    t.json "chat_ids", default: []
    t.json "request_counts"
    t.json "reported_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "provider_batch_id"], name: "index_ruby_llm_batches_on_provider_and_provider_batch_id", unique: true
    t.index ["status"], name: "index_ruby_llm_batches_on_status"
  end

  create_table "ruby_llm_mcp_credentials", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_ruby_llm_mcp_credentials_on_key", unique: true
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_mcp_credentials_on_owner"
  end

  create_table "ruby_llm_models", force: :cascade do |t|
    t.string "model_id", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "family"
    t.datetime "model_created_at"
    t.integer "context_window"
    t.integer "max_output_tokens"
    t.date "knowledge_cutoff"
    t.json "modalities", default: {}
    t.json "capabilities", default: []
    t.json "pricing", default: {}
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "unlisted_at"
    t.index ["family"], name: "index_ruby_llm_models_on_family"
    t.index ["provider", "model_id"], name: "index_ruby_llm_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_ruby_llm_models_on_provider"
  end

  create_table "ruby_llm_provider_files", force: :cascade do |t|
    t.string "blob_key", null: false
    t.string "provider", null: false
    t.string "account", null: false
    t.text "file_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_key", "provider", "account"], name: "index_ruby_llm_provider_files_uniqueness", unique: true
  end

  create_table "ruby_llm_tool_calls", force: :cascade do |t|
    t.integer "message_id", null: false
    t.string "tool_call_id"
    t.string "name"
    t.text "arguments", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_type", null: false
    t.string "result_type"
    t.integer "result_id"
    t.text "thought_signature"
    t.string "approval"
    t.boolean "remote", default: false, null: false
    t.json "mcp_state"
    t.json "mcp_result"
    t.index ["message_type", "message_id"], name: "index_ruby_llm_tool_calls_on_message_type_and_message_id"
    t.index ["name"], name: "index_ruby_llm_tool_calls_on_name"
    t.index ["result_type", "result_id"], name: "index_ruby_llm_tool_calls_on_result_type_and_result_id"
    t.index ["tool_call_id"], name: "index_ruby_llm_tool_calls_on_tool_call_id", unique: true
  end

  create_table "ruby_llm_usages", force: :cascade do |t|
    t.string "chat_type"
    t.integer "chat_id"
    t.string "message_type"
    t.integer "message_id"
    t.string "operation", null: false
    t.string "provider", null: false
    t.string "model", null: false
    t.string "status", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "cache_read_tokens"
    t.integer "cache_write_tokens"
    t.integer "thinking_tokens"
    t.decimal "input_cost", precision: 16, scale: 10
    t.decimal "output_cost", precision: 16, scale: 10
    t.decimal "cache_read_cost", precision: 16, scale: 10
    t.decimal "cache_write_cost", precision: 16, scale: 10
    t.decimal "thinking_cost", precision: 16, scale: 10
    t.decimal "total_cost", precision: 16, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "server_tool_use"
    t.string "owner_type"
    t.bigint "owner_id"
    t.index ["chat_type", "chat_id"], name: "index_ruby_llm_usages_on_chat_type_and_chat_id"
    t.index ["message_type", "message_id"], name: "index_ruby_llm_usages_on_message_type_and_message_id"
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_usages_on_owner"
    t.index ["status"], name: "index_ruby_llm_usages_on_status"
    t.check_constraint "operation IN ('chat', 'embedding', 'moderation', 'image', 'speech', 'transcription', 'ocr', 'rerank', 'judgment', 'video', 'research')"
    t.check_constraint "status IN ('pending', 'succeeded', 'failed', 'cancelled')"
  end

  create_table "series", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_series_on_name"
  end

  create_table "tag_connections", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "entity_id", null: false
    t.string "entity_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id", "tag_id"], name: "index_tag_connections_on_entity_type_and_entity_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_tag_connections_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0
    t.index ["category"], name: "index_tags_on_category"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_book_reads", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_user_book_reads_on_book_id"
    t.index ["user_id", "book_id"], name: "index_user_book_reads_on_user_id_and_book_id", unique: true
  end

  create_table "user_pins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "entity_type", null: false
    t.integer "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_user_pins_on_entity_type_and_entity_id"
    t.index ["user_id", "entity_type", "entity_id"], name: "index_user_pins_on_user_id_and_entity_type_and_entity_id", unique: true
  end

  create_table "user_pins_sharings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_user_pins_sharings_on_code", unique: true
    t.index ["user_id"], name: "index_user_pins_sharings_on_user_id", unique: true
  end

  create_table "user_reads_sharings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_user_reads_sharings_on_code", unique: true
    t.index ["user_id"], name: "index_user_reads_sharings_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wiki_links", force: :cascade do |t|
    t.string "entity_type", null: false
    t.integer "entity_id", null: false
    t.string "locale", null: false
    t.string "name", null: false
    t.integer "views"
    t.integer "views_last_month"
    t.datetime "views_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["entity_type", "entity_id"], name: "index_wiki_page_stats_on_entity"
  end

  create_table "wikidata_lookup_entities", force: :cascade do |t|
    t.string "qid", null: false
    t.string "label"
    t.string "description"
    t.datetime "fetched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qid"], name: "index_wikidata_lookup_entities_on_qid", unique: true
  end

  add_foreign_key "admin_data_fetch_tasks", "ai_chats", column: "chat_id"
  add_foreign_key "ai_chats", "ruby_llm_models"
  add_foreign_key "ai_messages", "ai_chats", column: "chat_id"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_collections", "books"
  add_foreign_key "book_collections", "books", column: "collection_id"
  add_foreign_key "book_genres", "books"
  add_foreign_key "book_genres", "genres"
  add_foreign_key "book_public_lists", "books"
  add_foreign_key "book_public_lists", "public_lists"
  add_foreign_key "book_series", "books"
  add_foreign_key "book_series", "series"
  add_foreign_key "external_identities", "external_links", on_delete: :nullify
  add_foreign_key "genres", "cover_designs"
  add_foreign_key "public_lists", "public_list_types"
  add_foreign_key "user_book_reads", "books"
  add_foreign_key "user_book_reads", "users"
  add_foreign_key "user_pins", "users"
  add_foreign_key "user_pins_sharings", "users"
  add_foreign_key "user_reads_sharings", "users"
end
