############### from here ####################

use Mix.Config

config :tg_cwibot,
  token: "bot token",
  host: "https://my-host.tld",
  endpoint: "telegram bot endpoint"

################# to here ####################
#  Create file "prod.exs" in this directory
# with content just like in this file
# (lines 3-8 only) and set configuration
# stuff according to your bot configuration

try do
  import_config "secret.exs"
catch
  _, _ -> :missing
end
