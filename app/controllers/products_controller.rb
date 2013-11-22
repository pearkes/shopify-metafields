class ProductsController < ApplicationController
  around_filter :shopify_session

  def index
    # get 10 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 100})
  end

  def show
    @product = ShopifyAPI::Product.find(params[:id])
  end
end
