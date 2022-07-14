defmodule ElectionTest do
  use ExUnit.Case
  doctest Election

  setup do
    %{
      election: %Election{},
      candidate_election: %Election{
        candidates: [%Candidate{id: 1, name: "Rohit Sharma", votes: 0}],
        name: "Cricket Team",
        next_id: 2
      }
    }
  end

  test "updating the election name from the command", context do
    command = "name Cricket Team"
    election = Election.update(context.election, command)
    assert election == %Election{name: "Cricket Team"}
  end

  test "adding a new Candidate from a command", context do
    command = "add Rohit Sharma"
    election = Election.update(context.election, command)

    assert election == %Election{
             candidates: [%Candidate{id: 1, name: "Rohit Sharma"}],
             next_id: 2
           }
  end

  test "voting for a candidate from a command", context do
    command = "vote 1"
    election = Election.update(context.candidate_election, command)

    assert election == %Election{
             candidates: [%Candidate{id: 1, name: "Rohit Sharma", votes: 1}],
             name: "Cricket Team",
             next_id: 2
           }
  end

  test "quitting the app", context do
    command = "quit"
    quit_application = Election.update(context.election, command)

    assert :quit == quit_application
  end

  test "invalid command", context do
    command = "invalid command"
    election = Election.update(context.election, command)

    assert election == %Election{}
  end
end
