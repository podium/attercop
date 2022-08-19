defmodule ArgsTest do
  use ExUnit.Case, async: true
  alias Attercop.Args
  alias Attercop.StubMock

  doctest Attercop.Args

  import Mox

  @tag :skip ## Obsolete, rewrite in V2
  describe "generate_args/2" do
    test "produces an empty string for no arguments" do
      assert Args.generate_args([]) == ""
    end

    @tag :skip ## Obsolete, rewrite in V2
    test "produces a graphql compatible string of arguments and values to look up with one argument" do
      StubMock
      |> expect(:stub, fn _name -> "Foo" end)

      assert Args.generate_args(["Bar"], [], StubMock) == "Bar: \"Foo\",\s"
    end
    
    @tag :skip ## Obsolete, rewrite in V2
    test "produces a graphql compatible string of arguments and values to look up with many arguments" do
      StubMock
      |> expect(:stub, fn _name -> "foo" end)
      |> expect(:stub, fn _name -> "bar" end)
      |> expect(:stub, fn _name -> "baz" end)
      
      
      assert false
    end
    
    @tag :skip ## Obsolete, rewrite in V2
    test "substitutes custom arguments with specified values" do
      StubMock
      |> expect(:stub, fn _name -> "" end)
      |> expect(:stub, fn _name -> "" end)
      
      assert false
    end
    
  end
end
  
  
