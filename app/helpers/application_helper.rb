module ApplicationHelper
  def icon_link(icon, target, options = {})
    options[:class] ||= ''
    options[:class] += ' only-icon'
    link_to content_tag(:span, nil, class: "icon-#{icon}", 'aria-hidden' => true), target, options
  end

  def show_edit_delete_links(object, name)
    icon_link('eye', object) + icon_link('pencil', edit_polymorphic_path(object)) + icon_link('remove', object, method: :delete, data: {confirm: "Really delete #{name}?"})
  end

  def tick_or_cross(bool)
    content_tag(:span, '', :class => bool ? 'icon-checkmark' : 'icon-cross', 'aria-hidden' => true)
  end

  def check_box_hack(label_contents, hack_id, &controlled_contents)
    checkbox = check_box_tag hack_id, nil, false, class: 'checkbox-hack'
    label = label_tag hack_id, content_tag(:span, nil, class: 'checkbox-hack-expander icon-caret-right') + " " + raw(label_contents)
    controlled_div = content_tag(:div, nil, {class: 'checkbox-controlled'}, &controlled_contents)

    label + checkbox + controlled_div
  end

  def transform_newlines(str)
    raw str.gsub("\n", '<br/>')
  end

end
