# TgCwibot

**TODO: Add description**

## Configuration

There is none, you'll have to edit source code for now.

## Deployment

Currently requires ERTS, doesn't include one (because I develop and run it on different platforms, so cba).

```sh
$ mix deps.get
$ MIX_ENV=prod mix compile
$ MIX_ENV=prod mix release
# now your release is at _build/prod/rel/tg_cwibot/releases/<version>/tg_cwibot.tar.gz
```

Unpack it somewhere and run

```sh
$ bin/tg_cwibot console       # run with elixir console
$ bin/tg_cwibot foreground    # run in foreground
$ bin/tg_cwibot daemon        # run in background

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tg_cwibot](https://hexdocs.pm/tg_cwibot).
