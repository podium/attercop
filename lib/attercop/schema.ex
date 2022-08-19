defmodule Attercop.Schema do
  
  @moduledoc """
  An abstraction around a GraphQL schema.
  """

  alias __MODULE__, as: Schema

  @enforce_keys [:domain]
  defstruct [:domain, uri: nil, path: "/", mutations: [], subscriptions: [], queries: []]

  @spec introspect(url_string :: String.t(), queries_fetcher :: (-> list()), mutations_fetcher :: (-> list()), subscriptions_fetcher :: (-> list())) :: %Schema{}
  def introspect(url_string, queries_fetcher, mutations_fetcher, subscriptions_fetcher) when is_binary(url_string) do
    url_string
    |> URI.parse()
    |> introspect(queries_fetcher, mutations_fetcher, subscriptions_fetcher)
  end

  @spec introspect(uri :: %URI{}, queries_fetcher :: (-> list()), mutations_fetcher :: (-> list()), subscriptions_fetcher :: (-> list())) :: %Schema{}
  def introspect(%URI{authority: domain, path: path} = uri, queries_fetcher, mutations_fetcher, subscriptions_fetcher) do
    %Schema{
      domain: domain,
      path: path,
      uri: uri,
    }
    |> introspect(queries_fetcher, mutations_fetcher, subscriptions_fetcher)
  end

  @spec introspect(schema :: %Schema{}, queries_fetcher :: (-> list()), mutations_fetcher :: (-> list()), subscriptions_fetcher :: (-> list())) :: %Schema{}
  def introspect(%Schema{domain: domain, path: path, uri: uri} = schema, queries_fetcher, mutations_fetcher, subscriptions_fetcher) do
    %Schema{
      schema |
      queries:       queries_fetcher.(),
      mutations:     mutations_fetcher.(),
      subscriptions: subscriptions_fetcher.(),
    }
  end

end
