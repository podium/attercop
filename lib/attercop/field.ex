defmodule Attercop.Field do

  @moduledoc """
  An abstraction around a GraphQL field (an endpoint) with utility functions to determine if there is useful data within that field.
  """

  defstruct name: "", type: "", args: [], subfields: [], uri: ""

  @doc """
  Determine if there are any subfields in the field that are scalar types. This can be used for simple query generation where non-nested fields are needed.

  ### Example
     iex> %Attercop.Field{ subfields: [ %Attercop.Field{ type: :SCALAR}] } |> Attercop.Field.has_scalars?
     true
  """
  @spec has_scalars?(field :: %Attercop.Field{}) :: bool()
  def has_scalars?(%Attercop.Field{} = field) do
    field.subfields
    |> Enum.any?(&scalar?/1)
  end

  @doc """
  Determine whether or not the given field is a scalar.

  ### Example:
     iex> %Attercop.Field{type: :SCALAR} |> Attercop.Field.scalar?
     true
     iex> %Attercop.Field{type: :SOMETHING_ELSE} |> Attercop.Field.scalar?
     false
  """
  @spec scalar?(field :: %Attercop.Field{}) :: bool()
  def scalar?(%Attercop.Field{} = field) do
    field.type == :SCALAR
  end

  @doc """
  Given a field struct, return any subfields that it contains.

  ## Example:
     iex> %Attercop.Field{ subfields: [ %Attercop.Field{name: "foo", type: :SCALAR } ]} |> Attercop.Field.scalar_subfields
     [%Attercop.Field{name: "foo", type: :SCALAR}]
  """
  @spec scalar_subfields(field :: %Attercop.Field{}) :: list(%Attercop.Field{})
  def scalar_subfields(%Attercop.Field{subfields: subfields}) do
    subfields
    |> Enum.filter(&scalar?/1)
  end

end
