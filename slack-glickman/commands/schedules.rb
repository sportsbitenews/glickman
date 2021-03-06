module SlackGlickman
  module Commands
    class Schedules < SlackGlickman::Commands::BaseCommand

      SlackGlickman::App.instance.teamoji.each do |sportmoji|
        sport = sportmoji['sport']
        statmoji = sportmoji['emoji']

        sportmoji['teams'].each do |team|
          teamoji = team['emoji']['slack']

          command ":calendar: #{teamoji} #{statmoji}" do |client, data, _match|
            games = schedule(sport: sport,
                             status: 'upcoming',
                             team_id: team['slug'],
                             count: 5)

            games = games.map { |game| "#{game.name} in #{game.city}" }

            if games == []
              send_message client, data, ":calendar: No #{teamoji} #{statmoji} games today."
            else
              games = games.join("\n")
              send_message client, data, ":calendar: Upcoming #{teamoji} #{statmoji} games! \n #{games}"
            end
          end
        end
      end

      SlackGlickman::App::SPORTS.each do |sport|
        statmoji = SlackGlickman::App.instance.statmoji_for_sport(sport: sport)


        command ":calendar: :#{statmoji}:" do |client, data, _match|

          games = schedule(sport: sport, status: 'upcoming', on: 'today')
          games = games.map { |game| "#{game.name} in #{game.city}" }

          if games == []
            send_message client, data, ":calendar: No :#{statmoji}: games today."
          else
            games = games.join("\n")
            send_message client, data, ":calendar: Today's :#{statmoji}: games! \n #{games}"
          end
        end
      end

      def self.schedule(sport: 'basketball', status: 'upcoming', team_id: nil, on: nil, count: 5)
        query_params = const_get("Stattleship::Params::#{sport.capitalize}GamesParams").new
        query_params.status = status
        query_params.team_id = team_id
        query_params.on = on

        const_get("Stattleship::#{sport.capitalize}Games").
                  fetch(params: query_params).
                  last(count).
                  reverse
      end
    end
  end
end
