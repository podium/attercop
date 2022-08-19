defmodule Attercop.Module.Pivot.Stub do
  @moduledoc """
  Read config file for Pivoting and provide a way to stub in values where they are missing.
  """
  def stub(argname, file_reader_module \\ File) do
    read_config(file_reader_module)
    |> Map.get("A")
    |> Map.get(argname)
  end

  def ids(file_reader_module \\ File) do
    fake = read_config(file_reader_module)

    {fake["A"]["uid"], fake["B"]["uid"]}
  end

  defp read_config(file \\ "lib/attercop/modules/pivot/pivot_default_data.json", file_reader_module) do
    {:ok, data} = file_reader_module.read(file)
    |> parse_json_contents(file)
    |> Jason.decode()

    data
  end

  defp parse_json_contents({:ok, data}, _file), do: data
  defp parse_json_contents({:error, :enoent}, file) do
    IO.puts "Unable to find file! enoent: #{file}"
  end

  

end
