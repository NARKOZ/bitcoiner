# frozen_string_literal: true

module Bitcoiner
  class Account
    attr_accessor :name

    def initialize(client, name)
      @client = client
      @name = name
    end

    def inspect
      "#<Bitcoiner::Account #{@name.inspect} >"
    end

    def send_to(destination, amount)
      txn_id = @client.request 'sendfrom', @name, destination, amount
      Transaction.new @clientm, self, txn_id
    end

    def balance(min_confirmations = 1)
      @balance ||= @client.request 'getbalance', @name, min_confirmations.to_i
    end

    def address
      @address ||= @client.request 'getaccountaddress', @name
    end

    def transactions
      txn_array = @client.request 'listtransactions', @name

      txn_array.map do |h|
        Transaction.new @client, self, h['txid']
      end
    end
  end
end
