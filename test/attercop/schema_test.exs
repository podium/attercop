defmodule Attercop.SchemaTest do
  use ExUnit.Case, async: true

  doctest Attercop.Schema

  alias Attercop.Schema

  setup _context do
      mutations_fetcher     = fn -> ["list", "of", "mutations"]     end
      queries_fetcher       = fn -> ["list", "of", "queries"]       end
      subscriptions_fetcher = fn -> ["list", "of", "subscriptions"] end
      uri                   = %URI{
        authority: "www.example.com",
        fragment: nil,
        host: "www.example.com",
        path: "/graphql",
        port: 443,
        query: nil,
        scheme: "https",
        userinfo: nil
      }

      schema = %Schema{
        uri: uri,
        domain: "www.example.com",
        path: "/graphql",
        queries: [],
        mutations: [],
        subscriptions: [],
      }

      %{
        mutations_fetcher: mutations_fetcher,
        queries_fetcher: queries_fetcher,
        subscriptions_fetcher: subscriptions_fetcher,
        uri: uri,
        schema_struct: schema,
      }

  end

  describe "introspect/4" do

    test "correctly organizes introspection data when given a plain binary", context do
        assert Schema.introspect(
          "https://www.example.com/graphql",
          context[:queries_fetcher],
          context[:mutations_fetcher],
          context[:subscriptions_fetcher]) ==
        %Schema{
          uri: context.uri,
          domain: "www.example.com",
          path: "/graphql",
          queries:       ["list", "of", "queries"],
          mutations:     ["list", "of", "mutations"],
          subscriptions: ["list", "of", "subscriptions"],
        }
    end

    test "correctly organizes introspection data when given a URI struct", context do
      assert Schema.introspect(
        context[:uri],
        context[:queries_fetcher],
        context[:mutations_fetcher],
        context[:subscriptions_fetcher]) ==
        %Schema{
          uri: context.uri,
          domain: "www.example.com",
          path: "/graphql",
          queries:       ["list", "of", "queries"],
          mutations:     ["list", "of", "mutations"],
          subscriptions: ["list", "of", "subscriptions"],
        }
    end

    test "correctly organizes introspection data when given an existing schema struct", context do
      assert Schema.introspect(
        context[:schema_struct],
        context[:queries_fetcher],
        context[:mutations_fetcher],
        context[:subscriptions_fetcher]) ==
        %Schema{
          uri: context.uri,
          domain: "www.example.com",
          path: "/graphql",
          queries:       ["list", "of", "queries"],
          mutations:     ["list", "of", "mutations"],
          subscriptions: ["list", "of", "subscriptions"],
        }
    end
  end

  # defp introspect_example_data(context) do
  #   mutations_fetcher     = fn uri -> ["list", "of", "mutations"]     end
  #   queries_fetcher       = fn uri -> ["list", "of", "queries"]       end
  #   subscriptions_fetcher = fn uri -> ["list", "of", "subscriptions"] end
  #   uri                   = %URI{
  #     authority: "www.example.com",
  #     fragment: nil,
  #     host: "www.example.com",
  #     path: "/graphql",
  #     port: 443,
  #     query: nil,
  #     scheme: "https",
  #     userinfo: nil
  #   }

  #   schema = %Schema{
  #     uri: uri,
  #     domain: "www.example.com",
  #     path: "/graphql",
  #     queries: [],
  #     mutations: [],
  #     subscriptions: [],
  #   }

  #   %{
  #     mutations_fetcher: mutations_fetcher,
  #     queries_fetcher: queries_fetcher,
  #     subscriptions_fetcher: subscriptions_fetcher,
  #     uri: uri,
  #     schema_struct: schema,
  #   }

  # end

end
