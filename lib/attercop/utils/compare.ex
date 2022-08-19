defmodule Attercop.Utils.Compare do
  @moduledoc """
  Utilities to perform shape comparisons on structs, recursively.
  """

  @doc ~S"""
  Determine if all keys in two Maps match recursively, i.e. a deep compare which ignores all values.

  ### Examples
    iex> Attercop.Utils.Compare.keys_match_deeply?(%{foo: "bar", baz: %{bang: "quux"}}, %{foo: "rab", baz: %{bang: "gnab"}})
    true

    iex> Attercop.Utils.Compare.keys_match_deeply?(%{foo: "bar", baz: %{bang: "quux"}}, %{foo: "bar", quux: "baz"})
    false
  """
  @spec keys_match_deeply?(a :: map(), b :: map()) :: boolean()
  def keys_match_deeply?(a, b) do
    all_keys(a) == all_keys(b)
  end

  ## Return all keys (inc. nested) from a map.
  defp all_keys(val) when not is_map(val), do: []
  defp all_keys(map) when is_map(map) do
    Enum.reduce(Map.keys(map), [], fn key, acc ->
      acc ++ [key] ++ all_keys(map[key])
    end)
  end

  @doc """
  Determine whether the bodies of two Neuron responses are nil.
  """
  @spec nil_bodies?(a :: %Neuron.Response{}, b :: %Neuron.Response{}) :: boolean()
  def nil_bodies?(%Neuron.Response{body: %{"data" =>  a}}, %Neuron.Response{body: %{"data" =>  b}}) when is_nil(a) and is_nil(b), do: true
  def nil_bodies?(%Neuron.Response{body: _a}, %Neuron.Response{body: _b}), do: false

  @doc """
  Determine whether the errors of two Neuron responses are equal.
  """
  @spec errors_match?(a :: %Neuron.Response{}, b :: %Neuron.Response{}) :: boolean()
  def errors_match?(%Neuron.Response{body: a}, %Neuron.Response{body: b}), do: a[:error] == b[:error]

  @doc """
  Determine if the resulting data matches in two responses.
  """
  @spec data_matches?(a :: %Neuron.Response{}, b :: %Neuron.Response{}) :: boolean()
  def data_matches?(%Neuron.Response{body: %{"data" =>  a}}, %Neuron.Response{body: %{"data" =>  b}}) when is_nil(a) or is_nil(b), do: false
  def data_matches?(%Neuron.Response{body: a}, %Neuron.Response{body: b}), do: a["data"] == b["data"]

  @doc """
  Determine if the any data was returned in two Neuron responses.
  """
  @spec data_returned?(a :: %Neuron.Response{}, b :: %Neuron.Response{}) :: boolean()
  def data_returned?(%Neuron.Response{body: %{"data" =>  a}}, %Neuron.Response{body: %{"data" =>  b}}) when is_nil(a) or is_nil(b), do: false
  def data_returned?(%Neuron.Response{body: %{"data" =>  a}}, %Neuron.Response{body: %{"data" =>  b}}) when not is_nil(a) and not is_nil(b), do: true
  def data_returned?(%Neuron.Response{body: _a}, %Neuron.Response{body: _b}), do: false

end
