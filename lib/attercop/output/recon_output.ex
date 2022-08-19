defmodule Attercop.Output.ReconOutput do

  alias Attercop.Utils.Formatter
  alias TableRex.Table

  def put(reports, _opts) do
    reports
    |> Formatter.recon_format_rows()
    |> generate_table_output()
    |> IO.puts
  end

  def generate_table_output([]) do
    IO.puts "No potential pivots found"
  end

  def generate_table_output(rows) do
    title  = "Attercop Reconnaissance"
    header = ["URL", "Field Name", "Argument"]

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
