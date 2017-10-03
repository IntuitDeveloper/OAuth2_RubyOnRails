require 'uri'
require 'net/http'
require 'openssl'
require 'yaml'


class TokensController < ApplicationController
  def index
    uri = URI("https://appcenter.intuit.com/connect/oauth2?client_id=Q0fXL014zAv3wzmlhwXMEHTrKepfAshCRjztEu58ZokzCD5T7D&scope=com.intuit.quickbooks.accounting&redirect_uri=https%3A%2F%2Fwww.getpostman.com%2Foauth2%2Fcallback&response_type=code&state=randomState")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '33f90d00-17d8-f5b9-7af3-42bc56d64587'

    response = http.request(request)
    puts response.read_body
  end
end
