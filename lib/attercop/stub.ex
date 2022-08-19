defmodule Attercop.Stub do

  def stub(argname) do
    %{
      "id" => System.get_env("ATTERCOP_STUB_ID")
    }[argname]
  end
  
end
