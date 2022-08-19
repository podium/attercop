defmodule Attercop.Utils.Formatter do

  alias Attercop.Recon.Report, as: ReconReport
  alias Attercop.Report

  # def row_format(reports) do
  #   reports
  #   |> Enum.map(&generate_row/1)
  # end

  # ## A row looks like:
  # #      URL                     |  Field Name  |   Status   |         Args          | Confidence Rating |      Reason
  # defp generate_row(%Report{confidence: confidence, field: field, reason: reason, status: status, path: path, host: host}) do
  #   [
  #     host <> path,
  #     field.name,
  #     status,
  #     field.args |> Enum.join(", "),
  #     confidence,
  #     reason
  #   ]
  # end

  ## A row looks like:
  #      URL                     |  Field Name  |  Arg   |
  def recon_format_rows(reports) do
    reports
    |> Enum.flat_map(&recon_generate_row/1)
  end

  defp recon_generate_row(%ReconReport{field: field, args: args}) do
    args
    |> Enum.map(fn arg ->
      [
        field.uri,
        field.name,
        arg
      ]
    end)
  end

end
