module RmplusDevtools
  module RmplusDevtools
    class Hooks < Redmine::Hook::ViewListener
         render_on(:view_layouts_base_html_head, :partial => 'hooks/rmplus_devtools/headers')
    end
  end
end
