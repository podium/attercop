defmodule Attercop.Output.SingleOutput do

  @moduledoc """
  Attercop.Output exposes a single function (put/2) which outputs a table containing scan data, or a message when no meaningful data is returned from a scan.
  """

  alias Attercop.Utils.Formatter
  alias TableRex.Table

  def put(reports, %{verbose: verbosity, no_truncate: no_truncate}) do
    Formatter.row_format(reports)
    |> create_table(verbosity, no_truncate)
    |> IO.puts
  end

  defp create_table(data, verbosity, no_truncate) do
    original_count = length(data)

    data
    |> verbosity_filter(verbosity)
    |> truncate_filter(no_truncate)
    |> generate_table_output(original_count)
  end

  defp generate_table_output({:error, :empty}, original_count) do
    IO.puts "\n\"It ought to be here, but it isn't.\"\n\nNo data was returned. 0 of #{original_count} endpoints shown. Use --verbose to show omitted targets."
  end

  defp generate_table_output({:ok, rows}, original_count) do
    title  = "Attercop Report"
    header = ["URL", "Field Name", "Status", "Args", "Confidence Rating", "Reason"]

    Table.new(rows, header, title)
    |> Table.put_column_meta(0..1, align: :left)
    |> Table.put_column_meta(2, align: :center)
    |> Table.put_column_meta(2, color: &color_code_status/2)
    |> Table.put_column_meta(3, align: :left, color: :light_blue)
    |> Table.put_column_meta(4, align: :center, color: &color_code_confidence/2)
    |> Table.put_column_meta(5, align: :center, color: :yellow)
    |> Table.put_header_meta(0..5, align: :center, color: [IO.ANSI.color_background(31), :white])
    |> Table.sort(0)
    |> Table.sort(2)
    |> Table.render!(top_frame_symbol: "=", title_separator_symbol: "=", header_separator_symbol: "=", horizontal_style: :all)
    |> render_scan_metadata(original_count, length(rows))
  end

  defp color_code_status(text, value) do
    case value do
      "vulnerable"          -> [:red, text]
      "not_vulnerable"      -> [:green, text]
      "not_testable"        -> [:yellow, text]
      "potential_candidate" -> [:inverse, text]
      "non_candidate"       -> [:blue, text]
      "unknown"             -> [:black, text]
      _                     -> text
    end
  end

  defp color_code_confidence(text, value) do
    case value do
      "high_confidence" -> [:red, text]
      "low_confidence"  -> [:yellow, text]
      _                 -> text
    end
  end

  defp render_scan_metadata(rendered_table, original_count, end_count) do
    cond do
      original_count == 0
        -> "\n\nNo targets found."
      original_count - end_count == 0
        -> rendered_table <> "\n\n#{end_count} of #{original_count} targets shown."
      true
        -> rendered_table <> "\n\n#{end_count} of #{original_count} targets shown. Use --verbose to show omitted targets."
    end
  end

  defp verbosity_filter(rows, _verbosity = 1), do: {:ok, rows}
  defp verbosity_filter(rows, _verbosity = 0) do
    rows
    |> Enum.reject(&non_candidate?/1)
    |> validate_rows()
  end

  defp truncate_filter({:error, :empty}, _), do: {:error, :empty}
  defp truncate_filter({:ok, rows}, _no_truncate = 1), do: {:ok, rows}
  defp truncate_filter({:ok, rows}, _no_truncate = 0) do
    rows = rows |> Enum.map(&truncate/1)
    {:ok, rows}
  end


  @truncate_max_len 42

  defp truncate(row) do
    args = row |> Enum.at(3)
    if String.length(args) > @truncate_max_len do
      trunc_args = String.slice(args, 0, @truncate_max_len) <> "..."
      List.replace_at(row, 3, trunc_args)
    else
      row
    end
  end

  @candidacy_index 2

  defp non_candidate?(row) do
    row
    |> Enum.at(@candidacy_index) == :non_candidate
  end

  defp validate_rows([]),   do: {:error, :empty}
  defp validate_rows(rows), do: {:ok, rows}

end
