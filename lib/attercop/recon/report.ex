defmodule Attercop.Recon.Report do
  @moduledoc """
  Identify possible future pivots on a Field
  """

  defstruct field: nil, args: [], match: false

  alias Attercop.Field
  alias __MODULE__, as: Report

  @type match_result :: {:match, list(String.t())} | {:none, nil}

  @doc """
  Identify all possible pivot arguments based on a match_fun/1. (Defaults to matching on the substring "id")
  """
  @spec potential_pivots(fields :: list(%Field{}), match_fun :: (Field.t() -> boolean())) :: list(%Report{})
  def potential_pivots(fields, match_fun \\ &matches_id?/1) do
    fields
    |> Enum.map(fn field -> guess_pivots(field, match_fun) end)
    |> Enum.filter(&matches_filter?/1)
  end

  defp matches_filter?(%Report{match: match}), do: match

  @doc """
  Given a %Field{} struct, create a %Report{} struct that contains information about which values represent potential pivots.

  This function takes a `match_fun` as its second argument, which should return a boolean value indicating whether an argument should be considered a match.

  The match function defaults to the matches_id? function.
  """
  @spec guess_pivots(field :: Field.t(), match_fun :: (Field.t() -> boolean())) :: %Report{}
  def guess_pivots(field, match_fun \\ &matches_id?/1) do
    case matches(field, match_fun) do
      {:none, nil} ->
        %Report{field: field, args: [], match: false}

      {:match, matching_args} ->
        %Report{field: field, args: matching_args, match: true}
    end
  end

  @doc """
  Given a field and a match function, determine what args match.
  """
  @spec matches(field :: %Field{}, match_fun :: (String.t() -> boolean())) :: match_result
  def matches(field, match_fun) do
    matches = Enum.filter(field.args, &(match_fun.(&1)))

    case matches do
      [] ->
        {:none, nil}

      _ ->
        {:match, matches}
    end
  end

  defp matches_id?(arg) do
    arg
    |> String.match?(~r/id/i)
  end

end
