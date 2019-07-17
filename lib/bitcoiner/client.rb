# frozen_string_literal: true

module Bitcoiner
  class Client

    DEFAULT_ID = 'jsonrpc'.freeze
    LOG_PREFIX = "[bitcoiner]".freeze

    attr_accessor :endpoint, :username, :password, :logger

    def initialize(user, pass, host, logger: nil)
      uri = Addressable::URI.heuristic_parse(host)
      self.username = uri.user || user
      self.password = uri.password || pass
      uri.user = uri.password = nil

      self.endpoint = uri.to_s

      self.logger = logger
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
        log("#{method_or_array_of_methods}")
        batch_request(method_or_array_of_methods)
      else
        log("#{method_or_array_of_methods}; args: #{args.inspect}")
        single_request(method_or_array_of_methods, *args)
      end
    end

    def inspect
      "#<Bitcoiner::Client #{endpoint.inspect} #{username}:#{password} >"
    end

    class JSONRPCError < RuntimeError; end

    private

    def post(body)
      msg = {
        endpoint: endpoint,
        username: username,
        body: body.to_json,
      }.to_s
      log(msg)

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
        error_messages = %i[code return_code].each_with_object({}) do |attr, hash|
          hash[attr] = response.send(attr)
        end
        error_messages[:body] = response.body
        raise JSONRPCError, error_messages.map {|k, v| "#{k}: `#{v}`"}.join("; ")
      end
    end

    def log(msg)
      self.logger.info("#{LOG_PREFIX} #{msg}") if self.logger
    end
  end
end
