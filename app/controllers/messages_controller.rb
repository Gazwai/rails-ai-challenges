class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Teaching Assistant.\n\nI am a student at the Le Wagon AI Software Development Bootcamp, learning how to code.\n\nHelp me break down my problem into small, actionable steps, without giving away solutions.\n\nAnswer concisely in Markdown."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @challenge = @chat.challenge
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      # give the ruby_llm_chat the history of our conversation
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message

      # redirect_to chat_messages_path(@chat)
      # stay on the page, display the two new messages only
      # find the messages div
      # insert the last two messages into that
      # render create.turbo_stream.erb
      respond_to do |format|
        format.html { redirect_to chat_messages_path(@chat) }
        format.turbo_stream { render 'create' }
      end
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  # system prompt, challenge context + message i sent (send the chat history)
  def instructions
    challenge_context = "Here is the context of the challenge: #{@challenge.content}."
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
