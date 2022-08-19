defmodule Attercop.ModuleArchives do

  alias Attercop.Module.OrgPivot

  def run(targets) do
    targets
    |> Enum.map(fn target ->
      OrgPivot.Root.report(target)
      ## TODO: FIXME, right now this only runs OrgPivot, but should iterate over a list
      #  of modules.
    end)
  end

  def run(targets, modules) do
  end

  def list() do
    IO.puts "OrgPivot"
  end

end
