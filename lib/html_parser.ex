defmodule ReviewsScraper.HtmlParser do
  @moduledoc """
  Collection of helper functions to encapsulate Floki, creating a facade and reducing the coupling with this dependency
  """

  @doc """
    Encapsulate Floki.parse_document/1 function, receives an HTML document as string and return it parsed to Floki structure

    ## Examples

    iex> ReviewsScraper.HtmlParser.parse_html_string("<html><head></head><body>hello</body></html>")
    {:ok, [{"html", [], [{"head", [], []}, {"body", [], ["hello"]}]}]}
  """
  def parse_html_string(html_string) when is_binary(html_string) do
    Floki.parse_document(html_string)
  end

  @doc """
    Encapsulate the Floki.find/2 function

    ## Examples

    iex> {:ok, html} = ReviewsScraper.HtmlParser.parse_html_string("<html><head></head><body><p><span class="hint">hello</span></p></body></html>")
    iex> ReviewsScraper.HtmlParser.find_nodes(html, ".hint")
    [{"span", [{"class", "hint"}], ["hello"]}]
  """
  def find_nodes(parsed_html, selector) when is_binary(selector) do
    Floki.find(parsed_html, selector)
  end

  @doc """
    Encapsulate the Floki.attribute/3 function

    ## Examples

    iex> {:ok, html} = ReviewsScraper.HtmlParser.parse_html_string("<html><head></head><body><p><span class="hint">hello</span></p></body></html>")
    iex> ReviewsScraper.HtmlParser.get_node_attribute(html, "span.hint", "class")
    ["hint"]
  """
  def get_node_attribute(parsed_html, selector, attribute) do
    Floki.attribute(parsed_html, selector, attribute)
  end

  @doc """
    Shorthand for get_node_attribute/3 function selecting the class attribute

    ## Examples

    iex> {:ok, html} = ReviewsScraper.HtmlParser.parse_html_string("<html><head></head><body><p><span class="hint">hello</span></p></body></html>")
    iex> ReviewsScraper.HtmlParser.get_node_class_attribute(html, "span.hint")
    ["hint"]
  """
  def get_node_class_attribute(parsed_html, selector), do: get_node_attribute(parsed_html, selector, "class")

  @doc """
    Shorthand for find_nodes/2 |> Floki.text()

    ## Examples

    iex> {:ok, html} = ReviewsScraper.HtmlParser.parse_html_string("<html><head></head><body><p><span class="hint">hello</span></p></body></html>")
    iex> ReviewsScraper.HtmlParser.get_node_text(html, "span.hint")
    "hello"
  """
  def get_node_text(parsed_html, selector) do
    parsed_html
    |> find_nodes(selector)
    |> Floki.text()
  end
end
