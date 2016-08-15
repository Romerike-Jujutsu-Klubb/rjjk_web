# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# FIXME(uwe): Remove or include in the activerecord-time gem
class TimeOfDay
  def min
    minute
  end

  def day
    nil
  end

  def month
    nil
  end

  def year
    nil
  end

  def day_phase
    self < self.class.new(17, 0) ? 'dag' : 'kveld'
  end
end
# EMXIF

# FIXME(uwe): Remove or report
module Prawn
  class Table
    class Cell
      class Text < Cell
        # Returns the width of this text with no wrapping. This will be far off
        # from the final width if the text is long.
        def natural_content_width
          @natural_content_width ||= rotated ?
              with_font {
                b = text_box(width: spanned_content_height + FPTolerance)
                b.render(dry_run: true)
                b.height
              } :
              [styled_width_of(@content), @pdf.bounds.width].min
        end

        def rotated
          @text_options[:rotate].to_i % 180 == 90
        end

        # Returns the natural height of this block of text, wrapped to the
        # preset width.
        def natural_content_height
          rotated ? [styled_width_of(@content), @pdf.bounds.height].min :
              with_font do
                b = text_box(width: spanned_content_width + FPTolerance)
                b.render(dry_run: true)
                b.height + b.line_gap
              end
        end

        # Draws the text content into its bounding box.
        def draw_content
          with_font do
            @pdf.move_down((@pdf.font.line_gap + @pdf.font.descender) / 2)
            with_text_color do
              text_box(width: rotated ? spanned_content_height : spanned_content_width + FPTolerance,
                  height: rotated ? spanned_content_width : spanned_content_height + FPTolerance,
                  at: [2, (rotated ? (spanned_content_height + FPTolerance - natural_content_height) / 2 : @pdf.cursor)]).render
            end
          end
        end
      end
    end
  end
end
# EMXIF
