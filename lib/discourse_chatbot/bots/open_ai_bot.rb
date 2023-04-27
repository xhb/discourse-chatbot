# frozen_string_literal: true
require "openai"
require "json"

module ::DiscourseChatbot

  class OpenAIBot < Bot

    def initialize
      @client = ::OpenAI::Client.new(
        access_token: SiteSetting.chatbot_open_ai_token, 
        uri_base: SiteSetting.chatbot_open_ai_uri_base,
        request_timeout: SiteSetting.chatbot_open_ai_request_timeout
      )
    end

    def get_response(prompt)
      if SiteSetting.chatbot_open_ai_model == "gpt-3.5-turbo"
        response = @client.chat(
          parameters: {
              model: "gpt-3.5-turbo",
              messages: prompt,
              max_tokens: SiteSetting.chatbot_max_response_tokens,
              temperature: SiteSetting.chatbot_request_temperature / 100.0,
              top_p: SiteSetting.chatbot_request_top_p / 100.0,
              frequency_penalty: SiteSetting.chatbot_request_frequency_penalty / 100.0,
              presence_penalty: SiteSetting.chatbot_request_presence_penalty / 100.0
          })

        if response.parsed_response["error"]
          begin
            raise StandardError, response.parsed_response["error"]["message"]
          rescue => e
            Rails.logger.error ("OpenAIBot: There was a problem: #{e}")
            I18n.t('chatbot.errors.general')
          end
        else
          hash_res = JSON.parse(response.body)
          hash_res.dig("choices", 0, "message", "content")
        end
      else
        response = @client.completions(
          parameters: {
              model: SiteSetting.chatbot_open_ai_model,
              prompt: prompt,
              max_tokens: SiteSetting.chatbot_max_response_tokens,
              temperature: SiteSetting.chatbot_request_temperature / 100.0,
              top_p: SiteSetting.chatbot_request_top_p / 100.0,
              frequency_penalty: SiteSetting.chatbot_request_frequency_penalty / 100.0,
              presence_penalty: SiteSetting.chatbot_request_presence_penalty / 100.0
          })

        if response.parsed_response["error"]
          begin
            raise StandardError, response.parsed_response["error"]["message"]
          rescue => e
            Rails.logger.error ("OpenAIBot: There was a problem: #{e}")
            I18n.t('chatbot.errors.general')
          end
        else
          hash_res = JSON.parse(response.body)
          hash_res.dig("choices", 0, "text")
        end
      end
    end

    def ask(opts)
      super(opts)
    end
  end
end
