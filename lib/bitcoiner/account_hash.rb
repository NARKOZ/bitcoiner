module Bitcoiner
  class AccountHash < Hash
    def initialize(client, balance_hash)
      @client = client
      balance_hash.each_key do |name|
        self[name] = Account.new client, name
      end
    end

    def new(name)
      @client.request 'getnewaddress', name
      self[name] = Account.new @client, name
      self[name]
    end
  end
end
