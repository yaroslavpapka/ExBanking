defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "Create new user account" do
    user = "Luca Toni"
    assert ExBanking.create_user(user) == :ok
  end

  test "Create new user and check if it's already created" do
    user = "James Rodrigues"
    ExBanking.create_user(user)
    assert ExBanking.create_user(user) == {:error, :user_already_exists}
  end

  test "Deposit test" do
    user = "Roger Federer"
    ExBanking.create_user(user)
    assert ExBanking.deposit(user, 5.25, "USD") == {:ok, 5.25}
  end

  test "Desposit invalid amount" do
    user = "Jose Mourinho"
    ExBanking.create_user(user)
    assert ExBanking.deposit(user, "mvjhvjhv", "Euro") == {:error, :wrong_arguments}
  end

  test "Deposit test for float number with more 3 number after ." do
    user = "Novak Djokovic"
    user1 = "Raphael Nadal"

    ExBanking.create_user(user)
    ExBanking.create_user(user1)

    assert ExBanking.deposit(user, 13.25555, "USD") == {:ok, 13.26}
    assert ExBanking.deposit(user1, 15.544444, "USD") == {:ok, 15.54}
  end

  test "Deposit amount to wrong account" do
    user = "Harry Kane"
    assert ExBanking.deposit(user, 100, "USD") == {:error, :user_does_not_exist}
  end

  test "Deposit multiple amounts" do
    user = "Haller"
    ExBanking.create_user(user)

    assert Enum.all?(1..10, fn x ->
             {:ok, _balance} = ExBanking.deposit(user, x, "USD")
           end)
  end

  test "Withdraw amount by currency from an existing user acccount" do
    user = "Rooney"
    ExBanking.create_user(user)
    ExBanking.deposit(user, 50, "USD")
    assert ExBanking.withdraw(user, 10.00, "USD") == {:ok, 40.0}
  end

  test "Withdraw amount before deposit" do
    user = "Van Persie"
    ExBanking.create_user(user)
    assert ExBanking.withdraw(user, 50.0, "USD") == {:error, :not_enough_money}
  end

  test "Get balance of an existing user acccount" do
    user = "Onana"
    ExBanking.create_user(user)
    ExBanking.deposit(user, 70, "USDT")
    assert ExBanking.get_balance(user, "USDT") == {:ok, 70.00}
  end

  test "Withdraw amount with wrong posision arguments" do
    user = "Kaka"
    ExBanking.create_user(user)
    assert ExBanking.withdraw(user, "USDC", 12.0) == {:error, :wrong_arguments}
  end

  test "Get balance of other currency" do
    user = "Farid"
    ExBanking.create_user(user)
    ExBanking.deposit(user, 50.50, "BTC")
    assert ExBanking.get_balance(user, "ETH") == {:ok, 0.00}
  end

  test "Send amount when sender does not exist" do
    sender = "Gavi"
    receiver = "Xsvi"
    ExBanking.create_user(receiver)
    assert ExBanking.send(sender, receiver, 70.00, "Euro") == {:error, :sender_does_not_exist}
  end

  test "Send amount to an existing user account" do
    sender = "Kane"
    receiver = "Mane"
    ExBanking.create_user(sender)
    ExBanking.create_user(receiver)

    ExBanking.deposit(sender, 200, "UAH")
    ExBanking.deposit(sender, 300, "USD")

    assert ExBanking.send(sender, receiver, 10.00, "UAH") == {:ok, 190.00, 10.0}
    assert ExBanking.send(sender, receiver, 20.00, "USD") == {:ok, 280.00, 20.0}
  end

  test "Send money before deposit" do
    sender = "Martial"
    receiver = "Cantona"
    ExBanking.create_user(sender)
    ExBanking.create_user(receiver)
    assert ExBanking.send(sender, receiver, 10.00, "Euro") == {:error, :not_enough_money}
  end

  test "Send amount when receiver does not exist" do
    sender = "Kagava"
    receiver = "Robben"
    ExBanking.create_user(sender)
    assert ExBanking.send(sender, receiver, 5.00, "TRC") == {:error, :receiver_does_not_exist}
  end

  #test "return error with more than 10 requests" do
  #  user = "Rivaldo"
  #  currency = "USD"
  #  ExBanking.create_user(user)

  #  result =
  #    Enum.reduce(1..100, [], fn x, acc -> [Task.async(fn -> ExBanking.deposit(user, x, currency) end) | acc] end)
  #    |> Enum.map(&Task.await/1)
  #    |> Enum.count(fn {res, _} -> res == :error end)

  #  assert(result == 90)
  #end

end
