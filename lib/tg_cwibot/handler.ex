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
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 8123)
  end

  get "/" do
    Logger.debug("ok")
    conn |> respond
  end


  post "/303531014" do
    Logger.debug("well")
    conn
    |> Plug.Conn.fetch_query_params
    |> inlineQuery
    |> respond
  end

  # post _ do
  #   Logger.debug("match-all post")
  #   IO.inspect conn
  #   conn
  #   |> Plug.Conn.fetch_query_params
  #   |> inspect_params
  #   |> respond
  # end

  match _, do: Plug.Conn.send_resp(conn, 404, "oops")

  defp inlineQuery(conn) do
    %{"inline_query" => %{"id" => id, "from" => from, "query" => query}} =
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

  defp inspect_params(conn) do
    IO.inspect conn.body_params
    conn
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
