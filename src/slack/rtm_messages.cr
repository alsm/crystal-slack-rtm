module Slack
  class Event
    def initialise(@type)
    end
  end

  class Message
    @subtype : String?
    def initialise(@ts, @user, @text, @channel)
    end
  end
end