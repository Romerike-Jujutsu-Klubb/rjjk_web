# frozen_string_literal: true

# TODO(uwe):  Remove this file when issue is solved:
# https://github.com/bootstrap-ruby/rails-bootstrap-forms/issues/339
# https://github.com/bootstrap-ruby/rails-bootstrap-forms/pull/340

module BootstrapForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    def error_class
      'text-danger'
    end

    def form_group(*args, &block)
      options = args.extract_options!
      name = args.first

      options[:class] = ['form-group', options[:class]].compact.join(' ')
      options[:class] << ' row' if get_group_layout(options[:layout]) == :horizontal
      options[:class] << " #{error_class}" if has_error?(name)
      options[:class] << " #{feedback_class}" if options[:icon]

      content_tag(:div,
          options.except(:id, :label, :help, :icon, :label_col, :control_col, :layout)) do
        if options[:label]
          label = generate_label(options[:id], name, options[:label], options[:label_col],
              options[:layout])
        end
        control = capture(&block).to_s
        control.concat(generate_help(name, options[:help]).to_s)
        control.concat(generate_icon(options[:icon])) if options[:icon]

        if get_group_layout(options[:layout]) == :horizontal
          control_class = options[:control_col] || control_col
          unless options[:label]
            control_offset = offset_col(options[:label_col] || @label_col)
            control_class = "#{control_class} #{control_offset}"
          end
          control = content_tag(:div, control, class: control_class)
        end

        concat(label).concat(control)
      end
    end

    private

    def form_group_builder(method, options, html_options = nil)
      options.symbolize_keys!
      html_options&.symbolize_keys!

      # Add control_class; allow it to be overridden by :control_class option
      css_options = html_options || options
      control_classes = css_options.delete(:control_class) { control_class }
      css_options[:class] = [control_classes, css_options[:class]].compact.join(' ')
      css_options[:class] << ' is-invalid' if has_error?(method)

      options = convert_form_tag_options(method, options) if acts_like_form_tag

      wrapper_class = css_options.delete(:wrapper_class)
      wrapper_options = css_options.delete(:wrapper)
      help = options.delete(:help)
      icon = options.delete(:icon)
      label_col = options.delete(:label_col)
      control_col = options.delete(:control_col)
      layout = get_group_layout(options.delete(:layout))
      form_group_options = {
        id: options[:id],
        help: help,
        icon: icon,
        label_col: label_col,
        control_col: control_col,
        layout: layout,
        class: wrapper_class,
      }

      form_group_options.merge!(wrapper_options) if wrapper_options.is_a?(Hash)

      unless options.delete(:skip_label)
        if options[:label].is_a?(Hash)
          label_text = options[:label].delete(:text)
          label_class = options[:label].delete(:class)
          options.delete(:label)
        end
        label_class ||= options.delete(:label_class)
        label_class = hide_class if options.delete(:hide_label)

        label_text ||= options.delete(:label) if options[:label].is_a?(String)

        form_group_options[:label] = {
          text: label_text,
          class: label_class,
          skip_required: options.delete(:skip_required),
        }
      end

      form_group(method, form_group_options) do
        yield
      end
    end

    def generate_help(name, help_text) # rubocop: disable Lint/ShadowedArgument,Style/CommentedKeyword
      if has_error?(name) && inline_errors
        help_text = get_error_messages(name)
        help_klass = 'invalid-feedback'
      end
      return if help_text == false

      help_klass ||= 'form-text text-muted'
      help_text ||= get_help_text_by_i18n_key(name)

      content_tag(:span, help_text, class: help_klass) if help_text.present?
    end
  end
end
