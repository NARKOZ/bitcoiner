module Bitcoiner
  class Transaction
    attr_accessor :id, :account

    def initialize(client, account, id)
      @client = client
      @account = account
      @id = id
    end

    def detail_hash
      @detail_hash ||= @client.request 'gettransaction', @id
    end

    def inspect
      "#<Bitcoiner::Transaction #{id} #{amount} to #{account.name} at #{time}>"
    rescue
      "#<Bitcoiner::Transaction #{id} UNCONFIRMED>"
    end

    def amount
      detail_hash['amount']
    end

    def confirmations
      detail_hash['confirmations'] rescue 0
    end

    def time
      @time ||= Time.at detail_hash['time']
    end

    def confirmed?(min_confirmations = 6)
      confirmations > min_confirmations
    end
  end
end
