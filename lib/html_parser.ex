defmodule ReviewsScraper.HtmlParser do

  def parse_html_string(html_string) when is_binary(html_string) do
    Floki.parse_document(html_string)
  end

  def find_nodes(parsed_html, selector) when is_binary(selector) do
    parsed_html
    |> Floki.find(selector)
  end

  def get_node_attribute(parsed_html, selector, attribute) do
    parsed_html
    |> Floki.attribute(selector, attribute)
  end

  def get_node_class_attribute(parsed_html, selector), do: get_node_attribute(parsed_html, selector, "class")

  def get_node_text(parsed_html, selector) do
    parsed_html
    |> find_nodes(selector)
    |> Floki.text()
  end

end
