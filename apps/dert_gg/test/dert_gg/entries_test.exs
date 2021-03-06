defmodule DertGG.EntriesTest do
  use DertGG.DataCase, async: true

  alias DertGG.Entries
  alias DertGG.Entries.Entry
  alias DertGG.Factory

  @possible_entry_timestamps %{
    "15.02.1999" => [entry_created_at: ~U[1999-02-15 00:00:00Z], entry_updated_at: nil],
    "17.12.1999 12:35" => [entry_created_at: ~U[1999-12-17 09:35:00Z], entry_updated_at: nil],
    "13.06.2001 21:35 ~ 14.09.2009 22:29" => [
      entry_created_at: ~U[2001-06-13 18:35:00Z],
      entry_updated_at: ~U[2009-09-14 19:29:00Z]
    ],
    "30.07.2002 09:47 ~ 09:50" => [
      entry_created_at: ~U[2002-07-30 06:47:00Z],
      entry_updated_at: ~U[2002-07-30 06:50:00Z]
    ]
  }

  describe "create_entry/1" do
    for {
          entry_timestamp,
          [entry_created_at: entry_created_at, entry_updated_at: entry_updated_at]
        } <- @possible_entry_timestamps do
      test "creates entry with entry timestamp #{entry_timestamp}" do
        entry_params =
          :entry_params
          |> Factory.build()
          |> Map.merge(%{entry_timestamp: unquote(entry_timestamp)})

        assert {:ok, %Entry{} = entry} = Entries.create_entry(entry_params)

        assert entry.entry_created_at == unquote(Macro.escape(entry_created_at)),
               "With given entry_timestamp #{entry_params.entry_timestamp} got entry_created_at as #{entry.entry_created_at}"

        assert entry.entry_updated_at == unquote(Macro.escape(entry_updated_at)),
               "With given entry_timestamp #{entry_params.entry_timestamp} got entry_updated_at as #{entry.entry_updated_at}"
      end
    end

    test "with invalid data, returns an error atom with Ecto.Changeset" do
      invalid_entry_params = Factory.params_for(:entry, author: nil)

      assert {:error, %Ecto.Changeset{}} = Entries.create_entry(invalid_entry_params)
    end
  end

  test "change_entry/1 returns an entry changeset" do
    entry = Factory.build(:entry)

    assert %Ecto.Changeset{} = Entries.change_entry(entry)
  end

  describe "upsert_entry/1" do
    test "inserts an entry and updates it with different timestamps properly" do
      for {
            entry_timestamp,
            [entry_created_at: entry_created_at, entry_updated_at: entry_updated_at]
          } <- @possible_entry_timestamps do
        entry_params =
          :entry_params
          |> Factory.build()
          |> Map.merge(%{entry_timestamp: entry_timestamp})

        assert {:ok, %Entry{} = entry} = Entries.upsert_entry(entry_params)

        assert entry.entry_created_at == entry_created_at,
               "With given entry_timestamp #{entry_params.entry_timestamp} got entry_created_at as #{entry.entry_created_at}"

        assert entry.entry_updated_at == entry_updated_at,
               "With given entry_timestamp #{entry_params.entry_timestamp} got entry_updated_at as #{entry.entry_updated_at}"
      end
    end
  end

  describe "get_daily_top_entries/0-1" do
    test "returns top 10 entries by vote count by default" do
      entry1 = Factory.insert(:entry)
      Factory.insert_list(3, :vote, entry: entry1)

      entry2 = Factory.insert(:entry)
      Factory.insert_list(2, :vote, entry: entry2)

      Factory.insert_list(9, :vote)

      entries = Entries.get_daily_top_entries()

      assert length(entries) == 10

      # First entry is the one with the highest vote count
      assert [%{entry: ^entry1, vote_count: 3} | _] = entries
    end

    test "returns the given number of entries by vote count" do
      entry1 = Factory.insert(:entry)
      Factory.insert_list(2, :vote, entry: entry1)

      entry2 = Factory.insert(:entry)
      Factory.insert_list(1, :vote, entry: entry2)

      entries = Entries.get_daily_top_entries(top: 1)

      assert %{entry: entry1, vote_count: 2} in entries
      refute %{entry: entry2, vote_count: 1} in entries
    end

    test "returns only current day's votes" do
      datetime_yesterday = DateTime.utc_now() |> DateTime.add(-24 * 60 * 60, :second)

      entry1 = Factory.insert(:entry)
      Factory.insert_list(2, :vote, entry: entry1, inserted_at: datetime_yesterday)
      Factory.insert(:vote, entry: entry1)

      entry2 = Factory.insert(:entry)
      Factory.insert_list(1, :vote, entry: entry2)

      entries = Entries.get_daily_top_entries(top: 10)

      assert %{entry: entry1, vote_count: 1} in entries
      assert %{entry: entry2, vote_count: 1} in entries
    end
  end
end
