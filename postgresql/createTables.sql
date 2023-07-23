CREATE SCHEMA IF NOT EXISTS chatstore AUTHORIZATION CURRENT_USER;

CREATE TABLE chatstore.system_prompt (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, prompt_name TEXT NOT NULL, system_prompt_text TEXT NOT NULL);
INSERT INTO  chatstore.system_prompt (prompt_name, system_prompt_text) VALUES ('default', 'Hello, I am a chatbot. I am here to help you with your questions. What would you like to know?');
CREATE TABLE chatstore.chat_user (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, name TEXT NOT NULL, default_prompt_id INTEGER NOT NULL REFERENCES chatstore.system_prompt(id) DEFAULT 1, input_tokens_total BIGINT NOT NULL, output_tokens_total BIGINT NOT NULL);
CREATE TABLE chatstore.conversation (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, chatuser_id INTEGER NOT NULL REFERENCES chatstore.chat_user(id), title TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,  last_active_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE chatstore.prompt_response (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, conversation_id INTEGER NOT NULL REFERENCES chatstore.conversation(id), order_num INTEGER NOT NULL,  prompt JSONB NOT NULL,  response JSONB);

ALTER TABLE chatstore.system_prompt OWNER TO chatstore;
ALTER TABLE chatstore.chat_user OWNER TO chatstore;
ALTER TABLE chatstore.conversation OWNER TO chatstore;
ALTER TABLE chatstore.prompt_response OWNER TO chatstore;

CREATE INDEX idx_chat_user_name ON chatstore.chat_user (name);
CREATE INDEX idx_conversation_chatuser_id ON chatstore.conversation (chatuser_id);
CREATE INDEX idx_prompt_response_conversation_id ON chatstore.prompt_response (conversation_id);

ALTER TABLE chatstore.chat_user ADD CONSTRAINT fk_chat_user_default_prompt_id FOREIGN KEY (default_prompt_id) REFERENCES chatstore.system_prompt(id);
ALTER TABLE chatstore.conversation ADD CONSTRAINT fk_conversation_chatuser_id FOREIGN KEY (chatuser_id) REFERENCES chatstore.chat_user(id);
ALTER TABLE chatstore.prompt_response ADD CONSTRAINT fk_prompt_response_conversation_id FOREIGN KEY (conversation_id) REFERENCES chatstore.conversation(id);