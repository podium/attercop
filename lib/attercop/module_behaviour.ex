defmodule Attercop.ModuleBehaviour do
  @callback vuln(endpoint :: %Attercop.Type{}, client :: module() | nil) :: boolean()
  @callback testable_field?(%Attercop.Type{}) :: boolean()
end
