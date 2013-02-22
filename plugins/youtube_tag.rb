module Jekyll

  class YoutubeTag < Liquid::Tag
    @video = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['src', 'width', 'height']

      if markup =~ /(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?/i
        @video = attributes.reduce({}) { |vid, attr| vid[attr] = $~[attr].strip if $~[attr]; vid }

        unless @video['width']
          @video['width'] = 620
        end

        unless @video['height']
          @video['height'] = 465
        end
      end
      super
    end

    def render(context)
      if @video
        "<iframe #{@video.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")} frameborder='0' allowfullscreen='true'></iframe>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('youtube', Jekyll::YoutubeTag)