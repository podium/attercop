defmodule Utils.CompareTest do
  @moduledoc """
  Tests for Attercop.Utils.Compare
  """
  use ExUnit.Case, async: true
  doctest Attercop.Utils.Compare
  alias Attercop.Utils.Compare

  describe "keys_match_deeply?/2" do

    test "handles empty maps correctly" do
      assert Compare.keys_match_deeply?(%{}, %{}) == true
    end

    test "handles comparison of empty to non-empty correctly" do
      assert Compare.keys_match_deeply?(%{}, %{foo: "bar"}) == false
      assert Compare.keys_match_deeply?(%{foo: "bar"}, %{}) == false
    end

    test "handles comparison of two idential non-nested maps correctly" do
      assert Compare.keys_match_deeply?(%{foo: "bar"}, %{foo: "bar"}) == true
    end

    test "handles comparison of two non-identical non-nested maps correctly" do
      assert Compare.keys_match_deeply?(%{foo: "bar"}, %{bar: "foo"}) == false
    end

    test "handles comparison of a nested map to one with identical keys, but mis-matched data" do
      a = %{
        foo: "bar",
        baz: %{
          bang: "quux"
        }
      }

      b = %{
        foo: "zork",
        baz: %{
          bang: "thud"
        }
      }

      assert Compare.keys_match_deeply?(a, b) == true
    end

    test "handles cases where nested keys are mismatched" do
      a = %{
        foo: "bar",
        baz: %{
          bang: "quux"
        }
      }

      b = %{
        foo: "oof",
        baz: %{
          zork: "xuuq"
        }
      }

      assert Compare.keys_match_deeply?(a, b) == false
    end

    test "handles cases where all key names are the same, but are in a different order" do
      a = %{
        zork: "oof",
        foo: %{
          baz: "xuuq"
        }
      }

      b = %{
        baz: "oof",
        foo: %{
          zork: "xuuq",
        }
      }

      assert Compare.keys_match_deeply?(a, b) == false
    end

    test "correctly handles cases where the bottom most value is an empty map" do
      a = %{
        zork: "oof",
        foo: %{}
      }

      assert Compare.keys_match_deeply?(a, a) == true
    end

  end

  describe "nil_bodies?/2" do
    test "is true when both bodies are nil" do
      a = %Neuron.Response{body: %{"data" =>  nil}}
      b = %Neuron.Response{body: %{"data" =>  nil}}

      assert Compare.nil_bodies?(a, b) == true
    end

    test "is false when one body is non-nil" do
      a = %Neuron.Response{body: %{"data" =>  "foo"}}
      b = %Neuron.Response{body: %{"data" =>  nil}}

      assert Compare.nil_bodies?(a, b) == false
    end

    test "is false when both bodies are non-nil" do
      a = %Neuron.Response{body: %{"data" =>  "foo"}}
      b = %Neuron.Response{body: %{"data" =>  "bar"}}

      assert Compare.nil_bodies?(a, b) == false
    end
  end

  describe "errors_match?/2" do
    test "is false when the one has an error and the other does not" do
      a = %Neuron.Response{body: %{error: "foo"}}
      b = %Neuron.Response{body: %{"data" =>  "bar"}}

      assert Compare.errors_match?(a, b) == false
    end

    test "is true when both have errors and the messages match" do
      a = %Neuron.Response{body: %{error: "foo"}}
      b = %Neuron.Response{body: %{error: "foo"}}

      assert Compare.errors_match?(a, b) == true
    end

    test "is false when both have errors and the messages mismatch" do
      a = %Neuron.Response{body: %{error: "foo"}}
      b = %Neuron.Response{body: %{error: "bar"}}

      assert Compare.errors_match?(a, b) == false
    end

    test "is true when there are no error messages to be found" do
      a = %Neuron.Response{body: %{"data" =>  "baz"}}
      b = %Neuron.Response{body: %{"data" =>  "bar"}}

      assert Compare.errors_match?(a, b) == true
    end
  end

  describe "data_matches?/2" do
    test "is true when no data is present in either case" do
      a = %Neuron.Response{body: %{}}
      b = %Neuron.Response{body: %{}}

      assert Compare.data_matches?(a, b) == true
    end

    test "is false when no data is present in only one case" do
      a = %Neuron.Response{body: %{"data" => "foo"}}
      b = %Neuron.Response{body: %{}}

      assert Compare.data_matches?(a, b) == false
    end

    test "is true when the data key is present and it is identical" do
      a = %Neuron.Response{body: %{"data" => "foo"}}
      b = %Neuron.Response{body: %{"data" => "foo"}}

      assert Compare.data_matches?(a, b) == true
    end

    test "is false when there is data, but it mismatches" do
      a = %Neuron.Response{body: %{"data" => "foo"}}
      b = %Neuron.Response{body: %{"data" => "bar"}}

      assert Compare.data_matches?(a, b) == false
    end

  end

  describe "data_returned/2" do
    test "false when no data is present" do
      a = %Neuron.Response{
        body: %{
          "error" => %{
            "Something" => "Something Else"
          }
        }
      }

      b = %Neuron.Response{
        body: %{
          "error" => "Error message"
        }
      }

      assert Compare.data_returned?(a, b) == false
    end

    test "true when data of any kind is present" do
      a = %Neuron.Response{
        body: %{
          "data" => %{
            "Something" => "Something Else"
          }
        }
      }

      b = %Neuron.Response{
        body: %{
          "data" => %{
            "moar_data" => "foo"
          }
        }
      }

      assert Compare.data_returned?(a, b) == true
    end

    test "false when only one response has data" do
      a = %Neuron.Response{
        body: %{
          "data" => %{
            "Something" => "Something Else"
          }
        }
      }

      b = %Neuron.Response{
        body: %{
          "error" => %{
            "Something" => "Something Else"
          }
        }
      }

      assert Compare.data_returned?(a, b) == false
    end

    test "true when data is present" do
      a = %Neuron.Response{
        body: %{
          "data" => %{
            "Something" => "Something Else"
          }
        }
      }

      b = %Neuron.Response{
        body: %{
          "data" => %{
            "Something" => "Something Else"
          }
        }
      }

      assert Compare.data_returned?(a, b) == true
    end

  end
end
