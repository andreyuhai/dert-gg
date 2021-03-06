defmodule DertGGWeb.Api.VoteController do
  use DertGGWeb, :controller

  alias DertGG.{
    Authentication,
    Entries,
    Votes,
    Votes.Vote
  }

  alias Phoenix.PubSub

  def create(conn, params) do
    with account <- Authentication.get_current_account(conn) do
      entry_params = prepare_params_for_entry(params)
      entry_id = Map.get(entry_params, :entry_id)

      case Votes.get_vote(account.id, entry_id) do
        %Vote{} = vote ->
          Votes.delete_vote(vote)

        nil ->
          {:ok, _vote} = Votes.create_vote(%{account: account, entry_params: entry_params})
      end

      vote_count = Votes.get_count(entry_id)

      PubSub.broadcast(DertGGWeb.PubSub, "vote-updates", %{
        entries: Entries.get_daily_top_entries()
      })

      json(conn, %{"vote-count": vote_count})
    end
  end

  defp prepare_params_for_entry(params) do
    Map.new(params, fn {key, value} ->
      key =
        key
        |> String.replace("-", "_")
        |> String.to_atom()

      {key, value}
    end)
  end
end
