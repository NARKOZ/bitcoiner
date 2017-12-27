require 'bitcoiner/version'
require 'typhoeus'
require 'json'

%w[client account account_hash transaction].each do |f|
  require File.join(File.dirname(__FILE__), 'bitcoiner', f)
end

module Bitcoiner
  def self.new(user, pass)
    Client.new user, pass
  end
end
