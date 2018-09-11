# frozen_string_literal: true

module Bitcoiner
  class Client
    attr_accessor :endpoint, :username, :password

    def initialize(user, pass, host)
      uri = Addressable::URI.heuristic_parse(host)
      self.username = uri.user || user
      self.password = uri.password || pass
      uri.user = uri.password = nil

      self.endpoint = uri.to_s
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
      response = Typhoeus.post(
        endpoint,
        userpwd: [username, password].join(":"),
        body: post_body,
      )
      response_hash = parse_body(response)
      raise JSONRPCError, response_hash['error'] if response_hash['error']
      response_hash['result']
    end

    def inspect
      "#<Bitcoiner::Client #{endpoint.inspect} #{username}:#{password} >"
    end

    class JSONRPCError < RuntimeError; end

    private

    def parse_body(response)
      if response.success?
        JSON.parse(response.body)
      else
        error_message = %i[code return_code].map do |attr|
          "#{attr}: `#{response.send(attr)}`"
        end.join(', ')
        raise JSONRPCError, "unsuccessful response; #{error_message}"
      end
    end
  end
end
