defmodule TgCwibot.Handler do

  use Plug.Router

  require Logger

  @commands %{
    attack: "⚔ Атака", defend: "🛡 Защита",
    white: "🇨🇾", red: "🇮🇲", blue: "🇪🇺", black: "🇬🇵",
    yellow: "🇻🇦", forest: "🌲Лесной форт", mountain: "⛰Горный форт"
  }

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def init(options), do: options

  def start_link() do
    {:ok, _} = Plug.Adapters.Cowboy.http(
      __MODULE__,
      nil,
      port: Application.get_env(:tg_cwibot, :port, 8123)
    )
  end

  get "/" do
    Logger.debug("ok")
    conn |> respond
  end


  post _ do
    endpoint = "/" <> Application.get_env(:tg_cwibot, :endpoint)

    Logger.debug("path #{conn.request_path}")

    case conn.request_path do
      ^endpoint ->
        conn
        |> Plug.Conn.fetch_query_params
        |> query
        |> respond

      other ->
        Logger.info "endpoint #{inspect other} is not supported"
        Plug.Conn.send_resp(conn, 404, "oops")
    end
  end

  match _, do: Plug.Conn.send_resp(conn, 404, "oops")

  defp query(
    conn = %{body_params: %{"inline_query" => _}}
  ) do
    inlineQuery(conn)
  end

  defp query(conn) do
    Logger.debug("Ignoring message #{inspect conn.body_params}")
    conn
  end

  defp inlineQuery(conn) do
    %{"inline_query" => %{"id" => id, "query" => query}} =
      conn.body_params
    result = %{"inline_query_id" => id,
               "results" => results(query)}
    answerInlineQuery(result)
    conn
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.send_resp(200, "")
  end

  defp results(_query) do
    Map.values(@commands)
    |> Stream.zip(1 .. 100)
    |> Enum.map(fn {f, idx} ->
      %{"type" => "article",
        "id" => "#{idx}",
        "title" => f,
        "input_message_content" => %{"message_text" => f}}
    end)
  end


  defp answerInlineQuery(result) do
    TgCwibot.Client.answerInlineQuery(result)
  end

end
