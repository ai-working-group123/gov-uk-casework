module ApplicationHelper
	def marksmithed_sanitized(markdown)
		rendered = marksmithed(markdown)
		sanitize(
			rendered,
			tags: %w(
				table thead tbody tfoot caption colgroup col tr th td
				ul ol li dl dt dd
				h1 h2 h3 h4 h5 h6 p br hr blockquote
				pre code kbd samp var
				strong em b i u s sub sup mark small
				span abbr cite q figure figcaption details summary
			) +
				ActionView::Helpers::SanitizeHelper.sanitizer_vendor.safe_list_sanitizer.allowed_tags.to_a
		)
	end
end
