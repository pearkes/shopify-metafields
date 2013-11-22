Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
           ShopifyApp.configuration.api_key,
           ShopifyApp.configuration.secret,

           # Example permission scopes - see http://docs.shopify.com/api/tutorials/oauth for full listing
           :scope => 'write_products, read_orders, write_content, read_customers',

           :setup => lambda {|env|
                       params = Rack::Utils.parse_query(env['QUERY_STRING'])
                       site_url = "https://#{params['shop']}"
                       env['omniauth.strategy'].options[:client_options][:site] = site_url
                     }
end
