require "http/web_socket"
require "http/client"
require "json"

module Slack
  VERSION = "0.1.0"

  RTM_URL = "https://slack.com/api/rtm.connect?token=%s"

  class Local
    JSON.mapping(
      id: String,
      name: String,
    )
  end

  class Team
    JSON.mapping(
      domain: String,
      id: String,
      name: String,
    )
  end

  class ConnectSuccess
    JSON.mapping(
      ok: Bool,
      local: {type: Local, key: "self"},
      team: {type: Team},
      ws_url: {type: String, key: "url"},
    )
  end

  class ConnectFailure
    JSON.mapping(
      ok: Bool,
      error: String,
    )
  end

  class Rtm
    property id : Local?
    property team : Team?
    property ws_url : String?

    def initialize(@token : String)
    end

    def start
      HTTP::Client.get(URI.parse(RTM_URL % @token)) do |resp|
        if resp.success?
          cs = (ConnectSuccess|ConnectFailure).from_json(resp.body_io)
          if cs.is_a?(ConnectSuccess)
            @id = cs.local
            @team = cs.team
            @ws_url = cs.ws_url
          else
            raise cs.error
          end
        else 
          raise resp.status_message.not_nil!
        end
      end
      conn = HTTP::Websocket.new(URI.parse(@ws_url), HTTP::Headers{"Origin" => "https://api.slack.com"})

      conn.on_message(self.handle)
      conn.run
    end

    def handle(msg : String)
      pp msg
    end
  end
end
