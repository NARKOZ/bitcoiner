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

    def request(method_or_array_of_methods, *args)
      if method_or_array_of_methods.is_a?(Array)
        post_body = method_or_array_of_methods.map do |m|
          {
            'method' => m[0],
            'params' => m[1],
            'id' => 'jsonrpc'
          }
        end
      else
        post_body = {
          'method' => method_or_array_of_methods,
          'params' => args,
          'id' => 'jsonrpc'
        }
      end

      response = Typhoeus.post(
        endpoint,
        userpwd: [username, password].join(":"),
        body: post_body.to_json,
      )

      parsed_response = parse_body(response)

      if parsed_response.is_a?(Hash)
        raise JSONRPCError, parsed_response['error'] if parsed_response['error']
        return parsed_response['result']
      end

      parsed_response
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
