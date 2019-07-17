# frozen_string_literal: true

require 'test_helper'

class ClientTest < Minitest::Test
  context 'a Bitcoiner client' do
    setup do
      @bcd = Bitcoiner.new 'testuser', 'testpass'
    end

    should 'have a simple and useful inspect' do
      assert_equal(
        '#<Bitcoiner::Client "http://127.0.0.1:8332" testuser:testpass >',
        @bcd.inspect
      )
    end

    context 'balance operation' do
      setup do
        response = Typhoeus::Response.new(
          code: 200,
          body: "{\"result\":12.34000000,\"error\":null,\"id\":\"jsonrpc\"}\n"
        )
        Typhoeus.stub('http://127.0.0.1:8332', userpwd: "testuser:testpass").
          and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'get the balance' do
        @result = @bcd.balance
        assert_equal 12.34, @result
      end
    end

    context 'accounts operation' do
      setup do
        response = Typhoeus::Response.new(
          code: 200,
          body: "{\"result\":{\"\":0.0,\"Your Address\":0.0,\"pi\":3.14,\"ben\":100.00},\"error\":null,\"id\":\"jsonrpc\"}\n"
        )
        Typhoeus.stub('http://127.0.0.1:8332', userpwd: "testuser:testpass").
          and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'return a hash of Account objects' do
        @result = @bcd.accounts
        assert_kind_of Hash, @result
        @result.each do |k, a|
          assert_kind_of Bitcoiner::Account, a
          assert_equal k, a.name
        end

        assert_equal 'pi', @result['pi'].name
      end
    end

    context 'response is not successful' do
      setup do
        response = Typhoeus::Response.new(
          code: 500,
          return_code: :ok,
          # response supposedly includes body
          # https://github.com/bitcoin/bitcoin/issues/12673#issuecomment-372334718
          body: {some: "body"}.to_json,
        )
        Typhoeus.stub('http://127.0.0.1:8332', userpwd: "testuser:testpass").
          and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'raise JSONRPCError' do
        error = assert_raises(Bitcoiner::Client::JSONRPCError) do
          @bcd.request('listtransactions')
        end

        expected_error_message = [
          'code: `500`',
          'return_code: `ok`',
          'body: `{"some":"body"}`',
        ].join("; ")
        assert_equal expected_error_message, error.message
      end
    end

    context "batch calls" do
      setup do
        response = Typhoeus::Response.new(
          code: 200,
          body: [
            {"result"=>{""=>0.0, "Your Address"=>0.0, "pi"=>3.14, "ben"=>100.0}, "error"=>nil, "id"=>"jsonrpc"},
            {"result"=>{""=>0.0, "Your Address"=>0.0, "pi"=>3.14, "ben"=>100.1}, "error"=>nil, "id"=>"jsonrpc"}
          ].to_json
        )
        Typhoeus.stub('http://127.0.0.1:8332', userpwd: "testuser:testpass").
          and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'be able to execute a batch transaction' do
        @result = @bcd.request([["listaccounts", []],["listaccounts", []]])
        assert_kind_of Array, @result

        assert_equal @result.count, 2
        assert_equal @result[0]["result"]["ben"], 100.0
        assert_equal @result[1]["result"]["ben"], 100.1
      end
    end
  end

  should 'allow setting of host separately from credentials' do
    client = Bitcoiner::Client.new('username', 'password', 'host.com')
    assert_equal 'http://host.com', client.endpoint
    assert_equal "username", client.username
    assert_equal "password", client.password
  end

  should 'allow setting of uri scheme' do
    client = Bitcoiner::Client.new('username', 'password', 'https://host.com')
    assert_equal 'https://host.com', client.endpoint
  end

  should 'prioritize the credentials in the host and strips them' do
    client = Bitcoiner::Client.new('username', 'password', 'https://abc:123@host.com')
    assert_equal 'https://host.com', client.endpoint
    assert_equal 'abc', client.username
    assert_equal '123', client.password
  end

  should 'have a customisable logger' do
    logger = Logger.new(STDOUT)

    client = Bitcoiner::Client.new('username', 'password', 'http://a.c', {
      logger: logger,
    })

    assert_equal logger, client.logger
  end

  should 'logs requests if logger configured' do
    FileUtils.rm_rf "tmp"
    FileUtils.mkdir_p "tmp"
    logger = Logger.new("tmp/test.log")
    client = Bitcoiner::Client.new('username', 'password', 'http://a.c', {
      logger: logger,
    })

    client.request("listtransactions") rescue # don't care that it fails

    f = File.read("tmp/test.log")
    assert f.include?("listtransactions")
  end
end
