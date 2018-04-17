# frozen_string_literal: true

require 'bitcoiner/version'
require 'typhoeus'
require 'json'
require 'addressable'

%w[client account account_hash transaction].each do |f|
  require File.join(File.dirname(__FILE__), 'bitcoiner', f)
end

module Bitcoiner
  def self.new(user, pass, host = '127.0.0.1:8332')
    Client.new user, pass, host
  end
end
