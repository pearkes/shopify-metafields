class MetafieldsController < ApplicationController
  around_filter :shopify_session
  def new
    @metafield = Metafield.new
  end

  def create
    metafield = ShopifyAPI::Metafield.new(params[:metafield])
    metafield.namespace = metafield.namespace.parameterize

    if metafield.save
      flash[:success] = 'Successfully created metafield.'
      redirect_to params[:redirect_to]
    else
      flash[:danger] = 'Your metafield could not be saved.'
      redirect_to params[:redirect_to]
    end
  end

  def edit
    @metafield = ShopifyAPI::Metafield.find(params[:id])
  end

  def update
    @metafield = ShopifyAPI::Metafield.find(params[:id]).load(params[:shopify_api_metafield])
    @metafield.namespace = @metafield.namespace.parameterize
    if @metafield.save
      flash[:success] = 'Successfully updated metafield.'
      redirect_to params[:redirect_to]
    else
      flash[:danger] = "Your metafield could not be saved: #{@metafield.errors.first}"
      render :action => 'edit'
    end
  end

  def show
    redirect_to edit_metafield_path(:id => params[:id])
  end

  def destroy
    metafield = ShopifyAPI::Metafield.find(params[:id])
    metafield.destroy
    flash[:success] = 'Successfully deleted metafield.'
    redirect_to params[:redirect_to]
  end
end
