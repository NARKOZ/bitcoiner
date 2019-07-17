# Bitcoiner [![Build Status](https://travis-ci.org/NARKOZ/bitcoiner.svg?branch=master)](https://travis-ci.org/NARKOZ/bitcoiner)

Automate your [Bitcoin](https://bitcoin.org/) transactions with this Ruby
interface to the `bitcoind` JSON-RPC API. This is a fork of
[bitcoind](https://github.com/bkerley/bitcoind) Ruby gem.

![Super Mario Coin](https://user-images.githubusercontent.com/253398/34371748-45c440f2-eae9-11e7-84ba-fddae754d59a.jpg)

## Installation

Install it from rubygems:

```
gem install bitcoiner
```

Or add to a Gemfile:

```ruby
gem 'bitcoiner'
# gem 'bitcoiner', github: 'NARKOZ/bitcoiner'
```

## Usage

### Connecting

Before connecting, you will need to configure a username and password for
`bitcoind`, and start `bitcoind`. Once that's done:

```ruby
client = Bitcoiner.new 'username', 'password' # REPLACE WITH YOUR bitcoin.conf rpcuser/rpcpassword
# => #<Bitcoiner::Client "http://username:password@127.0.0.1:8332" >
```

### Account Balances

You can get the balance of all addresses controlled by the client:

```ruby
client.balance
# => 12.34
```

You can also get a hash of all accounts the client controls:

```ruby
client.accounts
# => {"Your Address"=>#<Bitcoiner::Account "Your Address" >, "eve-online ransoms"=>#<Bitcoiner::Account "eve-online ransoms" >}
```

And of course each account has its own balance too:

```ruby
ransom = client.accounts['eve-online ransoms']
# => #<Bitcoiner::Account "eve-online ransoms" >

ransom.balance
# => 2.19
```

### Transactions

You can get all the transactions in an account:

```ruby
ransom.transactions
# => [#<Bitcoiner::Transaction abadbabe123deadbeef 2.19 to eve-online ransoms at 2011-02-19 16:21:09 -0500>]
```

You can send money from an account too:

```ruby
ransom.send_to 'destinationaddress', 2
# => #<Bitcoiner::Account deadbeef888abadbeef UNCONFIRMED>
```

### Making Accounts

Creating an account with an associated address is done through the accounts
interface:

```ruby
tiny_wings = client.accounts.new 'tiny wings ransoms'
# => #<Bitcoiner::Account "tiny wings ransoms" >

tiny_wings.address
# => "1KV5khnHbbHF2nNQkk7Pe5nPndEj43U27r"
```

### Logging

You may log requests (responses aren't logged) by setting a logger:

```
logger = Logger.new(STDOUT)
client = Bitcoiner::Client.new('username', 'password', 'http://a.c', {
  logger: logger,
})
```

## License

Released under the MIT license. See LICENSE.txt for details.
