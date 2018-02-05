# frozen_string_literal: true

require 'test_helper'

class AccountTest < Minitest::Test
  context 'an Account' do
    setup do
      @client = stub
      @acc = Bitcoiner::Account.new @client, 'pi'
    end

    should 'have name' do
      assert_equal 'pi', @acc.name
    end

    should 'have a short but useful inspect' do
      assert_equal '#<Bitcoiner::Account "pi" >', @acc.inspect
    end

    should 'ask the client for a balance' do
      @client.expects(:request)
             .once
             .with('getbalance', 'pi', 1)
             .returns(3.14)

      @balance = @acc.balance

      assert_equal 3.14, @balance
    end

    should 'ask the client for an address' do
      @client.expects(:request)
             .once
             .with('getaccountaddress', 'pi')
             .returns('testaddress')

      @address = @acc.address

      assert_equal 'testaddress', @address
    end

    should 'have a list of transactions' do
      @client.expects(:request)
             .once
             .with('listtransactions', 'pi')
             .returns [
               {
                 'account' => 'pi',
                 'address' => 'testaddress',
                 'category' => 'receive',
                 'amount' => 3.10,
                 'confirmations' => 310,
                 'txid' => '310',
                 'time' => 1_234_567_310
               },
               {
                 'account' => 'pi',
                 'address' => 'testaddress',
                 'category' => 'receive',
                 'amount' => 3.11,
                 'confirmations' => 311,
                 'txid' => '311',
                 'time' => 1_234_567_311
               },
               {
                 'account' => 'pi',
                 'address' => 'testaddress',
                 'category' => 'receive',
                 'amount' => 3.12,
                 'confirmations' => 312,
                 'txid' => '312',
                 'time' => 1_234_567_312
               }
             ]

      @txns = @acc.transactions

      @txns.each do |t|
        assert_kind_of Bitcoiner::Transaction, t
      end
      assert_equal %w[310 311 312], @txns.map(&:id)
    end

    context 'transactions' do
      should 'send money' do
        @client.expects(:request)
               .once
               .with('sendfrom', @acc.name, 'testdestinationaddress', 5)
               .returns('sentmoneytransactionid')

        @txn = @acc.send_to('testdestinationaddress', 5)

        assert_equal 'sentmoneytransactionid', @txn.id
      end
    end
  end
end
