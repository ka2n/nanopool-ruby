require 'faraday'
require 'faraday_middleware'
require 'mustermann/expander'

module Nanopool

  ENDPOINTS = {
     avghashratelimited:       Mustermann::Expander.new('/v1/:currency/avghashratelimited/:address/:hours') << '/v1/:currency/avghashratelimited/:address/:worker/:hours',
     #avghashratelimited:       Mustermann::Expander.new('/v1/:currency/avghashratelimited/:address/:worker/:hours'),
     #avghashrate:              Mustermann::Expander.new('/v1/:currency/avghashrate/:address'),
     avghashrate:              Mustermann::Expander.new('/v1/:currency/avghashrate/:address/:worker?'),
     #hashratechart:            Mustermann::Expander.new('/v1/:currency/hashratechart/:address'),
     hashratechart:            Mustermann::Expander.new('/v1/:currency/hashratechart/:address/:worker?'),
     accountexist:             Mustermann::Expander.new('/v1/:currency/accountexist/:address'),
     hashrate:                 Mustermann::Expander.new('/v1/:currency/hashrate/:address'),
     user:                     Mustermann::Expander.new('/v1/:currency/user/:address'),
     #history:                  Mustermann::Expander.new('/v1/:currency/history/:address'),
     history:                  Mustermann::Expander.new('/v1/:currency/history/:address/:worker?'),
     balance_hashrate:         Mustermann::Expander.new('/v1/:currency/balance_hashrate/:address'),
     #reportedhashrate:         Mustermann::Expander.new('/v1/:currency/reportedhashrate/:address'),
     workers:                  Mustermann::Expander.new('/v1/:currency/workers/:address'),
     payments:                 Mustermann::Expander.new('/v1/:currency/payments/:address'),
     paymentsday:              Mustermann::Expander.new('/v1/:currency/paymentsday/:address'),
     #shareratehistory:         Mustermann::Expander.new('/v1/:currency/shareratehistory/:address'),
     avghashrateworkers:       Mustermann::Expander.new('/v1/:currency/avghashrateworkers/:address/:hours?'),
     #avghashrateworkers:       Mustermann::Expander.new('/v1/:currency/avghashrateworkers/:address'),
     reportedhashrates:        Mustermann::Expander.new('/v1/:currency/reportedhashrates/:address'),
     network_avgblocktime:     Mustermann::Expander.new('/v1/:currency/network/avgblocktime'),
     block_stats:              Mustermann::Expander.new('/v1/:currency/block_stats/:offset/:count'),
     blocks:                   Mustermann::Expander.new('/v1/:currency/blocks/:offset/:count'),
     network_lastblocknumber:  Mustermann::Expander.new('/v1/:currency/network/lastblocknumber'),
     network_timetonextepoch:  Mustermann::Expander.new('/v1/:currency/network/timetonextepoch'),
     approximated_earnings:    Mustermann::Expander.new('/v1/:currency/approximated_earnings/:hashrate'),
     prices:                   Mustermann::Expander.new('/v1/:currency/prices'),
     pool_activeminers:        Mustermann::Expander.new('/v1/:currency/pool/activeminers'),
     pool_activeworkers:       Mustermann::Expander.new('/v1/:currency/pool/activeworkers'),
     pool_hashrate:            Mustermann::Expander.new('/v1/:currency/pool/hashrate'),
     pool_sharecoef:           Mustermann::Expander.new('/v1/:currency/pool/sharecoef'),
     pool_topminers:           Mustermann::Expander.new('/v1/:currency/pool/topminers'),
     usersettings:             Mustermann::Expander.new('/v1/:currency/usersettings/:address'),
     balance:                  Mustermann::Expander.new('/v1/:currency/balance/:address'),
     reportedhashrate:         Mustermann::Expander.new('/v1/:currency/reportedhashrate/:address/:worker?'),
     shareratehistory:         Mustermann::Expander.new('/v1/:currency/shareratehistory/:address/:worker?'),
  }

  class Client
    def initialize(client: nil, default_params: {})
      @client = client || Faraday.new("https://api.nanopool.org/") do |conn|
        conn.response :json, parser_options: { symbolize_names: true }
        conn.adapter Faraday.default_adapter
      end
      @default_params = default_params || {}
    end

    def method_missing(name, *args, **kwargs)
      pattern = Nanopool::ENDPOINTS[name]
      unless pattern
        super
        return
      end
      Response.from_faraday_resp call_api(pattern, @default_params.merge(kwargs))
    end

    private

    def call_api(route, params)
      path = route.expand(params)
      @client.get path
    end

    class Response
      attr_reader :status, :result, :error, :rate_limit, :rate_limit_remaining

      def self.from_faraday_resp(resp)
        body = resp.body
        status = body&.dig(:status)
        error = body&.dig(:error)
        data = status ? body&.dig(:data) : nil

        limit = resp.headers&.dig("x-ratelimit-limit")&.to_i
        remaining = resp.headers&.dig("x-ratelimit-remaining")&.to_i

        new(status, data, limit, remaining, error)
      end

      def initialize(status, result, rate_limit = nil, rate_limit_remaining = nil, error = nil)
        @status = status
        @result = result
        @rate_limit = rate_limit
        @rate_limit_remaining = rate_limit_remaining
        @error = error
      end

      def ok?
        status
      end
    end
  end
end
