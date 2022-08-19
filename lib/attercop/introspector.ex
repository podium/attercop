defmodule Attercop.Introspector do
  @moduledoc """
  Identify GraphQL endpoints and data to test against.
  """

  alias Attercop.Client

  @doc """
  Introspect the schema and generate a list of types at the specified URI.
  """

  @spec query_introspect!(uri :: URI.t(), client :: module()) :: list()
  def query_introspect!(uri, headers \\ %{},  client \\ Client) do
    %Client.Request{uri: uri, client: client, query:
  """
  query IntrospectionQuery {
    __schema {
      queryType {
        name
        fields {
          fieldName: name
          type {
            fieldType: kind
            subFields: fields {name, type {subFieldType: kind} }, 
          }
          args {
            argName: name
          }
        }
      }
    }
  }
  """
    }
    |> client.query()
    |> introspect_parse(uri)
  end

  defp introspect_parse({:ok, %Neuron.Response{body: %{"errors" => errors}}}, _uri) do
    IO.inspect errors
    
    []
  end

  defp introspect_parse({:ok, %Neuron.Response{} = data}, uri) do
    data
    |> raw_fields_list
    |> parse_fields(uri)
  end

  defp introspect_parse({:error, %Neuron.Response{} = data}, _uri) do
    IO.inspect data
  end

  defp raw_fields_list(%Neuron.Response{} = resp) do
    resp.body["data"]["__schema"]["queryType"]["fields"]
  end

  defp parse_fields(raw_fields, uri) do
    raw_fields
    |> Enum.map(fn field ->
      %Attercop.Field{
        name: field["fieldName"],
        type: field["type"]["fieldType"] |> String.to_atom,
        args: field["args"] |> parse_args,
        subfields: field["type"]["subFields"] |> parse_subfields,
        uri: uri
	}
    end)
  end

  defp parse_subfields(nil), do: []
  defp parse_subfields([]), do: []
  defp parse_subfields(raw_subfields) do
    raw_subfields
    |> Enum.map(fn subfield ->
      %Attercop.Field{
        name: subfield["name"],
        type: subfield["type"]["subFieldType"] |> String.to_atom,
      }
    end)
  end

  defp parse_args(raw_args) do
    raw_args
    |> Enum.map(fn arg ->
      arg["argName"]
    end)
  end

  @doc """
  Validate that a response came back with a non-404 status code.

  Note: Warns if a status code came back that was neither `200 OK` nor `404 NOT FOUND`. This function returns true for any non-404.
  """
  @spec response_from_valid_path?(resp :: tuple()) :: boolean() 
  def response_from_valid_path?({:ok, %Neuron.Response{status_code: 200}}),    do: true
  def response_from_valid_path?({:ok, %Neuron.Response{status_code: 404}}),    do: false
  def response_from_valid_path?({:error, %Neuron.Response{status_code: 404}}), do: false

  def response_from_valid_path?({:error, %Neuron.JSONParseError{response: response}}) do
    {:error, response} |> response_from_valid_path?
  end

  def response_from_valid_path?({:ok, %Neuron.Response{status_code: code}}) do
    IO.puts "Got a non 200 OK response from query: #{code}"
    true
  end

  def response_from_valid_path?({:error, %HTTPoison.Error{reason: :nxdomain}}) do
    IO.puts "No such domain! Either the domain scanned does not exist, or a connection cannot be established."
    false
  end

  def response_from_valid_path?({:error, %Neuron.Response{status_code: 301}}) do
    IO.puts "Got an HTTP 301. Hint: did you forget to prepend 'https://' to your domain?"
    false
  end

  def response_from_valid_path?({:error, response}) do
    IO.puts "Got an unknown failing response:\n\n#{Kernel.inspect(response)}"
    false
  end

end
