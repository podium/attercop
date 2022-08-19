defmodule Attercop.Client.ClientBehaviour do

  @moduledoc false

  @type neuron_config :: %{
    url: String.t,
    headers: list(String.t)
  }

  @callback query(request :: Attercop.Client.Request) :: Neuron.Response.t
  @callback config(host :: String.t, path :: String.t) :: neuron_config
end
