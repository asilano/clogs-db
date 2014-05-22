module ApplicationHelper
  def show_edit_delete_links(member)
    html = link_to(content_tag(:span, '', :class => 'icon-eye', 'aria-hidden' => true), member, :class => 'only-icon')
    html << link_to(content_tag(:span, '', :class => 'icon-pencil', 'aria-hidden' => true), edit_member_path(member), :class => 'only-icon')
    html << link_to(content_tag(:span, '', :class => 'icon-remove', 'aria-hidden' => true),
                   member, :method => :delete, :data => { :confirm => 'Are you sure?' }, :class => 'only-icon')
  end

  def tick_or_cross(bool)
    content_tag(:span, '', :class => bool ? 'icon-checkmark' : 'icon-cross', 'aria-hidden' => true)
  end

end
