defmodule DertGG.AccountsTest do
  use DertGG.DataCase, async: true

  alias DertGG.Accounts
  alias DertGG.Accounts.Account

  test "register for an account with valid information" do
    pre_count = count_of(Account)
    params = valid_account_params()

    result = Accounts.register(params)

    assert {:ok, %Account{}} = result
    assert pre_count + 1 == count_of(Account)
  end

  test "register for an account with an existing email address" do
    params = valid_account_params()
    Repo.insert!(%Account{email: params.email})

    pre_count = count_of(Account)

    result = Accounts.register(params)

    assert {:error, %Ecto.Changeset{}} = result
    assert pre_count == count_of(Account)
  end

  test "register for an account without matching password and confirmation" do
    pre_count = count_of(Account)
    params = valid_account_params()

    params = %{
      params
      | password_confirmation: "non-matching-password"
    }

    result = Accounts.register(params)

    assert {:error, %Ecto.Changeset{}} = result
    assert pre_count == count_of(Account)
  end

  defp count_of(queryable) do
    Repo.aggregate(queryable, :count, :id)
  end

  defp valid_account_params do
    %{
      email: "john@doe.com",
      password: "superdupersecret",
      password_confirmation: "superdupersecret"
    }
  end
end
