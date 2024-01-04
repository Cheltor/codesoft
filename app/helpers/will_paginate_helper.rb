module WillPaginateHelper
  class BootstrapLinkRenderer < WillPaginate::ActionView::LinkRenderer
    def html_container(html)
      tag(:nav, tag(:div, html, class: 'btn-group'), container_attributes)
    end

    def page_number(page)
      tag(:button, link(page, page, rel: rel_value(page)), class: 'btn btn-secondary ' + (page == current_page ? 'active' : ''))
    end

    def gap
      tag(:button, link(super, '#'), class: 'btn btn-secondary disabled')
    end

    def previous_or_next_page(page, text, classname, rel)
      tag(:button, link(text, page || '#'), class: ['btn btn-secondary', (page ? '' : 'disabled'), classname].join(' '))
    end
  end

  def will_paginate_with_bootstrap(collection, options = {})
    will_paginate(collection, options.merge(renderer: BootstrapLinkRenderer))
  end
end