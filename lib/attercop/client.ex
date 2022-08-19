defmodule Attercop.Client do
  @behaviour Attercop.Client.ClientBehaviour

  alias Attercop.Client.ClientBehaviour
  #alias Attercop.Auth

  import Logger

  @doc """
  Execute the query in Client.Request 
  """
  @impl ClientBehaviour
  @spec query(request :: Attercop.Client.Request) :: Neuron.Response.t
  def query(request) do
    config(request.uri)

    request.query
    |> Neuron.query
  end

  @doc """
  (Neuron Specific) Configure the GraphQL client.
  """
  @impl ClientBehaviour
  @spec config(uri :: URI.t()) :: ClientBehaviour.neuron_config
  def config(uri) do
    # Auth.auth_header
    # |> config!(uri)

    config!({:ok, nil}, uri)
  end

  defp config!({:ok, nil}, uri) do
    Neuron.Config.set(url: uri)

    %{
      url: Neuron.Config.get(:url),
      headers: Neuron.Config.get(:headers)
    }
  end

  defp config!({:ok, auth_header}, uri) do
    Neuron.Config.set(url: uri)
    Neuron.Config.set(headers: [authorization: auth_header])
    
    %{
      url: Neuron.Config.get(:url),
      headers: Neuron.Config.get(:headers)
    }
    
  end

  defp config!({:error, reason}, _host, _path) do
    Logger.warning("An unexpected error occured configuring the GraphQL request: #{reason}")

    %{
      url: Neuron.Config.get(:url),
      headers: Neuron.Config.get(:headers)
    }
  end

end
