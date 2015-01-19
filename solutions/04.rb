module UI
  class TextScreen
    @@content = []
    def self.draw(&block)
      @@content << []
      self.instance_eval(&block)
      print
    end
private

    def self.label(args)
      current_label = Label.new(args)
      current_label_container = []
      current_label_container << current_label
      @@content.last << current_label_container
    end

    def self.horizontal(*args, &block)
      @@content << []
      self.instance_eval(&block)

      last_group = @@content.last
      @@content.delete(last_group)

      @@content.last << horizontal_attributes(last_group, args).flatten
    end

    def self.horizontal_attributes(group, attributes)
      return group if attributes == []

      border_symbol = attributes.first[:border].to_s
      group.first.last.text = border_symbol + group.first.last.text
      group.last.last.text = group.last.last.text + border_symbol

      group.each{|label| label.last.style = attributes.first[:style] }
    end

    def self.vertical(*args, &block)
      self.instance_eval(&block)

      @@content.last.each do |group|
        group.last.text << "\n"
      end
    end

    def self.print
      result = ""
      @@content.flatten.each{|label| result << label.text}
      @@content = []
      result
    end
  end

  class Label
    def initialize(hash)
      @text   = hash[:text]
      @style  = hash[:style]
      @border = hash[:border]
    end

    def parse_attributes
      @text = @text.send(@style)        if @style != nil
      @text = @border + @text + @border if @border != nil
    end

    def text
      parse_attributes
      @text
    end

    def text=(new_text)
      @text = new_text
    end

    def style=(new_style)
      @style = new_style if @style == nil
    end

    def border=(new_border)
      @border = new_border if @border == nil
    end
  end
end
