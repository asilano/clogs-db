module ApplicationHelper
  def show_edit_delete_links(object)
    html = link_to(content_tag(:span, '', :class => 'icon-eye', 'aria-hidden' => true), object, :class => 'only-icon')
    html << link_to(content_tag(:span, '', :class => 'icon-pencil', 'aria-hidden' => true), edit_polymorphic_path(object), :class => 'only-icon')
    html << link_to(content_tag(:span, '', :class => 'icon-remove', 'aria-hidden' => true),
                   object, :method => :delete, :data => { :confirm => 'Are you sure?' }, :class => 'only-icon')
  end

  def tick_or_cross(bool)
    content_tag(:span, '', :class => bool ? 'icon-checkmark' : 'icon-cross', 'aria-hidden' => true)
  end

end
