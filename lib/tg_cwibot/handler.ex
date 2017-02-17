defmodule TgCwibot.Handler do

  use Plug.Router

  require Logger

  @commands [
    %{
      default: false,
      id: "1",
      strings: ["attack", "атака"],
      title: "⚔ Атака",
      command: "⚔ Атака"
    },
    %{
      default: false,
      id: "2",
      strings: ["defend", "защита"],
      title: "🛡 Защита",
      command: "🛡 Защита"
    },
    %{
      default: true,
      id: "3",
      strings: ["white", "белый"],
      title: "🇨🇾 Белый замок",
      command: "🇨🇾"
    },
    %{
      default: true,
      id: "4",
      strings: ["замок", "red", "красный"],
      title: "🇮🇲 Красный замок",
      command: "🇮🇲"
    },
    %{
      default: true,
      id: "5",
      strings: ["замок", "blue", "голубой", "синий"],
      title: "🇪🇺 Синий замок",
      command: "🇪🇺"
    },
    %{
      default: true,
      id: "6",
      strings: ["замок", "black", "чёрный", "черный"],
      title: "🇬🇵 Чёрный замок",
      command: "🇬🇵"
    },
    %{
      default: true,
      id: "7",
      strings: ["замок", "yellow", "жёлтый", "желтый"],
      title: "🇻🇦 Жёлтый замок",
      command: "🇻🇦"
    },
    %{
      default: true,
      id: "8",
      strings: ["форт", "forest fort", "лесной форт"],
      title: "🌲Лесной форт",
      command: "🌲Лесной форт"
    },
    %{
      default: true,
      id: "9",
      strings: ["форт", "mountain fort", "горный форт"],
      title: "⛰Горный форт",
      command: "⛰Горный форт"
    },
    %{
      default: false,
      id: "10",
      strings: ["квест", "лес"],
      title: "🌲Лес",
      command: "🌲Лес"
    },
    %{
      default: false,
      id: "11",
      strings: ["квест", "караван"],
      title: "🐫ГРАБИТЬ КОРОВАНЫ",
      command: "🐫ГРАБИТЬ КОРОВАНЫ"
    },
    %{
      default: false,
      id: "12",
      strings: ["квест", "пещера"],
      title: "🕸Пещера",
      command: "🕸Пещера"
    },
    %{
      default: false,
      id: "13",
      strings: ["лавка", "снаряжение"],
      title: "Снаряжение",
      command: "Снаряжение"
    },
    %{
      default: false,
      id: "14",
      strings: ["лавка"],
      title: "🏚Лавка",
      command: "🏚Лавка"
    }
  ]

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
    Logger.debug("query: #{query}")
    result = %{"inline_query_id" => id,
               "results" => results(query)}
    answerInlineQuery(result)
    conn
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.send_resp(200, "")
  end

  defp results("") do
    @commands
    |> Stream.filter(fn f -> f.default end)
    |> formatResults
  end

  defp results(".") do
    @commands
    |> formatResults
  end

  defp results(query) do
    lquery = String.downcase(query)

    @commands
    |> Stream.filter(fn f ->
      f.strings
      |> Enum.any?(&String.starts_with?(&1, lquery))
    end)
    |> formatResults
  end

  defp formatResults(results) do
    results
    |> Enum.map(fn f ->
      %{"type" => "article",
        "id" => f.id,
        "title" => f.title,
        "input_message_content" => %{"message_text" => f.command}}
    end)
  end


  defp answerInlineQuery(result) do
    TgCwibot.Client.answerInlineQuery(result)
  end

end
