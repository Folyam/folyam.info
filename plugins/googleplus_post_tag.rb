# A Liquid tag for Jekyll sites that allows embedding Gists and showing code for non-JavaScript enabled browsers and readers.
# by: Brandon Tilly
# Source URL: https://gist.github.com/1027674
# Post http://brandontilley.com/2011/01/31/gist-tag-for-jekyll.html
#
# Example usage: {% gist 1027674 gist_tag.rb %} //embeds a gist for this plugin

require 'cgi'
require 'digest/md5'
require 'net/https'
require 'uri'
require 'json'

module Jekyll
  class GooglePLusPostTag < Liquid::Tag
    def initialize(tag_name, text, token)
      super
      @text           = text
      @cache_folder   = File.expand_path "../.gplus-cache", File.dirname(__FILE__)
      FileUtils.mkdir_p @cache_folder

      @cache_disabled = false
    end

    def render(context)
      if parts = @text.match(/([\d]*) (.*)/)
        page_id = parts[1].strip
        post_id = parts[2].strip

        post = get_post(page_id, post_id)
        #puts post["id"]
        #script_url = script_url_for gist, file
        #code       = get_cached_gist(gist, file) || get_gist_from_web(gist, file)
        #html_output_for script_url, code

        if post["verb"] == "share"
          return render_share post
        elsif post["verb"] == "post"
          return "POST"
        end

        return "Google+ Embed Fail #{post["verb"]}"
      else
        ""
      end
    end

    def render_share(post)
      attachments = []
      post["object"]["attachments"].each do |staff|
        if staff["objectType"] == "article"
          attachments << <<-HTML
<div class="attachment">
  <a href="#{staff["url"]}"><img class="left" src="#{staff["fullImage"]["url"]}"></a>
  <div><a href="#{staff["url"]}"><strong>#{staff["displayName"]}</strong></a></div>
  <div class="annotation">#{staff["content"]}</div>
</div>
          HTML
        end
      end
      <<-HTML
<div class="googleplusembed">
  <div class="actor">
    <img class="left" src="#{post["actor"]["image"]["url"]}">
    <div>
      <strong><a href="#{post["actor"]["url"]}">+#{post["actor"]["displayName"]}</a></strong>
      <small>#{post["published"].gsub(/T.*/, " ")}</small>
      <a class="jump" href="#{post["url"]}">ugr&aacute;s a bejegyz&eacute;sre</a>
    </div>
  </div>
  <div class="annotation">
    #{post["annotation"]}
  </div>
  <div class="original">
    <div class="actor">
      <img class="left" src="#{post["object"]["actor"]["image"]["url"]}">
      <div>
        <strong>
          <a href="#{post["object"]["actor"]["url"]}">+#{post["object"]["actor"]["displayName"]}</a>
        </strong>
        <a class="jump" href="#{post["object"]["url"]}">ugr&aacute;s a bejegyz&eacute;sre</a>
      </div>
    </div>
    <div class="annotation">
      #{post["object"]["content"]}
    </div>
    <div class="attachments">#{attachments.join("\n")}</div>
  </div>
  <div class="comments">Kommentek: <a href="#{post["url"]}">#{post["object"]["replies"]["totalItems"]}</a></div>
</div>
      HTML
    end

    def cache_post(page_id, post_id, data)
      cache_file = File.join @cache_folder, "post-#{page_id}-#{post_id}.cache"
      File.open(cache_file, "w") do |io|
        io.write data.to_json
      end
      data
    end

    def get_cached_post(page_id, post_id)
      return nil if @cache_disabled
      cache_file = File.join @cache_folder, "post-#{page_id}-#{post_id}.cache"
      File.read cache_file if File.exist? cache_file
    end

    def get_post(page_id, post_id)
      post = get_cached_post page_id, post_id
      return JSON.parse(post) unless post.nil?

      puts "Fetch #{page_id}/#{post_id}"
      api = GooglePlusAPI.new("AIzaSyD2cOHCHvMs0IbVQnBS13uXmdWWAjh8b14")
      activities = api.get_activities(page_id)
      activities["items"].each do |activity|
        if activity["url"].match /#{page_id}\/posts\/#{post_id}/
          post = api.get_acivity(activity["id"])
          return cache_post page_id, post_id, post
        end
      end

      ""
    end
  end

  class GooglePlusAPI
    def initialize(api_key)
      @API_KEY  = api_key
      @base_url = "https://www.googleapis.com/plus/v1"
    end

    def api_url(path)
      "#{@base_url}#{path}?key=#{@API_KEY}"
    end

    def raw_request(path)
      proxy             = ENV['http_proxy']
      raw_uri           = URI.parse(api_url(path))
      if proxy
        proxy_uri       = URI.parse(proxy)
        https           = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port).new raw_uri.host, raw_uri.port
      else
        https           = Net::HTTP.new raw_uri.host, raw_uri.port
      end
      https.use_ssl     = true
      request           = Net::HTTP::Get.new raw_uri.request_uri
      data              = https.request request
      data              = JSON.parse(data.body)

      data
    end

    def get_acivity(id)
      raw_request "/activities/#{id}"
    end

    def get_activities(id)
      raw_request "/people/#{id}/activities/public"
    end
  end
end

Liquid::Template.register_tag('googleplus_post', Jekyll::GooglePLusPostTag)
