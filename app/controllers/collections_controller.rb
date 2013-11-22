class CollectionsController < ApplicationController
  around_filter :shopify_session

  def index
    # get 10 products
    @collections = ShopifyAPI::CustomCollection.find(:all, :params => {:limit => 10})
  end

  def show
    @collection = ShopifyAPI::CustomCollection.find(params[:id])
  end
end
