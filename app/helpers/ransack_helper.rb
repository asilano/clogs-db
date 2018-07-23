module RansackHelper
  def display_query(query, context = Member)
    return 'No query' if query.empty?

    # Generate the search object, then render it
    s = context.search(query)

    groups = s.groupings.map { |group| render_ransack_group(group, context) }
    groups += s.conditions.map { |cond| render_ransack_condition(cond, context) }

    groups.join ' AND '
  end

  def render_ransack_group(group, context)
    combiner = Ransack::Translate.word(group.m)

    condition_parts = group.c.map { |cond| render_ransack_condition(cond, context) }
    group_parts = group.g.map { |group| "(#{render_ransack_group(group, context)})" }

    (condition_parts + group_parts).join " #{combiner.upcase} "
  end

  def render_ransack_condition(cond, group)
    attribs = cond.a.map &:name
    predicate = Ransack::Translate.predicate cond.p
    values = cond.values.map { |val| "'#{val.value}'" }.join ' or '

    "<#{attribs.join ' or '}> #{predicate.upcase} #{values}"
  end

  def setup_search_form(builder)
    fields = builder.grouping_fields builder.object.new_grouping, object_name: 'new_object_name', child_index: 'new_grouping' do |f|
      render('ransack/grouping_fields', f: f)
    end
    content_for :document_ready, %Q{
      var search = new Search({grouping: "#{escape_javascript(fields)}"});
      $(document).on("click", "button.add-fields", function() {
        search.add_fields(this, $(this).data('fieldType'), $(this).data('content'));
        return false;
      });
      $(document).on("click", "button.remove-fields", function() {
        search.remove_fields(this);
        return false;
      });
      $(document).on("click", "button.nest-fields", function() {
        search.nest_fields(this, $(this).data('fieldType'));
        return false;
      });
    }.html_safe
  end

  def button_to_remove_fields(f, type)
    button_tag('&mdash;'.html_safe, class: "remove-fields remove-#{type}", title: "Remove #{type}")
  end

  def button_to_add_fields(name, f, type)
    new_object = f.object.send "build_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: "new_#{type}") do |builder|
      render("ransack/#{type}_fields", f: builder, hide: true)
    end
    button_tag name, :class => 'add-fields', 'data-field-type' => type, 'data-content' => "#{fields}", title: "Add #{type}"
  end

  def button_to_nest_fields(name, type)
    button_tag name, :class => 'nest-fields', 'data-field-type' => type, title: 'Add group'
  end
end

module ActionView
  module Helpers
    class FormBuilder
      def search_fields_for(record_name, record_object = nil, fields_options = {}, &proc)
        fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
        record_object, record_name = record_name, nil if record_object.nil?

        search = nil
        if record_object.is_a?(Ransack::Search)
          search = record_object
        elsif record_object.is_a?(Array)
          search = record.detect { |o| o.is_a?(Ransack::Search) }
        end

        if search.nil?
          raise ArgumentError,
            'No Ransack::Search object was provided to search_form_for!'
        end
        record_name ||= 'q'.freeze
        fields_options[:builder] ||= Ransack::Helpers::FormBuilder

        fields_for(record_name, record_object, fields_options, &proc)
      end
    end
  end
end
