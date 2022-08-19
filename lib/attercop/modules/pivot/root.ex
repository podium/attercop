defmodule Attercop.Module.Pivot.Root do
  # @behaviour Attercop.ModuleBehaviour

  # alias Attercop.Args
  # alias Attercop.Client
  # alias Attercop.Field
  # alias Attercop.Module.Pivot.Stub
  # alias Attercop.Utils.Compare

  # @moduledoc """
  # Pivot on an id or uid
  # """
  # def report(%Attercop.Endpoint{} = endpoint) do
  #   %{endpoint | report: endpoint.fields_list |> Enum.map(&vuln/1)}
  # end

  # @doc """
  # Check to see if a field contains an Uid and attempt to pivot on that Id. If substituting a different  Id produces an error mark the field as safe, but if it produces any other output flag it as a possible vulnerability.
  # """
  # @impl ModuleBehaviour
  # @spec vuln(field :: %Attercop.Field{}, client :: module) :: %Attercop.Report{}
  # def vuln(%Attercop.Field{} = field, client \\ Client) do
    
  #   cond do
  #     has_id?(field) and not Field.has_scalars?(field)
  #       -> generate_report(:potential_candidate, field, :high_confidence, "Has Uid, but lacks Scalars")
  #     has_id?(field) and lacking_required_args?(field)
  #       -> generate_report(:potential_candidate, field, :high_confidence, "Missing one or more of: " <> field.args |> Enum.join(", "))
  #     not has_id?(field)
  #       -> generate_report(:non_candidate, field, :high_confidence, "No Uid")
  #     true
  #       -> pivot!(field, client)
  #   end
  # end

  # @doc """
  # The only fields that are vulnerable to pivoting on the Uid field are ones that *have* and Uid field.  Filter them out here.
  # """
  # @impl ModuleBehaviour
  # @spec testable_field?(%Attercop.Field{}) :: boolean()
  # def testable_field?(%Attercop.Field{} = field) do
  #   has_id?(field) and
  #   field |> Field.has_scalars?
  # end

  # def lacking_scalars?(field) do
  #   has_id?(field) and (not Field.has_scalars?(field))
  # end

  # defp lacking_required_args?(%Attercop.Field{} = field) do
  #   false
  #   #field.args |> length() > 1 ## TODO: Fixme (find a more intelligent way of figuring out required args)
  # end

  # defp has_id?(%Attercop.Field{} = field) do
  #   field.args
  #   |> Enum.any?(&matches_uid?/1)
  # end

  # defp matches_uid?(arg) do
  #   Regex.match?(~r/uid/i, arg)
  # end

  # defp fetch_uid_name(%Attercop.Field{} = field) do
  #   field.args
  #   |> Enum.filter(&matches_uid?/1)
  #   |> extract_uid_name(field)
  # end

  # def extract_uid_name([arg], _field), do: arg
  # def extract_uid_name(args, field) do
  #   IO.warn "Got multiple matches for Uid arguments on field #{field.name}:\n#{args |> inspect}"

  #   args |> Enum.at(0)
  # end

  # defp _ids(%Attercop.Field{} = field) do
  #   {_uid_a, _uid_b} = _id_values()

  #   [
  #     {fetch_uid_name(field), _uid_a}, ## Names of the uid are not always consistent, fetch_uid_name will
  #     {fetch_uid_name(field), _uid_b}, #  get the correct name
  #   ]
  # end

  # defp _id_values do
  #   Stub._ids()
  # end

  # defp pivot!(%Attercop.Field{} = field, client \\ Client) do
  #   field
  #   |> execute_pivot_queries(client)
  #   |> pivot_report(field)
  # end

  # defp execute_pivot_queries(%Attercop.Field{} = field, client \\ Client) do
  #   field
  #   |> generate_queries()
  #   |> generate_requests(field.host, field.path)
  #   |> Enum.map(&client.query/1)
  #   |> Enum.map(&extract_response/1)
  # end

  # defp pivot_report([a, b] = _responses, %Attercop.Field{} = field) do
  #   if Compare.nil_bodies?(a, b) do
  #     generate_report(:not_testable, field, :high_confidence, :nil_bodies)
  #   else
  #     parse_bodies(a, b, field)
  #   end
  # end

  # # defp non_nil_bodies?(a, b) do
  # #   a.body["data"] && b.body["data"]
  # # end

  # defp parse_bodies(a, b, %Attercop.Field{} = field) do
  #   cond do ## Note: The order of these checks matters
  #     mismatched_errors?(a, b) ## If one produces error and another does not, mark not vulnerable
  #       -> generate_report(:not_vulnerable, field, :high_confidence, :mismatched_errors)
  #     not data_returned?(a, b) ## If no data is returned mark it as not-vulnerable
  #       -> generate_report(:not_vulnerable, field, :high_confidence, :no_data_returned)
  #     not identical_keys?(a, b) ## If different shapes are returned, something odd is happening
  #       -> generate_report(:unknown, field, :unknown, :unknown_reason)
  #     identical_bodies?(a, b) ## If the returned data matches in every way, low confidence vuln
  #       -> generate_report(:vulnerable, field, :low_confidence, :identical_bodies)
  #     mismatched_values?(a, b) ## If the keys match, but the values do not, mark high confidence
  #       -> generate_report(:vulnerable, field, :high_confidence, :mismatched_values)
  #     non_nil_error_states(a, b) ## The endpoint is currently not testable for another reason
  #       -> generate_report(:error, field, a.body.error <> "\n\n" <> b.body.error, :unknown_reason)
  #   end
  # end

  # defp data_returned?(a, b) do
  #   Compare.data_returned?(a, b)
  # end

  # defp identical_bodies?(a, b) do
  #   Compare.data_matches?(a, b)
  # end

  # defp identical_keys?(a, b) do
  #   Compare.keys_match_deeply?(a.body, b.body)
  # end

  # defp mismatched_errors?(a, b) do
  #   not Compare.errors_match?(a, b)
  # end

  # defp mismatched_values?(a, b) do
  #   Compare.keys_match_deeply?(a.body, b.body) and a != b
  # end

  # defp non_nil_error_states(a, b) do
  #   not (is_nil(a.body["error"]) && is_nil(b.body["error"]))
  # end
  # ##################################################################################################
  # # In generate_queries/1: custom_args should be a list of Tuples,			 	   #
  # # when you would like to pivot on an argument you can simply say			 	   #
  # # custom_args = [									 	   #
  # #   {"Uid", "1234"},							 	   #
  # #   {"Uid", "5678"},							 	   #
  # # ]											 	   #
  # # and two queries will be generated, one for							   #
  # # each custom arg you wish to pivot upon.							   #
  # ##################################################################################################
  # defp generate_queries(%Attercop.Field{} = field) do
  #   _ids(field)
  #   |> Enum.map(fn arg ->
  #   """
  #   query {
  #     #{field.name}(#{Args.generate_args(field.args, arg, Attercop.Module.Pivot.Stub)}) {
  #       #{Field.scalar_subfields(field) |> Enum.map(fn fld -> Map.get(fld, :name) end) |> Enum.join(", ")}
  #     }
  #   }
  #   """
  #   end)
  # end

  # defp generate_requests(queries, host, path) do
  #   queries
  #   |> Enum.map(fn query ->
  #     %Attercop.Client.Request{host: host, path: path, query: query}
  #   end)
  # end

  # defp extract_response({_, %Neuron.Response{} = resp}), do: resp

  # defp generate_report(status, field, confidence, reason) do
  #   %Attercop.Report{
  #     module_name: "Pivot",
  #     host: field.host,
  #     path: field.path,
  #     status: status,
  #     field: field,
  #     confidence: confidence,
  #     reason: reason
  #   }
  # end

end
