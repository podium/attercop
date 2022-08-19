defmodule Attercop.CLI do
  @moduledoc """
  Defines the Attercop CLI, commands, and output.
  """

  use ExCLI.DSL, escript: true

  alias Attercop.ModuleArchives
  alias Attercop.Output.ReconOutput
  alias Attercop.Output.SingleOutput
  alias Attercop.Recon.Report
  alias Attercop.ServerList
  alias Attercop.Introspector
  alias Attercop.Output.IntrospectionOutput

  import CliSpinners, only: [spin_fun: 2]

  ########################
  # global functionality #
  ########################

  name "attercop"
  description "Crawl and report on GraphQL schemas"
  long_description ~s"""
  Security tool for automating vulnerability detection on GraphQL endpoints
  """

  option :verbose, count: true, aliases: [:v], help: "Sets verbose mode ON"
  option :no_truncate, count: true, aliases: [:t], help: "Don't truncate any data in the table, even if it causes a wrap around when rendered."

  #######################
  # individual commands #
  #######################

  command :hello do
    argument :argument

    run context do
      greet(context)
    end
  end

  command :introspect do 
    description "Fetch and display the GraphQL schema"
    long_description """
    Send an introspection request to the specified URI and display the schema information in a table
    """

    argument :target

    run context do
      introspect(context)
    end

  end

  command :recon do
    description "Lists potential pivot arguments"
    long_description """
    Regex match for a value (default of 'id') in all arguments from an introspection run and create a list of arguments that might make good potential candidates
    """

    argument :target
    argument :value

    run context do
      recon(context)
    end
  end

  # command :pivot do
  #   description "Runs a Attercop scan against provided endpoint"
  #   long_description """
  #   Given a singular URL to target, runs some or all vulnerability modules
  #   """
  #   argument :target
  #   argument :arg
  #   argument :value_a
  #   argument :value_b

  #   run context do
  #     scan(:single, context)
  #   end
  # end


  ########################
  # supporting functions #
  ########################

  defp greet(context) do
    if context.argument == "there" do
      IO.puts("General Kenobi!")
    end
  end

  defp introspect(context) do
    IO.puts "Introspecting #{context.target} on #{(DateTime.utc_now |> DateTime.to_string) <> "\s" <> "(UTC)"}"

    load("Introspecting #{context.target}", "Done.", fn -> Introspector.query_introspect!(context.target) end)
    |> IntrospectionOutput.put(context)
  end

  defp recon(context) do
    IO.puts "Beginnning reconnissance of #{context.target} on #{(DateTime.utc_now |> DateTime.to_string) <> "\s" <> "(UTC)"}"
    IO.puts "Showing all GraphQL fields that accept '#{context.value}' as an argument name or a substring to an argument name."

    load("Introspecting #{context.target}", "Done.", fn -> Introspector.query_introspect!(context.target) end)
    |> Report.potential_pivots()
    |> ReconOutput.put(context)
  end

  # defp scan(mode, context) do
  #   IO.puts "Beginnning scan of #{context.target} on #{(DateTime.utc_now |> DateTime.to_string) <> "\s" <> "(UTC)"}"

  #   targets = get_targets(mode, context)
  #   reports =
  #     targets
  #     |> ModuleArchives.run()
  #     |> extract_reports()
  #     |> send_reports(context)

  #   SingleOutput.put(reports, context)
  # end

  # defp get_targets(:single, %{uri: uri}) do
  #   load("Introspecting #{target}", "Done.", fn -> Introspector.query_introspect(uri) end)
  # end

  # defp extract_reports(endpoints) do
  #   endpoints
  #   |> Enum.flat_map(&pull_reports/1)
  # end

  # defp pull_reports(%Attercop.Endpoint{report: reports}), do: reports

  defp load(load_text, done_text, func) do
    spin_fun([text: load_text, done: "▸▸▸▸▸ " <> done_text, frames: :arrow3], func)
  end

end
