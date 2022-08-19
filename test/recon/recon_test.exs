defmodule ReportTest do
  use ExUnit.Case, async: true

  alias Attercop.Field,        as: Field
  alias Attercop.Recon.Report, as: Report

  describe "potential_pivots/2" do
    test "returns an empty list when given an empty list" do
      fields    = []
      match_fun = fn _x -> true end

      assert Report.potential_pivots(fields, match_fun) == []
    end

    test "returns an empty list when given a list where no values match" do
      fields    = [%Field{}, %Field{}, %Field{}]
      match_fun = fn _x -> false end

      assert Report.potential_pivots(fields, match_fun) == []
    end

    test "returns a list of fields of equal length to original list when all values match" do
      fields    = [%Field{args: ["foo"]}, %Field{args: ["foo"]}, %Field{args: ["foo"]}]
      match_fun = fn _x -> true end

      assert length(Report.potential_pivots(fields, match_fun)) == length(fields)
    end

    test "correctly filters out any Reports that did not match the match_fun" do
      matching_field     = %Field{args: ["should match", "foo", "bar"]}
      non_matching_field = %Field{args: ["should not match", "foo", "bar"]}
      fields    = [matching_field, non_matching_field, non_matching_field]
      match_fun = fn x -> x == "should match" end

      assert Report.potential_pivots(fields, match_fun) == [%Report{field: matching_field, args: ["should match"], match: true}]
    end

  end

  describe "guess_pivots/2" do
    test "produces a non-matching report when no field is matched" do
      match_fun = fn argstring -> String.match?(argstring, ~r/id/i) end
      field     = %Field{name: "fooField", args: ["foo", "bar", "baz", "bang"]}

      assert Report.guess_pivots(field, match_fun) == %Report{field: field, args: [], match: false}
    end

    test "produces a matching report when a single valid id is found" do
      match_fun = fn argstring -> String.match?(argstring, ~r/id/i) end
      field     = %Field{name: "fooField", args: ["foo", "bar", "baz", "uid"]}

      assert Report.guess_pivots(field, match_fun) == %Report{field: field, args: ["uid"], match: true}
    end

    test "produces a matching report when multiple values are found" do
      match_fun = fn argstring -> String.match?(argstring, ~r/id/i) end
      field     = %Field{name: "fooField", args: ["foo", "bar", "baz", "uid", "uid", "baz", "zork"]}

      assert Report.guess_pivots(field, match_fun) == %Report{field: field, args: ["uid", "uid"], match: true}
    end

  end

  describe "matches/2" do
    test "returns the correct data for no matches" do
      field     = %Field{}
      match_fun = fn _x -> false end
      assert Report.matches(field, match_fun) == {:none, nil}
    end

    test "returns the correct data for non-zero number of matches" do
      field     = %Field{name: "fooField", args: ["foo", "bar", "baz"]}
      match_fun = fn _x -> true end

      assert Report.matches(field, match_fun) == {:match, ["foo", "bar", "baz"]}
    end

  end

end
