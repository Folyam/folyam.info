#
# Author: Balazs Nadasdi <yitsushi@gmail.com> (http://blog.code-infection.com/)
#
# Outputs a string with a given attribution as a block about a Product Promotion
#
#   {% product_promo_box %}
#     Title: Name of the product
#     Author: Author (books), Manufacturer, etc
#     Image: Image URL about the product
#     Price: Price of the product
#     PromoPrice: Promotion Price
#     PromoCode: Promotion code
#     Source: Publisher/Seller/Site
#     Url: URL to the product
#     Description: Description of the product (short)
#   {% endproduct_promo_box %}
#   ...
#   <div class="product-box">
#     <a href="URL to the product"
#        title="Name of the product">
#       <img class="product-image"
#            src="Image URL about the product"
#            alt="Name of the product"
#            title="Name of the product">
#     </a>
#     <div class="product-info">
#       <div class="product-title">
#         <a href="URL to the product"
#            title="Name of the product">
#           Name of the product
#         </a>
#       </div>
#       <div class="product-source">
#         <a href="URL to the product"
#            title="Publisher/Seller/Site">
#           Publisher/Seller/Site
#         </a>
#       </div>
#       <div class="product-author">
#         by <span>Author (books), Manufacturer, etc</span>
#       </div>
#       <div class="product-price">
#         Old price: <span class="old">Price of the product</span>; now: <span class="now">Promotion Price</span>
#       </div>
#       <div class="product-promo-code">
#         Promotion code: <span>DEAL</span>
#       </div>
#       <div class="product-description">
#         Description of the product (short)
#       </div>
#     </div>
#   </div>
#
# Example CSS:
#   .product-box {
#     overflow: hidden;
#     padding-bottom: 1.5em;
#     padding-top: 1.5em;
#   }
#   .product-box img {
#     float: left;
#     max-width: 25%;
#   }
#   .product-box .product-info {
#     margin-left: 28%;
#   }
#   .product-box .product-info .product-title {
#     padding-top: 10px;
#     padding-bottom: 5px;
#     font-size: 1.6em;
#     font-weight: bold;
#   }
#   .product-box .product-info .product-title a {
#     color: hsl(0, 0%, 30%);
#     text-decoration: none;
#   }
#   .product-box .product-info .product-author {
#     font-style: italic;
#   }
#   .product-box .product-info .product-price {
#     padding: 8px 0;
#   }
#   .product-box .product-info .product-price span {
#     padding: 0 5px;
#   }
#   .product-box .product-info .product-price .now {
#     color: hsl(120, 50%, 40%);
#     font-weight: bold;
#     font-size: 1.3em;
#   }
#   .product-box .product-info .product-price .old {
#     font-weight: bold;
#     font-size: 1.em;
#     text-decoration: line-through;
#   }
#   .product-box .product-info .product-promo-code {
#     font-size: 0.8em;
#   }
#   .product-box .product-info .product-promo-code span {
#     color: hsl(230, 50%, 40%);
#     font-weight: bold;
#     font-size: 1.3em;
#   }
#   .product-box .product-info .product-source {
#     font-size: 0.9em;
#     float: right;
#   }
#   .product-box .product-info .product-description {
#     padding-top: 6px;
#     font-size: 0.8em;
#     font-style: italic;
#   }

module Jekyll

  class ProductPromoBox < Liquid::Block
    Title = /^Title: (.*)$/
    Author = /^Author: (.*)$/
    Source = /^Source: (.*)$/
    Url = /^Url: (.*)$/
    Price = /^Price: (.*)$/
    PromoPrice = /^PromoPrice: (.*)$/
    Image = /^Image: (.*)$/
    PromoCode = /^PromoCode: (.*)$/
    Description = /^Description: (.*)$/

    def initialize(tag_name, markup, tokens)
      @by = nil
      @title = nil
      @source = nil
      @url = nil
      @price = nil
      @promoPrice = nil
      @image = nil
      @promoCode = nil
      @description = nil

      tokens[0].split(/\n/).each do |line|
        line = line.strip
        next if (line.length < 1)

        if line =~ Title
          @title = $1
        elsif line =~ Author
          @by = $1
        elsif line =~ Source
          @source = $1
        elsif line =~ Url
          @url = $1
        elsif line =~ Price
          @price = $1
        elsif line =~ PromoPrice
          @promoPrice = $1
        elsif line =~ Image
          @image = $1
        elsif line =~ PromoCode
          @promoCode = $1
        elsif line =~ Description
          @description = $1
        end
      end

      super
    end

    def render(context)
      promo = "";
      promo += "<div class='product-title'>#{with_link(@title, @url)}</div>" unless @title.nil?
      promo += "<div class='product-source'>#{with_link(@source, @url)}</div>" unless @source.nil?
      promo += "<div class='product-author'>by <span>#{@by}</span></div>" unless @by.nil?
      if @promoPrice.nil?
        promo += "<div class='product-price'><span class='now'>#{@price}</span></div>" unless @price.nil?
      else
        promo += "<div class='product-price'>Old price: <span class='old'>#{@price}</span>; now: <span class='now'>#{@promoPrice}</span></div>" unless @price.nil?
      end
      promo += "<div class='product-promo-code'>Promotion code: <span>#{@promoCode}</span></div>" unless @promoCode.nil?
      promo += "<div class='product-description'>#{@description}</div>" unless @description.nil?

      promo = "<div class='product-info'>#{promo}</div>";

      promo = with_link("<img class='product-image' src='#{@image}' alt='#{@title}' title='#{@title}'>", @url, @title) + "#{promo}" unless @image.nil?

      return "<div class='product-box'>#{promo}</div>"
    end

    def with_link(content, url, title = nil)
      return content if url.nil?

      title = content if title.nil?

      title.gsub!(/'/, "&#39;")

      return "<a href='#{url}' title='#{title}'>#{content}</a>"
    end
  end
end

Liquid::Template.register_tag('product_promo_box', Jekyll::ProductPromoBox)
