defmodule Bookstore.DB do
  def setup do
    run_query(:setup_table_books, [])
  end

  def teardown() do
    run_query(:teardown_table_books, [])
  end

  def add_book(isbn, title, author) do
    add_book(isbn, title, author, 0, 0)
  end

  def add_book(isbn, title, author, owned, avail) do
    bin_title = IO.chardata_to_string(title)
    bin_author = IO.chardata_to_string(author)

    case run_query(:add_book, [isbn, bin_title, bin_author, owned, avail]) do
      {{:insert, 0, 1}, []} -> :ok
      {:error, reason} -> {:error, reason}
      other -> {:error, other}
    end
  end

  def add_copy(isbn) do
    handle_single_update(run_query(:add_copy, [isbn]))
  end

  def borrow_copy(isbn) do
    case find_book_by_isbn(isbn) do
      {:error, reason} ->
        {:error, reason}
      {:ok, []} ->
        {:error, :not_found}
      {:ok, _} ->
        case handle_single_update(run_query(:borrow_copy, [isbn])) do
          {:error, :not_found} ->
            {:error, :unavailable}
          other ->
            other
        end
    end
  end

  def return_copy(isbn) do
    handle_single_update(run_query(:return_copy, [isbn]))
  end

  def find_book_by_author(author) do
    handle_select(
      run_query(
        :find_by_author,
        [IO.chardata_to_string(['%', author, '%'])]
      )
    )
  end

  def find_book_by_isbn(isbn) do
    handle_select(run_query(:find_by_isbn, [isbn]))
  end

  def find_book_by_title(title) do
    handle_select(
      run_query(
        :find_by_title,
        [IO.chardata_to_string(['%', title, '%'])]
      )
    )
  end

  def load_queries() do
    :ets.new(
      :bookstore_sql,
      [:named_table, :public, {:read_concurrency, true}]
    )

    sql_file = Path.join(:code.priv_dir(:bookstore), "queries.sql")
    {:ok, queries} = :eql.compile(sql_file)
    :ets.insert(:bookstore_sql, queries)
  end

  defp query(name) do
    case :ets.lookup(:bookstore_sql, name) do
      [] -> {:query_not_found, name}
      [{_, query}] -> query
    end
  end

  defp run_query(name, args) do
    with_connection(fn conn -> run_query(conn, name, args) end)
  end

  defp run_query(conn, name, args) do
    :pgsql_connection.extended_query(query(name), args, conn)
  end

  defp with_connection(f) do
    {:ok, conn} = connect()
    res = f.(conn)
    close(conn)
    res
  end

  defp connect() do
    connect(Application.get_env(:bookstore, :pg, []))
  end

  defp connect(args) do
    try do
      conn = {:pgsql_connection, _} = :pgsql_connection.open(args)
      {:ok, conn}
    catch
      :throw, err -> {:error, err}
    end
  end

  defp close(conn) do
    :pgsql_connection.close(conn)
  end

  defp handle_select({{:select, _}, list}), do: {:ok, list}
  defp handle_select(error), do: error

  defp handle_single_update({{:update, 1}, _}), do: :ok
  defp handle_single_update({{:update, 0}, _}), do: {:error, :not_found}
  defp handle_single_update({:error, reason}), do: {:error, reason}
  defp handle_single_update(other), do: {:error, other}
end
