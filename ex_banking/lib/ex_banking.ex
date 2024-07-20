defmodule ExBanking do
  @moduledoc """
  "ExBanking" app.
  """
  use GenServer

  @max_requests 10

  @doc """
  Function for create a new user

  ## Examples
  iex> ExBanking.create_user("Varane")
  :ok
  iex> ExBanking.create_user("Varane")
  {:error, :user_already_exists}
  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    GenServer.call(__MODULE__, {:create_user, user})
  end

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  Function for deposit some amount to account

  ## Examples
  iex> ExBanking.create_user("Pogba")
  :ok
  iex> ExBanking.deposit("Pogba", 100, "USDT")
  {:ok, 100.00}
  iex> ExBanking.deposit("Raphael", 100, "USDT")
  {:error, :user_does_not_exist}
  """
  @spec deposit(user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, new_balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) when is_binary(user) and is_number(amount) and is_binary(currency) do
    GenServer.call(__MODULE__, {:deposit, user, amount, currency})
  end

  @spec deposit(user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, new_balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Function for withdraw some amount to account

  ## Examples
  iex> ExBanking.create_user("Nani")
  :ok
  iex> ExBanking.deposit("Nani", 20.246, "USDT")
  {:ok, 20.25}
  iex> ExBanking.withdraw("Nani", 50, "USDT")
  {:error, :not_enough_money}
  iex> ExBanking.withdraw("Nani", 10, "USDT")
  {:ok, 10.25}
  """
  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, new_balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) when is_binary(user) and is_number(amount) and is_binary(currency) do
    GenServer.call(__MODULE__, {:withdraw, user, amount, currency})
  end

  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, new_balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Function for show amount of money on account

  ## Examples
  iex> ExBanking.create_user("Evra")
  :ok
  iex> ExBanking.get_balance("Evra", "USDT")
  {:ok, 0.0}
  iex> ExBanking.deposit("Evra", 50, "USDT")
  {:ok, 50.0}
  iex> ExBanking.get_balance("Evra", "USDT")
  {:ok, 50.0}
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) :: {:ok, balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    GenServer.call(__MODULE__, {:get_balance, user, currency})
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) :: {:ok, balance :: number()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(_, _), do: {:error, :wrong_arguments}

  @doc """
  Function for send money to another user

  ## Examples
  iex> ExBanking.create_user("Lukaku")
  :ok
  iex> ExBanking.create_user("Di Maria")
  :ok
  iex> ExBanking.deposit("Lukaku", 100, "USDT")
  {:ok, 100.0}
  iex> ExBanking.send("Lukaku", "Di Maria", 10, "USDT")
  {:ok, 90.00, 10.0}
  iex> ExBanking.send("Lukaku", "Di Maria", 2500, "USD")
  {:error, :not_enough_money}
  """
  @spec send(from_user :: String.t(), to_user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, from_user_balance :: number(), to_user_balance :: number()} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) when is_binary(from_user) and is_binary(to_user) and is_number(amount) and is_binary(currency) do
    GenServer.call(__MODULE__, {:send, from_user, to_user, amount, currency})
  end

  @spec send(from_user :: String.t(), to_user :: String.t(), amount :: number(), currency :: String.t()) :: {:ok, from_user_balance :: number(), to_user_balance :: number()} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(_, _, _, _), do: {:error, :wrong_arguments}

  @doc """
  Starts a new instance of the `GenServer` with the given initial state.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Initializes the `GenServer` with the given state.

  The `init/1` function is called when the `GenServer` is started. It sets the initial state of the `GenServer` to the value provided as an argument.
  This function is required to return `{:ok, state}` where `state` is the initial state of the server.
  """
  def init(state) do
    {:ok, state}
  end

  @doc """
  Handles a synchronous call to create a new user.

  The `handle_call/3` function processes requests to create a new user in the `GenServer` state.
  It checks if the user already exists in the state. If the user exists, it responds with an error.
  If the user does not exist, it adds the user to the state and responds with a success message.
  """
  @spec handle_call({:create_user, any()}, any(), map()) :: {:reply, :ok | {:error, :user_already_exists}, map()}
  def handle_call({:create_user, user}, _from, state) do
    case Map.has_key?(state, user) do
      true -> {:reply, {:error, :user_already_exists}, state}
      false -> {:reply, :ok, Map.put(state, user, %{"requests" => 0})}
    end
  end

  @spec handle_call({:deposit, any(), number(), String.t()}, pid(), map()) :: {:reply, {:ok, number()} | {:error, term()}, map()}
  def handle_call({:deposit, user, amount, currency}, _from, state) do
    with {:ok, user_data} <- get_user_data(state, user),
         :ok <- check_requests(user_data) do
      updated_user_data =
        update_balance(user_data, amount, currency)
        |> increment_requests()

      updated_state = Map.put(state, user, updated_user_data)

      {:reply, {:ok, updated_user_data[currency]}, updated_state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @spec handle_call({:withdraw, any(), number(), String.t()}, pid(), map()) :: {:reply, {:ok, number()} | {:error, term()}, map()}
  def handle_call({:withdraw, user, amount, currency}, _from, state) do
    with {:ok, user_data} <- get_user_data(state, user),
         :ok <- check_requests(user_data),
         :ok <- check_balance(user_data, amount, currency) do
      updated_user_data =
        user_data
        |> update_balance(-amount, currency)
        |> increment_requests()

      updated_state = Map.put(state, user, updated_user_data)

      {:reply, {:ok, updated_user_data[currency]}, updated_state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @spec handle_call({:get_balance, any(), String.t()}, pid(), map()) :: {:reply, {:ok, number()} | {:error, term()}, map()}
  def handle_call({:get_balance, user, currency}, _from, state) do
    with {:ok, user_data} <- get_user_data(state, user),
         :ok <- check_requests(user_data) do
      updated_user_data = increment_requests(user_data)
      updated_state = Map.put(state, user, updated_user_data)

      {:reply, {:ok, Map.get(user_data, currency, 0.0)}, updated_state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @spec handle_call({:send, any(), any(), number(), String.t()}, pid(), map()) :: {:reply, {:ok, number(), number()} | {:error, term()}, map()}
  def handle_call({:send, from_user, to_user, amount, currency}, _from, state) do
    case {Map.get(state, from_user), Map.get(state, to_user)} do
      {nil, _} ->
        {:reply, {:error, :sender_does_not_exist}, state}

      {_, nil} ->
        {:reply, {:error, :receiver_does_not_exist}, state}

      {from_user_data, to_user_data} ->
        with :ok <- check_requests(from_user_data),
             :ok <- check_requests(to_user_data),
             :ok <- check_balance(from_user_data, amount, currency) do
          updated_from_user_data =
            from_user_data
            |> update_balance(-amount, currency)
            |> increment_requests()

          updated_to_user_data =
            to_user_data
            |> update_balance(amount, currency)
            |> increment_requests()

          updated_state = state
            |> Map.put(from_user, updated_from_user_data)
            |> Map.put(to_user, updated_to_user_data)

          {:reply, {:ok, updated_from_user_data[currency], updated_to_user_data[currency]}, updated_state}
        else
          {:error, reason} -> {:reply, {:error, reason}, state}
        end
    end
  end

  @spec handle_info({:decrement_requests, any()}, map()) :: {:noreply, map()}
  def handle_info({:decrement_requests, user}, state) do
    case Map.fetch(state, user) do
      {:ok, user_data} ->
        updated_user_data = decrement_requests(user_data)
        updated_state = Map.put(state, user, updated_user_data)
        {:noreply, updated_state}

      :error ->
        {:noreply, state}
    end
  end

  @spec decrement_requests(map()) :: map()
  defp decrement_requests(user_data) do
    Map.update!(user_data, "requests", &(&1 - 1))
  end

  defp update_balance(user_data, amount, currency) do
    current_balance = Map.get(user_data, currency, 0.0)
    Map.put(user_data, currency, current_balance + rond(amount))
  end

  defp check_balance(user_data, amount, currency) do
    if Map.get(user_data, currency, 0.0) >= amount do
      :ok
    else
      {:error, :not_enough_money}
    end
  end

  defp get_user_data(state, user) do
    case Map.get(state, user) do
      nil -> {:error, :user_does_not_exist}
      user_data -> {:ok, user_data}
    end
  end

  defp check_requests(%{"requests" => requests}) when requests >= @max_requests do
    {:error, :too_many_requests_to_user}
  end

  defp check_requests(_) do
    :ok
  end

  defp increment_requests(user_data) do
    Map.update!(user_data, "requests", &(&1 + 1))
  end

  defp rond(amount) do
    Float.round(amount * 1.0, 2)
  end
end
