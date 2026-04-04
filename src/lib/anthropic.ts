import Anthropic from "@anthropic-ai/sdk";

const apiKey = process.env.ANTHROPIC_API_KEY;

let _client: Anthropic | null = null;

export function getAnthropicClient(): Anthropic {
  if (!apiKey) {
    throw new Error(
      "ANTHROPIC_API_KEY is not set. Add it to your .env file."
    );
  }
  if (!_client) {
    _client = new Anthropic({ apiKey });
  }
  return _client;
}
