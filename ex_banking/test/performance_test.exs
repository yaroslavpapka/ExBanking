defmodule ExBankingPerformanceTest do
  use ExUnit.Case

  @tag :performance
  test "performance test for deposit operation" do
    user = "Pepe"
    amount = 100.0
    currency = "USD"

    Benchee.run(
      %{
        "Deposit Operation" => fn ->
          ExBanking.create_user(user)
          ExBanking.deposit(user, amount, currency)
        end
      },
      time: 10,
      memory_time: 2
    )
  end

  @tag :performance
  test "performance test for withdraw operation" do
    user = "Van Nistelroy"
    amount = 100.0
    currency = "USD"

    ExBanking.create_user(user)
    ExBanking.deposit(user, amount, currency)

    Benchee.run(
      %{
        "Withdraw Operation" => fn ->
          ExBanking.withdraw(user, 50.0, currency)
        end
      },
      time: 10,
      memory_time: 2
    )
  end

  @tag :performance
  test "performance test for balance check" do
    user = "Van Persie"
    amount = 100.0
    currency = "USD"

    ExBanking.create_user(user)
    ExBanking.deposit(user, amount, currency)

    Benchee.run(
      %{
        "Balance Check Operation" => fn ->
          ExBanking.get_balance(user, currency)
        end
      },
      time: 10,
      memory_time: 2
    )
  end

  @tag :performance
  test "performance test for send operation" do
    sender = "Sneyder"
    receiver = "Van der Sarr"
    amount = 100.0
    currency = "USD"

    ExBanking.create_user(sender)
    ExBanking.create_user(receiver)
    ExBanking.deposit(sender, amount, currency)

    Benchee.run(
      %{
        "Send Operation" => fn ->
          ExBanking.send(sender, receiver, 50.0, currency)
        end
      },
      time: 10,
      memory_time: 2
    )
  end
end
