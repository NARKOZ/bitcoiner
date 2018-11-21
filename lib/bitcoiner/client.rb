# frozen_string_literal: true

module Bitcoiner
  class Client

    DEFAULT_ID = 'jsonrpc'.freeze

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

    def request(method_or_array_of_methods, *args)
      if method_or_array_of_methods.is_a?(Array)
        batch_request(method_or_array_of_methods)
      else
        single_request(method_or_array_of_methods, *args)
      end
    end

    def inspect
      "#<Bitcoiner::Client #{endpoint.inspect} #{username}:#{password} >"
    end

    class JSONRPCError < RuntimeError; end

    private

    def post(body)
      Typhoeus.post(
        endpoint,
        userpwd: [username, password].join(":"),
        body: body.to_json,
      )
    end

    def batch_request(methods_and_args)
      post_body = methods_and_args.map do |method, args|
        { 'method' => method, 'params' => args, 'id' => DEFAULT_ID }
      end
      response = post(post_body)
      parse_body(response)
    end

    def single_request(method, *args)
      post_body = { 'method' => method, 'params' => args, 'id' => DEFAULT_ID }
      response = post(post_body)
      parsed_response = parse_body(response)

      raise JSONRPCError, parsed_response['error'] if parsed_response['error']

      parsed_response['result']
    end

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
