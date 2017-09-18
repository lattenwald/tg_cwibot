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
      strings: ["castle", "замок", "white", "белый"],
      title: "🇨🇾 Белый замок",
      command: "🇨🇾"
    },
    %{
      default: true,
      id: "4",
      strings: ["castle", "замок", "red", "красный"],
      title: "🇮🇲 Красный замок",
      command: "🇮🇲"
    },
    %{
      default: true,
      id: "5",
      strings: ["castle", "замок", "blue", "голубой", "синий"],
      title: "🇪🇺 Синий замок",
      command: "🇪🇺"
    },
    %{
      default: true,
      id: "6",
      strings: ["castle", "замок", "black", "чёрный", "черный"],
      title: "🇬🇵 Чёрный замок",
      command: "🇬🇵"
    },
    %{
      default: true,
      id: "7",
      strings: ["castle", "замок", "yellow", "жёлтый", "желтый"],
      title: "🇻🇦 Жёлтый замок",
      command: "🇻🇦"
    },
    %{
      default: true,
      id: "18",
      strings: ["castle", "замок", "green", "mint", "зелёный", "зеленый", "мятный"],
      title: "🇲🇴 Мятный замок",
      command: "🇲🇴"
    },
    %{
      default: true,
      id: "19",
      strings: ["castle", "замок", "orange", "twilight", "сумрачный", "сумеречный", "оранжевый"],
      title: "🇰🇮 Сумрачный замок",
      command: "🇰🇮"
    },
    %{
      default: true,
      id: "8",
      strings: ["fort", "форт", "forest fort", "лесной форт"],
      title: "🌲Лесной форт",
      command: "🌲Лесной форт"
    },
    %{
      default: true,
      id: "9",
      strings: ["fort", "форт", "mountain fort", "горный форт"],
      title: "⛰Горный форт",
      command: "⛰Горный форт"
    },
    %{
      default: false,
      id: "10",
      strings: ["quest", "квест", "лес", "forest"],
      title: "🌲Лес",
      command: "🌲Лес"
    },
    %{
      default: false,
      id: "11",
      strings: ["quest", "квест", "caravan", "караван"],
      title: "🐫ГРАБИТЬ КОРОВАНЫ",
      command: "🐫ГРАБИТЬ КОРОВАНЫ"
    },
    %{
      default: false,
      id: "12",
      strings: ["quest", "квест", "cave", "пещера"],
      title: "🕸Пещера",
      command: "🕸Пещера"
    },
    %{
      default: false,
      id: "13",
      strings: ["shop", "лавка", "equipment", "снаряжение"],
      title: "Снаряжение",
      command: "Снаряжение"
    },
    %{
      default: false,
      id: "14",
      strings: ["shop", "лавка"],
      title: "🏚Лавка",
      command: "🏚Лавка"
    },
    %{
      default: false,
      id: "15",
      strings: ["arena", "арена"],
      title: "📯Арена",
      command: "📯Арена"
    },
    %{
      default: true,
      id: "16",
      strings: ["щит", "shield"],
      title: "Мифриловый щит",
      command: "/on_216"
    },
    %{
      default: true,
      id: "17",
      strings: ["knife", "кинжал"],
      title: "Кинжал",
      command: "/on_114"
    },
    %{
      default: false,
      id: "20",
      strings: ["биржа", "market"],
      title: "📊Биржа",
      command: "📊Биржа"
    },
    %{
      default: false,
      id: "21",
      strings: ["+", "plus", "test"],
      title: "➕ testing",
      command: "➕ testing",
      buttons: ["➕"]
    },
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

  defp query(conn = %{body_params: %{"inline_query" => _}}) do
    inlineQuery(conn)
  end

  defp query(conn = %{body_params: %{"callback_query" => _}}) do
    callbackQuery(conn)
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
    TgCwibot.Client.answerInlineQuery(result)
    conn
  end

  defp callbackQuery(conn) do
    %{"callback_query" => %{"data" => data, "id" => id}} =
      conn.body_params
    Logger.debug("callback query: #{data}")
    result = %{callback_query_id: id, text: "clicked: #{data}"}
    TgCwibot.Client.answerCallbackQuery(result)
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

  defp set_buttons(map, nil), do: map
  defp set_buttons(map, buttons) do
    Map.put(map, "reply_markup", %{"inline_keyboard" => [
                                    Enum.map(buttons, & %{"text" => &1, "callback_data" => &1})
                                  ]})
  end


  defp formatResults(results) do
    results
    |> Enum.map(fn f ->
      %{"type" => "article",
        "id" => f.id,
        "title" => " " <> f.title,
        "hide_url" => true,
        "thumb_width" => 0,
        "thumb_height" => 0,
        "input_message_content" => %{"message_text" => f.command}}
      |> set_buttons(f[:buttons])
    end)
  end

end
