module Bitcoiner
  class Client
    def initialize(user, pass, host = '127.0.0.1:8332')
      @endpoint = "http://#{user}:#{pass}@#{host}"
    end

    def balance
      request 'getbalance'
    end

    def accounts
      balance_hash = request 'listaccounts'
      AccountHash.new self, balance_hash
    end

    def request(method, *args)
      post_body = { 'method' => method, 'params' => args, 'id' => 'jsonrpc' }.to_json
      response = Typhoeus.post(@endpoint, body: post_body)
      response_hash = JSON.parse response.body
      raise JSONRPCError, response_hash['error'] if response_hash['error']
      response_hash['result']
    end

    def inspect
      "#<Bitcoiner::Client #{@endpoint.inspect} >"
    end

    class JSONRPCError < RuntimeError; end
  end
end
