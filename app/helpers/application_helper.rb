module ApplicationHelper
  # Sanitize LLM-generated markdown HTML with a strict allowlist.
  # Use instead of raw `sanitize` to ensure only safe tags survive.
  SAFE_MARKDOWN_TAGS = %w[
    p br strong em b i u s del code pre blockquote
    h1 h2 h3 h4 h5 h6 ul ol li a img table thead tbody tr th td
    hr span div dl dt dd sup sub
  ].freeze

  SAFE_MARKDOWN_ATTRIBUTES = {
    "a" => %w[href title],
    "img" => %w[src alt title width height],
    "td" => %w[colspan rowspan],
    "th" => %w[colspan rowspan scope]
  }.freeze

  def safe_markdown(content)
    sanitize(
      marksmithed(content),
      tags: SAFE_MARKDOWN_TAGS,
      attributes: SAFE_MARKDOWN_ATTRIBUTES.values.flatten.uniq
    )
  end
end
