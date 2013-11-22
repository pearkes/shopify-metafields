class HomeController < ApplicationController

  around_filter :shopify_session, :except => 'welcome'

  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end

  def index
    # get 10 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 100})
  end

end
