defmodule Attercop.Args do
  @moduledoc """
  "You will never find a more wretched hive of args and fakery. Please be cautious."

  Generate syntactically correct GraphQL parameters and values. Allows for the provision of a module to handle stubbing.

  Intended for use in GraphQL requests where a field must be used that requires certain arguments, but where the arguments do not matter for the sake of the test/module.

  E.g. 

  ```
  query {
    someField(<GENERATED ARG STRING GOES HERE>) {
      ...
    }
  }
  ```

  See `Attercop.Args.generate_args/3` for details.
  """

  @doc """
  Given a list of args, produce a string that can be substituted in the arguments portion of a GraphQL query/mutation string.
  
  ## Examples:
  #### Basic usage:
  ```
  Args.generate_args(["foo", "bar", "baz"])
  # => "foo: 10, bar: "fakedata", baz: "morefakedata""
  ```
  
  #### Exclude arguments:
  ```
  Args.generate_args(["foo", "bar", "baz"], ["bar"])
  # => "foo: 10, baz: "morefakedata""
  ```

  #### Specify a module to use for stubbing/faking:
  ```
  Args.generate_args(["foo", "bar", "baz"], [], Custom.StubbingModule)
  # => "..."
  ```
  *Note: Module must implement the* `Attercop.StubBehaviour` *behaviour.*

  #### Rationale:
  The intention being that the string produced by this function may be used in a GraphQL query/mutation where arguments are required but not relevant to the current test logic, like:

  ```
  query {
    someField(<GENERATED ARG STRING GOES HERE>) {
      ...
    }
  }
  ```
  """
  @spec generate_args(args :: list(String.t), custom_args :: list(Map.t), stubmodule :: module()) :: String.t
  def generate_args(args, custom_arg \\ [],  stubmodule \\ Attercop.Stub) do
    args
    |> defaults(custom_arg)
    |> generate_stubs(stubmodule)
    |> custom(custom_arg)
    |> String.trim(", ") ## Get rid of trailing characters
  end

  defp custom(arg_string, custom_arg) do
    custom_arg
    |> parse_custom()
    |> Kernel.<>(arg_string)
  end

  defp parse_custom(custom_arg) do
    custom_arg
    |> custom_arg_string()
  end

  defp custom_arg_string(arg) do
    {name, value} = arg
    "#{name}: \"#{value}\",\s"
  end

  defp generate_stubs(args, stubmodule) do
    args
    |> Enum.reduce("", fn argname, argstring ->
      argstring <> fake_arg(argname, stubmodule)
    end)
  end

  defp defaults(args, custom_arg) do ## list of only args not in the custom_args list
    args
    |> Enum.reject(fn argname ->
      custom_arg_name = custom_arg |> custom_name()
      custom_arg_name == argname
    end)
  end

  defp custom_name(custom_arg) do
    {argname, _} = custom_arg
    argname
  end

  defp fake_arg(argname, stubmodule) do
    lookup(argname, stubmodule)
    |> format_arg
  end

  defp lookup(argname, stubmodule) do
    {argname, stubmodule.stub(argname)}
  end

  defp format_arg({_name, nil}), do: "" ## If an argument is unknown, don't fake it.
  defp format_arg({name, value}) do
    "#{name}: \"#{value}\",\s"
  end
end
