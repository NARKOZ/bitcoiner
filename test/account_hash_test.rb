# frozen_string_literal: true

require 'test_helper'

class AccountHashTest < Minitest::Test
  context 'an AccountHash' do
    setup do
      @client = stub
      @ach = Bitcoiner::AccountHash.new @client, '' => 0.0, 'pi' => 3.14, 'john' => 100.0
    end

    should 'access accounts like a normal hash' do
      assert_equal 'pi', @ach['pi'].name
      assert_equal 'john', @ach['john'].name
    end

    context 'new method' do
      should 'make a new account with a given name' do
        @client.expects(:request)
               .once
               .with('getnewaddress', 'new test account')
               .returns('xxxnewtestaddress')

        @act = @ach.new 'new test account'
        assert_equal 'new test account', @act.name
      end
    end
  end
end
