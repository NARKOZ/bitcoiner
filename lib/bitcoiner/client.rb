# frozen_string_literal: true

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
      response_hash = parse_body(response)
      raise JSONRPCError, response_hash['error'] if response_hash['error']
      response_hash['result']
    end

    def inspect
      "#<Bitcoiner::Client #{@endpoint.inspect} >"
    end

    class JSONRPCError < RuntimeError; end

    private

    def parse_body(response)
      if response.success?
        JSON.parse(response.body)
      else
        error_message = [:code, :return_code].map do |attr|
          "#{attr}: `#{response.send(attr)}`"
        end.join(", ")
        fail JSONRPCError, "unsuccessful response; #{error_message}"
      end
    end

  end
end
