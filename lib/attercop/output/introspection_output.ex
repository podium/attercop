defmodule Attercop.Output.IntrospectionOutput do

  alias Attercop.Utils.Formatter
  alias TableRex.Table

  def put(fields, %{no_truncate: no_truncate}) do
    fields
    |> format_rows()
    |> truncate_filter(no_truncate)
    |> generate_table_output()
    |> IO.puts
  end

  defp format_rows(fields) do
    fields
    |> Enum.map(fn field ->
      [
        field.name,
        field.type,
        field.args |> Enum.join(", "),
        field.subfields |> Enum.map(fn sub_field -> sub_field.name end) |>Enum.join(", ")
      ]
    end)
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

  defp truncate_filter([], _), do: []
  defp truncate_filter([_ | _] = rows, _no_truncate = 1), do: rows
  defp truncate_filter([_ | _] = rows, _no_truncate = 0) do
    rows = rows |> Enum.map(&truncate/1)
    rows
  end

  defp generate_table_output([]) do
    IO.puts "No fields found"
  end

  defp generate_table_output(rows) do
    title  = "Introspection Data"
    header = ["Field Name", "Type", "Args", "Subfields"]

    Table.new(rows, header, title)
    |> Table.put_column_meta(0..1, align: :left)
    |> Table.put_column_meta(2, align: :center)
    |> Table.put_column_meta(2, color: :yellow)
    |> Table.put_column_meta(3, align: :left, color: :light_blue)
    |> Table.put_column_meta(4, align: :center, color: :green)
    |> Table.put_column_meta(5, align: :center, color: :yellow)
    |> Table.put_header_meta(0..2, align: :center, color: [IO.ANSI.color_background(31), :white])
    |> Table.sort(0)
    |> Table.sort(2)
    |> Table.render!(top_frame_symbol: "=", title_separator_symbol: "=", header_separator_symbol: "=", horizontal_style: :all)
  end
end
