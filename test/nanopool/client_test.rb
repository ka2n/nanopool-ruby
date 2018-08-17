require 'test_helper'
require 'faraday'

class Nanopool::ClientTest < Minitest::Test
  def test_client
    http_client = Faraday.new do |env|
      env.response :json, parser_options: { symbolize_names: true }
      env.adapter :test, client_stub
    end

    currency = 'eth'
    #addr = 'e2fbd83ce39a7f16ae16df312d4f1c49ba9e336a'

    client = ::Nanopool::Client.new(client: http_client, default_params: { currency: currency })
    resp = client.network_avgblocktime

    assert resp.status
    assert resp.result
    assert !resp.error
    assert resp.rate_limit
    assert resp.rate_limit_remaining
  end

  private

  def client_stub
    Faraday::Adapter::Test::Stubs.new do |stub|
      endpoints = {
        avghashratelimited:            %r{/v1/(?<currency>[^/]+)/avghashratelimited/(?<address>[^/]+)/(?<hours>[^/]+)},
        avghashrate:                   %r{/v1/(?<currency>[^/]+)/avghashrate/(?<address>[^/]+)},
        hashratechart:                  %r{/v1/(?<currency>[^/]+)/hashratechart/(?<address>[^/]+)},
        accountexist:                   %r{/v1/(?<currency>[^/]+)/accountexist/(?<address>[^/]+)},
        hashrate:                 %r{/v1/(?<currency>[^/]+)/hashrate/(?<address>[^/]+)},
        user:                     %r{/v1/(?<currency>[^/]+)/user/(?<address>[^/]+)},
        history:                   %r{/v1/(?<currency>[^/]+)/history/(?<address>[^/]+)},
        balance_hashrate:                              %r{/v1/(?<currency>[^/]+)/balance_hashrate/(?<address>[^/]+)},
        reportedhashrate:                              %r{/v1/(?<currency>[^/]+)/reportedhashrate/(?<address>[^/]+)},
        workers:                                       %r{/v1/(?<currency>[^/]+)/workers/(?<address>[^/]+)},
        payments:                                       %r{/v1/(?<currency>[^/]+)/payments/(?<address>[^/]+)},
        paymentsday:                   %r{/v1/(?<currency>[^/]+)/paymentsday/(?<address>[^/]+)},
        shareratehistory:              %r{/v1/(?<currency>[^/]+)/shareratehistory/(?<address>[^/]+)},
        avghashrateworkers_hours:            %r{/v1/(?<currency>[^/]+)/avghashrateworkers/(?<address>[^/]+)/(?<hours>[^/]+)},
        avghashrateworkers:            %r{/v1/(?<currency>[^/]+)/avghashrateworkers/(?<address>[^/]+)},
        reportedhashrates:             %r{/v1/(?<currency>[^/]+)/reportedhashrates/(?<address>[^/]+)},
        network_avgblocktime:          %r{/v1/(?<currency>[^/]+)/network/avgblocktime},
        block_stats:                   %r{/v1/(?<currency>[^/]+)/block_stats/(?<offset>[^/]+)/(?<count>[^/]+)},
        blocks:                        %r{/v1/(?<currency>[^/]+)/blocks/(?<offset>[^/]+)/(?<count>[^/]+)},
        network_lastblocknumber:       %r{/v1/(?<currency>[^/]+)/network/lastblocknumber},
        network_timetonextepoch:       %r{/v1/(?<currency>[^/]+)/network/timetonextepoch},
        approximated_earnings:         %r{/v1/(?<currency>[^/]+)/approximated_earnings/(?<hashrate>[^/]+)},
        prices:                        %r{/v1/(?<currency>[^/]+)/prices},
        pool_activeminers:        %r{/v1/(?<currency>[^/]+)/pool/activeminers},
        pool_activeworkers:       %r{/v1/(?<currency>[^/]+)/pool/activeworkers},
        pool_hashrate:            %r{/v1/(?<currency>[^/]+)/pool/hashrate},
        pool_sharecoef:           %r{/v1/(?<currency>[^/]+)/pool/sharecoef},
        pool_topminers:                %r{/v1/(?<currency>[^/]+)/pool/topminers},
        usersettings:           %r{/v1/(?<currency>[^/]+)/usersettings/(?<address>[^/]+)},
        avghashratelimited_worker:          %r{/v1/(?<currency>[^/]+)/avghashratelimited/(?<address>[^/]+)/(?<worker>[^/]+)/(?<hours>[^/]+)},
        avghashrate_worker:           %r{/v1/(?<currency>[^/]+)/avghashrate/(?<address>[^/]+)/(?<worker>[^/]+)},
        hashratechart_worker:           %r{/v1/(?<currency>[^/]+)/hashratechart/(?<address>[^/]+)/(?<worker>[^/]+)},
        balance:                  %r{/v1/(?<currency>[^/]+)/balance/(?<address>[^/]+)},
        history_worker:                %r{/v1/(?<currency>[^/]+)/history/(?<address>[^/]+)/(?<worker>[^/]+)},
        reportedhashrate_worker:              %r{/v1/(?<currency>[^/]+)/reportedhashrate/(?<address>[^/]+)/(?<worker>[^/]+)},
        shareratehistory_worker:              %r{/v1/(?<currency>[^/]+)/shareratehistory/(?<address>[^/]+)/(?<worker>[^/]+)}
      }

      endpoints.each do |key, endpoint|
        limit = 180
        limit_remain = 180
        stub.get(endpoint) do |_env|
          limit_remain -= 1
          headers = {
            'Content-Type' => 'application/json',
            'x-ratelimit-limit' => limit,
            'x-ratelimit-remaining' => limit_remain
          }

          begin
            body = open(File.join(__dir__, "../data/#{key}.json")).read
          rescue Errno::ENOENT
            body = { status: false, data: "API endpoint not found" }
          end

          [200, headers, body]
        end
      end
    end
  end
end
