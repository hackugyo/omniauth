require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to TSina via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::TSina, 'APIKey', 'APIKeySecret'
    #
    class Tsina < OmniAuth::Strategies::OAuth
      
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        @api_key = consumer_key
        
        client_options = {
          :site               => 'http://api.t.sina.com.cn',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authorize',
          :realm              => 'OmniAuth'
        }

        super(app, :tsina, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      
      def user_info
        user_hash = self.user_hash
        {
          'username' => user_hash['screen_name'],
          'name' => user_hash['name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {
            'Tsina' => user_hash['url']
          }
        }
      end

      def user_hash
        # http://api.t.sina.com.cn/users/show/:id.json?source=appkey
        # @access_token.params[:user_id] is the UID
        # @api_key is the appkey
        uid = @access_token.params[:user_id]
        @user_hash ||= MultiJson.decode(@access_token.get("http://api.t.sina.com.cn/users/show/#{uid}.json?source=#{@api_key}").body)
      end
    end
  end
end
