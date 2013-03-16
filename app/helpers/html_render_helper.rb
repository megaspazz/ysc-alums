# In order to have global scope as intended, it needs to end in "helper"

module HtmlRenderHelper

  # Returns &nbsp; if blank, which allows empty divs to render correctly in Chrome and possibly Safari
  def render_or_nbsp(text)
    if text.blank?
      "&nbsp;".html_safe
    else
      text
    end
  end
  
end
