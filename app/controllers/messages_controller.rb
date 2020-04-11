class MessagesController < ApplicationController
    def create
        message = Message.new(message_params)
        message.origin = 'app'
        conversation = Conversation.find(message_params[:conversation_id])
        if message.save

          PlivoClient.new.send_text(conversation.phone,message.text)

          serialized_data = ActiveModelSerializers::Adapter::Json.new(
            MessageSerializer.new(message)
          ).serializable_hash
          MessagesChannel.broadcast_to conversation, serialized_data

          

          head :ok
        end
      end
      
      private
      
      def message_params
        params.require(:message).permit(:text, :conversation_id)
      end
end
