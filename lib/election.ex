defmodule Election do
  defstruct(
    name: "",
    candidates: [],
    next_id: 1
  )

  def run() do
    %Election{} |> run()
  end

  def run(:quit), do: :quit

  def run(election = %Election{}) do
    [IO.ANSI.clear(), IO.ANSI.cursor(0, 0)]
    |> IO.write()

    election
    |> view()
    |> IO.write()

    command = IO.gets(">")

    election
    |> update(command)
    |> run()
  end

  @doc """
  Updates Election Struct, based on provided command

  ## Parameters

    - election: Election Struct
    - cmd: String based command. Each command can be shortened to what's shown in parenthesis.
      - (n)ame command updates the election name
        - example: "n Cricket Team"
      - (a)dd command adds the new candidate
        - example: "a Virat Kholi"
      - (v)ote command increments the vote count for the candidate
        - example: "v 1"
      - (q)uit command returns a quit atom
        - example: "q"

  Return `Election` struct

  ## Examples

      iex> %Election{} |> Election.update("n Cricket Team")
      %Election{name: "Cricket Team"}
  """

  def update(election, cmd) when is_binary(cmd) do
    update(election, String.split(cmd))
  end

  def update(election = %Election{}, ["n" <> _ | args]) do
    name = Enum.join(args, " ")
    Map.put(election, :name, name)
  end

  def update(election = %Election{}, ["a" <> _ | args]) do
    candidate_name = Enum.join(args, " ")
    candidate = Candidate.new(election.next_id, candidate_name)
    candidates = [candidate | election.candidates]
    %{election | candidates: candidates, next_id: election.next_id + 1}
  end

  def update(election = %Election{}, ["v" <> _, candidate_id]) do
    vote(election, Integer.parse(candidate_id))
  end

  def update(_election, ["q"<>_]), do: :quit

  def update(election, _), do: election

  defp vote(election = %Election{}, {id, _}) do
    candidates = Enum.map(election.candidates, &maybe_inc_vote(&1, id))
    Map.put(election, :candidates, candidates)
  end

  defp vote(election, _errors), do: election

  defp maybe_inc_vote(candidate, id) when is_integer(id) do
    maybe_inc_vote(candidate, candidate.id == id)
  end

  defp maybe_inc_vote(candidate, _inc_vote = true) do
    Map.update!(candidate, :votes, &(&1 + 1))
  end

  defp maybe_inc_vote(candidate, _inc_vote = false), do: candidate

  def view_header(election = %Election{}) do
    [
      "\nElection for: #{election.name}\n"
    ]
  end

  def view_body(election = %Election{}) do
    election.candidates
    |> sort_candidates_by_votes_desc()
    |> candidates_to_string()
    |> prepend_candidates_header(election.candidates)
  end

  def view_footer() do
    ["\n\n", "commands: (n)ame <election>, (a)dd <candidate>, (v)ote <id>, (q)uit\n"]
  end

  def view(election = %Election{}) do
    [
      view_header(election),
      view_body(election),
      view_footer()
    ]
  end

  defp sort_candidates_by_votes_desc(candidates) do
    candidates
    |> Enum.sort(&(&1.votes >= &2.votes))
  end

  defp candidates_to_string(candidates) do
    candidates
    |> Enum.map(fn %{id: id, votes: votes, name: name} ->
      "#{id}\t#{votes}\t#{name}\n"
    end)
  end

  defp prepend_candidates_header(candidates_string, candidates) do
    case length(candidates) do
      0 ->
        ""

      _ ->
        [
          "\n***\tCandidates List\t***\n",
          "---------------------------\n",
          "ID\tVotes\tName\n",
          "---------------------------\n" | candidates_string
        ]
    end
  end
end
