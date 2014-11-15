module MetaTable
  module Pagination

    extend ActiveSupport::Inflector
    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TextHelper 
    extend ActionView::Helpers::TagHelper
    extend ActionView::Context

    def self.controller
      MetaTable.controller     
    end

    def self.collection
      MetaTable.collection
    end

    def self.render_pagination
      current_url = controller.request.url
      current_page = collection.current_page
      # binding.pry
      url_wih_page = if current_url.match(/page=\d{1,}/)
        current_url.gsub(/page=\d{1,}/, "page=#{current_page}")
      elsif current_url.match('\?\w')
        "#{current_url}&page=#{current_page}"
      else
        "#{current_url}?page=#{current_page}"
      end
      rendered_links(url_wih_page, current_page)
    end

    def self.rendered_links(url_wih_page, current_page) 
      links = []
      # binding.pry
      first_page = link_to 'first page', format_link_url(url_wih_page, 1) unless collection.first_page? 
      prev_page  = link_to "#{current_page.to_i-1}", format_link_url(url_wih_page,current_page.to_i-1) if !collection.first_page? && current_page.to_i-1 <= 0 
      current    = "#{current_page}"
      next_page  = link_to "#{current_page.to_i+1}", format_link_url(url_wih_page,collection.next_page) if collection.next_page && current_page.to_i+1 < collection.num_pages
      last_page  = link_to "last page", format_link_url(url_wih_page,collection.num_pages) unless collection.last_page?
      links << first_page << prev_page << current << next_page << last_page 
      render_links(links)
    end

    def self.format_link_url url_wih_page, page_number
      url_wih_page.gsub(/page=\d{1,}/, "page=#{page_number}")
    end

    def self.render_links(links)
      rendered = links.map { |link| link }.join(' ').html_safe
      wrap_links(rendered)
    end

    def self.wrap_links(rendered)
      content_tag(:div, nil, class: 'pagination') do
        rendered
      end  
    end

  end
end

