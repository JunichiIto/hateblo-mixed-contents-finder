class InvalidContent
  def initialize(page_url, tag, attr, link_url)
    @page_url = page_url
    @tag = tag
    @attr = attr
    @link_url = link_url
  end

  def to_s
    "#{@page_url}\t#{@tag}\t#{@attr}\t#{@link_url}"
  end
end