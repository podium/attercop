defmodule IntrospectorTest do
  use ExUnit.Case, async: true
  import Mox
  doctest Attercop.Introspector

  alias Attercop.Introspector
  alias Attercop.Field
  alias Attercop.ClientMock

  setup :verify_on_exit!

  describe "introspect_query!/3" do

    @tag :skip ## TODO FIXME
    test "correctly introspects and structures fields" do
      ClientMock
      |> expect(:query, fn _req ->
	{:ok,
	 %Neuron.Response{
	   body: %{
	     "data" => %{
	       "__schema" => %{
		 "queryType" => %{
		   "fields" => [
		   %{
		     "args" => [%{"argName" => "foo"}, %{"argName" => "bar"}],
		     "fieldName" => "fooField",
		     "type" => %{
		       "fieldType" => "OBJECT",
                       "subFields" => [
			 %{"name" => "foo", "type" => %{"subFieldType" => "SCALAR"}},
                       ]
		     }
		   },
		   %{
		     "args" => [%{"argName" => "baz"}, %{"argName" => "bang"}],
		     "fieldName" => "bazField",
		     "type" => %{
		       "fieldType" => "OBJECT",
                       "subFields" => [
			 %{"name" => "bar", "type" => %{"subFieldType" => "SCALAR"}},
                       ]
		     }
		   },
		   %{
		     "args" => [%{"argName" => "quux"}, %{"argName" => "zork"}],
		     "fieldName" => "quuxField",
		     "type" => %{
		       "fieldType" => "OBJECT",
                       "subFields" => [
			 %{"name" => "baz", "type" => %{"subFieldType" => "SCALAR"}},
                       ]
		     }
		   },
		 ]
		 }
	       }
	     }
	   }
	 }
	}
      end)
      
      assert Introspector.query_introspect!("https://www.example.com", "/foo/bar/graphql", ClientMock) ==
	[
	  %Field{name: "fooField", type: :OBJECT, args: ["foo", "bar"], subfields: [%Field{name: "foo", type: :SCALAR}]},
	  %Field{name: "bazField", type: :OBJECT, args: ["baz", "bang"], subfields: [%Field{name: "bar", type: :SCALAR}]},
	  %Field{name: "quuxField", type: :OBJECT, args: ["quux", "zork"], subfields: [%Field{name: "baz", type: :SCALAR}]},
	]
    end

    @tag :skip ## TODO FIXME
    test "marks null subfields as empty arrays" do
      ClientMock
      |> expect(:query, fn _req ->
	{:ok,
	 %Neuron.Response{
	   body: %{
	     "data" => %{
	       "__schema" => %{
		 "queryType" => %{
		   "fields" => [
		   %{
		     "args" => [%{"argName" => "foo"}, %{"argName" => "bar"}],
		     "fieldName" => "fooField",
		     "type" => %{
		       "fieldType" => "OBJECT",
                       "subFields" => nil
		     }
		   },
		 ]
		 }
	       }
	     }
	   }
	 }
	}
      end)

      assert Introspector.query_introspect!("https://www.example.com", "/foo/bar/graphql", ClientMock) == [
	%Field{name: "fooField", type: :OBJECT, args: ["foo", "bar"], subfields: []},
      ]
    end
  end

  describe "response_from_valid_endpoint?/1" do
    test "false on 404" do
      non_existent = { :ok, %Neuron.Response{status_code: 404} }
      assert Introspector.response_from_valid_path?(non_existent) == false
    end

    test "true for a 200" do
      exists = { :ok, %Neuron.Response{status_code: 200} }
      assert Introspector.response_from_valid_path?(exists) == true
    end
  end


end
